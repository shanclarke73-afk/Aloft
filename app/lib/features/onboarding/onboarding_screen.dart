import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../data/photo_store.dart';
import '../../dose/dose_math.dart';
import '../../import/shotsy_import_screen.dart';
import '../../security/app_lock.dart';
import '../../settings/settings.dart';
import '../../theme/aloft_theme.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import '../backup/backup_screen.dart';
import '../body/goal_screen.dart';
import '../about/about_screen.dart';
import '../medications/medication_limit.dart';
import '../medications/medication_setup_screen.dart';
import '../progress/add_photos_screen.dart';
import '../../util/device.dart';

/// First launch (SPEC 6.1, mockups/Onboarding to OnbFinish): welcome, bringing history in
/// from Shotsy or a backup file, medication, starting weight, photos, then privacy choices and
/// the disclaimer. What a file brought in is not asked for again: the steps it answers are
/// passed over, and can still be reached with Back. Everything except the disclaimer
/// can be skipped and done later from inside the app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _importStep = 1, _medicationStep = 2, _weightStep = 3, _photosStep = 4, _lastStep = 5;
  int _step = 0;

  /// What a Shotsy file or a backup brought in, in words, shown on the step it led to.
  String? _broughtIn;
  int? _broughtInStep;

  // Starting weight.
  final _weight = TextEditingController();
  late WeightUnit _unit = ref.read(settingsProvider).weightUnit;
  DateTime _weightDay = DateTime.now();
  bool _weightProblem = false;
  bool _weightSaved = false;
  // Made in initState, not on first use: a file can answer the weight step so that it is never
  // opened, and dispose must not be the first thing to touch it.
  late final GoalHeightDraft _goal;

  bool _understood = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _goal = GoalHeightDraft(weightUnit: settings.weightUnit, lengthUnit: settings.lengthUnit);
  }

  @override
  void dispose() {
    _weight.dispose();
    _goal.dispose();
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
    final lengthUnit = ref.read(settingsProvider).lengthUnit;
    if (kg == null || _goal.problems(_unit, lengthUnit).isNotEmpty) {
      setState(() => _weightProblem = true);
      return;
    }
    await ref.read(databaseProvider).logWeight(kg: kg, measuredAt: _weightDay);
    final settings = ref.read(settingsProvider.notifier);
    await settings.setWeightUnit(_unit);
    await settings.setGoalAndHeight(goalWeightKg: _goal.goalKg(_unit), heightCm: _goal.heightCm(lengthUnit));
    _weightSaved = true;
    _go(_photosStep);
  }

  /// The weights came in with a file: only the goal and height are still to be asked.
  Future<void> _saveGoal() async {
    final lengthUnit = ref.read(settingsProvider).lengthUnit;
    if (_goal.problems(_unit, lengthUnit).isNotEmpty) {
      setState(() => _weightProblem = true);
      return;
    }
    final goal = _goal.goalKg(_unit), height = _goal.heightCm(lengthUnit);
    if (goal != null || height != null) {
      final settings = ref.read(settingsProvider);
      await ref
          .read(settingsProvider.notifier)
          .setGoalAndHeight(goalWeightKg: goal ?? settings.goalWeightKg, heightCm: height ?? settings.heightCm);
    }
    _go(_photosStep);
  }

  /// Opens a Shotsy file or a backup, then moves to the first step the file didn't answer.
  Future<void> _bringIn(Future<void> Function() open) async {
    final db = ref.read(databaseProvider);
    Future<(int, int, int)> counts() async => (
      (await db.watchMedications().first).length,
      (await db.watchWeights().first).length,
      (await db.watchPhotos().first).length,
    );
    final before = await counts();
    await open();
    if (!mounted) return;
    final after = await counts();
    if (!mounted || after == before) return; // Backed out, or the file added nothing.
    final (medications, weights, photos) = after;
    String some(int n, String one, String many) => '$n ${n == 1 ? one : many}';
    final found = [
      if (medications > 0) some(medications, 'medication', 'medications'),
      if (weights > 0) some(weights, 'weight', 'weights'),
      if (photos > 0) some(photos, 'photo', 'photos'),
    ];
    final step = medications == 0
        ? _medicationStep
        : weights == 0
        ? _weightStep
        : photos == 0
        ? _photosStep
        : _lastStep;
    setState(() {
      _broughtIn = 'Your history is in: ${found.join(', ')}. Aloft has set up what it could from it.';
      _broughtInStep = step;
      _step = step;
    });
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

  Future<void> _addMedication(MedicationForm form) async {
    // The first one is free; "taking something else as well" is a second active medication.
    if (!await allowAnotherActive(context, ref) || !mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => MedicationSetupScreen(form: form)));
  }

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
                  children: [
                    if (_broughtIn != null && _step == _broughtInStep) ...[
                      InfoBox(_broughtIn!, key: const Key('brought-in')),
                      const SizedBox(height: 16),
                    ],
                    ...switch (_step) {
                      0 => _welcome(context),
                      _importStep => _history(context),
                      _medicationStep => _medication(context),
                      _weightStep => _startingWeight(context),
                      _photosStep => _photos(context),
                      _ => _finish(context),
                    },
                  ],
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
        'No account, and we never see your data. It stays on this $deviceWord, and you can save your own backup file '
            'whenever you like.',
      ),
      point(Icons.timeline, 'See how far you\'ve come', 'Shots, weight and progress photos together, from day one.'),
      const SizedBox(height: 8),
      FilledButton(key: const Key('get-started'), onPressed: () => _go(_importStep), child: const Text('Get started')),
      const SizedBox(height: 12),
      _small(context, 'Aloft is a tracking tool, not medical advice.\nIt never tells you how much to take.'),
    ];
  }

  List<Widget> _history(BuildContext context) {
    Widget choice(Key key, IconData icon, String title, String detail, Future<void> Function() open) => Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(detail),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _bringIn(open),
      ),
    );
    return [
      _title('Bringing your history?'),
      _lead(
        context,
        'If you\'ve been tracking somewhere else, start with that. Aloft sets up your medication and weights '
        'from it, and only asks for what\'s missing.',
      ),
      choice(
        const Key('shotsy-link'),
        Icons.file_upload_outlined,
        'Import from Shotsy',
        'The CSV file you exported from Shotsy',
        () => pickShotsyFile(context),
      ),
      choice(
        const Key('restore-link'),
        Icons.restore,
        'Restore an Aloft backup file',
        'From another $deviceWord, or one you saved earlier',
        () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BackupScreen())),
      ),
      const SizedBox(height: 12),
      FilledButton(
        key: const Key('start-fresh'),
        onPressed: () => _go(_medicationStep),
        child: const Text('No, start fresh'),
      ),
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
        FilledButton(
          key: const Key('medication-continue'),
          onPressed: () => _go(_weightStep),
          child: const Text('Continue'),
        ),
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
      if (medications.isEmpty)
        TextButton(
          key: const Key('medication-later'),
          onPressed: () => _go(_weightStep),
          child: const Text('Set this up later'),
        ),
    ];
  }

  List<Widget> _startingWeight(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Oldest first: the first one is where they started.
    final had = [...?ref.watch(weightsProvider).value]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    if (had.isNotEmpty && !_weightSaved) {
      final first = had.first;
      return [
        _title('Where you\'re starting'),
        InfoBox(
          'Your ${had.length == 1 ? 'weight is' : '${had.length} weights are'} already here, starting at '
          '${formatNumber(fromKg(first.kg, _unit), 1)} ${_unit.name} on ${formatFullDate(context, first.measuredAt)}.',
          key: const Key('weights-here'),
        ),
        _lead(context, 'A goal weight and your height are optional. You can set them later in More.'),
        GoalHeightFields(
          draft: _goal,
          weightUnit: _unit,
          lengthUnit: ref.watch(settingsProvider).lengthUnit,
          onChanged: () => setState(() {}),
          weights: {'Starting': first.kg},
        ),
        if (_weightProblem)
          for (final problem in _goal.problems(_unit, ref.watch(settingsProvider).lengthUnit))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                problem,
                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
              ),
            ),
        const SizedBox(height: 20),
        FilledButton(key: const Key('weight-continue'), onPressed: _saveGoal, child: const Text('Continue')),
      ];
    }
    return [
      _title('Where you\'re starting'),
      _lead(
        context,
        'Already on a GLP-1? Use your weight from when you began, so your progress counts from day one. '
        'This is optional.',
      ),
      if (_weightSaved)
        InfoBox('Your starting weight is saved. You can edit it in History, and your goal and height in More.')
      else ...[
        SegmentedButton<WeightUnit>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
            ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
          ],
          selected: {_unit},
          onSelectionChanged: (s) => setState(() {
            final current = _kg, goal = _goal.goalKg(_unit);
            _unit = s.single;
            if (current != null) _weight.text = fromKg(current, _unit).toStringAsFixed(1);
            if (goal != null) _goal.goal.text = fromKg(goal, _unit).toStringAsFixed(1);
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
        GoalHeightFields(
          draft: _goal,
          weightUnit: _unit,
          lengthUnit: ref.watch(settingsProvider).lengthUnit,
          onChanged: () => setState(() {}),
          weights: {'Starting': _kg},
        ),
        if (_weightProblem)
          for (final problem in _goal.problems(_unit, ref.watch(settingsProvider).lengthUnit))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                problem,
                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
              ),
            ),
      ],
      const SizedBox(height: 20),
      FilledButton(
        key: const Key('weight-continue'),
        onPressed: _weightSaved ? () => _go(_photosStep) : _saveWeight,
        child: const Text('Continue'),
      ),
      if (!_weightSaved)
        TextButton(key: const Key('weight-skip'), onPressed: () => _go(_photosStep), child: const Text('Skip')),
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
        onPressed: () => _go(_lastStep),
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
        'Your data stays on this $deviceWord. Save a backup file now and then in More → Backup and restore, '
        'so a lost $deviceWord doesn\'t mean lost history.',
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
