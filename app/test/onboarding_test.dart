import 'dart:io';

import 'package:aloft/app.dart';
import 'package:aloft/backup/backup_file.dart';
import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/features/about/about_screen.dart';
import 'package:aloft/features/onboarding/onboarding_screen.dart';
import 'package:aloft/photos/photo_picker.dart';
import 'package:aloft/security/app_lock.dart';
import 'package:aloft/settings/settings.dart';
import 'package:aloft/shell/home_shell.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import 'app_lock_test.dart' show FakeAuthenticator;
import 'medication_store_test.dart' show tirzepatideVial;
import 'photos_test.dart' show FakePicker;
import 'support/wait.dart';

void main() {
  late Directory dir;
  late AloftDatabase db;
  late AppSettings settings;

  Future<void> open(WidgetTester tester, {Future<void> Function()? before}) async {
    dir = Directory.systemTemp.createTempSync('aloft_onboarding');
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      settings = await db.loadSettings(countryCode: 'US');
      await before?.call();
    });
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 16; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> start(WidgetTester tester) async {
    final lock = AppLock(authenticator: FakeAuthenticator(), enabled: false, lockAfter: LockAfter.immediately);
    await tester.runAsync(lock.detectMethod);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(settings),
          appLockProvider.overrideWithValue(lock),
          photoPickerProvider.overrideWithValue(FakePicker()),
          photoFolderProvider.overrideWithValue(Directory('${dir.path}/photos')),
        ],
        child: const AloftApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, Key key) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(key));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('a new install opens on the welcome screens, and every step but the disclaimer can be skipped', (
    tester,
  ) async {
    await open(tester);
    await start(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    expect(find.text('From titration to thriving.'), findsOneWidget);
    // Says only what is true today: no automatic cloud backup is promised.
    expect(find.textContaining('iCloud'), findsNothing);
    expect(find.textContaining('It stays on this phone'), findsOneWidget);
    expect(find.textContaining('It never tells you how much to take.'), findsOneWidget);

    await tap(tester, const Key('get-started'));
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('What are you taking?'), findsOneWidget);
    await tap(tester, const Key('medication-later'));
    expect(find.text('Step 2 of 4'), findsOneWidget);
    await tap(tester, const Key('weight-skip'));
    expect(find.text('Starting photos'), findsOneWidget);
    await tap(tester, const Key('onboarding-back'));
    expect(find.text("Where you're starting"), findsOneWidget);
    await tap(tester, const Key('weight-skip'));
    await tap(tester, const Key('photos-continue'));

    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text(medicalDisclaimer), findsOneWidget);
    expect(find.text('Lock with Face ID'), findsOneWidget);
    // The button does nothing until the box is ticked.
    expect(tester.widget<FilledButton>(find.byKey(const Key('start-using'))).onPressed, isNull);
    await tap(tester, const Key('understand'));
    await tap(tester, const Key('start-using'));

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Add your medication'), findsOneWidget);
    // Weight, notes and photos don't have to wait for a medication.
    expect(find.text('Add your starting weight'), findsOneWidget);
    expect(find.byTooltip('Add to your log'), findsOneWidget);
    await tester.runAsync(() async {
      expect((await db.loadSettings()).onboardingDone, isTrue);
      expect(await db.select(db.weights).get(), isEmpty);
    });
    await finish(tester);
  });

  testWidgets('a medication already set up is shown, and the starting weight is saved on its date', (tester) async {
    await open(tester, before: () => db.addMedication(tirzepatideVial));
    await start(tester);
    await tap(tester, const Key('get-started'));
    expect(find.text('Your medication'), findsOneWidget);
    expect(find.text(tirzepatideVial.name), findsOneWidget);
    expect(find.byKey(const Key('medication-later')), findsNothing);
    // "Taking something else as well" is a second medication at once, which is Pro.
    await tester.runAsync(() async {
      await tester.tap(find.text('Brand-name pen'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await pumpUntilFound(tester, find.byKey(const Key('pro-reason')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Track another medication alongside ${tirzepatideVial.name} with Pro.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Your medication'), findsOneWidget);
    await tap(tester, const Key('medication-continue'));

    await tap(tester, const Key('weight-continue'));
    expect(find.text('Enter your weight, or skip this step.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('start-weight')), '197');
    await tester.pump();
    // Goal and height are optional; BMI shows only once there is a height.
    expect(find.textContaining('BMI 3'), findsNothing);
    await tester.enterText(find.byKey(const Key('goal-weight')), '150');
    await tester.enterText(find.byKey(const Key('height-ft')), '5');
    await tester.enterText(find.byKey(const Key('height-in')), '6');
    await tester.pump();
    expect(find.text('Starting BMI 31.8'), findsOneWidget);
    expect(find.text('Goal BMI 24.2'), findsOneWidget);
    await tap(tester, const Key('weight-continue'));
    expect(find.text('Starting photos'), findsOneWidget);
    await tester.runAsync(() async {
      final settings = await db.loadSettings();
      expect(settings.goalWeightKg, closeTo(toKg(150, WeightUnit.lb), 1e-9));
      expect(settings.heightCm, closeTo(167.64, 1e-9));
    });
    await tester.runAsync(() async {
      final saved = (await db.select(db.weights).get()).single;
      expect(saved.kg, closeTo(toKg(197, WeightUnit.lb), 1e-9));
      expect(DateUtils.isSameDay(saved.measuredAt, DateTime.now()), isTrue);
    });
    // Going back doesn't ask for it, or save it, a second time.
    await tap(tester, const Key('onboarding-back'));
    expect(find.textContaining('Your starting weight is saved.'), findsOneWidget);
    await tap(tester, const Key('weight-continue'));
    await tester.runAsync(() async => expect((await db.select(db.weights).get()).length, 1));
    await finish(tester);
  });

  testWidgets('once finished, the app opens straight to Today', (tester) async {
    await open(
      tester,
      before: () async {
        settings = await db.saveSettings(const AppSettingsTableCompanion(onboardingDone: Value(true)));
      },
    );
    await start(tester);
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    await finish(tester);
  });

  group('data', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('aloft_onboarding_db'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('a version 6 database gains the setting, switched off', () async {
      final key = generateDatabaseKey();
      final file = File('${dir.path}/v6.db');
      var db = openEncryptedDatabase(file, key);
      await db.loadSettings(countryCode: 'US');
      await db.saveSettings(const AppSettingsTableCompanion(weightUnit: Value(WeightUnit.kg)));
      await db.close();
      final raw = sqlite3.open(file.path);
      applyDatabaseKey(raw, key);
      raw.execute('ALTER TABLE app_settings DROP COLUMN onboarding_done; PRAGMA user_version = 6;');
      raw.close();
      db = openEncryptedDatabase(file, key);
      final settings = await db.loadSettings();
      expect((settings.onboardingDone, settings.weightUnit), (false, WeightUnit.kg));
      await db.close();
    });

    test('restoring a backup never skips the welcome screens on a new phone', () async {
      final old = openEncryptedDatabase(File('${dir.path}/old.db'), generateDatabaseKey());
      await old.loadSettings(countryCode: 'US');
      await old.saveSettings(const AppSettingsTableCompanion(onboardingDone: Value(true)));
      await old.logWeight(kg: 80, measuredAt: DateTime(2026, 11, 20));
      final file = File('${dir.path}/b.zip');
      await old.writeBackup(to: file, photoFolder: Directory('${dir.path}/p1'));
      final backup = await openBackup(file, currentSchemaVersion: old.schemaVersion);
      await old.close();

      final phone = openEncryptedDatabase(File('${dir.path}/new.db'), generateDatabaseKey());
      await phone.loadSettings(countryCode: 'US');
      await phone.restoreBackup(backup, photoFolder: Directory('${dir.path}/p2'), replace: true);
      expect((await phone.loadSettings()).onboardingDone, isFalse);
      expect((await phone.select(phone.weights).get()).single.kg, 80);
      await phone.close();
    });
  });
}
