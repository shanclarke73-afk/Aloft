import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../import/shotsy_import.dart';
import '../../dose/dose_math.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../body/log_weight_screen.dart';
import '../log/log_dose_screen.dart';

enum _Filter { all, shots, weight, effects }

/// History tab (mockups/History): everything logged, newest first, grouped by day. Tap a row
/// to edit or delete it. Photos join this list when they're built.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unit = ref.watch(settingsProvider.select((s) => s.weightUnit));
    final doses = ref.watch(historyProvider).value ?? const <HistoryEntry>[];
    final weights = ref.watch(weightsProvider).value ?? const <Weight>[];
    final effects = ref.watch(sideEffectsProvider).value ?? const <SideEffect>[];
    final notes = ref.watch(dayNotesProvider).value ?? const <DayNote>[];
    final names = {
      for (final d in ref.watch(medicationsProvider).value ?? const <MedicationDetail>[])
        d.medication.id: d.medication.name,
    };
    final nothingLogged = doses.isEmpty && weights.isEmpty && effects.isEmpty && notes.isEmpty;

    final items = <(DateTime, Widget)>[
      if (_filter == _Filter.all || _filter == _Filter.shots)
        for (final entry in doses) (entry.dose.takenAt, _DoseRow(entry: entry)),
      if (_filter == _Filter.all || _filter == _Filter.weight)
        for (final w in weights) (w.measuredAt, _WeightRow(weight: w, unit: unit)),
      if (_filter == _Filter.all || _filter == _Filter.effects)
        for (final e in effects) (e.occurredAt, _EffectRow(effect: e, medicationName: names[e.medicationId])),
      // A day's note sorts to the end of its day.
      if (_filter == _Filter.all)
        for (final n in notes) (n.noteDate, _NoteRow(note: n)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));

    final rows = <Widget>[];
    DateTime? day;
    for (final (at, row) in items) {
      final thisDay = DateUtils.dateOnly(at);
      if (thisDay != day) {
        day = thisDay;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
            child: Text(
              formatLongDay(context, at),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
            ),
          ),
        );
      }
      rows.add(Padding(padding: const EdgeInsets.only(bottom: 8), child: row));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: nothingLogged
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Nothing logged yet. Your shots, weights and side effects will be listed here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    for (final (filter, label) in const [
                      (_Filter.all, 'All'),
                      (_Filter.shots, 'Shots'),
                      (_Filter.weight, 'Weight'),
                      (_Filter.effects, 'Effects'),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        showCheckmark: false,
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                  ],
                ),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Nothing of this kind yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ...rows,
              ],
            ),
    );
  }
}

class _NoteRow extends ConsumerWidget {
  const _NoteRow({required this.note});
  final DayNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Note', style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(note.body),
        onLongPress: () async {
          final db = ref.read(databaseProvider);
          final messenger = ScaffoldMessenger.of(context);
          await db.deleteDayNote(note);
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: const Text('Note deleted'),
              // With an action, Flutter keeps a message up until it's dismissed; Undo should leave on its own.
              persist: false,
              action: SnackBarAction(label: 'Undo', onPressed: () => db.restoreDayNote(note)),
            ),
          );
        },
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({required this.weight, required this.unit});
  final Weight weight;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text('Weight · ${formatWeight(weight.kg, unit)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: weight.notes == null ? null : Text('“${weight.notes}”'),
        trailing: Text(formatTime(context, weight.measuredAt.hour * 60 + weight.measuredAt.minute)),
        onTap: () => openLogWeight(context, editing: weight),
      ),
    );
  }
}

class _EffectRow extends ConsumerWidget {
  const _EffectRow({required this.effect, required this.medicationName});
  final SideEffect effect;
  final String? medicationName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = sideEffectName(effect);
    final details = [?medicationName, if (effect.notes != null) '“${effect.notes}”'];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          '$name · ${severityWord(effect.severity)} (${effect.severity} of 10)',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: details.isEmpty ? null : Text(details.join(' · ')),
        trailing: Text(formatTime(context, effect.occurredAt.hour * 60 + effect.occurredAt.minute)),
        onTap: () async {
          final db = ref.read(databaseProvider);
          final messenger = ScaffoldMessenger.of(context);
          final delete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(name),
              content: Text(
                '${formatWhen(context, effect.occurredAt)}\n${severityWord(effect.severity)} (${effect.severity} of 10)',
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Close')),
              ],
            ),
          );
          if (delete != true) return;
          await db.deleteSideEffect(effect);
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: const Text('Side effect deleted'),
              // With an action, Flutter keeps a message up until it's dismissed; Undo should leave on its own.
              persist: false,
              action: SnackBarAction(label: 'Undo', onPressed: () => db.restoreSideEffect(effect)),
            ),
          );
        },
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final dose = entry.dose;
    final pill = entry.medication.form == MedicationForm.oral;
    final String title;
    if (dose.skipped) {
      title = 'Skipped';
    } else {
      final typed = describeAmount(dose.amountEntered, dose.unitEntered);
      final mg = dose.drugMg == null || dose.unitEntered == DoseUnit.mg
          ? ''
          : ' = ${describeAmount(dose.drugMg!, DoseUnit.mg)}';
      title = '${pill ? 'Dose' : 'Shot'} · $typed$mg';
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          [entry.medication.name, ?dose.injectionSite?.label, if (dose.notes != null) '“${dose.notes}”'].join(' · '),
        ),
        trailing: Text(formatTime(context, dose.takenAt.hour * 60 + dose.takenAt.minute)),
        onTap: () => openEditDose(context, entry),
      ),
    );
  }
}
