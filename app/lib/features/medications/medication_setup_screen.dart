import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../settings/settings.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/schedule_editor.dart';
import 'catalog.dart';
import 'medication_limit.dart';
import '../../theme/aloft_theme.dart';
import '../../widgets/system_bar_spacer.dart';

/// Asks which kind of medication, then opens the setup screen for it. One medication at a
/// time is free; with one already active this shows the Pro screen first.
Future<void> startAddMedication(BuildContext context, WidgetRef ref) async {
  if (!await allowAnotherActive(context, ref) || !context.mounted) return;
  final form = await showModalBottomSheet<MedicationForm>(
    context: context,
    showDragHandle: true,
    // Scrolls on a short screen or with large text, instead of cutting the last choice off.
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What are you taking?',
                  style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            for (final (form, title, subtitle) in const [
              (MedicationForm.brandPen, 'Brand-name pen', 'Ozempic®, Wegovy®, Mounjaro®, Zepbound® and others'),
              (
                MedicationForm.compoundedVial,
                'Compounded vial',
                'From a pharmacy, drawn with a syringe: semaglutide, tirzepatide, or add-ons like NAD+ and B12',
              ),
              (MedicationForm.oral, 'Pill', 'Oral GLP-1s such as Rybelsus®'),
            ])
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, form),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (form == null || !context.mounted) return;
  await Navigator.of(context)
      .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => MedicationSetupScreen(form: form)));
}

/// Typed-in setup for a compounded vial, a brand-name pen or a pill (SPEC 6.2, mockups/VialSetupTyped).
class MedicationSetupScreen extends ConsumerStatefulWidget {
  const MedicationSetupScreen({super.key, required this.form});
  final MedicationForm form;

  @override
  ConsumerState<MedicationSetupScreen> createState() => _MedicationSetupScreenState();
}

class _AdditiveRow {
  final name = TextEditingController();
  final amount = TextEditingController();
  String unit = 'mg';
}

class _MedicationSetupScreenState extends ConsumerState<MedicationSetupScreen> {
  static const _other = KnownDrug('Something else', 'other', isGlp1: false);

  KnownDrug? _drug;
  final _customName = TextEditingController();
  final _strength = TextEditingController();
  final _strengthPer = TextEditingController(text: '1');
  final _vialSize = TextEditingController();
  final _pillCount = TextEditingController();
  final _dose = TextEditingController();
  final _pharmacy = TextEditingController();
  final _lot = TextEditingController();
  final _cost = TextEditingController();
  final _additives = <_AdditiveRow>[];

  /// Names offered when adding an ingredient: ones typed on earlier vials, then the common ones.
  List<String> _suggestions = commonAdditives;

  late DoseUnit _doseUnit;
  double _tablets = 1;
  late final ScheduleDraft _scheduleDraft;
  DateTime? _opened;
  DateTime? _useBy;
  bool _showProblems = false;
  bool _saving = false;

  bool get _isVial => widget.form == MedicationForm.compoundedVial;
  bool get _isPill => widget.form == MedicationForm.oral;

  @override
  void initState() {
    super.initState();
    _doseUnit = _isVial ? DoseUnit.units : DoseUnit.mg;
    _scheduleDraft = ScheduleDraft(type: _isPill ? ScheduleType.daily : ScheduleType.weekly);
    if (_isVial) _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final used = await ref.read(databaseProvider).usedAdditiveNames();
    if (!mounted || used.isEmpty) return;
    final seen = <String>{};
    setState(() => _suggestions = [...used, ...commonAdditives].where((a) => seen.add(a.toLowerCase())).toList());
  }

  @override
  void dispose() {
    for (final c in [_customName, _strength, _strengthPer, _vialSize, _pillCount, _dose, _pharmacy, _lot, _cost]) {
      c.dispose();
    }
    _scheduleDraft.dispose();
    for (final row in _additives) {
      row.name.dispose();
      row.amount.dispose();
    }
    super.dispose();
  }

  String get _name => _drug == null || _drug == _other ? _customName.text.trim() : _drug!.label;
  double? get _strengthValue => _isVial ? vialStrength(_strength.text, _strengthPer.text) : parseAmount(_strength.text);
  double? get _doseValue => _isPill ? _tablets : parseAmount(_dose.text);

  List<Additive> get _additiveValues => [
    for (final row in _additives)
      if (row.name.text.trim().isNotEmpty && parseAmount(row.amount.text) != null)
        Additive(name: row.name.text.trim(), amountPerMl: parseAmount(row.amount.text)!, unit: row.unit),
  ];

  /// What still needs filling in, in plain words. Empty when ready to save.
  List<String> get _problems => [
    if (_name.isEmpty) 'Choose or type the medication.',
    if (_isVial && _strengthValue == null) 'Enter the strength from your label: the mg, and the mL it is in.',
    if (_isPill && _strengthValue == null) 'Enter the strength per pill in mg.',
    if (_doseValue == null) 'Enter your dose.',
    if (_isVial && _vialSize.text.trim().isNotEmpty && parseAmount(_vialSize.text) == null)
      'Vial size should be a number of mL.',
    ..._scheduleDraft.problems,
    for (final row in _additives)
      if (row.name.text.trim().isNotEmpty != (parseAmount(row.amount.text) != null))
        'Each other ingredient needs a name and an amount per mL.',
  ];

