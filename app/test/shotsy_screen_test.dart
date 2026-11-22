import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/import/shotsy_file.dart';
import 'package:aloft/import/shotsy_import_screen.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shotsy_file_test.dart' show sampleShotsy;

void main() {
  testWidgets('the preview shows what will come in, asks pen or vial, and imports', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_shotsy_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: ShotsyImportScreen(file: parseShotsy(sampleShotsy)!)),
      ),
    );
    expect(find.text('From Jan 6, 2025 to Jan 21, 2025'), findsOneWidget);
    for (final line in ['3 shots', '3 weights', '1 note', '3 side effects']) {
      expect(find.text(line), findsOneWidget);
    }
    expect(find.textContaining('Calories, protein and water on 1 day are left out'), findsOneWidget);
    expect(find.text('Tirzepatide: what was it?'), findsOneWidget);
    expect(find.text('Strength in mg per mL (optional)'), findsNothing);

    await tester.tap(find.text('Compounded vial'));
    await tester.pump();
    expect(find.text('Strength in mg per mL (optional)'), findsOneWidget);

    final import = find.byKey(const Key('import'));
    await tester.scrollUntilVisible(import, 200, scrollable: find.byType(Scrollable).first);
    await tester.runAsync(() async {
      await tester.tap(import);
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    expect(find.textContaining('Imported 3 shots, 3 weights, 1 note and 3 side effects.'), findsOneWidget);
    expect(find.textContaining('Check the dose and schedule'), findsOneWidget);
    late Medication medication;
    await tester.runAsync(() async => medication = await db.select(db.medications).getSingle());
    expect(medication.form, MedicationForm.compoundedVial);
    await tester.runAsync(db.close);
  });

  testWidgets('a medication already in Aloft under another name is offered as the place for the shots', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_shotsy_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
      await db.addMedication(
        const NewMedication(
          name: 'Zepbound®',
          activeIngredient: 'tirzepatide',
          isGlp1: true,
          form: MedicationForm.brandPen,
          scheduleType: ScheduleType.weekly,
          scheduleDays: [4],
          doseAmount: 5,
          doseUnit: DoseUnit.mg,
        ),
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: ShotsyImportScreen(file: parseShotsy(sampleShotsy)!)),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    // Same ingredient, so it is already chosen, and the pen-or-vial question isn't asked.
    expect(find.text('Tirzepatide: where do these shots go?'), findsOneWidget);
    expect(find.text('Add to Zepbound®'), findsOneWidget);
    expect(find.text('Tirzepatide: what was it?'), findsNothing);

    // Choosing a new medication brings the question back.
    final asNew = find.byKey(const Key('target-Tirzepatide-new'));
    await tester.scrollUntilVisible(asNew, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(asNew);
    await tester.pump();
    expect(find.text('Tirzepatide: what was it?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('target-Tirzepatide-Zepbound®')));
    await tester.pump();

    final import = find.byKey(const Key('import'));
    await tester.scrollUntilVisible(import, 200, scrollable: find.byType(Scrollable).first);
    await tester.runAsync(() async {
      await tester.tap(import);
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    expect(find.textContaining('Imported 3 shots'), findsOneWidget);
    late List<Medication> medications;
    await tester.runAsync(() async => medications = await db.select(db.medications).get());
    expect(medications.single.name, 'Zepbound®');
    await tester.runAsync(db.close);
  });
}
