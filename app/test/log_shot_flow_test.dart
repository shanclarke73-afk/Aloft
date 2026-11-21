import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:aloft/features/log/log_dose_screen.dart';
import 'package:aloft/security/app_lock.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'app_lock_test.dart' show FakeAuthenticator;
import 'medication_store_test.dart' show tirzepatideVial;

void main() {
  late Directory dir;
  late AloftDatabase db;
  late AppSettings settings;

  Future<void> open(WidgetTester tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_flow');
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      settings = await db.loadSettings(countryCode: 'US');
    });
  }

  List<Override> overrides() => [
    databaseProvider.overrideWithValue(db),
    initialSettingsProvider.overrideWithValue(settings),
    appLockProvider.overrideWithValue(
      AppLock(authenticator: FakeAuthenticator(), enabled: false, lockAfter: LockAfter.immediately),
    ),
  ];

  testWidgets('Log shot shows the conversion and math, warns on a very different dose, and saves', (tester) async {
    await open(tester);
    late MedicationDetail detail;
    await tester.runAsync(() async {
      await db.addMedication(tirzepatideVial);
      detail = (await db.watchMedications().first).single;
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: LogDoseScreen(
            detail: detail,
            siteHistory: [(site: InjectionSite.abdomenLowerLeft, takenAt: DateTime(2026, 11, 13))],
          ),
        ),
      ),
    );

    // Pre-filled from the usual dose.
    expect(find.text('= 0.25 mL = 2.5 mg tirzepatide'), findsOneWidget);
    expect(find.text('+ 0.125 mg Cyanocobalamin (B12)'), findsOneWidget);
    expect(find.text('25 units ÷ 100 = 0.25 mL × 10 mg/mL'), findsOneWidget);
    expect(find.text('Same as your prescription'), findsOneWidget);
    expect(find.text('Abdomen, lower right'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('amount')), '50');
    await tester.pump();
    expect(find.text('= 0.5 mL = 5 mg tirzepatide'), findsOneWidget);
    expect(find.textContaining('different from your saved dose (25 units)'), findsOneWidget);

    // Switching to mg keeps the same dose.
    await tester.tap(find.text('mg'));
    await tester.pump();
    expect(find.text('= 50 units = 0.5 mL'), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('save')), 200, scrollable: find.byType(Scrollable).first);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('save')));
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    late Dose saved;
    await tester.runAsync(() async => saved = await db.select(db.doses).getSingle());
    expect((saved.amountEntered, saved.unitEntered, saved.volumeMl, saved.drugMg), (5, DoseUnit.mg, 0.5, 5));
    expect(saved.injectionSite, InjectionSite.abdomenLowerRight);
    await tester.runAsync(db.close);
  });
}
