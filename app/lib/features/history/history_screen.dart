import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../log/log_dose_screen.dart';

/// History tab: everything logged, newest first, grouped by day. Tap a row to edit or delete.
/// Weight, side effects and photos join this list as those features are built.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final entries = ref.watch(historyProvider).value ?? const <HistoryEntry>[];
    final rows = <Widget>[];
    DateTime? day;
    for (final entry in entries) {
      final at = entry.dose.takenAt;
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
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _DoseRow(entry: entry),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Nothing logged yet. Your shots and doses will be listed here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: rows),
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
