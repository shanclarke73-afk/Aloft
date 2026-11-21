import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../import/shotsy_import_screen.dart';
import '../../security/app_lock.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../medications/my_medications_screen.dart';

const medicalDisclaimer =
    'Aloft is a personal tracking tool, not a medical device. It does not provide medical advice or tell you '
    'how much to take. Always follow your prescriber.';

/// More tab: settings (mockups/Settings). Rows for features that aren't built yet are left out.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final lock = ref.watch(appLockProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const _SectionTitle('Your medications'),
          _Section(
            children: [
              ListTile(
                title: const Text('My medications'),
                subtitle: switch (ref.watch(medicationsProvider).value) {
                  null || [] => const Text('None yet'),
                  final list => Text(
                    [
                      for (final d in list) [d.medication.name, ?describeUsualDose(d)].join(' · '),
                    ].join('\n'),
                  ),
                },
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MyMedicationsScreen())),
              ),
            ],
          ),
          const _SectionTitle('Data'),
          _Section(
            children: [
              ListTile(
                title: const Text('Import from Shotsy'),
                subtitle: const Text('Bring your shots, weights and notes from Shotsy\'s CSV export'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => pickShotsyFile(context),
              ),
            ],
          ),
          const _SectionTitle('Reminders'),
          _Section(
            children: [
              SwitchListTile(
                title: const Text('Shot and dose days'),
                subtitle: const Text('At the time you set for each medication'),
                value: settings.remindShots,
                onChanged: controller.setRemindShots,
              ),
              SwitchListTile(
                title: const Text('Reorder'),
                subtitle: const Text('At 2 doses left'),
                value: settings.remindReorder,
                onChanged: controller.setRemindReorder,
              ),
              SwitchListTile(
                title: const Text('Use-by date'),
                subtitle: const Text('A week before'),
                value: settings.remindUseBy,
                onChanged: controller.setRemindUseBy,
              ),
            ],
          ),
          const _SectionTitle('Preferences'),
          _Section(
            children: [
              _ChoiceRow<WeightUnit>(
                title: 'Weight',
                value: settings.weightUnit,
                labels: const {WeightUnit.lb: 'lb', WeightUnit.kg: 'kg'},
                onChanged: controller.setWeightUnit,
              ),
              _ChoiceRow<LengthUnit>(
                title: 'Measurements',
                value: settings.lengthUnit,
                labels: const {LengthUnit.inches: 'inches', LengthUnit.cm: 'cm'},
                onChanged: controller.setLengthUnit,
              ),
              _ChoiceRow<Appearance>(
                title: 'Appearance',
                value: settings.appearance,
                labels: const {Appearance.system: 'Match phone', Appearance.light: 'Light', Appearance.dark: 'Dark'},
                onChanged: controller.setAppearance,
              ),
            ],
          ),
          const _SectionTitle('Privacy & security'),
          ListenableBuilder(
            listenable: lock,
            builder: (context, _) => _Section(
              children: [
                SwitchListTile(
                  title: Text(lock.methodName == 'passcode' ? 'Lock with passcode' : 'Lock with ${lock.methodName}'),
                  value: settings.appLock,
                  onChanged: (on) async {
                    final messenger = ScaffoldMessenger.of(context);
                    final changed = await lock.setEnabled(
                      on,
                      onProblem: (message) => messenger.showSnackBar(SnackBar(content: Text(message))),
                    );
                    if (changed) await controller.setAppLock(on);
                  },
                ),
                if (settings.appLock)
                  _ChoiceRow<LockAfter>(
                    title: 'Lock after',
                    value: settings.lockAfter,
                    labels: const {LockAfter.immediately: 'Immediately', LockAfter.oneMinute: '1 minute'},
                    onChanged: (value) {
                      lock.lockAfter = value;
                      controller.setLockAfter(value);
                    },
                  ),
                SwitchListTile(
                  title: const Text('Hide screen in app switcher'),
                  value: settings.hideInAppSwitcher,
                  onChanged: controller.setHideInAppSwitcher,
                ),
              ],
            ),
          ),
          const _SectionTitle('About & help'),
          _Section(
            children: [
              ListTile(
                title: const Text('Medical disclaimer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Medical disclaimer'),
                    content: const Text(medicalDisclaimer),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Aloft · From titration to thriving.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[if (i > 0) const Divider(indent: 16), child],
        ],
      ),
    );
  }
}

/// A row showing the current choice; tapping it opens the list of choices.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({required this.title, required this.value, required this.labels, required this.onChanged});
  final String title;
  final T value;
  final Map<T, String> labels;
  final void Function(T value) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(labels[value]!, style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
      onTap: () async {
        final picked = await showModalBottomSheet<T>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in labels.entries)
                  ListTile(
                    title: Text(entry.value),
                    trailing: entry.key == value ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, entry.key),
                  ),
              ],
            ),
          ),
        );
        if (picked != null && picked != value) onChanged(picked);
      },
    );
  }
}
