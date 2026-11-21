import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../import/shotsy_import_screen.dart';
import '../../security/app_lock.dart';
import '../../settings/settings.dart';
import '../../theme/aloft_theme.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import '../backup/backup_screen.dart';
import '../about/about_screen.dart';
import '../medications/medication_setup_screen.dart';
import '../progress/add_photos_screen.dart';

/// First launch (SPEC 6.1, mockups/Onboarding to OnbFinish): welcome, medication, starting
/// weight, photos, then privacy choices and the disclaimer. Everything except the disclaimer
/// can be skipped and done later from inside the app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _lastStep = 4;
  int _step = 0;

  // Starting weight.
  final _weight = TextEditingController();
  late WeightUnit _unit = ref.read(settingsProvider).weightUnit;
  DateTime _weightDay = DateTime.now();
  bool _weightProblem = false;
  bool _weightSaved = false;

  bool _understood = false;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  void _go(int step) => setState(() => _step = step.clamp(0, _lastStep));

  double? get _kg {
    final typed = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    if (typed == null) return null;
    final kg = toKg(typed, _unit);
    return kg >= 20 && kg <= 500 ? kg : null;
  }

  Future<void> _saveWeight() async {
    final kg = _kg;
    if (kg == null) {
      setState(() => _weightProblem = true);
      return;
    }
    await ref.read(databaseProvider).logWeight(kg: kg, measuredAt: _weightDay);
    await ref.read(settingsProvider.notifier).setWeightUnit(_unit);
    _weightSaved = true;
    _go(3);
  }

  Future<void> _chooseWeightDay() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _weightDay,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    // Morning, so a shot logged later the same day sorts after it.
    if (date != null) setState(() => _weightDay = DateTime(date.year, date.month, date.day, 8));
  }

  Future<void> _addMedication(MedicationForm form) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => MedicationSetupScreen(form: form)));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: _step == 0
                  ? null
                  : Row(
                      children: [
                        IconButton(
                          key: const Key('onboarding-back'),
                          tooltip: 'Back',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => _go(_step - 1),
                        ),
                        Text(
                          'Step $_step of $_lastStep',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: switch (_step) {
                    0 => _welcome(context),
                    1 => _medication(context),
                    2 => _startingWeight(context),
                    3 => _photos(context),
                    _ => _finish(context),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontFamily: displayFont, fontSize: 26, fontWeight: FontWeight.w800, height: 1.15),
    ),
  );

  Widget _lead(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.45, color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );

  Widget _small(BuildContext context, String text, {TextAlign align = TextAlign.center}) => Text(
    text,
    textAlign: align,
    style: TextStyle(fontSize: 13, height: 1.45, color: Theme.of(context).colorScheme.onSurfaceVariant),
  );

  List<Widget> _welcome(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget point(IconData icon, String title, String detail) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.secondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(fontSize: 14, height: 1.4, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
    return [
      const SizedBox(height: 24),
      const Text(
        'Aloft',
        style: TextStyle(fontFamily: displayFont, fontSize: 40, fontWeight: FontWeight.w800, color: AloftColors.teal),
      ),
      _lead(context, 'From titration to thriving.'),
      const SizedBox(height: 8),
      point(
        Icons.vaccines_outlined,
        'Works with any GLP-1',
        'Brand-name pens, compounded vials with your exact strength and added ingredients, or pills.',
      ),
      point(
        Icons.lock_outline,
        'Private',
        'No account, and we never see your data. It stays on this phone, and you can save your own backup file '
            'whenever you like.',
      ),
      point(Icons.timeline, 'See how far you\'ve come', 'Shots, weight and progress photos together, from day one.'),
      const SizedBox(height: 8),
      FilledButton(key: const Key('get-started'), onPressed: () => _go(1), child: const Text('Get started')),
      TextButton(
        key: const Key('restore-link'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BackupScreen())),
        child: const Text('Have an Aloft backup file? Restore it'),
      ),
      const SizedBox(height: 12),
      _small(context, 'Aloft is a tracking tool, not medical advice.\nIt never tells you how much to take.'),
    ];
  }

  List<Widget> _medication(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final medications = ref.watch(medicationsProvider).value ?? const <MedicationDetail>[];
    Widget choice(Key key, MedicationForm form, String title, String detail) => Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(detail),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _addMedication(form),
      ),
    );
    return [
      _title(medications.isEmpty ? 'What are you taking?' : 'Your medication'),
      _lead(
        context,
        medications.isEmpty
            ? 'You can add more medications or switch later.'
            : 'You can change the dose and schedule any time in More → My medications.',
      ),
      for (final d in medications)
        Card(
          child: ListTile(
            leading: Icon(Icons.check_circle, color: scheme.secondary),
            title: Text(d.medication.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text([?describeUsualDose(d), describeSchedule(context, d.medication)].join(' · ')),
          ),
        ),
      if (medications.isNotEmpty) ...[
        const SizedBox(height: 12),
        FilledButton(key: const Key('medication-continue'), onPressed: () => _go(2), child: const Text('Continue')),
        const SizedBox(height: 16),
        _small(context, 'Taking something else as well? Add it here.', align: TextAlign.start),
        const SizedBox(height: 8),
      ],
      choice(
        const Key('choose-pen'),
        MedicationForm.brandPen,
        'Brand-name pen',
        'Ozempic®, Wegovy®, Mounjaro®, Zepbound® and others',
      ),
      choice(
        const Key('choose-vial'),
        MedicationForm.compoundedVial,
        'Compounded vial',
        'From a pharmacy, drawn with a syringe: semaglutide, tirzepatide, or add-ons like NAD+ and B12',
      ),
      choice(const Key('choose-pill'), MedicationForm.oral, 'Pill', 'Oral GLP-1s such as Rybelsus®'),
      const SizedBox(height: 8),
      TextButton(
        key: const Key('shotsy-link'),
        onPressed: () => pickShotsyFile(context),
        child: const Text('Coming from Shotsy? Import your history'),
      ),
      if (medications.isEmpty)
        TextButton(key: const Key('medication-later'), onPressed: () => _go(2), child: const Text('Set this up later')),
    ];
  }

  List<Widget> _startingWeight(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      _title('Where you\'re starting'),
      _lead(
        context,
        'Already on a GLP-1? Use your weight from when you began, so your progress counts from day one. '
        'This is optional.',
      ),
      if (_weightSaved)
        InfoBox('Your starting weight is saved. You can edit it in History.')
      else ...[
        SegmentedButton<WeightUnit>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
            ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
          ],
          selected: {_unit},
          onSelectionChanged: (s) => setState(() {
            final current = _kg;
            _unit = s.single;
            if (current != null) _weight.text = fromKg(current, _unit).toStringAsFixed(1);
          }),
        ),
        const FieldLabel('Starting weight'),
        NumberField(
          key: const Key('start-weight'),
          controller: _weight,
          suffix: _unit.name,
          large: true,
          onChanged: (_) => setState(() {}),
        ),
        if (_weightProblem && _kg == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Enter your weight, or skip this step.',
              style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
            ),
          ),
        const FieldLabel('When that was'),
        PickerField(text: formatFullDate(context, _weightDay), onTap: _chooseWeightDay),
      ],
      const SizedBox(height: 20),
      FilledButton(
        key: const Key('weight-continue'),
        onPressed: _weightSaved ? () => _go(3) : _saveWeight,
        child: const Text('Continue'),
      ),
      if (!_weightSaved) TextButton(key: const Key('weight-skip'), onPressed: () => _go(3), child: const Text('Skip')),
    ];
  }

  List<Widget> _photos(BuildContext context) {
    final count = ref.watch(photosProvider).value?.length ?? 0;
    Widget tip(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4))),
        ],
      ),
    );
    return [
      _title('Starting photos'),
      _lead(
        context,
        'Optional. Many people are glad later that they took one at the start: the scale doesn\'t show '
        'everything that changes.',
      ),
      tip('Same spot and lighting each time'),
      tip('Fitted clothes you\'ll wear again later'),
      tip('Front, side and back, if you like'),
      const SizedBox(height: 8),
      if (count > 0) ...[
        InfoBox('$count ${count == 1 ? 'photo' : 'photos'} saved. Find them in the Progress tab.'),
        const SizedBox(height: 12),
      ],
      OutlinedButton.icon(
        key: const Key('onboarding-add-photos'),
        onPressed: () => startAddPhotos(context),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(count > 0 ? 'Add more photos' : 'Add photos'),
      ),
      const SizedBox(height: 12),
      FilledButton(
        key: const Key('photos-continue'),
        onPressed: () => _go(4),
        child: Text(count > 0 ? 'Continue' : 'Maybe later'),
      ),
      const SizedBox(height: 16),
      _small(context, 'Only you can see them. $photosStayPrivate'),
    ];
  }

  List<Widget> _finish(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final lock = ref.watch(appLockProvider);
    return [
      _title('Private and safe'),
      _lead(context, 'Both of these can be changed any time in More.'),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListenableBuilder(
              listenable: lock,
              builder: (context, _) => SwitchListTile(
                key: const Key('onboarding-lock'),
                title: Text(lock.methodName == 'passcode' ? 'Lock with passcode' : 'Lock with ${lock.methodName}'),
                subtitle: const Text('Asked each time you open Aloft'),
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
            ),
            const Divider(indent: 16),
            SwitchListTile(
              key: const Key('onboarding-remind'),
              title: const Text('Remind me on shot and dose days'),
              subtitle: const Text('At the time you set for each medication'),
              value: settings.remindShots,
              onChanged: controller.setRemindShots,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _small(
        context,
        'Your data stays on this phone. Save a backup file now and then in More → Backup and restore, '
        'so a lost phone doesn\'t mean lost history.',
        align: TextAlign.start,
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        key: const Key('understand'),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: _understood,
        onChanged: (v) => setState(() => _understood = v ?? false),
        title: const Text('I understand', style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text(medicalDisclaimer),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('start-using'),
        onPressed: _understood ? controller.finishOnboarding : null,
        child: const Text('Start using Aloft'),
      ),
    ];
  }
}
