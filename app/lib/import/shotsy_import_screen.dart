import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/app_lock.dart';
import '../data/database.dart';
import '../dose/dose_math.dart';
import '../features/medications/medication_limit.dart';
import '../pro/pro.dart';
import '../settings/settings.dart';
import '../widgets/form_widgets.dart';
import 'shotsy_file.dart';
import 'shotsy_import.dart';
import '../theme/aloft_theme.dart';
import '../widgets/system_bar_spacer.dart';

/// Lets the person pick Shotsy's CSV export, then shows the preview. Nothing is saved until
/// they tap Import there.
Future<void> pickShotsyFile(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final lock = ProviderScope.containerOf(context).read(appLockProvider);
  ShotsyFile? file;
  try {
    final picked = await lock.awayOnPurpose(
      () => FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'txt']),
    );
    final path = picked.singleOrNull?.path;
    if (path == null) return;
    file = parseShotsy(utf8.decode(await File(path).readAsBytes(), allowMalformed: true));
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('Couldn\'t open that file.')));
    return;
  }
  if (file == null || file.days.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('That doesn\'t look like a Shotsy export. In Shotsy, export your data as CSV.')),
    );
    return;
  }
  await navigator.push(
    MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => ShotsyImportScreen(file: file!)),
  );
}

/// Preview of a Shotsy export before anything is saved (mockups/ShotsyImport).
class ShotsyImportScreen extends ConsumerStatefulWidget {
  const ShotsyImportScreen({super.key, required this.file});
  final ShotsyFile file;

  @override
  ConsumerState<ShotsyImportScreen> createState() => _ShotsyImportScreenState();
}

class _ShotsyImportScreenState extends ConsumerState<ShotsyImportScreen> {
  late final _forms = {for (final name in widget.file.medications) name: MedicationForm.brandPen};
  late final _strengths = {for (final name in widget.file.medications) name: TextEditingController()};

