import 'package:drift/drift.dart';

import '../dose/dose_math.dart';
import '../dose/injection_sites.dart';
import 'database.dart';

/// A medication with what's needed to show and log it.
class MedicationDetail {
  const MedicationDetail({
    required this.medication,
    required this.supply,
    required this.usualDose,
    required this.lastDose,
    required this.lastLogged,
    required this.usedMl,
    required this.usedPills,
  });
  final Medication medication;

  /// The active vial, pen strength or bottle. Null only if it has been finished.
  final Supply? supply;
  final Prescription? usualDose;

  /// Most recent dose that was taken (not skipped).
  final Dose? lastDose;

  /// Most recent dose taken or skipped: what the schedule counts from.
  final Dose? lastLogged;
  final double usedMl;
  final double usedPills;

  double? get remainingMl =>
      supply?.volumeMl == null ? null : (supply!.volumeMl! - supply!.lostMl - usedMl).clamp(0, double.infinity);
  double? get remainingPills =>
      supply?.pillCount == null ? null : (supply!.pillCount! - usedPills).clamp(0, double.infinity);
}

/// Everything entered on the setup screen, saved together.
class NewMedication {
  const NewMedication({
    required this.name,
    required this.activeIngredient,
    required this.isGlp1,
    required this.form,
    required this.scheduleType,
    this.scheduleDays = const [],
    this.scheduleInterval,
    this.timeOfDayMinutes,
    this.concentrationMgPerMl,
    this.pillStrengthMg,
    this.additives = const [],
    this.volumeMl,
    this.pillCount,
    this.pharmacy,
    this.lotNumber,
    this.dateOpened,
    this.beyondUseDate,
    this.cost,
    this.doseAmount,
    this.doseUnit,
  });
  final String name;
  final String activeIngredient;
  final bool isGlp1;
  final MedicationForm form;
  final ScheduleType scheduleType;
  final List<int> scheduleDays;
  final int? scheduleInterval;
  final int? timeOfDayMinutes;
  final double? concentrationMgPerMl;
  final double? pillStrengthMg;
  final List<Additive> additives;
  final double? volumeMl;
  final double? pillCount;
  final String? pharmacy;
  final String? lotNumber;
  final DateTime? dateOpened;
  final DateTime? beyondUseDate;
  final double? cost;
  final double? doseAmount;
  final DoseUnit? doseUnit;
}

extension MedicationStore on AloftDatabase {
  Future<Medication> addMedication(NewMedication m, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return transaction(() async {
      final medication = await into(medications).insertReturning(
        MedicationsCompanion.insert(
          name: m.name,
          activeIngredient: m.activeIngredient,
          isGlp1: m.isGlp1,
          form: m.form,
          scheduleType: m.scheduleType,
          scheduleDays: Value(m.scheduleDays),
          scheduleInterval: Value(m.scheduleInterval),
          timeOfDayMinutes: Value(m.timeOfDayMinutes),
          startDate: today,
        ),
      );
      await into(supplies).insert(
        SuppliesCompanion.insert(
          medicationId: medication.id,
          concentrationMgPerMl: Value(m.concentrationMgPerMl),
          penDoseMg: Value(m.form == MedicationForm.brandPen && m.doseUnit == DoseUnit.mg ? m.doseAmount : null),
          pillStrengthMg: Value(m.pillStrengthMg),
          additives: Value(m.additives),
          volumeMl: Value(m.volumeMl),
          pillCount: Value(m.pillCount),
          pharmacy: Value(m.pharmacy),
          lotNumber: Value(m.lotNumber),
          dateOpened: Value(m.dateOpened),
          beyondUseDate: Value(m.beyondUseDate),
          cost: Value(m.cost),
        ),
      );
      if (m.doseAmount != null && m.doseUnit != null) {
        await into(prescriptions).insert(
          PrescriptionsCompanion.insert(
            medicationId: medication.id,
            prescribedDose: m.doseAmount!,
            unit: m.doseUnit!,
            startDate: today,
          ),
        );
      }
      return medication;
    });
  }

