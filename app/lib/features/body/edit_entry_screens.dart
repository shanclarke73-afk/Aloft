import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../import/shotsy_import.dart';
import '../../settings/settings.dart';
import '../../theme/aloft_theme.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/system_bar_spacer.dart';

Future<void> openEditSideEffect(BuildContext context, SideEffect effect) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => EditSideEffectScreen(effect: effect)));

/// Adds a note for a day, or changes one.
Future<void> openNote(BuildContext context, {DayNote? editing}) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => NoteScreen(editing: editing)));

PreferredSizeWidget _bar(BuildContext context, String title) => AppBar(
  leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
  leadingWidth: 88,
  title: Text(
    title,
    style: const TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
  ),
  centerTitle: true,
);

/// Change one logged side effect: how strong, when, and its note. Or delete it.
class EditSideEffectScreen extends ConsumerStatefulWidget {
  const EditSideEffectScreen({super.key, required this.effect});
  final SideEffect effect;

  @override
  ConsumerState<EditSideEffectScreen> createState() => _EditSideEffectScreenState();
}

class _EditSideEffectScreenState extends ConsumerState<EditSideEffectScreen> {
  late int _severity = widget.effect.severity;
  late DateTime _when = widget.effect.occurredAt;
  late final _note = TextEditingController(text: widget.effect.notes ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(databaseProvider)
        .updateSideEffect(widget.effect, severity: _severity, occurredAt: _when, notes: _note.text);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final effect = widget.effect;
    await db.deleteSideEffect(effect);
    if (mounted) Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: const Text('Side effect deleted'),
        // With an action, Flutter keeps a message up until it's dismissed; Undo should leave on its own.
        persist: false,
        action: SnackBarAction(label: 'Undo', onPressed: () => db.restoreSideEffect(effect)),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _bar(context, sideEffectName(widget.effect)),
      bottomNavigationBar: const SystemBarSpacer(),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FieldLabel('How strong? 1 = barely, 10 = severe'),
            Text(
              '${severityWord(_severity)} ($_severity of 10)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Slider(
              key: const Key('severity'),
              value: _severity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_severity',
              onChanged: (v) => setState(() => _severity = v.round()),
            ),
            const FieldLabel('When'),
            PickerField(text: formatWhen(context, _when), onTap: _chooseWhen),
            const FieldLabel('Note'),
            TextField(
              key: const Key('effect-note'),
              controller: _note,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            FilledButton(key: const Key('save'), onPressed: _save, child: const Text('Save')),
            TextButton(
              key: const Key('delete'),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              onPressed: _delete,
              child: const Text('Delete this side effect'),
            ),
            const SizedBox(height: 8),
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
}

/// A note for a day: new, or one being changed.
class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key, this.editing});
  final DayNote? editing;

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late final _body = TextEditingController(text: widget.editing?.body ?? '');
  late DateTime _day = widget.editing?.noteDate ?? DateTime.now();
  bool _showProblem = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_body.text.trim().isEmpty) {
      setState(() => _showProblem = true);
      return;
    }
    final db = ref.read(databaseProvider);
    final editing = widget.editing;
    if (editing == null) {
      await db.addDayNote(body: _body.text, day: _day);
    } else {
      await db.updateDayNote(editing, body: _body.text, day: _day);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final note = widget.editing!;
    await db.deleteDayNote(note);
    if (mounted) Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: const Text('Note deleted'),
        // With an action, Flutter keeps a message up until it's dismissed; Undo should leave on its own.
        persist: false,
        action: SnackBarAction(label: 'Undo', onPressed: () => db.restoreDayNote(note)),
      ),
    );
  }

  Future<void> _chooseDay() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (date != null) setState(() => _day = date);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _bar(context, 'Note'),
      bottomNavigationBar: const SystemBarSpacer(),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FieldLabel('What do you want to remember?'),
            TextField(
              key: const Key('note-body'),
              controller: _body,
              autofocus: widget.editing == null,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
            if (_showProblem && _body.text.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Type something to save.',
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                ),
              ),
            const FieldLabel('Day'),
            PickerField(text: formatDay(context, _day), onTap: _chooseDay),
            const SizedBox(height: 20),
            FilledButton(key: const Key('save'), onPressed: _save, child: const Text('Save')),
            if (widget.editing != null)
              TextButton(
                key: const Key('delete'),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                onPressed: _delete,
                child: const Text('Delete this note'),
              ),
          ],
        ),
      ),
    );
  }
}
