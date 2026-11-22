import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/features/medications/medication_setup_screen.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('typing in a vial shows the conversion and supply, and saves it', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_setup');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: MedicationSetupScreen(form: MedicationForm.compoundedVial)),
      ),
    );
    final scroll = find.byType(Scrollable).first;
    final save = find.byKey(const Key('save'));

    // Saving with nothing filled in explains what's missing instead of saving.
    await tester.scrollUntilVisible(save, 300, scrollable: scroll);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Choose or type the medication.'), findsOneWidget);
    expect(find.text('Enter the strength in mg per mL from your label.'), findsOneWidget);
    expect(find.text('Enter your dose.'), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('medication')), -300, scrollable: scroll);
    await tester.tap(find.byKey(const Key('medication')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirzepatide').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('strength')), '10');
    await tester.enterText(find.byKey(const Key('vialSize')), '2');
    await tester.scrollUntilVisible(find.byKey(const Key('dose')), 200, scrollable: scroll);
    await tester.enterText(find.byKey(const Key('dose')), '25');
    await tester.pump();
    expect(find.text('= 0.25 mL = 2.5 mg tirzepatide'), findsOneWidget);

    await tester.scrollUntilVisible(save, 300, scrollable: scroll);
    expect(find.text('20 mg tirzepatide in this vial\nAbout 8 doses at 25 units'), findsOneWidget);
    // The picker still shows the choice after scrolling away and back.
    expect(find.text('Choose or type the medication.'), findsNothing);

    await tester.runAsync(() async {
      await tester.tap(save);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    late MedicationDetail saved;
    await tester.runAsync(() async => saved = (await db.watchMedications().first).single);
    expect(
      (saved.medication.name, saved.medication.activeIngredient, saved.medication.isGlp1),
      ('Tirzepatide', 'tirzepatide', true),
    );
    expect((saved.supply!.concentrationMgPerMl, saved.supply!.volumeMl), (10, 2));
    expect((saved.usualDose!.prescribedDose, saved.usualDose!.unit), (25, DoseUnit.units));
    expect(saved.medication.scheduleType, ScheduleType.weekly);
    await tester.runAsync(db.close);
  });

  testWidgets('an ingredient that is not in the list can be typed in', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_setup');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: MedicationSetupScreen(form: MedicationForm.compoundedVial)),
      ),
    );
    final scroll = find.byType(Scrollable).first;
    final save = find.byKey(const Key('save'));

    await tester.tap(find.byKey(const Key('medication')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirzepatide').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('strength')), '10');
    await tester.scrollUntilVisible(find.text('Add ingredient'), 200, scrollable: scroll);
    await tester.tap(find.text('Add ingredient'));
    await tester.pumpAndSettle();

    final name = find.widgetWithText(TextField, 'Type or choose');
    await tester.tap(name);
    await tester.pumpAndSettle();
    expect(find.text('Glycine'), findsOneWidget);
    await tester.enterText(name, 'Methylcobalamin');
    await tester.pumpAndSettle();
    // Nothing in the list matches, so the typed name is offered as its own choice.
    expect(find.text('Glycine'), findsNothing);
    await tester.tap(find.text('Use "Methylcobalamin"'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Per mL'), '1');

    await tester.scrollUntilVisible(find.byKey(const Key('dose')), 200, scrollable: scroll);
    await tester.enterText(find.byKey(const Key('dose')), '25');
    await tester.pump();
    await tester.scrollUntilVisible(save, 300, scrollable: scroll);
    await tester.runAsync(() async {
      await tester.tap(save);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    late MedicationDetail saved;
    await tester.runAsync(() async => saved = (await db.watchMedications().first).single);
    expect(
      saved.supply!.additives.single.toString(),
      const Additive(name: 'Methylcobalamin', amountPerMl: 1, unit: 'mg').toString(),
    );

    // On the next vial the typed name is in the list, ahead of the common ones.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: MedicationSetupScreen(form: MedicationForm.compoundedVial)),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Add ingredient'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Add ingredient'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextField, 'Type or choose'));
    await tester.pumpAndSettle();
    expect(find.text('Methylcobalamin'), findsOneWidget);
    expect(find.text('Glycine'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Methylcobalamin')).dy, lessThan(tester.getTopLeft(find.text('Glycine')).dy));
    await tester.runAsync(db.close);
  });
}
