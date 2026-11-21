import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';

Future<void> openLogSideEffect(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const LogSideEffectScreen()));

/// Log one or more side effects, each with its own strength (mockups/LogSideEffect).
class LogSideEffectScreen extends ConsumerStatefulWidget {
  const LogSideEffectScreen({super.key});

  @override
  ConsumerState<LogSideEffectScreen> createState() => _LogSideEffectScreenState();
}

class _LogSideEffectScreenState extends ConsumerState<LogSideEffectScreen> {
  /// What's picked, with its strength from 1 to 10.
  final _picked = <SideEffectType, int>{};
  final _custom = TextEditingController();
  final _note = TextEditingController();
  DateTime _when = DateTime.now();
  String? _medicationId;
  bool _medicationChosen = false;
  bool _showProblem = false;

  @override
  void dispose() {
    _custom.dispose();
    _note.dispose();
    super.dispose();
  }

  List<String> get _problems => [
    if (_picked.isEmpty) 'Pick at least one.',
    if (_picked.containsKey(SideEffectType.custom) && _custom.text.trim().isEmpty) 'Type a name for "Other".',
  ];

  Future<void> _save() async {
    if (_problems.isNotEmpty) {
      setState(() => _showProblem = true);
      return;
    }
    await ref
        .read(databaseProvider)
        .logSideEffects(
          severities: _picked,
          customName: _custom.text,
          occurredAt: _when,
          medicationId: _medicationId,
          notes: _note.text,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final medications = ref.watch(medicationsProvider).value ?? const <MedicationDetail>[];
    // The medication with the most recent dose, for "N days after your shot" and "Likely from".
    MedicationDetail? recent;
    for (final d in medications) {
      final at = d.lastDose?.takenAt;
      if (at != null && (recent == null || at.isAfter(recent.lastDose!.takenAt))) recent = d;
    }
    if (!_medicationChosen) _medicationId = recent?.medication.id ?? medications.singleOrNull?.medication.id;

    String? context_;
    if (recent != null) {
      final days = DateUtils.dateOnly(_when).difference(DateUtils.dateOnly(recent.lastDose!.takenAt)).inDays;
      final noun = recent.medication.form == MedicationForm.oral ? 'dose' : 'shot';
      if (days >= 0) {
        context_ =
            '${weekdayLong[_when.weekday - 1]}, '
            '${days == 0 ? 'the day of your $noun' : '$days ${days == 1 ? 'day' : 'days'} after your $noun'}'
            ' (${recent.medication.name})';
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        leadingWidth: 88,
        title: const Text('Side effects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (context_ != null) Text(context_, style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant)),
            const FieldLabel('What are you noticing? Pick any.'),
            Wrap(
              spacing: 6,
              children: [
                for (final type in SideEffectType.values)
                  FilterChip(
                    label: Text(type == SideEffectType.custom ? '+ Other' : type.label),
                    showCheckmark: false,
                    selected: _picked.containsKey(type),
                    onSelected: (on) => setState(() => on ? _picked[type] = 3 : _picked.remove(type)),
                  ),
              ],
            ),
            if (_picked.containsKey(SideEffectType.custom)) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _custom,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'What is it?'),
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (_picked.isNotEmpty) const FieldLabel('How strong? 1 = barely, 10 = severe'),
            for (final type in _picked.keys.toList()) ...[
              Text(
                '${type == SideEffectType.custom && _custom.text.trim().isNotEmpty ? _custom.text.trim() : type.label}'
                ' · ${severityWord(_picked[type]!)} (${_picked[type]} of 10)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Slider(
                value: _picked[type]!.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_picked[type]}',
                onChanged: (v) => setState(() => _picked[type] = v.round()),
              ),
            ],
            if (_showProblem)
              for (final problem in _problems)
                Text(
                  problem,
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                ),
            const FieldLabel('When'),
            PickerField(text: formatWhen(context, _when), onTap: _chooseWhen),
            if (medications.isNotEmpty) ...[
              const FieldLabel('Likely from'),
              DropdownMenu<String?>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: _medicationId,
                requestFocusOnTap: false,
                dropdownMenuEntries: [
                  for (final d in medications) DropdownMenuEntry(value: d.medication.id, label: d.medication.name),
                  const DropdownMenuEntry(value: null, label: 'Not sure'),
                ],
                onSelected: (id) => setState(() {
                  _medicationId = id;
                  _medicationChosen = true;
                }),
              ),
            ],
            const FieldLabel('Note'),
            TextField(controller: _note, maxLines: 2, textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 20),
            FilledButton(key: const Key('save'), onPressed: _save, child: const Text('Save')),
            const SizedBox(height: 12),
            Text(
              'If a side effect is severe or worrying, contact your prescriber.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseWhen() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (time == null) return;
    setState(() => _when = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
}
