import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/body_store.dart';
import '../data/database.dart';
import '../data/encrypted_database.dart';
import '../data/medication_store.dart';
import '../dose/dose_math.dart';
import '../dose/injection_sites.dart';
import '../pro/pro_store.dart';

/// Screenshot builds only: `--dart-define=ALOFT_DEMO=true` in a debug build opens a throwaway
/// database filled with a made-up person's twelve weeks, so store screenshots never show
/// anyone's real records. A release build ignores the switch, and the real database is never
/// opened or touched while it is on.
const demoRequested = bool.fromEnvironment('ALOFT_DEMO');

const _lbPerKg = 2.2046226218;

/// A fresh database with the made-up history, ending today. Rebuilt on every launch.
Future<AloftDatabase> openDemoDatabase({DateTime? now}) async {
  final folder = Directory(p.join((await getTemporaryDirectory()).path, 'aloft_demo'));
  if (folder.existsSync()) folder.deleteSync(recursive: true);
  folder.createSync(recursive: true);
  final db = openEncryptedDatabase(File(p.join(folder.path, 'demo.db')), generateDatabaseKey());
  await seedDemoData(db, now: now ?? DateTime.now());
  return db;
}

/// Twelve weekly shots of compounded semaglutide stepping up 0.25 → 0.5 → 1 mg, a weight each
/// week, a few side effects after each step up, and a goal. The next shot is due today.
Future<void> seedDemoData(AloftDatabase db, {required DateTime now}) async {
  const weeks = 12;
  final today = DateTime(now.year, now.month, now.day);
  DateTime weeksAgo(int n, {int hour = 8}) => today.subtract(Duration(days: 7 * n)).add(Duration(hours: hour));

  await db.loadSettings(countryCode: 'US');
  await db.saveSettings(
    AppSettingsTableCompanion(
      onboardingDone: const Value(true),
      // Backed up yesterday, so Today shows the tracking cards and not the backup reminder.
      lastBackupAt: Value(today.subtract(const Duration(days: 1))),
      goalWeightKg: const Value(165 / _lbPerKg),
      heightCm: const Value(167.6),
    ),
  );

  final medication = await db.addMedication(
    NewMedication(
      name: 'Semaglutide + B12',
      activeIngredient: 'semaglutide',
      isGlp1: true,
      form: MedicationForm.compoundedVial,
      scheduleType: ScheduleType.weekly,
      scheduleDays: [today.weekday],
      timeOfDayMinutes: 8 * 60,
      concentrationMgPerMl: 2.5,
      additives: const [Additive(name: 'Cyanocobalamin (B12)', amountPerMl: 0.5)],
      volumeMl: 4,
      pharmacy: 'Harbor Compounding',
      dateOpened: weeksAgo(weeks),
      beyondUseDate: today.add(const Duration(days: 45)),
      doseAmount: 40,
      doseUnit: DoseUnit.units,
    ),
    now: weeksAgo(weeks),
  );
  final supply = (await db.watchMedications().first).single.supply!;

  const sites = [
    InjectionSite.abdomenUpperLeft,
    InjectionSite.abdomenUpperRight,
    InjectionSite.abdomenLowerLeft,
    InjectionSite.abdomenLowerRight,
  ];
  // Pounds on each shot morning, oldest first, then this morning's.
  const pounds = [208.4, 207.0, 205.8, 204.1, 202.6, 200.2, 199.0, 197.3, 195.9, 193.8, 192.4, 190.7, 189.6];
  for (var week = weeks; week >= 1; week--) {
    final done = weeks - week; // 0 for the first shot
    final units = done < 4 ? 10.0 : (done < 8 ? 20.0 : 40.0);
    await db.logDose(
      medication: medication,
      supply: supply,
      amount: units,
      unit: DoseUnit.units,
      takenAt: weeksAgo(week, hour: 8),
      site: sites[done % sites.length],
      pain: done % 3 == 0 ? 1 : 0,
    );
    await db.logWeight(kg: pounds[done] / _lbPerKg, measuredAt: weeksAgo(week, hour: 7));
  }
  await db.logWeight(kg: pounds.last / _lbPerKg, measuredAt: today.add(const Duration(hours: 7)));

  // The day after each step up.
  await db.logSideEffects(
    severities: {SideEffectType.nausea: 4, SideEffectType.fatigue: 3},
    occurredAt: weeksAgo(8).add(const Duration(days: 1, hours: 6)),
    medicationId: medication.id,
  );
  await db.logSideEffects(
    severities: {SideEffectType.nausea: 3, SideEffectType.constipation: 2},
    occurredAt: weeksAgo(4).add(const Duration(days: 1, hours: 6)),
    medicationId: medication.id,
  );
  await db.logSideEffects(
    severities: {SideEffectType.lowAppetite: 2},
    occurredAt: weeksAgo(1).add(const Duration(days: 2, hours: 4)),
    medicationId: medication.id,
  );
}

/// Screenshot builds only: the three plans as the stores list them in the US, with the
/// yearly free trial, so the Aloft Pro screen can be captured without a store account.
/// Nothing can be bought from it.
class DemoProStore implements ProStore {
  const DemoProStore();

  @override
  bool get available => true;
  @override
  Future<void> start(void Function(bool pro) onChange) async {}
  @override
  Future<List<ProPlan>> plans() async => const [
    ProPlan(kind: ProPlanKind.yearly, price: r'$14.99', trial: FreeTrial(14)),
    ProPlan(kind: ProPlanKind.lifetime, price: r'$29.99'),
    ProPlan(kind: ProPlanKind.monthly, price: r'$1.99'),
  ];
  @override
  Future<PurchaseOutcome> buy(ProPlan plan) async => PurchaseOutcome.cancelled;
  @override
  Future<bool> restore() async => false;
  @override
  Future<Uri?> manageUrl() async => null;
}
