import 'package:drift/drift.dart';

import '../data/body_store.dart';
import '../data/database.dart';
import '../data/medication_store.dart';
import '../dose/dose_math.dart';
import '../util/format.dart';

/// One logged dose, in the words the report prints.
class ReportDose {
  const ReportDose({
    required this.at,
    required this.medication,
    required this.dose,
    required this.mg,
    required this.site,
    required this.note,
    required this.skipped,
  });
  final DateTime at;
  final String medication;

  /// As it was entered, with what it converts to: "25 units = 2.5 mg", "5 mg", "1 tablet".
  final String dose;
  final double? mg;
  final String? site;
  final String? note;
  final bool skipped;
}

/// A run of doses of one medication at one amount, so stepping up or down is easy to see.
class DoseStep {
  DoseStep({required this.medication, required this.dose, required this.doses});
  final String medication;
  final String dose;
  final List<ReportDose> doses;
}

/// How often a side effect was logged and how strong, for one medication.
class EffectSummary {
  const EffectSummary({
    required this.medication,
    required this.name,
    required this.count,
    required this.average,
    required this.strongest,
  });

  /// The medication it was logged as likely from; "Not linked to a medication" otherwise.
  final String medication;
  final String name;
  final int count;
  final double average;
  final int strongest;
}

/// Everything the provider report prints, already worked out. Building it reads the database;
/// drawing it (report_pdf.dart) does no arithmetic of its own.
class ReportData {
  const ReportData({
    required this.from,
    required this.to,
    required this.createdAt,
    required this.weightUnit,
    required this.medications,
    required this.steps,
    required this.dosesTaken,
    required this.dosesSkipped,
    required this.firstDose,
    required this.weights,
    required this.bmi,
    required this.effects,
    required this.notes,
  });

  /// The days covered, both included. [from] is null for "everything".
  final DateTime? from;
  final DateTime to;
  final DateTime createdAt;
  final WeightUnit weightUnit;

  /// Current medications: name, then what it is and the usual dose.
  final List<({String name, String detail})> medications;
  final List<DoseStep> steps;
  final int dosesTaken;
  final int dosesSkipped;

  /// The first dose in the period, for "length of treatment".
  final DateTime? firstDose;

  /// Oldest first, in [weightUnit].
  final List<({DateTime at, double value})> weights;

  /// From the latest weight in the period, when a height is set.
  final String? bmi;
  final List<EffectSummary> effects;
  final List<({DateTime day, String body})> notes;

  bool get isEmpty => steps.isEmpty && weights.isEmpty && effects.isEmpty && notes.isEmpty;

  /// Whole days from the first dose in the period to its end.
  int? get treatmentDays => firstDose == null
      ? null
      : DateTime(
              to.year,
              to.month,
              to.day,
            ).difference(DateTime(firstDose!.year, firstDose!.month, firstDose!.day)).inDays +
            1;

  /// "−12.4 lb (−6.2%)", first weight to last in the period. Null with fewer than two weights.
  String? get weightChange {
    if (weights.length < 2) return null;
    final first = weights.first.value, last = weights.last.value;
    final change = last - first;
    if (change.abs() < 0.05) return 'no change';
    final sign = change < 0 ? '−' : '+';
    return '$sign${change.abs().toStringAsFixed(1)} ${weightUnit.name} '
        '($sign${(change.abs() / first * 100).toStringAsFixed(1)}%)';
  }

  /// "−1.1 lb per week" on average. Null when the weights span less than two weeks.
  String? get weightPerWeek {
    if (weights.length < 2) return null;
    final days = weights.last.at.difference(weights.first.at).inHours / 24;
    if (days < 14) return null;
    final perWeek = (weights.last.value - weights.first.value) / (days / 7);
    if (perWeek.abs() < 0.05) return null;
    return '${perWeek < 0 ? '−' : '+'}${perWeek.abs().toStringAsFixed(1)} ${weightUnit.name} per week';
  }
}

/// "25 units = 2.5 mg" from what was typed and what it converted to at the time.
String reportDoseText(Dose d) {
  final typed = describeAmount(d.amountEntered, d.unitEntered);
  final mg = d.drugMg;
  if (mg == null || d.unitEntered == DoseUnit.mg) {
    final ml = d.volumeMl;
    return ml == null || d.unitEntered == DoseUnit.ml ? typed : '$typed = ${describeAmount(ml, DoseUnit.ml)}';
  }
  return '$typed = ${describeAmount(mg, DoseUnit.mg)}';
}

