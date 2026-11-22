import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/features/body/goal_screen.dart';
import 'package:aloft/settings/settings.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('BMI is kg over height in metres squared', () {
    expect(formatBmi(70, 175), '22.9');
    expect(formatBmi(toKg(200, WeightUnit.lb), 66 * cmPerInch), '32.3');
  });

  test('height is read from feet and inches or from cm, and odd values are refused', () {
    GoalHeightDraft draft({double? goalKg, double? heightCm, LengthUnit unit = LengthUnit.inches}) =>
        GoalHeightDraft(goalKg: goalKg, heightCm: heightCm, weightUnit: WeightUnit.lb, lengthUnit: unit);

    final d = draft();
    expect(d.problems(WeightUnit.lb, LengthUnit.inches), isEmpty, reason: 'both are optional');
    expect((d.goalKg(WeightUnit.lb), d.heightCm(LengthUnit.inches)), (null, null));
    d.heightMain.text = '5';
    d.heightInches.text = '6';
    expect(d.heightCm(LengthUnit.inches), closeTo(167.64, 0.001));
    d.heightInches.text = '12';
    expect(d.problems(WeightUnit.lb, LengthUnit.inches), ['Check your height, or leave it blank.']);
    d.heightMain.text = '170';
    d.heightInches.text = '';
    expect(d.heightCm(LengthUnit.cm), 170);
    expect(d.heightCm(LengthUnit.inches), isNull, reason: '170 feet');
    d.goal.text = '5';
    expect(d.problems(WeightUnit.lb, LengthUnit.cm), ['Check your goal weight, or leave it blank.']);

    // A saved height comes back as the feet and inches that were typed.
    final saved = draft(goalKg: toKg(150, WeightUnit.lb), heightCm: 71.5 * cmPerInch);
    expect((saved.goal.text, saved.heightMain.text, saved.heightInches.text), ('150', '5', '11.5'));
    final nearlySix = draft(heightCm: 182.8);
    expect((nearlySix.heightMain.text, nearlySix.heightInches.text), ('6', '0'));
    expect(draft(heightCm: 170, unit: LengthUnit.cm).heightMain.text, '170');
  });

  test('a version 7 database gains an empty goal and height', () async {
    final dir = Directory.systemTemp.createTempSync('aloft_goal_db');
    addTearDown(() => dir.deleteSync(recursive: true));
    final key = generateDatabaseKey();
    final file = File('${dir.path}/v7.db');
    var db = openEncryptedDatabase(file, key);
    await db.loadSettings(countryCode: 'US');
    await db.saveSettings(const AppSettingsTableCompanion(onboardingDone: Value(true)));
    await db.close();
    final raw = sqlite3.open(file.path);
    applyDatabaseKey(raw, key);
    raw.execute(
      'ALTER TABLE app_settings DROP COLUMN goal_weight_kg; ALTER TABLE app_settings DROP COLUMN height_cm; '
      'PRAGMA user_version = 7;',
    );
    raw.close();
    db = openEncryptedDatabase(file, key);
    var settings = await db.loadSettings();
    expect((settings.onboardingDone, settings.goalWeightKg, settings.heightCm), (true, null, null));
    settings = await db.saveSettings(const AppSettingsTableCompanion(goalWeightKg: Value(70), heightCm: Value(170)));
    expect((settings.goalWeightKg, settings.heightCm), (70, 170));
    await db.close();
  });

  test('a version 8 database gains empty backup-reminder times', () async {
    final dir = Directory.systemTemp.createTempSync('aloft_v8_db');
    addTearDown(() => dir.deleteSync(recursive: true));
    final key = generateDatabaseKey();
    final file = File('${dir.path}/v8.db');
    var db = openEncryptedDatabase(file, key);
    await db.loadSettings(countryCode: 'US');
    await db.saveSettings(const AppSettingsTableCompanion(goalWeightKg: Value(70)));
    await db.close();
    final raw = sqlite3.open(file.path);
    applyDatabaseKey(raw, key);
    raw.execute(
      'ALTER TABLE app_settings DROP COLUMN last_backup_at; '
      'ALTER TABLE app_settings DROP COLUMN backup_reminder_snoozed_until; PRAGMA user_version = 8;',
    );
    raw.close();
    db = openEncryptedDatabase(file, key);
    final settings = await db.loadSettings();
    expect((settings.goalWeightKg, settings.lastBackupAt, settings.backupReminderSnoozedUntil), (70, null, null));
    await db.close();
  });

  testWidgets('goal and height are saved from More, and BMI appears once there is a height', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_goal');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    late AppSettings settings;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      settings = await db.loadSettings(countryCode: 'US');
      await db.logWeight(kg: toKg(200, WeightUnit.lb), measuredAt: DateTime(2026, 9, 1));
      await db.logWeight(kg: toKg(190, WeightUnit.lb), measuredAt: DateTime(2026, 11, 1));
    });
    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), initialSettingsProvider.overrideWithValue(settings)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GoalScreen())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await settle();

    // No height yet: no BMI anywhere.
    expect(find.textContaining('BMI 3'), findsNothing);
    expect(find.textContaining('BMI stays off'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('goal-weight')), '150');
    await tester.enterText(find.byKey(const Key('height-ft')), '5');
    await tester.enterText(find.byKey(const Key('height-in')), '6');
    await tester.pump();
    expect(find.text('Starting BMI 32.3'), findsOneWidget);
    expect(find.text('Current BMI 30.7'), findsOneWidget);
    expect(find.text('Goal BMI 24.2'), findsOneWidget);
    // The number only: no category and no judgement.
    for (final word in ['overweight', 'obese', 'normal', 'healthy']) {
      expect(find.textContaining(word), findsNothing);
    }

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('goal-save')));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    // Waits for the save to finish rather than for a fixed time.
    for (var i = 0; i < 200 && find.byType(GoalScreen).evaluate().isNotEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }
    expect(find.byType(GoalScreen), findsNothing);
    late AppSettings saved;
    await tester.runAsync(() async => saved = await db.loadSettings());
    expect(saved.goalWeightKg, closeTo(68.039, 0.001));
    expect(saved.heightCm, closeTo(167.64, 0.001));
    expect(describeGoal(saved), 'Goal 150 lb · BMI on');
    expect(describeGoal(settings), 'BMI off');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
