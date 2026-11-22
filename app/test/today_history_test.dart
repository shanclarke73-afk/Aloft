import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:aloft/features/history/history_screen.dart';
import 'package:aloft/features/today/today_screen.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medication_store_test.dart' show tirzepatideVial;

void main() {
  late AloftDatabase db;
  late AppSettings settings;

  Future<void> open(WidgetTester tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_today');
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      settings = await db.loadSettings(countryCode: 'US');
      await db.addMedication(tirzepatideVial, now: DateTime(2026, 11, 2));
    });
  }

  /// Each database answer arrives in real time and is then handled on the next pump.
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

  Future<void> shot(WidgetTester tester, DateTime at) => tester.runAsync(() async {
    final d = (await db.watchMedications().first).single;
    await db.logDose(
      medication: d.medication,
      supply: d.supply!,
      amount: 25,
      unit: DoseUnit.units,
      takenAt: at,
      site: InjectionSite.abdomenLowerLeft,
    );
  });

  testWidgets('Today on shot day, then after logging', (tester) async {
    await open(tester);
    await shot(tester, DateTime(2026, 11, 12, 20, 10));
    await show(tester, TodayScreen(now: DateTime(2026, 11, 19, 7)));
    expect(find.text('Shot day'), findsOneWidget);
    expect(find.text('Today, 8:00 PM'), findsOneWidget);
    expect(find.text('Week 3'), findsOneWidget);
    expect(find.text('Usual dose: 25 units = 2.5 mg'), findsOneWidget);
    expect(find.text('7 doses left'), findsOneWidget);
    expect(find.text('Log shot'), findsOneWidget);

    await shot(tester, DateTime(2026, 11, 19, 7));
    await settle(tester);
    expect(find.text('Next shot'), findsOneWidget);
    expect(find.text('Thursday, 8:00 PM'), findsOneWidget);
    expect(find.text('in 7 days'), findsOneWidget);
    // Nothing is due: the bright button is gone, and logging early is a quiet outline button.
    expect(find.text('Log shot'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Log a shot early'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('6 doses left'), findsOneWidget);
    await tester.runAsync(db.close);
  });

  testWidgets('a late shot offers three ways to record it and never says what to do', (tester) async {
    await open(tester);
    await shot(tester, DateTime(2026, 11, 12, 20, 10));
    await show(tester, TodayScreen(now: DateTime(2026, 11, 21, 9)));
    expect(find.text('Not logged yet'), findsOneWidget);
    expect(find.text('Thursday\'s shot · 2 days ago'), findsOneWidget);
    expect(find.text('Taking it now'), findsOneWidget);
    expect(find.text('I took it, just didn\'t log it'), findsOneWidget);
    expect(find.textContaining('ask your prescriber'), findsOneWidget);
    expect(find.text('Log shot'), findsNothing);

    await tester.runAsync(() async {
      await tester.tap(find.text('Skipped this one'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
    expect(find.text('Next shot'), findsOneWidget);
    expect(find.text('Thursday, 8:00 PM'), findsOneWidget);
    expect(find.text('in 5 days'), findsOneWidget);
    late Dose skipped;
    await tester.runAsync(() async => skipped = (await db.watchHistory().first).first.dose);
    expect((skipped.skipped, skipped.takenAt), (true, DateTime(2026, 11, 19, 20)));
    await tester.runAsync(db.close);
  });

  testWidgets('History lists doses by day; a shot can be deleted and brought back with Undo', (tester) async {
    await open(tester);
    await shot(tester, DateTime(2026, 11, 12, 20, 10));
    await shot(tester, DateTime(2026, 11, 19, 20, 4));
    await show(tester, const HistoryScreen());
    expect(find.text('Thu, Nov 19'), findsOneWidget);
    expect(find.text('Thu, Nov 12'), findsOneWidget);
    expect(find.text('Shot · 25 units = 2.5 mg'), findsNWidgets(2));
    expect(find.text('Tirzepatide · Abdomen, lower left'), findsNWidgets(2));

    await tester.tap(find.text('8:04 PM'));
    await tester.pumpAndSettle();
    expect(find.text('Edit shot'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('delete')), 300, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const Key('delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('0.25 mL goes back to your vial'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('Delete shot'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
    expect(find.text('Thu, Nov 19'), findsNothing);
    expect(find.text('Shot deleted'), findsOneWidget);
    // The message leaves on its own after a few seconds instead of waiting to be dismissed.
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).persist, isFalse);

    await tester.runAsync(() async {
      await tester.tap(find.text('Undo'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
    expect(find.text('Thu, Nov 19'), findsOneWidget);
    await tester.runAsync(db.close);
  });
}
