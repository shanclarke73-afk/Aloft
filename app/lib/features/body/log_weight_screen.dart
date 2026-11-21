import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';

Future<void> openLogWeight(BuildContext context, {Weight? editing}) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => LogWeightScreen(editing: editing)));

/// Log or edit a weight (mockups/LogWeight). Saving to Apple Health / Health Connect comes
/// with the Health step.
class LogWeightScreen extends ConsumerStatefulWidget {
  const LogWeightScreen({super.key, this.editing});
  final Weight? editing;

  @override
  ConsumerState<LogWeightScreen> createState() => _LogWeightScreenState();
}

class _LogWeightScreenState extends ConsumerState<LogWeightScreen> {
  final _value = TextEditingController();
  final _note = TextEditingController();
  late WeightUnit _unit;
  DateTime _when = DateTime.now();
  bool _showProblem = false;

  @override
  void initState() {
    super.initState();
    _unit = ref.read(settingsProvider).weightUnit;
    final editing = widget.editing;
    if (editing != null) {
      _value.text = fromKg(editing.kg, _unit).toStringAsFixed(1);
      _note.text = editing.notes ?? '';
      _when = editing.measuredAt;
    }
  }

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Kilograms, or null when the number isn't a believable body weight.
  double? get _kg {
    final typed = double.tryParse(_value.text.trim().replaceAll(',', '.'));
    if (typed == null) return null;
    final kg = toKg(typed, _unit);
    return kg >= 20 && kg <= 500 ? kg : null;
  }

  Future<void> _save() async {
    final kg = _kg;
    if (kg == null) {
      setState(() => _showProblem = true);
      return;
    }
    final db = ref.read(databaseProvider);
    final editing = widget.editing;
    if (editing == null) {
      await db.logWeight(kg: kg, measuredAt: _when, notes: _note.text);
    } else {
      await db.updateWeight(editing, kg: kg, measuredAt: _when, notes: _note.text);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final weight = widget.editing!;
    final db = ref.read(databaseProvider);
    await db.deleteWeight(weight);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: const Text('Weight deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: () => db.restoreWeight(weight)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kg = _kg;
    // Other weigh-ins, newest first, to compare against.
    final others = [
      for (final w in ref.watch(weightsProvider).value ?? const <Weight>[])
        if (w.id != widget.editing?.id && w.measuredAt.isBefore(_when)) w,
    ];
    final previous = others.firstOrNull, first = others.lastOrNull;
    final muted = TextStyle(fontSize: 14, height: 1.5, color: scheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        leadingWidth: 88,
        title: const Text('Weight', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<WeightUnit>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
              ],
              selected: {_unit},
              onSelectionChanged: (s) => setState(() {
                // Switching units keeps the same weight.
                final current = _kg;
                _unit = s.single;
                if (current != null) _value.text = fromKg(current, _unit).toStringAsFixed(1);
              }),
            ),
            FieldLabel('Weight in ${_unit == WeightUnit.lb ? 'pounds' : 'kilograms'}'),
            NumberField(
              key: const Key('weight'),
              controller: _value,
              suffix: _unit.name,
              large: true,
              onChanged: (_) => setState(() {}),
            ),
            if (_showProblem && kg == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Enter your weight.',
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                ),
              ),
            if (kg != null && previous != null) ...[
              const SizedBox(height: 10),
              Text(
                '${formatWeightChange(previous.kg, kg, _unit)} since ${formatDay(context, previous.measuredAt)}',
                style: muted,
              ),
              if (first != null && first.id != previous.id)
                Text('${formatWeightChange(first.kg, kg, _unit)} since you started', style: muted),
            ],
            const FieldLabel('When'),
            PickerField(text: formatWhen(context, _when), onTap: _chooseWhen),
            const FieldLabel('Note'),
            TextField(controller: _note, maxLines: 2, textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 20),
            FilledButton(key: const Key('save'), onPressed: _save, child: const Text('Save')),
            if (widget.editing != null)
              TextButton(
                key: const Key('delete'),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                onPressed: _delete,
                child: const Text('Delete this weight'),
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
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (time == null) return;
    setState(() => _when = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
}
