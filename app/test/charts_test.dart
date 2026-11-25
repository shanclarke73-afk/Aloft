import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/features/charts/charts_screen.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medication_store_test.dart' show tirzepatideVial;

const zepbound = NewMedication(
  name: 'Zepbound®',
  activeIngredient: 'tirzepatide',
  isGlp1: true,
  form: MedicationForm.brandPen,
  scheduleType: ScheduleType.weekly,
  scheduleDays: [4],
  timeOfDayMinutes: 20 * 60,
  doseAmount: 2.5,
  doseUnit: DoseUnit.mg,
);
const rybelsus = NewMedication(
  name: 'Rybelsus®',
  activeIngredient: 'semaglutide',
  isGlp1: true,
  form: MedicationForm.oral,
  scheduleType: ScheduleType.daily,
  pillStrengthMg: 7,
  doseAmount: 1,
  doseUnit: DoseUnit.tablets,
);
const nad = NewMedication(
  name: 'NAD+',
  activeIngredient: 'nad',
  isGlp1: false,
  form: MedicationForm.compoundedVial,
  scheduleType: ScheduleType.asNeeded,
  concentrationMgPerMl: 100,
  doseAmount: 20,
  doseUnit: DoseUnit.units,
);

void main() {
  late Directory dir;
  late AloftDatabase db;
  late AppSettings settings;

  Future<void> open() async {
    dir = Directory.systemTemp.createTempSync('aloft_charts');
    db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
    settings = await db.loadSettings(countryCode: 'US');
    for (final m in [zepbound, tirzepatideVial, rybelsus, nad]) {
      await db.addMedication(m, now: DateTime(2026, 9, 1));
    }
    final [pen, vial, pill, addOn] = await db.watchMedications().first;
    Future<void> log(MedicationDetail d, double amount, DoseUnit unit, DateTime at, {bool skipped = false}) =>
        db.logDose(
          medication: d.medication,
          supply: d.supply!,
          amount: amount,
          unit: unit,
          takenAt: at,
          skipped: skipped,
        );
    await log(pen, 2.5, DoseUnit.mg, DateTime(2026, 11, 5, 20));
    await log(vial, 25, DoseUnit.units, DateTime(2026, 11, 12, 20));
    await log(vial, 25, DoseUnit.units, DateTime(2026, 11, 19, 20), skipped: true);
    await log(pill, 1, DoseUnit.tablets, DateTime(2026, 11, 19, 7));
    await log(addOn, 20, DoseUnit.units, DateTime(2026, 11, 19, 9));
  }

  test('one curve per injected ingredient: pen and vial together, pills and add-ons left out', () async {
    await open();
    final series = levelSeries(await db.watchHistory().first, await db.watchMedications().first);
    expect(series.single.ingredient, 'tirzepatide');
    expect([for (final d in series.single.doses) d.mg]..sort(), [2.5, 2.5], reason: 'the skipped dose adds nothing');
    expect(series.single.nextDue, isNotNull);
    final now = DateTime(2026, 11, 21, 9);
    expect(series.single.now(now), inExclusiveRange(0.5, 5));
    await db.close();
    dir.deleteSync(recursive: true);
  });

  testWidgets('Charts shows the level curve as an estimate, with its source, and the weight change', (tester) async {
    await tester.runAsync(() async {
      await open();
      await db.logWeight(kg: toKg(197, WeightUnit.lb), measuredAt: DateTime(2026, 9, 4, 7));
      await db.logWeight(kg: toKg(184.6, WeightUnit.lb), measuredAt: DateTime(2026, 11, 20, 7));
    });
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), initialSettingsProvider.overrideWithValue(settings)],
        child: MaterialApp(home: ChartsScreen(now: DateTime(2026, 11, 21, 9))),
      ),
    );
    for (var i = 0; i < 16; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    expect(find.text('Estimated tirzepatide level'), findsOneWidget);
    expect(find.textContaining('estimate only'), findsOneWidget);
    expect(find.text(levelDisclaimer), findsOneWidget);
    expect(find.textContaining('US prescribing information for tirzepatide'), findsOneWidget);
    expect(find.byType(LevelChart), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(WeightChart), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('−12.4 lb since Sep 4'), findsOneWidget);
    // Take the screen down and let its timers run out. The database isn't closed here: closing
    // while the chart screen's queries are winding down stalls the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
