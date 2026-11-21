import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/reminders/reminder_plan.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'medication_store_test.dart' show tirzepatideVial;

void main() {
  late Directory dir;
  late AloftDatabase db;
  late AppSettings settings;
  // Saturday morning. Shots are Thursdays at 8 PM; the medication was added on Nov 2.
  final now = DateTime(2026, 11, 21, 9, 30);

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('aloft_reminders');
    db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
    settings = await db.loadSettings(countryCode: 'US');
    await db.addMedication(tirzepatideVial, now: DateTime(2026, 11, 2));
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<List<MedicationDetail>> meds() => db.watchMedications().first;
  Future<List<PlannedReminder>> plan({AppSettings? with_}) async =>
      planReminders(medications: await meds(), settings: with_ ?? settings, now: now);
  Future<void> shot(MedicationDetail d, DateTime at, {double units = 25}) =>
      db.logDose(medication: d.medication, supply: d.supply!, amount: units, unit: DoseUnit.units, takenAt: at);

  test('shot reminders follow the schedule from the next dose that is still ahead', () async {
    await shot((await meds()).single, DateTime(2026, 11, 19, 20, 4));
    final shots = (await plan()).where((r) => r.channel == ReminderChannel.shots).toList();
    expect(shots.first.at, DateTime(2026, 11, 26, 20));
    expect(shots[1].at, DateTime(2026, 12, 3, 20));
    expect(shots.length, 14);
    expect((shots.first.title, shots.first.body), ('Shot day', 'Tap to log it in Aloft.'));
  });

  test('the medication is named only when there is more than one', () async {
    expect((await plan()).every((r) => !r.body.contains('Tirzepatide')), isTrue);
    await db.addMedication(
      const NewMedication(
        name: 'NAD+',
        activeIngredient: 'nad',
        isGlp1: false,
        form: MedicationForm.compoundedVial,
        scheduleType: ScheduleType.daysOfWeek,
        scheduleDays: [1, 3, 5],
        timeOfDayMinutes: 9 * 60,
        concentrationMgPerMl: 100,
        doseAmount: 20,
        doseUnit: DoseUnit.units,
      ),
      now: DateTime(2026, 11, 20),
    );
    final all = await plan();
    expect(all.where((r) => r.body == 'NAD+. Tap to log it.'), isNotEmpty);
    expect(all.where((r) => r.body == 'Tirzepatide. Tap to log it.'), isNotEmpty);
    expect(all.length, lessThanOrEqualTo(60));
    expect([for (final r in all) r.at], orderedEquals([for (final r in all) r.at]..sort()));
  });

  test('nothing for a paused medication, or when the switch is off', () async {
    expect(await plan(with_: settings.copyWith(remindShots: false)), isEmpty);
    await db.setMedicationStatus((await meds()).single.medication, MedicationStatus.paused);
    expect(await plan(), isEmpty);
  });

  test('reorder: once, the morning after the dose that leaves two doses', () async {
    final d = (await meds()).single;
    // 2 mL vial at 0.25 mL: six doses leaves two.
    for (var i = 0; i < 5; i++) {
      await shot(d, DateTime(2026, 10, 8 + 7 * i, 20));
    }
    expect((await plan()).where((r) => r.channel == ReminderChannel.supply), isEmpty, reason: 'three left');
    await shot(d, DateTime(2026, 11, 21, 8));
    final supply = (await plan()).where((r) => r.channel == ReminderChannel.supply).single;
    expect((supply.at, supply.title), (DateTime(2026, 11, 22, 9), 'Running low'));
    expect(supply.body, 'About 2 doses left in your Tirzepatide vial.');
    expect(await plan(with_: settings.copyWith(remindReorder: false)), isNot(contains(supply)));
    // A day later it has fired and isn't planned again.
    final later = planReminders(medications: await meds(), settings: settings, now: DateTime(2026, 11, 22, 10));
    expect(later.where((r) => r.channel == ReminderChannel.supply), isEmpty);
  });

  test('use-by: a week before, at 9 AM', () async {
    final d = (await meds()).single;
    await (db.update(
      db.supplies,
    )..where((s) => s.id.equals(d.supply!.id))).write(SuppliesCompanion(beyondUseDate: Value(DateTime(2026, 12, 30))));
    final useBy = (await plan()).where((r) => r.channel == ReminderChannel.supply).single;
    expect((useBy.at, useBy.title), (DateTime(2026, 12, 23, 9), 'Use-by date in a week'));
    expect(await plan(with_: settings.copyWith(remindUseBy: false)), isNot(contains(useBy)));
  });

  test('doses left counts whole doses at the usual dose', () async {
    final d = (await meds()).single;
    expect(dosesLeft(d), 8);
    await shot(d, DateTime(2026, 11, 19, 20), units: 30);
    expect(dosesLeft((await meds()).single), 6, reason: '1.7 mL at 0.25 mL');
  });
}
