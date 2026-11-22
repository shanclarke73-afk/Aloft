import 'package:drift/drift.dart';

import '../data/body_store.dart';
import '../data/database.dart';
import '../dose/dose_math.dart';
import '../features/medications/catalog.dart';
import 'shotsy_file.dart';

/// The answer to "brand pen or compounded vial?" for one medication name in the file.
class ShotsyMedicationChoice {
  const ShotsyMedicationChoice({required this.form, this.concentrationMgPerMl, this.addToMedicationId});
  final MedicationForm form;

  /// A medication already in Aloft, under another name, that these shots belong to. When set,
  /// no new medication is made and the other answers aren't used.
  final String? addToMedicationId;

  /// Optional, for a compounded vial, so units and mL can be shown for its shots.
  final double? concentrationMgPerMl;
}

class ShotsyImportResult {
  int shots = 0, weights = 0, notes = 0, effects = 0, duplicates = 0, medicationsAdded = 0;
}

/// The ingredient a medication name refers to, from the built-in names. "other" when unknown.
({String ingredient, bool isGlp1}) ingredientFor(String name) {
  final lower = name.toLowerCase();
  for (final drug in [...compoundedDrugs, ...brandPens]) {
    final label = drug.label.replaceAll('®', '').toLowerCase();
    if (lower.contains(drug.ingredient.toLowerCase()) || lower.contains(label)) {
      return (ingredient: drug.ingredient, isGlp1: drug.isGlp1);
    }
  }
  return (ingredient: 'other', isGlp1: false);
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

extension ShotsyImport on AloftDatabase {
  /// Saves everything in [file]. Running it again on the same file adds nothing: a shot on the
  /// same day with the same medication and dose, a weight on the same day with the same value,
  /// and a repeated note or side effect are skipped and counted.
  Future<ShotsyImportResult> importShotsy(ShotsyFile file, Map<String, ShotsyMedicationChoice> choices) {
    return transaction(() async {
      final result = ShotsyImportResult();
      final existingDoses = await select(doses).get();
      final existingWeights = await select(weights).get();
      final existingNotes = await select(dayNotes).get();
      final existingEffects = await select(sideEffects).get();

      // One medication per name in the file, reusing one already in Aloft with the same name.
      final medicationFor = <String, Medication>{};
      final supplyFor = <String, Supply>{};
      for (final name in file.medications) {
        final shots = [
          for (final s in file.shots)
            if (s.medication == name) s,
        ];
        // The one the person pointed at, else one with the same name.
        final chosenId = choices[name]?.addToMedicationId;
        var medication = chosenId == null
            ? null
            : await (select(medications)..where((m) => m.id.equals(chosenId))).getSingleOrNull();
        medication ??=
            await (select(medications)
                  ..where((m) => m.name.lower().equals(name.toLowerCase()))
                  ..limit(1))
                .getSingleOrNull();
        Supply? supply;
        if (medication != null) {
          supply =
              await (select(supplies)
                    ..where((s) => s.medicationId.equals(medication!.id))
                    ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
                    ..limit(1))
                  .getSingleOrNull();
        } else {
          final choice = choices[name] ?? const ShotsyMedicationChoice(form: MedicationForm.brandPen);
          final kind = ingredientFor(name);
          final last = shots.last, first = shots.first;
          medication = await into(medications).insertReturning(
            MedicationsCompanion.insert(
              name: name,
              activeIngredient: kind.ingredient,
              isGlp1: kind.isGlp1,
              form: choice.form,
              // Taken from the most recent shot: the same weekday and time. Editable afterwards.
              scheduleType: ScheduleType.weekly,
              scheduleDays: Value([last.at.weekday]),
              timeOfDayMinutes: Value(last.at.hour * 60 + last.at.minute),
              startDate: first.at,
            ),
          );
          result.medicationsAdded++;
          // The doses in the file become the dose history; the latest is the usual dose.
          for (var i = 0; i < shots.length; i++) {
            if (i > 0 && shots[i].mg == shots[i - 1].mg) continue;
            var end = shots.length;
            for (var j = i + 1; j < shots.length; j++) {
              if (shots[j].mg != shots[i].mg) {
                end = j;
                break;
              }
            }
            await into(prescriptions).insert(
              PrescriptionsCompanion.insert(
                medicationId: medication.id,
                prescribedDose: shots[i].mg,
                unit: DoseUnit.mg,
                startDate: shots[i].at,
                endDate: Value(end < shots.length ? shots[end].at : null),
              ),
            );
          }
        }
        supply ??= await into(supplies).insertReturning(
          SuppliesCompanion.insert(
            medicationId: medication.id,
            concentrationMgPerMl: Value(
              choices[name]?.form == MedicationForm.compoundedVial ? choices[name]?.concentrationMgPerMl : null,
            ),
          ),
        );
        medicationFor[name] = medication;
        supplyFor[name] = supply;
      }

      for (final day in file.days) {
        final shot = day.shot;
        if (shot != null) {
          final medication = medicationFor[shot.medication]!, supply = supplyFor[shot.medication]!;
          final duplicate = existingDoses.any(
            (d) =>
                d.medicationId == medication.id &&
                !d.skipped &&
                _sameDay(d.takenAt, shot.at) &&
                d.drugMg != null &&
                !differs(d.drugMg!, shot.mg),
          );
          if (duplicate) {
            result.duplicates++;
          } else {
            final strength = supply.concentrationMgPerMl;
            final note = [?shot.note, if (shot.siteText != null) 'Site: ${shot.siteText}'].join(' · ');
            await into(doses).insert(
              DosesCompanion.insert(
                medicationId: medication.id,
                supplyId: supply.id,
                takenAt: shot.at,
                amountEntered: shot.mg,
                unitEntered: DoseUnit.mg,
                drugMg: Value(shot.mg),
                volumeMl: Value(strength == null ? null : shot.mg / strength),
                syringeType: Value(strength == null ? null : 'U-100'),
                injectionPain: Value(shot.pain),
                injectionSite: Value(shot.site),
                notes: Value(note.isEmpty ? null : note),
              ),
            );
            result.shots++;
          }
        }

        final pounds = day.weightLb;
        if (pounds != null) {
          final kg = toKg(pounds, WeightUnit.lb);
          // Shotsy gives a date with no time; noon keeps it on the right day everywhere.
          final at = DateTime(day.date.year, day.date.month, day.date.day, 12);
          if (existingWeights.any((w) => _sameDay(w.measuredAt, at) && (w.kg - kg).abs() < 0.03)) {
            result.duplicates++;
          } else {
            await into(weights).insert(WeightsCompanion.insert(measuredAt: at, kg: kg));
            result.weights++;
          }
        }

        for (final body in day.notes) {
          if (existingNotes.any((n) => _sameDay(n.noteDate, day.date) && n.body == body)) {
            result.duplicates++;
          } else {
            await into(dayNotes).insert(DayNotesCompanion.insert(noteDate: day.date, body: body));
            result.notes++;
          }
        }

        for (final MapEntry(key: type, value: severity) in day.effects.entries) {
          final at = DateTime(day.date.year, day.date.month, day.date.day, 12);
          if (existingEffects.any((e) => _sameDay(e.occurredAt, at) && e.type == type && e.severity == severity)) {
            result.duplicates++;
          } else {
            await into(sideEffects).insert(SideEffectsCompanion.insert(occurredAt: at, type: type, severity: severity));
            result.effects++;
          }
        }
      }
      return result;
    });
  }

  Stream<List<DayNote>> watchDayNotes() => (select(dayNotes)..orderBy([(n) => OrderingTerm.desc(n.noteDate)])).watch();
  Future<void> deleteDayNote(DayNote note) => (delete(dayNotes)..where((n) => n.id.equals(note.id))).go();
  Future<void> restoreDayNote(DayNote note) => into(dayNotes).insert(note);
}