  /// Medications already in Aloft, and for each name in the file the one its shots go to
  /// (null for a new medication).
  List<Medication> _existing = const [];
  final _targets = <String, String?>{};
  ShotsyImportResult? _result;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final db = ref.read(databaseProvider);
    final existing = [
      for (final m in await db.select(db.medications).get())
        if (m.status != MedicationStatus.ended) m,
    ];
    if (!mounted) return;
    setState(() {
      _existing = existing;
      for (final name in widget.file.medications) {
        if (_sameName(name) != null) continue;
        // One medication with the same ingredient is almost certainly the same thing under
        // another name ("Zepbound" in Shotsy, "Tirzepatide" here). The person can change it.
        final ingredient = ingredientFor(name).ingredient;
        final alike = [
          for (final m in existing)
            if (ingredient != 'other' && m.activeIngredient == ingredient) m,
        ];
        _targets[name] = alike.length == 1 ? alike.single.id : null;
      }
    });
  }

  Medication? _sameName(String name) {
    for (final m in _existing) {
      if (m.name.toLowerCase() == name.toLowerCase()) return m;
    }
    return null;
  }

  @override
  void dispose() {
    for (final c in _strengths.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    final result = await ref.read(databaseProvider).importShotsy(oneActiveOnly: !ref.read(proProvider), widget.file, {
      for (final name in widget.file.medications)
        name: ShotsyMedicationChoice(
          form: _forms[name]!,
          addToMedicationId: _targets[name],
          concentrationMgPerMl: _forms[name] == MedicationForm.compoundedVial
              ? parseAmount(_strengths[name]!.text)
              : null,
        ),
    });
    if (mounted) setState(() => _result = result);
  }

  static String _count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final file = widget.file;
    final dates = MaterialLocalizations.of(context);
    final muted = TextStyle(fontSize: 13, height: 1.4, color: scheme.onSurfaceVariant);
    final result = _result;
    // With the year: an export usually covers more than one.
    String day(DateTime d) => '${dates.formatShortMonthDay(d)}, ${d.year}';

    return Scaffold(
      appBar: AppBar(
        leading: result != null
            ? const SizedBox.shrink()
            : TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        leadingWidth: 88,
        title: const Text(
          'Import from Shotsy',
          style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const SystemBarSpacer(),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: result != null
              ? [
                  InfoBox(
                    [
                      'Imported ${_count(result.shots, 'shot', 'shots')}, ${_count(result.weights, 'weight', 'weights')}, '
                          '${_count(result.notes, 'note', 'notes')} and ${_count(result.effects, 'side effect', 'side effects')}.',
                      if (result.duplicates > 0)
                        '${_count(result.duplicates, 'entry was', 'entries were')} already in Aloft and skipped.',
                      if (result.medicationsAdded > 0) 'Check the dose and schedule in More → My medications: they were taken from your most recent shot.',
                      if (result.paused.isNotEmpty)
                        '${joinNames(result.paused)} ${result.paused.length == 1 ? 'was' : 'were'} added as paused, with all '
                            'the history. One medication at a time is free; tracking more at once is part of Aloft Pro.',
                    ].join('\n'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                ]
              : [
                  Text(
                    'From ${day(file.days.first.date)} to ${day(file.days.last.date)}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final line in [
                            _count(file.shotCount, 'shot', 'shots'),
                            _count(file.weightCount, 'weight', 'weights'),
                            _count(file.noteCount, 'note', 'notes'),
                            _count(file.effectCount, 'side effect', 'side effects'),
                          ])
                            Text(line, style: const TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w600)),
                          if (file.foodDays > 0)
                            Text(
                              'Calories, protein and water on ${_count(file.foodDays, 'day', 'days')} are left out: '
                              'Aloft doesn\'t track food.',
                              style: muted,
                            ),
                          Text('Anything already in Aloft is skipped, so importing twice is safe.', style: muted),
                        ],
                      ),
                    ),
                  ),
                  for (final name in file.medications)
                    if (_sameName(name) != null) ...[
                      FieldLabel(name),
                      Text('$name is already in Aloft, so its shots are added to it.', style: muted),
                    ] else ...[
                      if (_existing.isNotEmpty) ...[
                        FieldLabel('$name: where do these shots go?'),
                        RadioGroup<String?>(
                          groupValue: _targets[name],
                          onChanged: (id) => setState(() => _targets[name] = id),
                          child: Column(
                            children: [
                              for (final m in _existing)
                                RadioListTile<String?>(
                                  key: Key('target-$name-${m.name}'),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  value: m.id,
                                  title: Text('Add to ${m.name}'),
                                  subtitle: const Text('Already in Aloft. Its dose and schedule stay as they are.'),
                                ),
                              RadioListTile<String?>(
                                key: Key('target-$name-new'),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                value: null,
                                title: const Text('A new medication'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_targets[name] == null) ...[
                        FieldLabel('$name: what was it?'),
                        SegmentedButton<MedicationForm>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(value: MedicationForm.brandPen, label: Text('Brand-name pen')),
                            ButtonSegment(value: MedicationForm.compoundedVial, label: Text('Compounded vial')),
                          ],
                          selected: {_forms[name]!},
                          onSelectionChanged: (s) => setState(() => _forms[name] = s.single),
                        ),
                        if (_forms[name] == MedicationForm.compoundedVial) ...[
                          const FieldLabel('Strength in mg per mL (optional)'),
                          NumberField(controller: _strengths[name]!, suffix: 'mg/mL'),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'With the strength, Aloft can also show these shots in units. Without it they stay in '
                              'mg. If your vials changed strength, leave it empty.',
                              style: muted,
                            ),
                          ),
                        ],
                      ],
                    ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('import'),
                    onPressed: _importing ? null : _import,
                    child: const Text('Import'),
                  ),
                ],
        ),
      ),
    );
  }
}