  Future<void> _save() async {
    if (_problems.isNotEmpty) {
      setState(() => _showProblems = true);
      return;
    }
    setState(() => _saving = true);
    final drug = _drug == null || _drug == _other ? null : _drug;
    await ref
        .read(databaseProvider)
        .addMedication(
          NewMedication(
            name: _name,
            activeIngredient: drug?.ingredient ?? 'other',
            isGlp1: drug?.isGlp1 ?? false,
            form: widget.form,
            scheduleType: _scheduleDraft.type,
            scheduleDays: _scheduleDraft.scheduleDays,
            scheduleInterval: _scheduleDraft.scheduleInterval,
            timeOfDayMinutes: _scheduleDraft.timeOfDayMinutes,
            concentrationMgPerMl: _isVial ? _strengthValue : null,
            pillStrengthMg: _isPill ? _strengthValue : null,
            additives: _isVial ? _additiveValues : const [],
            volumeMl: _isVial ? parseAmount(_vialSize.text) : null,
            pillCount: _isPill ? parseAmount(_pillCount.text) : null,
            pharmacy: _textOrNull(_pharmacy),
            lotNumber: _textOrNull(_lot),
            dateOpened: _opened,
            beyondUseDate: _useBy,
            cost: parseAmount(_cost.text),
            doseAmount: _doseValue,
            doseUnit: _isPill ? DoseUnit.tablets : _doseUnit,
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  static String? _textOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = switch (widget.form) {
      MedicationForm.compoundedVial => 'New vial',
      MedicationForm.brandPen => 'New pen',
      _ => 'New pill',
    };
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        leadingWidth: 88,
        title: Text(
          title,
          style: const TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      // Not a ListView: that would discard fields scrolled off screen, and what was typed in them.
      bottomNavigationBar: const SystemBarSpacer(),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isVial
                  ? 'Copy these from your vial label and prescription. You can change them later in My medications.'
                  : 'Enter what your prescriber ordered, whatever the amount.',
              style: TextStyle(fontSize: 14, height: 1.4, color: scheme.onSurfaceVariant),
            ),
            const FieldLabel('Medication'),
            DropdownMenu<KnownDrug>(
              key: const Key('medication'),
              expandedInsets: EdgeInsets.zero,
              hintText: 'Choose',
              initialSelection: _drug,
              requestFocusOnTap: false,
              dropdownMenuEntries: [
                for (final drug in [...drugsFor(widget.form), _other])
                  DropdownMenuEntry(value: drug, label: drug.label),
              ],
              onSelected: (drug) => setState(() => _drug = drug),
            ),
            if (_drug == _other) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Type a name'),
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (_isVial)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'GLP-1s get a level chart. Add-ons like NAD+ get logging and reminders.',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
            if (_isVial) ...[
              const FieldLabel('Strength, as printed on your label'),
              VialStrengthField(
                mg: _strength,
                perMl: _strengthPer,
                mgKey: const Key('strength'),
                perMlKey: const Key('strengthPer'),
                onChanged: _refresh,
              ),
              const FieldLabel('Vial size'),
              NumberField(key: const Key('vialSize'), controller: _vialSize, suffix: 'mL', onChanged: _refresh),
              const FieldLabel('Other ingredients'),
              for (final row in _additives) _additiveRow(row),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add ingredient'),
                  onPressed: () => setState(() => _additives.add(_AdditiveRow())),
                ),
              ),
            ],
            if (_isPill) ...[
              const FieldLabel('Strength per pill'),
              NumberField(key: const Key('strength'), controller: _strength, suffix: 'mg', onChanged: _refresh),
            ],
            const SizedBox(height: 20),
            _doseCard(context),
            if (_isVial) ...[
              const FieldLabel('Pharmacy (optional)'),
              TextField(controller: _pharmacy, textCapitalization: TextCapitalization.words),
              const FieldLabel('Lot (optional)'),
              TextField(controller: _lot),
              Row(
                children: [
                  Expanded(
                    child: _dateField('Use by (optional)', _useBy, (d) => setState(() => _useBy = d), future: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _dateField('Opened (optional)', _opened, (d) => setState(() => _opened = d))),
                ],
              ),
              const FieldLabel('Cost (optional)'),
              NumberField(controller: _cost, onChanged: _refresh),
            ],
            if (_isPill) ...[
              const FieldLabel('Pills left in bottle (optional)'),
              NumberField(controller: _pillCount, suffix: 'tablets', onChanged: _refresh),
            ],
            if (_vialSummary case final summary?) ...[const SizedBox(height: 20), InfoBox(summary)],
            if (_showProblems && _problems.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final problem in _problems.toSet())
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    problem,
                    style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('save'),
              onPressed: _saving ? null : _save,
              child: Text(_isVial ? 'Save vial' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _refresh(String _) => setState(() {});

  Widget _additiveRow(_AdditiveRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Autocomplete<String>(
              // The list is only a shortcut: whatever is typed is kept, and offered back as
              // its own choice so it is clear a name outside the list is fine.
              optionsBuilder: (value) {
                final typed = value.text.trim();
                if (typed.isEmpty) return _suggestions;
                final matches = _suggestions.where((a) => a.toLowerCase().contains(typed.toLowerCase())).toList();
                return [...matches, if (!matches.any((a) => a.toLowerCase() == typed.toLowerCase())) typed];
              },
              onSelected: (value) => setState(() => row.name.text = value),
              optionsViewBuilder: (context, onSelected, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240, maxWidth: 260),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        for (final option in options)
                          ListTile(
                            dense: true,
                            title: Text(_suggestions.contains(option) ? option : 'Use "$option"'),
                            onTap: () => onSelected(option),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
                controller: controller,
                focusNode: focus,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Type or choose'),
                onChanged: (value) => setState(() => row.name.text = value),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: NumberField(controller: row.amount, hint: 'Per mL', onChanged: _refresh),
          ),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: row.unit,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'mg', child: Text('mg')),
              DropdownMenuItem(value: 'mcg', child: Text('mcg')),
            ],
            onChanged: (unit) => setState(() => row.unit = unit!),
          ),
          IconButton(
            tooltip: 'Remove ingredient',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _additives.remove(row)),
          ),
        ],
      ),
    );
  }

  Widget _doseCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strength = _strengthValue;
    final dose = _doseValue;
    final drug = _name.isEmpty ? 'medication' : _name.toLowerCase();
    String? conversion;
    var extras = const <String>[];
    if (_isVial && strength != null && dose != null) {
      final converted = convertVialDose(amount: dose, unit: _doseUnit, concentrationMgPerMl: strength);
      conversion = '= ${conversionLine(converted, _doseUnit, drug).split(' = ').skip(1).join(' = ')}';
      extras = additiveLines(_additiveValues, converted.volumeMl);
    } else if (_isPill && strength != null) {
      conversion = '= ${describeAmount(_tablets * strength, DoseUnit.mg)} $drug each time';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Your dose', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                Text('As prescribed', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            if (_isPill)
              TabletStepper(value: _tablets, onChanged: (v) => setState(() => _tablets = v))
            else ...[
              SegmentedButton<DoseUnit>(
                showSelectedIcon: false,
                segments: [
                  for (final unit
                      in _isVial
                          ? const [DoseUnit.units, DoseUnit.ml, DoseUnit.mg]
                          : const [DoseUnit.mg, DoseUnit.units, DoseUnit.ml])
                    ButtonSegment(value: unit, label: Text(doseUnitLabel(unit))),
                ],
                selected: {_doseUnit},
                onSelectionChanged: (s) => setState(() => _doseUnit = s.single),
              ),
              const SizedBox(height: 12),
              NumberField(
                key: const Key('dose'),
                controller: _dose,
                hint: 'Amount',
                suffix: doseUnitLabel(_doseUnit),
                onChanged: _refresh,
              ),
            ],
            if (conversion != null) ...[
              const SizedBox(height: 10),
              Text(conversion, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              for (final line in extras)
                Text('$line · U-100 syringe', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            ],
            ScheduleEditor(draft: _scheduleDraft, pill: _isPill, onChanged: () => setState(() {})),
            const SizedBox(height: 12),
            Text(
              'Enter what your prescriber ordered. Aloft converts it but never suggests a dose.',
              style: TextStyle(fontSize: 12, height: 1.4, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, void Function(DateTime) onPicked, {bool future = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        PickerField(
          text: value == null ? 'Not set' : MaterialLocalizations.of(context).formatMediumDate(value),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: DateTime(now.year - 3),
              lastDate: future ? DateTime(now.year + 3) : now,
            );
            if (picked != null) onPicked(picked);
          },
        ),
      ],
    );
  }

  /// "20 mg tirzepatide in this vial · About 8 doses at 25 units".
  String? get _vialSummary {
    final strength = _strengthValue, size = parseAmount(_vialSize.text), dose = _doseValue;
    if (!_isVial || strength == null || size == null) return null;
    final total =
        '${describeAmount(strength * size, DoseUnit.mg)} ${_name.isEmpty ? '' : '${_name.toLowerCase()} '}in this vial';
    if (dose == null) return total;
    final converted = convertVialDose(amount: dose, unit: _doseUnit, concentrationMgPerMl: strength);
    final n = dosesIn(size, converted.volumeMl);
    if (n == null) return total;
    return '$total\nAbout $n ${n == 1 ? 'dose' : 'doses'} at ${describeAmount(dose, _doseUnit)}';
  }
}
