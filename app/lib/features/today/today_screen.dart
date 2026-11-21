import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../log/log_dose_screen.dart';
import '../medications/medication_setup_screen.dart';

/// Today tab. For now: each medication with a Log button. The countdown, weight and supply
/// cards from the mockup come with build step 3.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: medications.when(
        loading: () => const SizedBox.shrink(),
        error: (error, _) =>
            Center(child: Text('Couldn\'t load your medications.\n$error', textAlign: TextAlign.center)),
        data: (list) => list.isEmpty
            ? const _NoMedication()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  for (final detail in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MedicationCard(detail: detail),
                    ),
                ],
              ),
      ),
    );
  }
}

class _NoMedication extends StatelessWidget {
  const _NoMedication();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Add your medication', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Enter your pen, vial or pill once. After that, logging a dose takes a few seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => startAddMedication(context), child: const Text('Add medication')),
        ],
      ),
    );
  }
}

/// One medication: usual dose, schedule, supply, last dose, and the Log button.
class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key, required this.detail});
  final MedicationDetail detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final m = detail.medication;
    final last = detail.lastDose;
    final isPill = m.form == MedicationForm.oral;
    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(describeSupply(detail), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            if (describeUsualDose(detail) case final dose?) line('Usual dose', dose),
            line('Schedule', describeSchedule(context, m)),
            if (describeRemaining(detail) case final left?) line('Supply', left),
            line(
              isPill ? 'Last dose' : 'Last shot',
              last == null
                  ? 'Nothing logged yet'
                  : '${describeAmount(last.amountEntered, last.unitEntered)} · ${formatWhen(context, last.takenAt)}',
            ),
            const SizedBox(height: 14),
            if (detail.supply != null)
              FilledButton(
                onPressed: () => openLogDose(context, detail),
                child: Text(isPill ? 'Log dose' : 'Log shot'),
              ),
          ],
        ),
      ),
    );
  }
}
