import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:aloft/features/charts/charts_screen.dart';
import 'package:aloft/import/shotsy_file.dart';
import 'package:aloft/import/shotsy_import.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shotsy_file_test.dart' show sampleShotsy, shotsyHeader, shotsyRow;

void main() {
  late Directory dir;
  late AloftDatabase db;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aloft_shotsy');
    db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  const asPen = {'Tirzepatide': ShotsyMedicationChoice(form: MedicationForm.brandPen)};

  test('the sample comes in as a medication with its shots, weights, note and side effects', () async {
    final result = await db.importShotsy(parseShotsy(sampleShotsy)!, asPen);
    expect(
      (result.shots, result.weights, result.notes, result.effects, result.duplicates, result.medicationsAdded),
      (3, 3, 1, 3, 0, 1),
    );

    final d = (await db.watchMedications().first).single;
    expect(
      (d.medication.name, d.medication.activeIngredient, d.medication.isGlp1),
      ('Tirzepatide', 'tirzepatide', true),
    );
    expect((d.medication.form, d.medication.startDate), (MedicationForm.brandPen, DateTime(2025, 1, 6, 19)));
    // Schedule from the most recent shot: Monday at 8:40 PM.
    expect((d.medication.scheduleType, d.medication.timeOfDayMinutes), (ScheduleType.weekly, 20 * 60 + 40));
    expect(d.medication.scheduleDays, [DateTime.monday]);
    // The latest dose is the usual dose; the earlier one is kept as history.
    expect((d.usualDose!.prescribedDose, d.usualDose!.unit), (5, DoseUnit.mg));
    final history = await db.select(db.prescriptions).get();
    expect(
      [for (final p in history) (p.prescribedDose, p.endDate)],
      [(2.5, DateTime(2025, 1, 20, 20, 40)), (5.0, null)],
    );

    final doses = (await db.watchHistory().first).map((e) => e.dose).toList();
    expect([for (final x in doses) x.drugMg], [5, 2.5, 2.5]);
    expect((doses.last.injectionSite, doses.last.takenAt), (InjectionSite.armRight, DateTime(2025, 1, 6, 19)));
    expect((doses[1].injectionPain, doses[0].notes), (2, 'stung, a bit'));

    final weights = await db.watchWeights().first;
    expect(fromKg(weights.last.kg, WeightUnit.lb), closeTo(210, 1e-9));
    expect(weights.last.measuredAt, DateTime(2025, 1, 6, 12));
    expect((await db.watchDayNotes().first).single.body, 'felt great today');
    expect((await db.watchSideEffects().first).length, 3);

    // The level chart fills in from the imported shots.
    expect(levelSeries(await db.watchHistory().first, await db.watchMedications().first).single.doses.length, 3);
  });

  test('importing the same file twice adds nothing', () async {
    await db.importShotsy(parseShotsy(sampleShotsy)!, asPen);
    final again = await db.importShotsy(parseShotsy(sampleShotsy)!, asPen);
    expect((again.shots, again.weights, again.notes, again.effects, again.medicationsAdded), (0, 0, 0, 0, 0));
    expect(again.duplicates, 10);
    expect((await db.watchHistory().first).length, 3);
    expect((await db.select(db.medications).get()).length, 1);
  });

  test('a compounded vial with a strength also gets units and mL; an unknown site is kept in the note', () async {
    final file = parseShotsy(
      [shotsyHeader, shotsyRow('2025-03-02', shot: 'Tirzepatide 5 mg', time: '09:00', site: 'Left Buttock')].join('\n'),
    )!;
    await db.importShotsy(file, const {
      'Tirzepatide': ShotsyMedicationChoice(form: MedicationForm.compoundedVial, concentrationMgPerMl: 10),
    });
    final dose = (await db.watchHistory().first).single.dose;
    expect(
      (dose.volumeMl, dose.syringeType, dose.injectionSite, dose.notes),
      (0.5, 'U-100', null, 'Site: Left Buttock'),
    );
    final d = (await db.watchMedications().first).single;
    expect((d.medication.form, d.supply!.concentrationMgPerMl), (MedicationForm.compoundedVial, 10));
  });

  test('shots join a medication already in Aloft with the same name, and its dose is left alone', () async {
    await db.addMedication(
      const NewMedication(
        name: 'tirzepatide',
        activeIngredient: 'tirzepatide',
        isGlp1: true,
        form: MedicationForm.compoundedVial,
        scheduleType: ScheduleType.weekly,
        scheduleDays: [4],
        concentrationMgPerMl: 10,
        doseAmount: 25,
        doseUnit: DoseUnit.units,
      ),
    );
    final result = await db.importShotsy(parseShotsy(sampleShotsy)!, const {});
    expect((result.medicationsAdded, result.shots), (0, 3));
    final d = (await db.watchMedications().first).single;
    expect((d.usualDose!.prescribedDose, d.usualDose!.unit), (25, DoseUnit.units));
    expect((await db.watchHistory().first).first.dose.volumeMl, 0.5);
  });

  test('names are matched to their ingredient', () {
    expect(ingredientFor('Compounded Tirzepatide').ingredient, 'tirzepatide');
    expect(ingredientFor('Zepbound').ingredient, 'tirzepatide');
    expect(ingredientFor('Ozempic').ingredient, 'semaglutide');
    expect(ingredientFor('Mystery').ingredient, 'other');
  });
}
