import 'dart:io';

import 'package:aloft/backup/csv_export.dart';
import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medication_store_test.dart' show tirzepatideVial;

void main() {
  test('a CSV line quotes what needs it and defuses spreadsheet formulas', () {
    expect(csvLine(['2026-11-22', 25, null, 'plain']), '2026-11-22,25,,plain');
    expect(csvLine(['a, b', 'she said "hi"', 'two\nlines']), '"a, b","she said ""hi""","two\nlines"');
    expect(
      csvLine(['=SUM(A1:A9)', '+1 walk', '@home', '-12.5', '-felt off']),
      "'=SUM(A1:A9),'+1 walk,'@home,-12.5,'-felt off",
    );
  });

  test('the file is named for the day', () {
    expect(csvExportFileName(DateTime(2026, 3, 4)), 'Aloft export 2026-03-04.zip');
  });

  group('export', () {
    late Directory dir;
    late AloftDatabase db;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aloft_csv');
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    List<String> lines(String file) {
      expect(file.startsWith('﻿'), isTrue, reason: 'so Excel reads symbols correctly');
      return file.substring(1).trimRight().split('\r\n');
    }

    test('nothing logged gives four files with only their headings', () async {
      final files = await db.csvFiles(weightUnit: WeightUnit.lb);
      expect(files.keys, ['doses.csv', 'weights.csv', 'side_effects.csv', 'notes.csv']);
      for (final file in files.values) {
        expect(lines(file).length, 1);
      }
    });

    test('doses, weights, side effects and notes come out oldest first, as they were logged', () async {
      await db.loadSettings(countryCode: 'US');
      await db.addMedication(tirzepatideVial);
      final med = (await db.watchMedications().first).single;
      await db.logDose(
        medication: med.medication,
        supply: med.supply!,
        amount: 25,
        unit: DoseUnit.units,
        takenAt: DateTime(2026, 11, 20, 20, 5),
        site: InjectionSite.abdomenLowerLeft,
        pain: 2,
        notes: 'Left side, no sting',
      );
      await db.logDose(
        medication: med.medication,
        supply: med.supply!,
        amount: 25,
        unit: DoseUnit.units,
        takenAt: DateTime(2026, 11, 13, 20),
      );
      await db.logWeight(kg: toKg(190, WeightUnit.lb), measuredAt: DateTime(2026, 11, 20, 7), notes: 'After, coffee');
      await db.logWeight(kg: toKg(200, WeightUnit.lb), measuredAt: DateTime(2026, 9, 4, 7));
      await db.logSideEffects(
        severities: {SideEffectType.nausea: 4},
        occurredAt: DateTime(2026, 11, 21, 9, 30),
        medicationId: med.medication.id,
      );
      await db.addDayNote(body: '=felt "fine"', day: DateTime(2026, 11, 21, 15));

      final files = await db.csvFiles(weightUnit: WeightUnit.lb);
      final doses = lines(files['doses.csv']!);
      expect(
        doses[0],
        'Date,Time,Medication,Status,Amount entered,Unit,mg,mL,Vial strength (mg/mL),Other ingredients,'
        'Injection site,Pain (0-10),Note',
      );
      expect(doses[1], startsWith('2026-11-13,20:00,${med.medication.name},taken,25,units,2.5,0.25,10,'));
      expect(doses[2], contains('"Abdomen, lower left",2,"Left side, no sting"'));
      expect(doses[2], contains('Cyanocobalamin (B12) 0.125 mg'));

      expect(lines(files['weights.csv']!), [
        'Date,Time,Weight (lb),Note',
        '2026-09-04,07:00,200.0,',
        '2026-11-20,07:00,190.0,"After, coffee"',
      ]);
      expect(lines(files['side_effects.csv']!), [
        'Date,Time,Side effect,Strength (1-10),Likely from,Note',
        '2026-11-21,09:30,Nausea,4,${med.medication.name},',
      ]);
      expect(lines(files['notes.csv']!), ['Date,Note', '2026-11-21,"\'=felt ""fine"""']);

      // In kg when that is the setting.
      expect(lines((await db.csvFiles(weightUnit: WeightUnit.kg))['weights.csv']!)[0], 'Date,Time,Weight (kg),Note');

      final zip = File('${dir.path}/${csvExportFileName(DateTime(2026, 11, 22))}');
      await db.writeCsvExport(to: zip, weightUnit: WeightUnit.lb);
      final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
      expect(archive.files.map((f) => f.name), ['doses.csv', 'weights.csv', 'side_effects.csv', 'notes.csv']);
    });
  });
}
