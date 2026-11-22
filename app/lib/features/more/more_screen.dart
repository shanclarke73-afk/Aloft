import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../about/about_screen.dart';
import '../backup/backup_screen.dart';
import '../body/goal_screen.dart';

import '../../backup/backup_file.dart';
import '../../data/database.dart';
import '../../import/shotsy_import_screen.dart';
import '../../security/app_lock.dart';
import '../../photos/photo_picker.dart';
import '../../settings/settings.dart';
import '../../widgets/form_widgets.dart';
import '../../reminders/reminders.dart';
import '../../util/format.dart';
import '../medications/my_medications_screen.dart';

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
                key: const Key('backup-and-restore'),
                title: const Text('Backup and restore'),
                subtitle: const Text('Save everything to a file, or bring a backup back'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BackupScreen())),
              ),
              ListTile(
                title: const Text('Import from Shotsy'),
                subtitle: const Text('Bring your shots, weights and notes from Shotsy\'s CSV export'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => pickShotsyFile(context),
              ),
              ListTile(
                key: const Key('delete-all-data'),
                title: Text('Delete all my data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                subtitle: const Text('Remove everything you\'ve entered from this phone'),
                onTap: () => _deleteAllData(context, ref),
              ),
            ],
          ),
          const _SectionTitle('Reminders'),
          // Reminders that are switched on here but blocked by the phone would otherwise fail silently.
          if (ref.watch(notificationsAllowedProvider).value == false &&
              (settings.remindShots || settings.remindReorder || settings.remindUseBy))
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: InfoBox(
                'Notifications are turned off for Aloft in your phone\'s settings, so these reminders won\'t '
                'show. Turn them on in your phone\'s Settings → Notifications → Aloft.',
                warning: true,
              ),
            ),
          // Allowed, but the phone may hold reminders back: offer the setting that makes them punctual.
          if (ref.watch(notificationsAllowedProvider).value != false &&
              ref.watch(remindersOnTimeProvider).value == false &&
              (settings.remindShots || settings.remindReorder || settings.remindUseBy))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const InfoBox(
                    'Your phone may deliver reminders late, sometimes by up to an hour. To get them on time, '
                    'allow "Alarms & reminders" for Aloft.',
                  ),
                  const SizedBox(height: 8),
                  // An outlined button: as plain text it didn't read as something to tap.
                  OutlinedButton.icon(
                    key: const Key('on-time-reminders'),
                    onPressed: () => ref.read(remindersProvider).askForOnTime(),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open the setting'),
                  ),
                ],
              ),
            ),
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
              ListTile(
                key: const Key('goal-and-bmi'),
                title: const Text('Goal weight and BMI'),
                subtitle: Text(describeGoal(settings)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GoalScreen())),
              ),
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
                key: const Key('about-aloft'),
                title: const Text('About Aloft'),
                subtitle: const Text('Medical disclaimer, privacy and licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AboutScreen())),
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

/// Asks first, then removes everything the person has entered.
Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
  final scheme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete all your data?'),
      content: const Text(
        'This removes every medication, shot, weight, side effect, note and progress photo from this phone, '
        'along with your goal weight and height.\n\n'
        'It can\'t be undone. If you might want any of it later, save a backup file first.\n\n'
        'Your units, reminder switches and app lock stay as they are.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          key: const Key('confirm-delete-all'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Delete everything',
            style: TextStyle(color: scheme.error, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(databaseProvider).deleteAllData(photoFolder: ref.read(photoFolderProvider));
  await ref.read(settingsProvider.notifier).reload();
  messenger.showSnackBar(const SnackBar(content: Text('All your data was deleted from this phone.')));
}