extension ReportQueries on AloftDatabase {
  /// Gathers the report for [from] to [to] (whole days, both included; [from] null means from
  /// the beginning). [medicationIds] limits doses and side effects to those medications.
  Future<ReportData> reportData({
    DateTime? from,
    required DateTime to,
    required AppSettings settings,
    Set<String>? medicationIds,
    DateTime? now,
  }) async {
    final start = from == null ? null : DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);
    bool inRange(DateTime t) => (start == null || !t.isBefore(start)) && t.isBefore(end);
    bool wanted(String? id) => medicationIds == null || (id != null && medicationIds.contains(id));

    final details = [
      for (final d in await watchMedications().first)
        if (wanted(d.medication.id)) d,
    ];
    final names = {for (final m in await select(medications).get()) m.id: m.name};

    final doseRows = [
      for (final d in await (select(doses)..orderBy([(d) => OrderingTerm.asc(d.takenAt)])).get())
        if (inRange(d.takenAt) && wanted(d.medicationId)) d,
    ];
    final reportDoses = [
      for (final d in doseRows)
        ReportDose(
          at: d.takenAt,
          medication: names[d.medicationId] ?? 'Medication',
          dose: d.skipped ? 'Skipped' : reportDoseText(d),
          mg: d.skipped ? null : d.drugMg,
          site: d.injectionSite?.label,
          note: d.notes,
          skipped: d.skipped,
        ),
    ];
    // A step is a run of taken doses of one medication at one amount. A skipped dose stays
    // in the step it falls in, so it doesn't split the run.
    final steps = <DoseStep>[];
    final open = <String, DoseStep>{};
    for (final dose in reportDoses) {
      final current = open[dose.medication];
      if (current != null && (dose.skipped || current.dose == dose.dose)) {
        current.doses.add(dose);
      } else if (dose.skipped && current == null) {
        final step = DoseStep(medication: dose.medication, dose: 'Skipped', doses: [dose]);
        steps.add(step);
      } else {
        final step = DoseStep(medication: dose.medication, dose: dose.dose, doses: [dose]);
        steps.add(step);
        open[dose.medication] = step;
      }
    }

    final weightRows = [
      for (final w in await (select(weights)..orderBy([(w) => OrderingTerm.asc(w.measuredAt)])).get())
        if (inRange(w.measuredAt)) w,
    ];

    final effectRows = [
      for (final e in await select(sideEffects).get())
        if (inRange(e.occurredAt) && (medicationIds == null || wanted(e.medicationId))) e,
    ];
    final grouped = <(String, String), List<int>>{};
    for (final e in effectRows) {
      final medication = names[e.medicationId] ?? 'Not linked to a medication';
      grouped.putIfAbsent((medication, sideEffectName(e)), () => []).add(e.severity);
    }
    final effects = [
      for (final MapEntry(key: (medication, name), value: severities) in grouped.entries)
        EffectSummary(
          medication: medication,
          name: name,
          count: severities.length,
          average: severities.reduce((a, b) => a + b) / severities.length,
          strongest: severities.reduce((a, b) => a > b ? a : b),
        ),
    ]..sort((a, b) => a.medication != b.medication ? a.medication.compareTo(b.medication) : b.count.compareTo(a.count));

    final noteRows = [
      for (final n in await (select(dayNotes)..orderBy([(n) => OrderingTerm.asc(n.noteDate)])).get())
        if (inRange(n.noteDate)) n,
    ];

    final taken = reportDoses.where((d) => !d.skipped);
    return ReportData(
      from: start,
      to: DateTime(to.year, to.month, to.day),
      createdAt: now ?? DateTime.now(),
      weightUnit: settings.weightUnit,
      medications: [
        for (final d in details)
          (name: d.medication.name, detail: [describeSupply(d), ?describeUsualDose(d)].join(' · ')),
      ],
      steps: steps,
      dosesTaken: taken.length,
      dosesSkipped: reportDoses.length - taken.length,
      firstDose: taken.isEmpty ? null : taken.first.at,
      weights: [for (final w in weightRows) (at: w.measuredAt, value: fromKg(w.kg, settings.weightUnit))],
      bmi: weightRows.isEmpty || settings.heightCm == null ? null : formatBmi(weightRows.last.kg, settings.heightCm!),
      effects: effects,
      notes: [for (final n in noteRows) (day: n.noteDate, body: n.body)],
    );
  }
}
