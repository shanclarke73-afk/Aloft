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
    required this.usedMl,
    required this.usedPills,
  });
  final Medication medication;

  /// The active vial, pen strength or bottle. Null only if it has been finished.
  final Supply? supply;
  final Prescription? usualDose;

  /// Most recent dose that was taken (not skipped).
  final Dose? lastDose;
  final double usedMl;
  final double usedPills;

  double? get remainingMl => supply?.volumeMl == null ? null : (supply!.volumeMl! - usedMl).clamp(0, double.infinity);
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
    final cleanNotes = notes?.trim();
    return into(doses).insertReturning(
      DosesCompanion.insert(
        medicationId: medication.id,
        supplyId: supply.id,
        takenAt: takenAt,
        amountEntered: skipped ? 0 : amount,
        unitEntered: unit,
        volumeMl: Value(volumeMl),
        drugMg: Value(drugMg),
        additiveAmounts: Value(extras),
        injectionPain: Value(skipped ? 0 : pain),
        injectionSite: Value(skipped ? null : site),
        syringeType: Value(volumeMl != null && supply.concentrationMgPerMl != null ? 'U-100' : null),
        notes: Value(cleanNotes == null || cleanNotes.isEmpty ? null : cleanNotes),
        skipped: Value(skipped),
      ),
    );
  }
}
