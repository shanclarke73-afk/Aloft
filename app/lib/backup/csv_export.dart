import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';

import '../data/body_store.dart';
import '../data/database.dart';
import '../dose/dose_math.dart';

/// "Aloft export 2026-11-22.zip".
String csvExportFileName(DateTime now) =>
    'Aloft export ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.zip';

/// One line of a CSV file. A field with a comma, a quote or a line break is quoted, and a
/// field that a spreadsheet would run as a formula is made plain text first.
String csvLine(List<Object?> fields) => fields
    .map((field) {
      var text = field?.toString() ?? '';
      if (text.startsWith(RegExp(r'[=+\-@\t\r]')) && double.tryParse(text) == null) text = "'$text";
      return text.contains(RegExp('[",\n\r]')) ? '"${text.replaceAll('"', '""')}"' : text;
    })
    .join(',');

String _date(DateTime t) => '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
String _number(double? value, int decimals) => value == null ? '' : formatNumber(value, decimals);

Future<void> _zipText(String outPath, Map<String, String> files) {
  return Isolate.run(() {
    final zip = ZipFileEncoder()..create(outPath);
    try {
      for (final MapEntry(key: name, value: text) in files.entries) {
        zip.addArchiveFile(ArchiveFile.string(name, text));
      }
    } finally {
      zip.closeSync();
    }
  });
}

extension CsvExport on AloftDatabase {
  /// Everything logged as spreadsheet files, oldest first: doses.csv, weights.csv,
  /// side_effects.csv and notes.csv (SPEC 6.11). Photos and settings are not included; a
  /// backup file is the way to move those.
  Future<Map<String, String>> csvFiles({required WeightUnit weightUnit}) async {
    final names = {for (final m in await select(medications).get()) m.id: m.name};
    final strengths = {for (final s in await select(supplies).get()) s.id: s.concentrationMgPerMl};

    final doseRows = await (select(doses)..orderBy([(d) => OrderingTerm.asc(d.takenAt)])).get();
    final dosesCsv = [
      csvLine([
        'Date', 'Time', 'Medication', 'Status', 'Amount entered', 'Unit', 'mg', 'mL', 'Vial strength (mg/mL)',
        'Other ingredients', 'Injection site', 'Pain (0-10)', 'Note', //
      ]),
      for (final d in doseRows)
        csvLine([
          _date(d.takenAt),
          _time(d.takenAt),
          names[d.medicationId],
          d.skipped ? 'skipped' : 'taken',
          d.skipped ? '' : _number(d.amountEntered, 3),
          d.skipped ? '' : doseUnitLabel(d.unitEntered, amount: d.amountEntered),
          d.skipped ? '' : _number(d.drugMg, 3),
          d.skipped ? '' : _number(d.volumeMl, 3),
          _number(strengths[d.supplyId], 3),
          [for (final e in d.additiveAmounts.entries) '${e.key} ${e.value}'].join('; '),
          d.injectionSite?.label,
          d.skipped || d.injectionSite == null ? '' : d.injectionPain,
          d.notes,
        ]),
    ];

    final weightRows = await (select(weights)..orderBy([(w) => OrderingTerm.asc(w.measuredAt)])).get();
    final weightsCsv = [
      csvLine(['Date', 'Time', 'Weight (${weightUnit.name})', 'Note']),
      for (final w in weightRows)
        csvLine([_date(w.measuredAt), _time(w.measuredAt), fromKg(w.kg, weightUnit).toStringAsFixed(1), w.notes]),
    ];

    final effectRows = await (select(sideEffects)..orderBy([(e) => OrderingTerm.asc(e.occurredAt)])).get();
    final effectsCsv = [
      csvLine(['Date', 'Time', 'Side effect', 'Strength (1-10)', 'Likely from', 'Note']),
      for (final e in effectRows)
        csvLine([
          _date(e.occurredAt),
          _time(e.occurredAt),
          sideEffectName(e),
          e.severity,
          names[e.medicationId],
          e.notes,
        ]),
    ];

    final noteRows = await (select(dayNotes)..orderBy([(n) => OrderingTerm.asc(n.noteDate)])).get();
    final notesCsv = [
      csvLine(['Date', 'Note']),
      for (final n in noteRows) csvLine([_date(n.noteDate), n.body]),
    ];

    // Windows line ends and a byte-order mark, so Excel opens accents and symbols correctly.
    String file(List<String> lines) => '﻿${lines.join('\r\n')}\r\n';
    return {
      'doses.csv': file(dosesCsv),
      'weights.csv': file(weightsCsv),
      'side_effects.csv': file(effectsCsv),
      'notes.csv': file(notesCsv),
    };
  }

  /// Writes the CSV files into one zip at [to]. The zip is not locked: anyone who has the
  /// file can read it.
  Future<void> writeCsvExport({required File to, required WeightUnit weightUnit}) async {
    final files = await csvFiles(weightUnit: weightUnit);
    await _zipText(to.path, files);
  }
}
