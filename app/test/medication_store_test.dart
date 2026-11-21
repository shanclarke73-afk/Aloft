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

  group('changing things later', () {
    Future<Dose> shot(MedicationDetail d, {double amount = 25, int day = 19}) => db.logDose(
      medication: d.medication,
      supply: d.supply!,
      amount: amount,
      unit: DoseUnit.units,
      takenAt: DateTime(2026, 11, day, 20),
      site: InjectionSite.abdomenLowerLeft,
    );

    test('editing a shot works the amounts out again and gives the difference back to the vial', () async {
      await db.addMedication(tirzepatideVial);
      final dose = await shot(await only());
      final edited = await db.updateDose(
        dose,
        amount: 20,
        unit: DoseUnit.units,
        takenAt: DateTime(2026, 11, 19, 21),
        site: InjectionSite.thighLeft,
        pain: 3,
        notes: 'fixed',
      );
      expect((edited.volumeMl, edited.drugMg, edited.injectionPain, edited.notes), (0.2, 2.0, 3, 'fixed'));
      expect(edited.additiveAmounts, {'Cyanocobalamin (B12)': '0.1 mg'});
      expect((await only()).remainingMl, closeTo(1.8, 1e-9));
    });

    test('deleting a shot gives its volume back, and Undo restores it exactly', () async {
      await db.addMedication(tirzepatideVial);
      final dose = await shot(await only());
      await db.deleteDose(dose);
      expect(((await only()).remainingMl, (await only()).lastDose), (2, null));
      await db.restoreDose(dose);
      final back = (await only()).lastDose!;
      expect((back.id, back.drugMg, back.takenAt), (dose.id, dose.drugMg, dose.takenAt));
    });

    test('history lists doses newest first with their medication', () async {
      await db.addMedication(tirzepatideVial);
      final d = await only();
      await shot(d, day: 12);
      await shot(d, day: 19);
      final history = await db.watchHistory().first;
      expect([for (final e in history) e.dose.takenAt.day], [19, 12]);
      expect(history.first.medication.name, 'Tirzepatide');
    });

    test('changing the usual dose keeps the old one in history', () async {
      await db.addMedication(tirzepatideVial);
      await db.changeUsualDose((await only()).medication, 5, DoseUnit.mg);
      final d = await only();
      expect((d.usualDose!.prescribedDose, d.usualDose!.unit), (5, DoseUnit.mg));
      final all = await db.select(db.prescriptions).get();
      expect(all.length, 2);
      expect(all.where((p) => p.endDate != null).single.prescribedDose, 25);
    });

    test('a new vial finishes the old one and starts full; its doses stay with the old vial', () async {
      await db.addMedication(tirzepatideVial);
      var d = await only();
      await shot(d);
      await db.startNewSupply(
        d.medication,
        const SuppliesCompanion(concentrationMgPerMl: Value(20), volumeMl: Value(1), additives: Value([b12])),
      );
      d = await only();
      expect((d.supply!.concentrationMgPerMl, d.remainingMl), (20, 1));
      final past = await db.pastSupplies(d.medication);
      expect((past.single.concentrationMgPerMl, past.single.status), (10, SupplyStatus.finished));
      // The last dose is still known, so the next Log shot starts from it.
      expect(d.lastDose!.drugMg, 2.5);
    });

    test('a finished vial leaves nothing to log from until a new one is started', () async {
      await db.addMedication(tirzepatideVial);
      await db.finishSupply((await only()).supply!);
      expect((await only()).supply, isNull);
    });

    test('adjusting what is left records the loss without touching logged doses', () async {
      await db.addMedication(tirzepatideVial);
      var d = await only();
      await shot(d);
      d = await only();
      await db.setRemainingMl(d, 1.5);
      d = await only();
      expect((d.remainingMl, d.supply!.lostMl, d.usedMl), (1.5, 0.25, 0.25));
    });

    test('pausing and the schedule can be changed', () async {
      await db.addMedication(tirzepatideVial);
      var m = (await only()).medication;
      await db.setMedicationStatus(m, MedicationStatus.paused);
      await db.updateSchedule(m, type: ScheduleType.daysOfWeek, days: [1, 5], timeOfDayMinutes: 9 * 60);
      m = (await only()).medication;
      expect((m.status, m.scheduleType, m.timeOfDayMinutes), (MedicationStatus.paused, ScheduleType.daysOfWeek, 540));
      expect(m.scheduleDays, [1, 5]);
    });
  });

  test('a version 2 database gains the reminder switches and the lost-volume column', () async {
    await db.close();
    final key = generateDatabaseKey();
    final file = File('${dir.path}/v2.db');
    // Build a current database, then turn it back into what version 2 looked like.
    db = openEncryptedDatabase(file, key);
    await db.loadSettings(countryCode: 'US');
    await db.addMedication(tirzepatideVial);
    await db.close();
    final raw = sqlite3.open(file.path);
    applyDatabaseKey(raw, key);
    raw.execute('''
      ALTER TABLE app_settings DROP COLUMN remind_shots;
      ALTER TABLE app_settings DROP COLUMN remind_reorder;
      ALTER TABLE app_settings DROP COLUMN remind_use_by;
      ALTER TABLE supplies DROP COLUMN lost_ml;
      PRAGMA user_version = 2;
    ''');
    raw.close();

    db = openEncryptedDatabase(file, key);
    final settings = await db.loadSettings();
    expect((settings.remindShots, settings.remindReorder, settings.remindUseBy), (true, true, true));
    final d = await only();
    expect((d.supply!.lostMl, d.remainingMl), (0, 2));
  });
}
