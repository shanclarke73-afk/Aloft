import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../dose/dose_math.dart';
import '../../settings/settings.dart';
import '../../widgets/form_widgets.dart';

/// What the BMI number is, in the app's own words. Shown wherever BMI is.
const bmiNote =
    'BMI is worked out from height and weight only. Aloft shows the number and leaves what it means to you and '
    'your prescriber.';

/// The typed-in goal weight and height, shared by the welcome screens and More.
class GoalHeightDraft {
  GoalHeightDraft({double? goalKg, double? heightCm, required WeightUnit weightUnit, required LengthUnit lengthUnit}) {
    if (goalKg != null) goal.text = formatNumber(fromKg(goalKg, weightUnit), 1);
    if (heightCm != null) {
      if (lengthUnit == LengthUnit.cm) {
        heightMain.text = formatNumber(heightCm, 1);
      } else {
        // Rounded to the half inch first, so 5 ft 12 in can't appear.
        final halfInches = (heightCm / cmPerInch * 2).round();
        heightMain.text = '${halfInches ~/ 24}';
        heightInches.text = formatNumber((halfInches % 24) / 2, 1);
      }
    }
  }

  final goal = TextEditingController();

  /// Feet, or centimetres.
  final heightMain = TextEditingController();
  final heightInches = TextEditingController();

  void dispose() {
    goal.dispose();
    heightMain.dispose();
    heightInches.dispose();
  }

  bool get _goalBlank => goal.text.trim().isEmpty;
  bool get _heightBlank => heightMain.text.trim().isEmpty && heightInches.text.trim().isEmpty;

  double? goalKg(WeightUnit unit) {
    final typed = parseAmount(goal.text);
    if (typed == null) return null;
    final kg = toKg(typed, unit);
    return kg >= 20 && kg <= 500 ? kg : null;
  }

  double? heightCm(LengthUnit unit) {
    final double cm;
    if (unit == LengthUnit.cm) {
      final typed = parseAmount(heightMain.text);
      if (typed == null) return null;
      cm = typed;
    } else {
      final feet = heightMain.text.trim().isEmpty ? 0.0 : parseAmount(heightMain.text);
      final inches = heightInches.text.trim().isEmpty ? 0.0 : parseAmount(heightInches.text);
      if (feet == null || inches == null || inches >= 12) return null;
      cm = (feet * 12 + inches) * cmPerInch;
    }
    return cm >= 90 && cm <= 250 ? cm : null;
  }

  /// What needs fixing, in plain words. Blank fields are fine: both are optional.
  List<String> problems(WeightUnit weightUnit, LengthUnit lengthUnit) => [
    if (!_goalBlank && goalKg(weightUnit) == null) 'Check your goal weight, or leave it blank.',
    if (!_heightBlank && heightCm(lengthUnit) == null) 'Check your height, or leave it blank.',
  ];
}

/// Goal weight and height fields, with BMI shown beside them once there is a height.
class GoalHeightFields extends StatelessWidget {
  const GoalHeightFields({
    super.key,
    required this.draft,
    required this.weightUnit,
    required this.lengthUnit,
    required this.onChanged,
    this.weights = const {},
  });
  final GoalHeightDraft draft;
  final WeightUnit weightUnit;
  final LengthUnit lengthUnit;
  final VoidCallback onChanged;

  /// Other weights to show a BMI for, by label: "Starting" → kg.
  final Map<String, double?> weights;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant);
    final height = draft.heightCm(lengthUnit);
    final goal = draft.goalKg(weightUnit);
    final lines = [
      for (final MapEntry(key: label, value: kg) in {...weights, 'Goal': goal}.entries)
        if (kg != null && height != null) '$label BMI ${formatBmi(kg, height)}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Goal weight (optional)'),
        NumberField(
          key: const Key('goal-weight'),
          controller: draft.goal,
          suffix: weightUnit.name,
          onChanged: (_) => onChanged(),
        ),
        const FieldLabel('Height (optional, for BMI)'),
        if (lengthUnit == LengthUnit.cm)
          NumberField(
            key: const Key('height-cm'),
            // The unit only shows inside a field once it has focus; the hint labels it before that.
            hint: 'cm',
            controller: draft.heightMain,
            suffix: 'cm',
            onChanged: (_) => onChanged(),
          )
        else
          Row(
            children: [
              Expanded(
                child: NumberField(
                  key: const Key('height-ft'),
                  // The unit only shows inside a field once it has focus; the hint labels it before that.
                  hint: 'ft',
                  controller: draft.heightMain,
                  suffix: 'ft',
                  wholeNumber: true,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NumberField(
                  key: const Key('height-in'),
                  // The unit only shows inside a field once it has focus; the hint labels it before that.
                  hint: 'in',
                  controller: draft.heightInches,
                  suffix: 'in',
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 4),
          Text(bmiNote, style: muted),
        ] else if (height == null) ...[
          const SizedBox(height: 6),
          Text('Add your height to see BMI. Leave it blank and BMI stays off.', style: muted),
        ],
      ],
    );
  }
}

/// More → Goal weight and BMI: change the goal and height after the welcome screens.
class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  late final GoalHeightDraft _draft;
  bool _showProblems = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _draft = GoalHeightDraft(
      goalKg: s.goalWeightKg,
      heightCm: s.heightCm,
      weightUnit: s.weightUnit,
      lengthUnit: s.lengthUnit,
    );
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = ref.read(settingsProvider);
    if (_draft.problems(s.weightUnit, s.lengthUnit).isNotEmpty) {
      setState(() => _showProblems = true);
      return;
    }
    await ref
        .read(settingsProvider.notifier)
        .setGoalAndHeight(goalWeightKg: _draft.goalKg(s.weightUnit), heightCm: _draft.heightCm(s.lengthUnit));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    // Newest first.
    final weights = ref.watch(weightsProvider).value ?? const <Weight>[];
    final problems = _draft.problems(s.weightUnit, s.lengthUnit);
    return Scaffold(
      appBar: AppBar(title: const Text('Goal weight and BMI')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          GoalHeightFields(
            draft: _draft,
            weightUnit: s.weightUnit,
            lengthUnit: s.lengthUnit,
            onChanged: () => setState(() {}),
            weights: {
              if (weights.length > 1) 'Starting': weights.last.kg,
              if (weights.isNotEmpty) 'Current': weights.first.kg,
            },
          ),
          if (_showProblems)
            for (final problem in problems)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  problem,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                ),
              ),
          const SizedBox(height: 20),
          FilledButton(key: const Key('goal-save'), onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}

/// "Goal 150 lb · BMI on", for the More row.
String describeGoal(AppSettings s) => [
  if (s.goalWeightKg case final kg?) 'Goal ${formatNumber(fromKg(kg, s.weightUnit), 1)} ${s.weightUnit.name}',
  s.heightCm == null ? 'BMI off' : 'BMI on',
].join(' · ');