  /// Medications that aren't ended, oldest first, kept up to date as doses are logged.
  Stream<List<MedicationDetail>> watchMedications() {
    final query = select(medications)
      ..where((m) => m.status.equalsValue(MedicationStatus.ended).not())
      ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]);
    // Re-run when any of the four tables change.
    return customSelect(
      'SELECT 1',
      readsFrom: {medications, supplies, prescriptions, doses},
    ).watch().asyncMap((_) async => [for (final m in await query.get()) await _detail(m)]);
  }

  Future<MedicationDetail> _detail(Medication m) async {
    final supply =
        await (select(supplies)
              ..where((s) => s.medicationId.equals(m.id) & s.status.equalsValue(SupplyStatus.active))
              ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    final usual =
        await (select(prescriptions)
              ..where((p) => p.medicationId.equals(m.id) & p.endDate.isNull())
              ..orderBy([(p) => OrderingTerm.desc(p.startDate)])
              ..limit(1))
            .getSingleOrNull();
    final last =
        await (select(doses)
              ..where((d) => d.medicationId.equals(m.id) & d.skipped.equals(false))
              ..orderBy([(d) => OrderingTerm.desc(d.takenAt)])
              ..limit(1))
            .getSingleOrNull();
    final lastLogged =
        await (select(doses)
              ..where((d) => d.medicationId.equals(m.id))
              ..orderBy([(d) => OrderingTerm.desc(d.takenAt)])
              ..limit(1))
            .getSingleOrNull();
    var usedMl = 0.0, usedPills = 0.0;
    if (supply != null) {
      final taken = await (select(doses)..where((d) => d.supplyId.equals(supply.id) & d.skipped.equals(false))).get();
      for (final d in taken) {
        usedMl += d.volumeMl ?? 0;
        if (d.unitEntered == DoseUnit.tablets) usedPills += d.amountEntered;
      }
    }
    return MedicationDetail(
      medication: m,
      supply: supply,
      usualDose: usual,
      lastDose: last,
      lastLogged: lastLogged,
      usedMl: usedMl,
      usedPills: usedPills,
    );
  }

  /// Logged injection sites across every medication, newest first.
  Future<List<({InjectionSite site, DateTime takenAt})>> siteHistory({int limit = 40}) async {
    final rows =
        await (select(doses)
              ..where((d) => d.injectionSite.isNotNull() & d.skipped.equals(false))
              ..orderBy([(d) => OrderingTerm.desc(d.takenAt)])
              ..limit(limit))
            .get();
    return [for (final d in rows) (site: d.injectionSite!, takenAt: d.takenAt)];
  }

  /// Saves a dose, working out and freezing mL, mg and extra-ingredient amounts from the supply
  /// as it is right now.
  Future<Dose> logDose({
    required Medication medication,
    required Supply supply,
    required double amount,
    required DoseUnit unit,
    required DateTime takenAt,
    InjectionSite? site,
    int pain = 0,
    String? notes,
    bool skipped = false,
  }) {
    final frozen = _freeze(supply, amount, unit, skipped);
    final cleanNotes = notes?.trim();
    return into(doses).insertReturning(
      DosesCompanion.insert(
        medicationId: medication.id,
        supplyId: supply.id,
        takenAt: takenAt,
        amountEntered: skipped ? 0 : amount,
        unitEntered: unit,
        volumeMl: Value(frozen.volumeMl),
        drugMg: Value(frozen.drugMg),
        additiveAmounts: Value(frozen.extras),
        injectionPain: Value(skipped ? 0 : pain),
        injectionSite: Value(skipped ? null : site),
        syringeType: Value(frozen.syringe),
        notes: Value(cleanNotes == null || cleanNotes.isEmpty ? null : cleanNotes),
        skipped: Value(skipped),
      ),
    );
  }

  /// mL, mg and extra-ingredient amounts for a dose from this supply, as it is right now.
  ({double? volumeMl, double? drugMg, Map<String, String> extras, String? syringe}) _freeze(
    Supply supply,
    double amount,
    DoseUnit unit,
    bool skipped,
  ) {
    double? volumeMl, drugMg;
    var extras = <String, String>{};
    if (!skipped) {
      if (unit == DoseUnit.tablets) {
        final strength = supply.pillStrengthMg;
        drugMg = strength == null ? null : amount * strength;
      } else if (supply.concentrationMgPerMl != null) {
        final dose = convertVialDose(amount: amount, unit: unit, concentrationMgPerMl: supply.concentrationMgPerMl!);
        volumeMl = dose.volumeMl;
        drugMg = dose.drugMg;
        extras = {
          for (final a in supply.additives) a.name: '${formatNumber(additiveAmount(a, dose.volumeMl), 3)} ${a.unit}',
        };
      } else {
        // Pens: the dose is what's on the pen. No conversion between units.
        if (unit == DoseUnit.mg) drugMg = amount;
        if (unit == DoseUnit.ml) volumeMl = amount;
      }
    }
    final vial = volumeMl != null && supply.concentrationMgPerMl != null;
    return (volumeMl: volumeMl, drugMg: drugMg, extras: extras, syringe: vial ? 'U-100' : null);
  }

  /// Changes a logged dose. Amounts are worked out again from the vial it came from.
  Future<Dose> updateDose(
    Dose dose, {
    required double amount,
    required DoseUnit unit,
    required DateTime takenAt,
    InjectionSite? site,
    int pain = 0,
    String? notes,
  }) async {
    final supply = await (select(supplies)..where((s) => s.id.equals(dose.supplyId))).getSingle();
    final frozen = _freeze(supply, amount, unit, false);
    final cleanNotes = notes?.trim();
    final rows = await (update(doses)..where((d) => d.id.equals(dose.id))).writeReturning(
      DosesCompanion(
        updatedAt: Value(DateTime.now()),
        takenAt: Value(takenAt),
        amountEntered: Value(amount),
        unitEntered: Value(unit),
        volumeMl: Value(frozen.volumeMl),
        drugMg: Value(frozen.drugMg),
        additiveAmounts: Value(frozen.extras),
        injectionPain: Value(pain),
        injectionSite: Value(site),
        syringeType: Value(frozen.syringe),
        notes: Value(cleanNotes == null || cleanNotes.isEmpty ? null : cleanNotes),
        skipped: const Value(false),
      ),
    );
    return rows.single;
  }

  Future<void> deleteDose(Dose dose) => (delete(doses)..where((d) => d.id.equals(dose.id))).go();

  /// Puts back a dose that was just deleted (Undo), exactly as it was.
  Future<void> restoreDose(Dose dose) => into(doses).insert(dose);

  /// Everything logged, newest first, with the medication and vial each dose came from.
  Stream<List<HistoryEntry>> watchHistory() {
    final query = select(doses).join([
      innerJoin(medications, medications.id.equalsExp(doses.medicationId)),
      innerJoin(supplies, supplies.id.equalsExp(doses.supplyId)),
    ])..orderBy([OrderingTerm.desc(doses.takenAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          HistoryEntry(
            dose: row.readTable(doses),
            medication: row.readTable(medications),
            supply: row.readTable(supplies),
          ),
      ],
    );
  }

  /// Ends the current usual dose and starts a new one. History keeps the old one.
  Future<void> changeUsualDose(Medication m, double amount, DoseUnit unit, {DateTime? now}) {
    final at = now ?? DateTime.now();
    return transaction(() async {
      await (update(prescriptions)..where((p) => p.medicationId.equals(m.id) & p.endDate.isNull())).write(
        PrescriptionsCompanion(endDate: Value(at), updatedAt: Value(at)),
      );
      await into(prescriptions)
          .insert(PrescriptionsCompanion.insert(medicationId: m.id, prescribedDose: amount, unit: unit, startDate: at));
    });
  }

  Future<void> updateSchedule(
    Medication m, {
    required ScheduleType type,
    required List<int> days,
    int? interval,
    int? timeOfDayMinutes,
  }) => (update(medications)..where((x) => x.id.equals(m.id))).write(
    MedicationsCompanion(
      updatedAt: Value(DateTime.now()),
      scheduleType: Value(type),
      scheduleDays: Value(days),
      scheduleInterval: Value(interval),
      timeOfDayMinutes: Value(timeOfDayMinutes),
    ),
  );

  /// Pausing stops reminders and "due" on Today but keeps all history.
  Future<void> setMedicationStatus(Medication m, MedicationStatus status) =>
      (update(medications)..where((x) => x.id.equals(m.id))).write(
        MedicationsCompanion(status: Value(status), updatedAt: Value(DateTime.now())),
      );

  Future<void> finishSupply(Supply supply) => (update(supplies)..where((s) => s.id.equals(supply.id))).write(
    SuppliesCompanion(status: const Value(SupplyStatus.finished), updatedAt: Value(DateTime.now())),
  );

  /// Starts a new vial, pen strength or bottle; the one in use before is marked finished.
  Future<Supply> startNewSupply(Medication m, SuppliesCompanion supply) {
    return transaction(() async {
      await (update(supplies)..where((s) => s.medicationId.equals(m.id) & s.status.equalsValue(SupplyStatus.active)))
          .write(SuppliesCompanion(status: const Value(SupplyStatus.finished), updatedAt: Value(DateTime.now())));
      return into(supplies).insertReturning(supply.copyWith(medicationId: Value(m.id)));
    });
  }

  /// Sets what's left in a vial by hand (after a spill, or priming the needle). The difference
  /// is recorded as lost, so logged doses stay as they are.
  Future<void> setRemainingMl(MedicationDetail d, double remainingMl) {
    final supply = d.supply!;
    final lost = (supply.volumeMl! - d.usedMl - remainingMl).clamp(0.0, supply.volumeMl!);
    return (update(supplies)..where((s) => s.id.equals(supply.id))).write(
      SuppliesCompanion(lostMl: Value(lost), updatedAt: Value(DateTime.now())),
    );
  }

  /// Vials, pens and bottles this medication has finished, newest first.
  Future<List<Supply>> pastSupplies(Medication m) =>
      (select(supplies)
            ..where((s) => s.medicationId.equals(m.id) & s.status.equalsValue(SupplyStatus.active).not())
            ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
          .get();
}

class HistoryEntry {
  const HistoryEntry({required this.dose, required this.medication, required this.supply});
  final Dose dose;
  final Medication medication;
  final Supply supply;
}
