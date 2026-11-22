import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_data.dart';

/// "Aloft report 2026-11-22.pdf".
String reportFileName(DateTime now) =>
    'Aloft report ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.pdf';

/// The line at the foot of every page (SPEC 6.11).
const reportFooter = 'Created with Aloft · personal tracking record, not medical advice.';

const _navy = PdfColor.fromInt(0xFF1E3557);
const _teal = PdfColor.fromInt(0xFF237A82);
const _muted = PdfColor.fromInt(0xFF5B6675);
const _rule = PdfColor.fromInt(0xFFD9DEE5);
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _day(DateTime t) => '${_months[t.month - 1]} ${t.day}, ${t.year}';
String _shortDay(DateTime t) => '${_months[t.month - 1]} ${t.day}';
String _time(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$hour:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
}

String _length(int days) {
  if (days < 14) return '$days ${days == 1 ? 'day' : 'days'}';
  final weeks = days ~/ 7;
  return '$weeks weeks';
}

/// Draws the report as real text (searchable, copyable, readable aloud). Sections with nothing
/// in them are left out. [font] and [bold] must cover whatever people type; Letter in the US,
/// A4 elsewhere, is the caller's choice through [format].
Future<Uint8List> buildReportPdf(
  ReportData data, {
  required pw.Font font,
  required pw.Font bold,
  PdfPageFormat format = PdfPageFormat.letter,
}) {
  final base = pw.TextStyle(font: font, fontFallback: [font], fontSize: 10, color: PdfColors.black, lineSpacing: 2);
  final strong = base.copyWith(font: bold, fontFallback: [font]);
  final small = base.copyWith(fontSize: 8.5, color: _muted);
  final heading = strong.copyWith(fontSize: 13, color: _navy);

  pw.Widget section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: heading),
        pw.SizedBox(height: 4),
        pw.Container(height: 1, color: _rule),
      ],
    ),
  );

  pw.Widget fact(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(label, style: base.copyWith(color: _muted)),
        ),
        pw.Expanded(child: pw.Text(value, style: base)),
      ],
    ),
  );

  pw.Widget cell(String text, {pw.TextStyle? style, pw.Alignment alignment = pw.Alignment.centerLeft}) => pw.Container(
    alignment: alignment,
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    child: pw.Text(text, style: style ?? base),
  );

  final period = data.from == null ? 'Everything to ${_day(data.to)}' : '${_day(data.from!)} to ${_day(data.to)}';
  final doc = pw.Document(title: 'Aloft report', author: 'Aloft', creator: 'Aloft', subject: period);

  final content = <pw.Widget>[
    pw.Text('Aloft report', style: strong.copyWith(fontSize: 22, color: _navy)),
    pw.SizedBox(height: 2),
    pw.Text(period, style: base.copyWith(fontSize: 11)),
    pw.Text('Created ${_day(data.createdAt)}', style: small),
  ];

  if (data.isEmpty) {
    content.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 24),
        child: pw.Text('Nothing was logged in this period.', style: base),
      ),
    );
  }

  // Summary.
  final summary = <pw.Widget>[
    if (data.treatmentDays case final days?)
      fact('Length of treatment', '${_length(days)} (first dose ${_day(data.firstDose!)})'),
    for (final m in data.medications) fact(m.name, m.detail),
    if (data.dosesTaken + data.dosesSkipped > 0)
      fact('Doses', '${data.dosesTaken} logged${data.dosesSkipped == 0 ? '' : ', ${data.dosesSkipped} skipped'}'),
    if (data.weights.isNotEmpty)
      fact(
        'Weight',
        data.weights.length == 1
            ? '${data.weights.single.value.toStringAsFixed(1)} ${data.weightUnit.name} on ${_day(data.weights.single.at)}'
            : '${data.weights.first.value.toStringAsFixed(1)} ${data.weightUnit.name} on ${_day(data.weights.first.at)}, '
                  '${data.weights.last.value.toStringAsFixed(1)} ${data.weightUnit.name} on ${_day(data.weights.last.at)}',
      ),
    if (data.weightChange case final change?) fact('Weight change', [change, ?data.weightPerWeek].join(' · ')),
    if (data.bmi case final bmi?) fact('BMI at latest weight', bmi),
  ];
  if (summary.isNotEmpty) content.addAll([section('Summary'), ...summary]);

  // Weight chart.
  if (data.weights.length >= 2) {
    final first = data.weights.first.at;
    double x(DateTime t) => t.difference(first).inHours / 24;
    final values = data.weights.map((w) => w.value);
    final low = values.reduce((a, b) => a < b ? a : b), high = values.reduce((a, b) => a > b ? a : b);
    final pad = ((high - low) * 0.15).clamp(1.0, 50.0);
    final bottom = (low - pad).floorToDouble(), top = (high + pad).ceilToDouble();
    final span = x(data.weights.last.at);
    final yStep = ((top - bottom) / 4).ceilToDouble().clamp(1.0, 1000.0);
    final yAxis = [for (var v = bottom; v <= top + 0.001; v += yStep) v];
    final xAxis = span <= 0 ? [0.0, 1.0] : [for (var i = 0; i <= 4; i++) span * i / 4];
    content.addAll([
      section('Weight (${data.weightUnit.name})'),
      pw.SizedBox(
        height: 170,
        child: pw.Chart(
          grid: pw.CartesianGrid(
            xAxis: pw.FixedAxis(
              xAxis,
              format: (v) => _shortDay(first.add(Duration(hours: (v * 24).round()))),
              textStyle: small,
              divisions: false,
            ),
            yAxis: pw.FixedAxis(
              yAxis,
              format: (v) => v.toStringAsFixed(0),
              textStyle: small,
              divisions: true,
              divisionsColor: _rule,
            ),
          ),
          datasets: [
            pw.LineDataSet(
              color: _teal,
              lineWidth: 1.5,
              drawPoints: data.weights.length <= 40,
              pointSize: 2,
              data: [for (final w in data.weights) pw.PointChartValue(x(w.at), w.value)],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text('${data.weights.length} weigh-ins, as logged.', style: small),
    ]);
  }

  // Dose history, grouped by step.
  if (data.steps.isNotEmpty) {
    content.add(section('Dose history'));
    for (final step in data.steps) {
      final taken = step.doses.where((d) => !d.skipped).length;
      final range = step.doses.length == 1
          ? _day(step.doses.first.at)
          : '${_day(step.doses.first.at)} to ${_day(step.doses.last.at)}';
      content.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
          child: pw.Text(
            '${step.medication} · ${step.dose} · $range'
            '${step.doses.length == 1 ? '' : ' · $taken ${taken == 1 ? 'dose' : 'doses'}'}',
            style: strong,
          ),
        ),
      );
      content.add(
        pw.Table(
          columnWidths: const {
            0: pw.FixedColumnWidth(110),
            1: pw.FixedColumnWidth(120),
            2: pw.FixedColumnWidth(110),
            3: pw.FlexColumnWidth(),
          },
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _rule, width: 0.5)),
          children: [
            pw.TableRow(
              children: [
                for (final title in ['Date', 'Dose', 'Site', 'Note']) cell(title, style: small),
              ],
            ),
            for (final d in step.doses)
              pw.TableRow(
                children: [
                  cell('${_day(d.at)}\n${_time(d.at)}'),
                  cell(d.dose, style: d.skipped ? base.copyWith(color: _muted) : base),
                  cell(d.site ?? ''),
                  cell(d.note ?? ''),
                ],
              ),
          ],
        ),
      );
    }
  }

  // Side effects.
  if (data.effects.isNotEmpty) {
    content.addAll([
      section('Side effects'),
      pw.Text('Strength is the person\'s own rating, 1 (barely) to 10 (severe).', style: small),
      pw.SizedBox(height: 4),
      pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(3),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.4),
          4: pw.FlexColumnWidth(1.4),
        },
        border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _rule, width: 0.5)),
        children: [
          pw.TableRow(
            children: [
              for (final title in ['Likely from', 'Side effect', 'Times', 'Average', 'Strongest'])
                cell(title, style: small),
            ],
          ),
          for (final e in data.effects)
            pw.TableRow(
              children: [
                cell(e.medication),
                cell(e.name),
                cell('${e.count}'),
                cell(e.average.toStringAsFixed(1)),
                cell('${e.strongest}'),
              ],
            ),
        ],
      ),
    ]);
  }

  // Notes.
  if (data.notes.isNotEmpty) {
    content.add(section('Notes'));
    for (final n in data.notes) {
      content.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 90,
                child: pw.Text(_day(n.day), style: base.copyWith(color: _muted)),
              ),
              pw.Expanded(child: pw.Text(n.body, style: base)),
            ],
          ),
        ),
      );
    }
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(reportFooter, style: small),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: small),
          ],
        ),
      ),
      build: (_) => content,
    ),
  );
  return doc.save();
}
