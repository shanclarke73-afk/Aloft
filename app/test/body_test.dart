import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/features/body/log_side_effect_screen.dart';
import 'package:aloft/features/body/log_weight_screen.dart';
import 'package:aloft/features/history/history_screen.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import 'medication_store_test.dart' show tirzepatideVial;

void main() {
  group('weight units', () {
    test('pounds and kilograms convert both ways', () {
      expect(toKg(184.6, WeightUnit.lb), closeTo(83.733, 0.001));
      expect(fromKg(toKg(184.6, WeightUnit.lb), WeightUnit.lb), closeTo(184.6, 1e-9));
      expect(toKg(80, WeightUnit.kg), 80);
      expect(formatWeight(toKg(184.6, WeightUnit.lb), WeightUnit.lb), '184.6 lb');
      expect(formatWeight(80, WeightUnit.kg), '80.0 kg');
    });

    test('change is signed, and tiny differences read as no change', () {
      final start = toKg(197, WeightUnit.lb), now = toKg(184.6, WeightUnit.lb);
      expect(formatWeightChange(start, now, WeightUnit.lb), '−12.4 lb');
      expect(formatWeightChange(now, start, WeightUnit.lb), '+12.4 lb');
      expect(formatWeightChange(80, 80.01, WeightUnit.kg), 'no change');
    });

    test('strength words follow the 1 to 10 scale', () {
      expect([1, 3, 4, 6, 7, 10].map(severityWord), ['mild', 'mild', 'moderate', 'moderate', 'strong', 'strong']);
    });
  });

  group('saving', () {
    late Directory dir;
    late AloftDatabase db;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aloft_body');
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('weights are listed newest first and can be edited, deleted and restored', () async {
      final first = await db.logWeight(kg: 89.4, measuredAt: DateTime(2026, 9, 4, 7), notes: ' start ');
      await db.logWeight(kg: 83.7, measuredAt: DateTime(2026, 11, 20, 7));
      var all = await db.watchWeights().first;
      expect([for (final w in all) w.kg], [83.7, 89.4]);
      expect((first.notes, first.source), ('start', WeightSource.manual));

      final latest = all.first;
      await db.updateWeight(first, kg: 89.0, measuredAt: first.measuredAt);
      await db.deleteWeight(latest);
      all = await db.watchWeights().first;
      expect((all.single.kg, all.single.notes), (89.0, null));
      await db.restoreWeight(latest);
      expect((await db.watchWeights().first).first.kg, 83.7);
    });

    test('several side effects are saved together, each with its own strength', () async {
      await db.addMedication(tirzepatideVial);
      final med = (await db.watchMedications().first).single.medication;
      await db.logSideEffects(
        severities: {SideEffectType.nausea: 2, SideEffectType.custom: 6},
        customName: ' Dizzy ',
        occurredAt: DateTime(2026, 11, 21, 9, 30),
        medicationId: med.id,
        notes: 'after breakfast',
      );
      final effects = await db.watchSideEffects().first;
      expect(effects.length, 2);
      final byName = {for (final e in effects) sideEffectName(e): e};
      expect(byName.keys, containsAll(['Nausea', 'Dizzy']));
      expect((byName['Nausea']!.severity, byName['Dizzy']!.severity), (2, 6));
      expect(effects.every((e) => e.medicationId == med.id && e.notes == 'after breakfast'), isTrue);

      await db.deleteSideEffect(byName['Nausea']!);
      expect((await db.watchSideEffects().first).length, 1);
      await db.restoreSideEffect(byName['Nausea']!);
      expect((await db.watchSideEffects().first).length, 2);
    });

    test('a version 3 database gains the weight and side-effect tables', () async {
      await db.loadSettings(countryCode: 'US');
      await db.addMedication(tirzepatideVial);
      await db.close();
      final key = generateDatabaseKey();
      final file = File('${dir.path}/v3.db');
      db = openEncryptedDatabase(file, key);
      await db.loadSettings(countryCode: 'US');
      await db.close();
      final raw = sqlite3.open(file.path);
      applyDatabaseKey(raw, key);
      raw.execute('DROP TABLE weights; DROP TABLE side_effects; PRAGMA user_version = 3;');
      raw.close();
      db = openEncryptedDatabase(file, key);
      await db.logWeight(kg: 80, measuredAt: DateTime(2026, 11, 21));
      expect((await db.watchWeights().first).single.kg, 80);
      expect(await db.watchSideEffects().first, isEmpty);
    });
  });

  // In these tests, read the tables directly: a second watch() on a query the screen is already
  // watching answers on the test's fake clock and never arrives.
  group('screens', () {
    late AloftDatabase db;
    late AppSettings settings;

    Future<void> open(WidgetTester tester) async {
      final dir = Directory.systemTemp.createTempSync('aloft_body_ui');
      addTearDown(() => dir.deleteSync(recursive: true));
      await tester.runAsync(() async {
        db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
        settings = await db.loadSettings(countryCode: 'US');
      });
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 16; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<void> show(WidgetTester tester, Widget screen) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db), initialSettingsProvider.overrideWithValue(settings)],
          child: MaterialApp(home: screen),
        ),
      );
      await settle(tester);
    }

    testWidgets('logging a weight shows the change, and switching to kg keeps the same weight', (tester) async {
      await open(tester);
      await tester.runAsync(() async {
        await db.logWeight(kg: toKg(197, WeightUnit.lb), measuredAt: DateTime(2026, 9, 4, 7));
        await db.logWeight(kg: toKg(185.4, WeightUnit.lb), measuredAt: DateTime(2026, 11, 13, 7));
      });
      await show(tester, const LogWeightScreen());
      await tester.enterText(find.byKey(const Key('weight')), '184.6');
      await tester.pump();
      expect(find.text('−0.8 lb since Nov 13'), findsOneWidget);
      expect(find.text('−12.4 lb since you started'), findsOneWidget);

      await tester.tap(find.text('kg'));
      await tester.pump();
      expect(find.text('83.7'), findsOneWidget);
      expect(find.text('−0.4 kg since Nov 13'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('save')));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      late Weight saved;
      await tester.runAsync(() async => saved = (await db.select(db.weights).get()).last);
      expect(saved.kg, closeTo(83.7, 1e-9));
      await tester.runAsync(db.close);
    });

    testWidgets('a weight that is not believable is not saved', (tester) async {
      await open(tester);
      await show(tester, const LogWeightScreen());
      await tester.enterText(find.byKey(const Key('weight')), '5');
      await tester.tap(find.byKey(const Key('save')));
      await tester.pump();
      expect(find.text('Enter your weight.'), findsOneWidget);
      await tester.runAsync(() async => expect(await db.select(db.weights).get(), isEmpty));
      await tester.runAsync(db.close);
    });

    testWidgets('side effects: pick, set a strength, save; advice is only to contact the prescriber', (tester) async {
      await open(tester);
      await show(tester, const LogSideEffectScreen());
      final save = find.byKey(const Key('save'));
      await tester.scrollUntilVisible(save, 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(save);
      await tester.pump();
      expect(find.text('Pick at least one.'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Nausea'), -200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Nausea'));
      await tester.pump();
      expect(find.text('Nausea · mild (3 of 10)'), findsOneWidget);
      expect(find.text('If a side effect is severe or worrying, contact your prescriber.'), findsOneWidget);

      await tester.scrollUntilVisible(save, 200, scrollable: find.byType(Scrollable).first);
      await tester.runAsync(() async {
        await tester.tap(save);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      late SideEffect saved;
      await tester.runAsync(() async => saved = (await db.select(db.sideEffects).get()).single);
      expect((saved.type, saved.severity, saved.medicationId), (SideEffectType.nausea, 3, null));
      await tester.runAsync(db.close);
    });

    testWidgets('History mixes shots, weights and side effects and can be filtered', (tester) async {
      await open(tester);
      await tester.runAsync(() async {
        await db.logWeight(kg: toKg(184.6, WeightUnit.lb), measuredAt: DateTime(2026, 11, 20, 7, 10));
        await db.logSideEffects(severities: {SideEffectType.nausea: 2}, occurredAt: DateTime(2026, 11, 18, 21, 30));
      });
      await show(tester, const HistoryScreen());
      expect(find.text('Weight · 184.6 lb'), findsOneWidget);
      expect(find.text('Nausea · mild (2 of 10)'), findsOneWidget);
      expect(find.text('Fri, Nov 20'), findsOneWidget);

      await tester.tap(find.text('Effects'));
      await tester.pumpAndSettle();
      expect(find.text('Weight · 184.6 lb'), findsNothing);
      expect(find.text('Nausea · mild (2 of 10)'), findsOneWidget);

      await tester.tap(find.text('Shots'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing of this kind yet.'), findsOneWidget);
      await tester.runAsync(db.close);
    });
  });
}
