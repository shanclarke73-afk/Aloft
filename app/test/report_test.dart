import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:aloft/report/report_data.dart';
import 'package:aloft/report/report_pdf.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'medication_store_test.dart' show tirzepatideVial;

void main() {
  late Directory dir;
  late AloftDatabase db;
  late AppSettings settings;
  setUp(() async {
    dir = Directory.systemTemp.createTempSync('aloft_report');
    db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
    await db.loadSettings(countryCode: 'US');
    settings = await db.saveSettings(const AppSettingsTableCompanion(heightCm: Value(167.64)));
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  /// Four weeks at 25 units, one skipped, then two at 50 units; weights, side effects, a note.
  Future<void> fill() async {
    await db.addMedication(tirzepatideVial, now: DateTime(2026, 9, 3));
    final med = (await db.watchMedications().first).single;
    Future<void> shot(DateTime at, double units, {InjectionSite? site, String? notes}) => db.logDose(
      medication: med.medication,
      supply: med.supply!,
      amount: units,
      unit: DoseUnit.units,
      takenAt: at,
      site: site,
      notes: notes,
    );
    await shot(DateTime(2026, 9, 3, 20), 25, site: InjectionSite.abdomenLowerLeft, notes: 'First one');
    await shot(DateTime(2026, 9, 10, 20), 25, site: InjectionSite.abdomenLowerRight);
    await db.logDose(
      medication: med.medication,
      supply: med.supply!,
      amount: 25,
      unit: DoseUnit.units,
      takenAt: DateTime(2026, 9, 17, 20),
      skipped: true,
      notes: 'Travelling',
    );
    await shot(DateTime(2026, 9, 24, 20), 25, site: InjectionSite.thighLeft);
    await shot(DateTime(2026, 10, 1, 20, 15), 50, site: InjectionSite.thighRight, notes: 'Dose changed by Dr. Lee');
    await shot(DateTime(2026, 10, 8, 20), 50);
    for (final (day, lb) in [
      (DateTime(2026, 9, 3, 7), 200.0),
      (DateTime(2026, 9, 17, 7), 196.5),
      (DateTime(2026, 10, 8, 7), 190.0),
    ]) {
      await db.logWeight(kg: toKg(lb, WeightUnit.lb), measuredAt: day);
    }
    await db.logSideEffects(
      severities: {SideEffectType.nausea: 4},
      occurredAt: DateTime(2026, 9, 4, 9),
      medicationId: med.medication.id,
    );
    await db.logSideEffects(
      severities: {SideEffectType.nausea: 6, SideEffectType.fatigue: 3},
      occurredAt: DateTime(2026, 10, 2, 9),
      medicationId: med.medication.id,
    );
    await db.logSideEffects(severities: {SideEffectType.headache: 2}, occurredAt: DateTime(2026, 10, 5, 9));
    await db.addDayNote(body: 'Appetite much lower this week', day: DateTime(2026, 9, 12));
  }

  test('nothing logged makes an empty report', () async {
    final data = await db.reportData(to: DateTime(2026, 10, 10), settings: settings);
    expect(data.isEmpty, isTrue);
    expect((data.treatmentDays, data.weightChange, data.weightPerWeek, data.bmi), (null, null, null, null));
  });

  test('the report works out its numbers from what was logged', () async {
    await fill();
    final data = await db.reportData(to: DateTime(2026, 10, 10), settings: settings, now: DateTime(2026, 10, 10, 9));

    expect(data.medications.single.name, tirzepatideVial.name);
    expect(data.medications.single.detail, contains('10 mg/mL'));
    expect((data.dosesTaken, data.dosesSkipped), (5, 1));
    expect(data.firstDose, DateTime(2026, 9, 3, 20));
    expect(data.treatmentDays, 38);

    // Two steps; the skipped dose stays inside the first and doesn't count as a dose.
    expect(data.steps.map((s) => (s.dose, s.doses.length)), [('25 units = 2.5 mg', 4), ('50 units = 5 mg', 2)]);
    final skipped = data.steps.first.doses[2];
    expect((skipped.skipped, skipped.dose, skipped.note), (true, 'Skipped', 'Travelling'));
    expect(data.steps.first.doses.first.site, 'Abdomen, lower left');

    expect(data.weights.map((w) => w.value.toStringAsFixed(1)), ['200.0', '196.5', '190.0']);
    expect(data.weightChange, '−10.0 lb (−5.0%)');
    expect(data.weightPerWeek, '−2.0 lb per week');
    expect(data.bmi, '30.7');

    expect(data.effects.map((e) => (e.medication, e.name, e.count, e.average, e.strongest)), [
      ('Not linked to a medication', 'Headache', 1, 2.0, 2),
      (tirzepatideVial.name, 'Nausea', 2, 5.0, 6),
      (tirzepatideVial.name, 'Fatigue', 1, 3.0, 3),
    ]);
    expect(data.notes.single, (day: DateTime(2026, 9, 12), body: 'Appetite much lower this week'));
  });

  test('a date range keeps only what falls inside it, both days included', () async {
    await fill();
    final data = await db.reportData(from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 8), settings: settings);
    expect(data.steps.single.doses.length, 2);
    expect(data.weights.single.value.toStringAsFixed(1), '190.0');
    expect(data.weightChange, isNull, reason: 'one weight is not a change');
    expect(data.effects.map((e) => e.name), unorderedEquals(['Headache', 'Nausea', 'Fatigue']));
    expect(data.notes, isEmpty);
    expect(data.treatmentDays, 8);
  });

  test('the PDF is made in Letter and A4, and an empty one still has a page', () async {
    final font = pw.Font.ttf(File('assets/fonts/Inter.ttf').readAsBytesSync().buffer.asByteData());
    await fill();
    final data = await db.reportData(to: DateTime(2026, 10, 10), settings: settings, now: DateTime(2026, 10, 10, 9));
    for (final format in [PdfPageFormat.letter, PdfPageFormat.a4]) {
      final bytes = await buildReportPdf(data, font: font, bold: font, format: format);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(5000));
      final out = Platform.environment['ALOFT_REPORT_OUT'];
      if (out != null && format == PdfPageFormat.letter) File(out).writeAsBytesSync(bytes);
    }
    final empty = await db.reportData(from: DateTime(2020), to: DateTime(2020, 2), settings: settings);
    expect(String.fromCharCodes((await buildReportPdf(empty, font: font, bold: font)).take(5)), '%PDF-');
    expect(reportFileName(DateTime(2026, 3, 4)), 'Aloft report 2026-03-04.pdf');
  });
}
