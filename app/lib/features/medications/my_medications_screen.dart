import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/schedule_editor.dart';
import 'catalog.dart';
import 'medication_setup_screen.dart';
import '../../theme/aloft_theme.dart';

/// More → My medications (mockups/MyMeds): usual dose, schedule, the vial in use, and the
/// changes a person makes over time.
class MyMedicationsScreen extends ConsumerWidget {
  const MyMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(medicationsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My medications',
          style: TextStyle(fontFamily: displayFont, fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          for (final detail in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MedicationCard(detail: detail),
            ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.add),
            label: Text(list.isEmpty ? 'Add medication' : 'Add another medication'),
            onPressed: () => startAddMedication(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Dose changes come from what you enter. Aloft never suggests a dose.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  const _MedicationCard({required this.detail});
  final MedicationDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final db = ref.read(databaseProvider);
    final m = detail.medication;
    final supply = detail.supply;
    final paused = m.status == MedicationStatus.paused;
    final isVial = m.form == MedicationForm.compoundedVial;
    final isPill = m.form == MedicationForm.oral;
    final container = isPill ? 'bottle' : (isVial ? 'vial' : 'pen');

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
    Widget action(String label, VoidCallback onTap, {Key? key}) =>
        OutlinedButton(key: key, onPressed: onTap, child: Text(label));
    final dates = MaterialLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                Text(
                  paused ? 'PAUSED' : 'ACTIVE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            Text(describeSupply(detail), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            if (describeUsualDose(detail) case final dose?) line('Usual dose', dose),
            line('Schedule', describeSchedule(context, m)),
            if (supply == null)
              line('Current $container', 'None. Start a new one to keep logging.')
            else ...[
              if (describeRemaining(detail) case final left?) line('Current $container', left),
              if (supply.lotNumber != null) line('Lot', supply.lotNumber!),
              if (supply.dateOpened != null) line('Opened', dates.formatMediumDate(supply.dateOpened!)),
              if (supply.beyondUseDate != null) line('Use by', dates.formatMediumDate(supply.beyondUseDate!)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (supply != null) action('Change dose', () => _changeDose(context, db), key: const Key('changeDose')),
                action('Edit schedule', () => _editSchedule(context, db)),
                if (isVial || isPill)
                  action('Start new $container', () => _startNew(context, db), key: const Key('startNew')),
                if (supply != null && (isVial || isPill))
                  action('Finish this $container', () => _finish(context, db, container)),
                if (supply?.volumeMl != null) action('Adjust what\'s left', () => _adjust(context, db)),
                action(
                  paused ? 'Resume' : 'Pause',
                  () => db.setMedicationStatus(m, paused ? MedicationStatus.active : MedicationStatus.paused),
                ),
              ],
            ),
            if (!paused)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Pausing stops reminders but keeps all your history.',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
            FutureBuilder(
              // Rebuilt with the card whenever supplies change.
              future: db.pastSupplies(m),
              builder: (context, snapshot) {
                final past = snapshot.data ?? const <Supply>[];
                if (past.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Past ${container}s',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                    ),
                    for (final s in past)
                      Text(
                        [
                          if (s.lotNumber != null) 'Lot ${s.lotNumber}',
                          if (s.concentrationMgPerMl != null) '${formatNumber(s.concentrationMgPerMl!, 3)} mg/mL',
                          if (s.pillStrengthMg != null) '${formatNumber(s.pillStrengthMg!, 2)} mg',
                          'started ${formatMonthDay(context, s.dateOpened ?? s.createdAt)}',
                        ].join(' · '),
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeDose(BuildContext context, AloftDatabase db) {
    final usual = detail.usualDose;
    final isPill = detail.medication.form == MedicationForm.oral;
    final strength = detail.supply?.concentrationMgPerMl;
    final amount = TextEditingController(
      text: usual == null || isPill ? '' : formatDoseAmount(usual.prescribedDose, usual.unit),
    );
    var unit = isPill ? DoseUnit.tablets : usual?.unit ?? (strength != null ? DoseUnit.units : DoseUnit.mg);
    var tablets = isPill ? (usual?.prescribedDose ?? 1) : 1.0;
    return _sheet(
      context,
      title: 'Change dose',
      builder: (context, setState) {
        final value = isPill ? tablets : parseAmount(amount.text);
        return [
          if (isPill)
            TabletStepper(value: tablets, onChanged: (v) => setState(() => tablets = v))
          else ...[
            SegmentedButton<DoseUnit>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: DoseUnit.units, label: Text('Units')),
                ButtonSegment(value: DoseUnit.ml, label: Text('mL')),
                ButtonSegment(value: DoseUnit.mg, label: Text('mg')),
              ],
              selected: {unit},
              onSelectionChanged: (s) => setState(() => unit = s.single),
            ),
            const SizedBox(height: 12),
            NumberField(
              key: const Key('newDose'),
              controller: amount,
              suffix: doseUnitLabel(unit),
              large: true,
              onChanged: (_) => setState(() {}),
            ),
          ],
          if (strength != null && value != null && !isPill) ...[
            const SizedBox(height: 10),
            Text(
              conversionLine(
                convertVialDose(amount: value, unit: unit, concentrationMgPerMl: strength),
                unit,
                drugWord(detail.medication),
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Enter what your prescriber ordered. Your earlier dose stays in your history.',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('saveDose'),
            onPressed: value == null
                ? null
                : () async {
                    await db.changeUsualDose(detail.medication, value, unit);
                    if (context.mounted) Navigator.pop(context);
                  },
            child: const Text('Save'),
          ),
        ];
      },
    );
  }

  Future<void> _editSchedule(BuildContext context, AloftDatabase db) {
    final draft = ScheduleDraft.of(detail.medication);
    return _sheet(
      context,
      title: 'Edit schedule',
      builder: (context, setState) => [
        ScheduleEditor(
          draft: draft,
          pill: detail.medication.form == MedicationForm.oral,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: draft.problems.isNotEmpty
              ? null
              : () async {
                  await db.updateSchedule(
                    detail.medication,
                    type: draft.type,
                    days: draft.scheduleDays,
                    interval: draft.scheduleInterval,
                    timeOfDayMinutes: draft.timeOfDayMinutes,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _startNew(BuildContext context, AloftDatabase db) {
    final old = detail.supply;
    final isPill = detail.medication.form == MedicationForm.oral;
    final strength = TextEditingController(
      text: switch (isPill ? old?.pillStrengthMg : old?.concentrationMgPerMl) {
        null => '',
        final value => formatNumber(value, 3),
      },
    );
    final size = TextEditingController(
      text: switch (isPill ? old?.pillCount : old?.volumeMl) {
        null => '',
        final value => formatNumber(value, 2),
      },
    );
    final strengthPer = TextEditingController(text: '1');
    final lot = TextEditingController();
    DateTime? useBy;
    return _sheet(
      context,
      title: isPill ? 'Start new bottle' : 'Start new vial',
      builder: (context, setState) {
        final newStrength = isPill ? parseAmount(strength.text) : vialStrength(strength.text, strengthPer.text);
        final usual = detail.usualDose;
        final oldStrength = old?.concentrationMgPerMl;
        // SPEC section 5: a changed strength is shown as a conversion, never as an instruction.
        String? changed;
        if (!isPill &&
            usual != null &&
            oldStrength != null &&
            newStrength != null &&
            differs(oldStrength, newStrength, decimals: 3)) {
          final before = convertVialDose(
            amount: usual.prescribedDose,
            unit: usual.unit,
            concentrationMgPerMl: oldStrength,
          );
          final sameMg = convertVialDose(amount: before.drugMg, unit: DoseUnit.mg, concentrationMgPerMl: newStrength);
          changed =
              'This vial is a different strength. ${describeAmount(before.drugMg, DoseUnit.mg)} equals '
              '${describeAmount(sameMg.units, DoseUnit.units)} with this vial (it was '
              '${describeAmount(before.units, DoseUnit.units)}). Check your label and prescription, then use '
              'Change dose if your saved dose needs updating.';
        }
        final date = MaterialLocalizations.of(context);
        return [
          FieldLabel(isPill ? 'Strength per pill' : 'Strength, as printed on your label'),
          if (isPill)
            NumberField(
              key: const Key('newStrength'),
              controller: strength,
              suffix: 'mg',
              onChanged: (_) => setState(() {}),
            )
          else
            VialStrengthField(
              mg: strength,
              perMl: strengthPer,
              mgKey: const Key('newStrength'),
              perMlKey: const Key('newStrengthPer'),
              onChanged: (_) => setState(() {}),
            ),
          FieldLabel(isPill ? 'Pills in the bottle (optional)' : 'Vial size'),
          NumberField(controller: size, suffix: isPill ? 'tablets' : 'mL', onChanged: (_) => setState(() {})),
          if (!isPill) ...[
            const FieldLabel('Lot (optional)'),
            TextField(controller: lot),
            const FieldLabel('Use by (optional)'),
            PickerField(
              text: useBy == null ? 'Not set' : date.formatMediumDate(useBy!),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: useBy ?? now,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 3),
                );
                if (picked != null) setState(() => useBy = picked);
              },
            ),
            if (old != null && old.additives.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Other ingredients are carried over: '
                  '${[for (final a in old.additives) '${a.name} ${formatNumber(a.amountPerMl, 3)} ${a.unit}/mL'].join(', ')}.',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
          ],
          if (changed != null) ...[const SizedBox(height: 12), InfoBox(changed, warning: true)],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('saveNew'),
            onPressed: newStrength == null
                ? null
                : () async {
                    await db.startNewSupply(
                      detail.medication,
                      SuppliesCompanion(
                        concentrationMgPerMl: Value(isPill ? null : newStrength),
                        pillStrengthMg: Value(isPill ? newStrength : null),
                        volumeMl: Value(isPill ? null : parseAmount(size.text)),
                        pillCount: Value(isPill ? parseAmount(size.text) : null),
                        additives: Value(old?.additives ?? const []),
                        pharmacy: Value(old?.pharmacy),
                        lotNumber: Value(lot.text.trim().isEmpty ? null : lot.text.trim()),
                        dateOpened: Value(DateTime.now()),
                        beyondUseDate: Value(useBy),
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
            child: Text(old == null ? 'Start' : 'Start, and finish the old one'),
          ),
        ];
      },
    );
  }

  Future<void> _finish(BuildContext context, AloftDatabase db, String container) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finish this $container?'),
        content: Text('It moves to past ${container}s with its doses. You\'ll start a new one before logging again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finish')),
        ],
      ),
    );
    if (confirmed == true) await db.finishSupply(detail.supply!);
  }

  Future<void> _adjust(BuildContext context, AloftDatabase db) {
    final left = TextEditingController(text: formatNumber(detail.remainingMl ?? 0, 2));
    return _sheet(
      context,
      title: 'Adjust what\'s left',
      builder: (context, setState) {
        final value = double.tryParse(left.text.trim().replaceAll(',', '.'));
        final max = detail.supply!.volumeMl! - detail.usedMl;
        final ok = value != null && value >= 0 && value <= max + 1e-9;
        return [
          Text(
            'For a spill or priming the needle. Your logged doses don\'t change.',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const FieldLabel('Left in the vial'),
          NumberField(controller: left, suffix: 'mL', onChanged: (_) => setState(() {})),
          if (value != null && !ok)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'At most ${formatNumber(max, 2)} mL can be left after the doses you\'ve logged.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: !ok
                ? null
                : () async {
                    await db.setRemainingMl(detail, value);
                    if (context.mounted) Navigator.pop(context);
                  },
            child: const Text('Save'),
          ),
        ];
      },
    );
  }
}

/// A bottom sheet with a title and its own state, sized to sit above the keyboard.
Future<void> _sheet(
  BuildContext context, {
  required String title,
  required List<Widget> Function(BuildContext context, StateSetter setState) builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...builder(context, setState),
            ],
          ),
        ),
      ),
    ),
  );
}
