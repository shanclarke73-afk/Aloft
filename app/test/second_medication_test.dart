import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/features/medications/medication_limit.dart';
import 'package:aloft/features/medications/my_medications_screen.dart';
import 'package:aloft/import/shotsy_file.dart';
import 'package:aloft/import/shotsy_import.dart';
import 'package:aloft/pro/pro.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pro_test.dart' show FakeStore;
import 'shotsy_file_test.dart' show shotsyHeader, shotsyRow;
import 'support/wait.dart';

NewMedication pen(String name) => NewMedication(
  name: name,
  activeIngredient: 'tirzepatide',
  isGlp1: true,
  form: MedicationForm.brandPen,
  scheduleType: ScheduleType.weekly,
  scheduleDays: const [1],
  doseAmount: 5,
  doseUnit: DoseUnit.mg,
);

void main() {
  late Directory dir;
  late AloftDatabase db;

  Future<void> open(WidgetTester tester, {List<String> active = const [], List<String> paused = const []}) async {
    dir = Directory.systemTemp.createTempSync('aloft_second');
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
      for (final name in [...active, ...paused]) {
        await db.addMedication(pen(name));
      }
      for (final m in await db.select(db.medications).get()) {
        if (paused.contains(m.name)) await db.setMedicationStatus(m, MedicationStatus.paused);
      }
    });
  }

  Future<void> show(WidgetTester tester, {ProStore? store}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          if (store != null) proStoreProvider.overrideWithValue(store),
        ],
        child: const MaterialApp(home: MyMedicationsScreen()),
      ),
    );
    // The medications arrive from the database a moment after the screen does.
    await pumpUntilFound(tester, find.byType(Card));
    await tester.pumpAndSettle();
  }

  /// Taps something that reads the database first, then waits for [then] to appear.
  Future<void> tapAndWait(WidgetTester tester, Finder target, Finder then) async {
    await tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(target);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await pumpUntilFound(tester, then);
    await tester.pumpAndSettle();
  }

  Future<Map<String, MedicationStatus>> statuses(WidgetTester tester) async {
    late Map<String, MedicationStatus> found;
    await tester.runAsync(
      () async => found = {for (final m in await db.select(db.medications).get()) m.name: m.status},
    );
    return found;
  }

  test('the reason names what is being tracked alongside what', () {
    expect(joinNames(['Zepbound']), 'Zepbound');
    expect(joinNames(['Zepbound', 'NAD+']), 'Zepbound and NAD+');
    expect(joinNames(['Zepbound', 'NAD+', 'B12']), 'Zepbound, NAD+ and B12');
    expect(
      secondMedicationReason(['Zepbound']),
      startsWith(
        'Track another medication alongside Zepbound with Pro. One medication at a time is free: pause Zepbound',
      ),
    );
    expect(
      secondMedicationReason(['Zepbound'], resuming: 'NAD+'),
      startsWith('Track NAD+ alongside Zepbound with Pro.'),
    );
  });

  testWidgets('without Pro, adding a second medication next to an active one shows the Pro screen', (tester) async {
    await open(tester, active: ['Zepbound']);
    await show(tester);
    await tapAndWait(tester, find.text('Add another medication'), find.byKey(const Key('pro-reason')));
    expect(find.textContaining('Track another medication alongside Zepbound with Pro.'), findsOneWidget);
    expect(find.text('More than one medication'), findsOneWidget);
    // Closing without buying goes back; the "what are you taking" sheet never opens.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('What are you taking?'), findsNothing);
    await tester.runAsync(db.close);
  });

  testWidgets('with Pro, a second medication can be added', (tester) async {
    await open(tester, active: ['Zepbound']);
    await show(tester, store: FakeStore(alreadyPro: true));
    await tapAndWait(tester, find.text('Add another medication'), find.text('What are you taking?'));
    expect(find.text('What are you taking?'), findsOneWidget);
    expect(find.byKey(const Key('pro-reason')), findsNothing);
    await tester.runAsync(db.close);
  });

  testWidgets('without Pro, one medication at a time is free: with the other paused, a new one can be added', (
    tester,
  ) async {
    await open(tester, paused: ['Zepbound']);
    await show(tester);
    await tapAndWait(tester, find.text('Add another medication'), find.text('What are you taking?'));
    expect(find.text('What are you taking?'), findsOneWidget);
    await tester.runAsync(db.close);
  });

  testWidgets('without Pro, resuming next to an active medication shows the Pro screen and leaves it paused', (
    tester,
  ) async {
    await open(tester, active: ['Zepbound'], paused: ['Mounjaro']);
    await show(tester);
    await tapAndWait(tester, find.byKey(const Key('pause-Mounjaro')), find.byKey(const Key('pro-reason')));
    expect(find.textContaining('Track Mounjaro alongside Zepbound with Pro.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(await statuses(tester), {'Zepbound': MedicationStatus.active, 'Mounjaro': MedicationStatus.paused});

    await tester.runAsync(db.close);
  });

  testWidgets('without Pro, a paused medication can be resumed when nothing else is active', (tester) async {
    await open(tester, paused: ['Zepbound', 'Mounjaro']);
    await show(tester);
    await tapAndWait(tester, find.byKey(const Key('pause-Mounjaro')), find.text('ACTIVE'));
    expect(find.byKey(const Key('pro-reason')), findsNothing);
    expect(await statuses(tester), {'Zepbound': MedicationStatus.paused, 'Mounjaro': MedicationStatus.active});
    await tester.runAsync(db.close);
  });

  group('importing without Pro', () {
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aloft_second_import');
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    // Someone who moved from Mounjaro to Zepbound.
    final twoMedications = parseShotsy(
      [
        shotsyHeader,
        shotsyRow('2025-01-06', shot: 'Mounjaro 2.5 mg', time: '19:00'),
        shotsyRow('2025-01-13', shot: 'Mounjaro 2.5 mg', time: '19:00'),
        shotsyRow('2025-01-20', shot: 'Zepbound 5 mg', time: '19:00'),
        shotsyRow('2025-01-27', shot: 'Zepbound 5 mg', time: '19:00'),
      ].join('\n'),
    )!;
    Future<Map<String, MedicationStatus>> statuses() async => {
      for (final m in await db.select(db.medications).get()) m.name: m.status,
    };

    test('the medication with the latest shot is active; the earlier one arrives paused with its history', () async {
      final result = await db.importShotsy(twoMedications, const {}, oneActiveOnly: true);
      expect((result.medicationsAdded, result.shots), (2, 4));
      expect(result.paused, ['Mounjaro']);
      expect(await statuses(), {'Mounjaro': MedicationStatus.paused, 'Zepbound': MedicationStatus.active});
      expect((await db.watchHistory().first).length, 4);
    });

    test('with one already active, every new medication arrives paused', () async {
      await db.addMedication(pen('Wegovy'));
      final result = await db.importShotsy(twoMedications, const {}, oneActiveOnly: true);
      expect(result.paused, ['Zepbound', 'Mounjaro']);
      expect(await statuses(), {
        'Wegovy': MedicationStatus.active,
        'Mounjaro': MedicationStatus.paused,
        'Zepbound': MedicationStatus.paused,
      });
    });

    test('with Pro, both come in active', () async {
      final result = await db.importShotsy(twoMedications, const {});
      expect(result.paused, isEmpty);
      expect(await statuses(), {'Mounjaro': MedicationStatus.active, 'Zepbound': MedicationStatus.active});
    });
  });
}
