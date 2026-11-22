import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../backup/backup_files.dart';
import '../../data/database.dart';
import '../../report/report_data.dart';
import '../../report/report_pdf.dart';
import '../../settings/settings.dart';
import '../../theme/aloft_theme.dart';
import '../../widgets/form_widgets.dart';

/// How far back the report goes.
enum ReportPeriod {
  threeMonths('Last 3 months', 3),
  sixMonths('Last 6 months', 6),
  year('Last 12 months', 12),
  all('Everything', null);

  const ReportPeriod(this.label, this.months);
  final String label;
  final int? months;

  /// The first day covered, counting back from [today]; null for everything.
  DateTime? from(DateTime today) => months == null ? null : DateTime(today.year, today.month - months!, today.day + 1);
}

/// The font the report is drawn in. Bundled, so the PDF is made on the phone with no download.
final reportFontProvider = FutureProvider<pw.Font>(
  (ref) async => pw.Font.ttf(await rootBundle.load('assets/fonts/Inter.ttf')),
);

/// More → Report for your provider (Pro): pick the period and paper, then save or send a PDF.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, this.now});
  final DateTime? now;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportPeriod _period = ReportPeriod.threeMonths;
  // Letter where people measure in inches, A4 everywhere else; either can be chosen.
  late bool _letter = ref.read(settingsProvider).lengthUnit == LengthUnit.inches;
  bool _busy = false;
  String? _message;
  bool _problem = false;

  Future<void> _make({required bool send}) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      _busy = true;
      _message = null;
      _problem = false;
    });
    final now = widget.now ?? DateTime.now();
    final folder = Directory.systemTemp.createTempSync('aloft_report');
    final file = File(p.join(folder.path, reportFileName(now)));
    try {
      final data = await ref
          .read(databaseProvider)
          .reportData(from: _period.from(now), to: now, settings: ref.read(settingsProvider), now: now);
      final font = await ref.read(reportFontProvider.future);
      final bytes = await buildReportPdf(
        data,
        font: font,
        bold: font,
        format: _letter ? PdfPageFormat.letter : PdfPageFormat.a4,
      );
      file.writeAsBytesSync(bytes);
      final files = ref.read(backupFilesProvider);
      final place = send ? null : await files.saveOnPhone(file);
      if (place == null) await files.share(file, origin: origin);
      if (place != null) {
        // Straight into the phone's PDF viewer, so the report can be looked over before it is sent.
        final opened = await files.openLastSaved();
        if (mounted) {
          setState(
            () => _message =
                'Saved to $place as ${p.basename(file.path)}.'
                '${opened ? '' : ' Open it from your Files app.'}',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = "The report couldn't be made. Check that your phone has free space.";
          _problem = true;
        });
      }
    } finally {
      // Don't leave a readable copy of someone's health data lying in temporary storage.
      try {
        folder.deleteSync(recursive: true);
      } catch (_) {}
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report for your provider',
          style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'A PDF of what you\'ve logged: your medication and doses, weight, side effects and notes. '
              'It is your own record to share; it isn\'t medical advice.',
              style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
            ),
            const FieldLabel('Period'),
            RadioGroup<ReportPeriod>(
              groupValue: _period,
              onChanged: (value) => setState(() => _period = value!),
              child: Column(
                children: [
                  for (final period in ReportPeriod.values)
                    RadioListTile<ReportPeriod>(
                      key: Key('period-${period.name}'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: period,
                      title: Text(period.label),
                    ),
                ],
              ),
            ),
            const FieldLabel('Paper size'),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: true, label: Text('Letter')),
                ButtonSegment(value: false, label: Text('A4')),
              ],
              selected: {_letter},
              onSelectionChanged: (s) => setState(() => _letter = s.single),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('report-save'),
              onPressed: _busy ? null : () => _make(send: false),
              child: Text(_busy ? 'Working…' : 'Save the report to this phone'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('report-send'),
              onPressed: _busy ? null : () => _make(send: true),
              child: const Text('Send the report somewhere else'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              InfoBox(_message!, key: const Key('report-message'), warning: _problem),
            ],
            const SizedBox(height: 8),
            Text(
              'The report isn\'t locked: anyone who has the file can read it.',
              style: TextStyle(fontSize: 13, height: 1.45, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
