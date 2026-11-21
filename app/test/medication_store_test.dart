import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

const b12 = Additive(name: 'Cyanocobalamin (B12)', amountPerMl: 0.5);

const tirzepatideVial = NewMedication(
  name: 'Tirzepatide',
  activeIngredient: 'tirzepatide',
  isGlp1: true,
  form: MedicationForm.compoundedVial,
  scheduleType: ScheduleType.weekly,
  scheduleDays: [4],
  timeOfDayMinutes: 20 * 60,
  concentrationMgPerMl: 10,
  additives: [b12],
  volumeMl: 2,
  doseAmount: 25,
  doseUnit: DoseUnit.units,
);

void main() {
  late Directory dir;
  late AloftDatabase db;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aloft_store');
    db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<MedicationDetail> only() async => (await db.watchMedications().first).single;

  test('a new vial is saved with its strength, extras, schedule and usual dose', () async {
    await db.addMedication(tirzepatideVial);
    final d = await only();
    expect(d.medication.name, 'Tirzepatide');
    expect(d.medication.scheduleType, ScheduleType.weekly);
    expect(d.medication.scheduleDays, [4]);
    expect(d.medication.halfLifeHours, isNull, reason: 'level-chart numbers are not filled in until verified');
    expect(d.supply!.concentrationMgPerMl, 10);
    expect(d.supply!.additives, [b12]);
    expect((d.usualDose!.prescribedDose, d.usualDose!.unit), (25, DoseUnit.units));
    expect((d.lastDose, d.remainingMl), (null, 2));
  });

  test('logging a shot freezes mL, mg and extras, and uses up the vial', () async {
    await db.addMedication(tirzepatideVial);
    var d = await only();
    final dose = await db.logDose(
      medication: d.medication,
      supply: d.supply!,
      amount: 25,
      unit: DoseUnit.units,
      takenAt: DateTime(2026, 11, 19, 20, 4),
      site: InjectionSite.abdomenLowerLeft,
      pain: 2,
      notes: '  easy one ',
    );
    expect((dose.volumeMl, dose.drugMg), (0.25, 2.5));
    expect(dose.additiveAmounts, {'Cyanocobalamin (B12)': '0.125 mg'});
    expect((dose.injectionSite, dose.injectionPain, dose.notes), (InjectionSite.abdomenLowerLeft, 2, 'easy one'));
    expect(dose.syringeType, 'U-100');

    d = await only();
    expect(d.lastDose!.id, dose.id);
    expect(d.remainingMl, 1.75);

    // Changing the vial's strength afterwards must not rewrite the logged dose.
    await (db.update(
      db.supplies,
    )..where((s) => s.id.equals(d.supply!.id))).write(const SuppliesCompanion(concentrationMgPerMl: Value(20)));
    final again = await (db.select(db.doses)..where((x) => x.id.equals(dose.id))).getSingle();
    expect(again.drugMg, 2.5);
  });

  test('a skipped dose is recorded but uses nothing and is not the "last dose"', () async {
    await db.addMedication(tirzepatideVial);
    var d = await only();
    final skipped = await db.logDose(
      medication: d.medication,
      supply: d.supply!,
      amount: 25,
      unit: DoseUnit.units,
      takenAt: DateTime(2026, 11, 19),
      site: InjectionSite.thighLeft,
      skipped: true,
    );
    expect((skipped.skipped, skipped.volumeMl, skipped.injectionSite), (true, null, null));
    d = await only();
    expect((d.lastDose, d.remainingMl), (null, 2));
    expect(await db.siteHistory(), isEmpty);
  });

  test('pens keep the typed dose with no conversion; pills count tablets and mg', () async {
    await db.addMedication(
      const NewMedication(
        name: 'Zepbound®',
        activeIngredient: 'tirzepatide',
        isGlp1: true,
        form: MedicationForm.brandPen,
        scheduleType: ScheduleType.weekly,
        scheduleDays: [4],
        doseAmount: 3.75,
        doseUnit: DoseUnit.mg,
      ),
    );
    await db.addMedication(
      const NewMedication(
        name: 'Rybelsus®',
        activeIngredient: 'semaglutide',
        isGlp1: true,
        form: MedicationForm.oral,
        scheduleType: ScheduleType.daily,
        pillStrengthMg: 7,
        pillCount: 30,
        doseAmount: 1,
        doseUnit: DoseUnit.tablets,
      ),
    );
    final [pen, pill] = await db.watchMedications().first;

    final shot = await db.logDose(
      medication: pen.medication,
      supply: pen.supply!,
      amount: 3.75,
      unit: DoseUnit.mg,
      takenAt: DateTime(2026, 11, 19),
    );
    expect((shot.drugMg, shot.volumeMl, shot.syringeType), (3.75, null, null));

    final tablet = await db.logDose(
      medication: pill.medication,
      supply: pill.supply!,
      amount: 0.5,
      unit: DoseUnit.tablets,
      takenAt: DateTime(2026, 11, 19),
    );
    expect(tablet.drugMg, 3.5);
    expect((await db.watchMedications().first)[1].remainingPills, 29.5);
  });

  test('site history covers every medication, newest first', () async {
    await db.addMedication(tirzepatideVial);
    await db.addMedication(
      const NewMedication(
        name: 'NAD+',
        activeIngredient: 'nad',
        isGlp1: false,
        form: MedicationForm.compoundedVial,
        scheduleType: ScheduleType.daysOfWeek,
        scheduleDays: [1, 3, 5],
        concentrationMgPerMl: 100,
        doseAmount: 20,
        doseUnit: DoseUnit.units,
      ),
    );
    final [glp, nad] = await db.watchMedications().first;
    Future<void> log(MedicationDetail d, InjectionSite site, int day) => db.logDose(
      medication: d.medication,
      supply: d.supply!,
      amount: 20,
      unit: DoseUnit.units,
      takenAt: DateTime(2026, 11, day),
      site: site,
    );
    await log(glp, InjectionSite.abdomenLowerLeft, 12);
    await log(nad, InjectionSite.thighRight, 16);
    await log(glp, InjectionSite.abdomenLowerRight, 19);
    final sites = [for (final entry in await db.siteHistory()) entry.site];
    expect(sites, [InjectionSite.abdomenLowerRight, InjectionSite.thighRight, InjectionSite.abdomenLowerLeft]);
    expect(suggestSite(sites), InjectionSite.abdomenLowerLeft);
  });

  test('a database from the first version gains the new tables and keeps its settings', () async {
    await db.close();
    final key = generateDatabaseKey();
    final file = File('${dir.path}/old.db');
    final old = sqlite3.open(file.path);
    applyDatabaseKey(old, key);
    old.execute('''
      CREATE TABLE app_settings (
        id INTEGER NOT NULL DEFAULT 1 CHECK (id = 1), weight_unit TEXT NOT NULL, length_unit TEXT NOT NULL,
        appearance TEXT NOT NULL DEFAULT 'system', app_lock INTEGER NOT NULL DEFAULT 0,
        lock_after TEXT NOT NULL DEFAULT 'immediately', hide_in_app_switcher INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (id));
      INSERT INTO app_settings (weight_unit, length_unit, app_lock) VALUES ('kg', 'cm', 1);
      PRAGMA user_version = 1;
    ''');
    old.close();

    db = openEncryptedDatabase(file, key);
    final settings = await db.loadSettings();
    expect((settings.weightUnit, settings.appLock), (WeightUnit.kg, true));
    await db.addMedication(tirzepatideVial);
    expect((await only()).medication.name, 'Tirzepatide');
  });
}
