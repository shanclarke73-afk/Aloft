import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../dose/injection_sites.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import '../medications/catalog.dart';

Future<void> openLogDose(BuildContext context, MedicationDetail detail) async {
  final history = await ProviderScope.containerOf(context, listen: false).read(databaseProvider).siteHistory();
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => LogDoseScreen(detail: detail, siteHistory: history),
    ),
  );
}

/// Log a shot or a pill (SPEC 6.4, mockups/LogShot and LogPill).
class LogDoseScreen extends ConsumerStatefulWidget {
  const LogDoseScreen({super.key, required this.detail, required this.siteHistory});
  final MedicationDetail detail;

  /// Sites logged across every medication, newest first.
  final List<({InjectionSite site, DateTime takenAt})> siteHistory;

  @override
  ConsumerState<LogDoseScreen> createState() => _LogDoseScreenState();
}

class _LogDoseScreenState extends ConsumerState<LogDoseScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late DoseUnit _unit;
  double _tablets = 1;
  late InjectionSite _site;
  late final InjectionSite _suggested;
  DateTime _when = DateTime.now();
  int _pain = 0;
  bool _showProblem = false;
  bool _saving = false;

  MedicationDetail get _d => widget.detail;
  Medication get _med => _d.medication;
  Supply get _supply => _d.supply!;
  bool get _isPill => _med.form == MedicationForm.oral;
  double? get _strength => _supply.concentrationMgPerMl;

  @override
  void initState() {
    super.initState();
    // Starts from the last dose taken, else the usual dose. Both were typed by the person.
    final last = _d.lastDose, usual = _d.usualDose;
    final amount = last?.amountEntered ?? usual?.prescribedDose;
    _unit = last?.unitEntered ?? usual?.unit ?? (_strength != null ? DoseUnit.units : DoseUnit.mg);
    if (_isPill) {
      _unit = DoseUnit.tablets;
      _tablets = amount ?? 1;
    } else if (amount != null) {
      _amount.text = formatDoseAmount(amount, _unit);
    }
    _suggested = suggestSite([for (final entry in widget.siteHistory) entry.site]);
    _site = _suggested;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  double? get _value => _isPill ? _tablets : parseAmount(_amount.text);

  VialDose? get _converted {
    final value = _value, strength = _strength;
    if (value == null || strength == null || _isPill) return null;
    return convertVialDose(amount: value, unit: _unit, concentrationMgPerMl: strength);
  }

  /// This dose and an earlier one as comparable numbers: mg when both have it, otherwise the
  /// typed amounts when they share a unit. Null when they can't be compared.
  (double, double)? _comparable(double amount, DoseUnit unit) {
    final value = _value;
    if (value == null) return null;
    final strength = _strength;
    if (strength != null && unit != DoseUnit.tablets) {
      final other = convertVialDose(amount: amount, unit: unit, concentrationMgPerMl: strength);
      return (_converted!.drugMg, other.drugMg);
    }
    return unit == _unit ? (value, amount) : null;
  }

  /// Shown, never blocking (SPEC section 5).
  ({String text, bool warning})? get _check {
    if (_value == null) return null;
    final last = _d.lastDose, usual = _d.usualDose;
    final vsLast = last == null ? null : _comparable(last.amountEntered, last.unitEntered);
    final vsUsual = usual == null ? null : _comparable(usual.prescribedDose, usual.unit);
    if (vsLast != null && differsALot(vsLast.$1, vsLast.$2)) {
      return (
        text:
            'This is different from your last dose (${describeAmount(last!.amountEntered, last.unitEntered)}). '
            'Double-check your label and prescription.',
        warning: true,
      );
    }
    if (vsUsual != null && differs(vsUsual.$1, vsUsual.$2)) {
      return (
        text:
            'This is different from your saved dose (${describeAmount(usual!.prescribedDose, usual.unit)}). '
            'Double-check your label and prescription.',
        warning: true,
      );
    }
    final sameAsLast = vsLast != null && !differs(vsLast.$1, vsLast.$2);
    if (vsUsual != null) {
      return (
        text: sameAsLast ? 'Same as your prescription and last dose' : 'Same as your prescription',
        warning: false,
      );
    }
    return sameAsLast ? (text: 'Same as your last dose', warning: false) : null;
  }

  Future<void> _save({bool skipped = false}) async {
    final value = _value;
    if (!skipped && value == null) {
      setState(() => _showProblem = true);
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(databaseProvider)
        .logDose(
          medication: _med,
          supply: _supply,
          amount: value ?? 0,
          unit: _unit,
          takenAt: _when,
          site: _isPill ? null : _site,
          pain: _pain,
          notes: _note.text,
          skipped: skipped,
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(skipped ? 'Saved as skipped.' : 'Saved.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, height: 1.4, color: scheme.onSurfaceVariant);
    final check = _check;
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        leadingWidth: 88,
        title: Text(
          _isPill ? 'Log dose' : 'Log shot',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      // Not a ListView: that would discard fields scrolled off screen, and what was typed in them.
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text(_med.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text([describeSupply(_d), ?describeRemaining(_d)].join('\n')),
              ),
            ),
            const SizedBox(height: 16),
            if (_isPill) ...[
              const FieldLabel('How many tablets'),
              TabletStepper(value: _tablets, onChanged: (v) => setState(() => _tablets = v)),
              if (_supply.pillStrengthMg case final strength?) ...[
                const SizedBox(height: 10),
                Text(
                  '= ${describeAmount(_tablets * strength, DoseUnit.mg)} ${drugWord(_med)} by mouth',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ] else ...[
              SegmentedButton<DoseUnit>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: DoseUnit.units, label: Text('Units')),
                  ButtonSegment(value: DoseUnit.ml, label: Text('mL')),
                  ButtonSegment(value: DoseUnit.mg, label: Text('mg')),
                ],
                selected: {_unit},
                onSelectionChanged: (s) => setState(() {
                  // On a vial, switching units keeps the same dose and shows it in the new unit.
                  final converted = _converted;
                  _unit = s.single;
                  if (converted != null) _amount.text = formatDoseAmount(converted.amountIn(_unit), _unit);
                }),
              ),
              FieldLabel('Amount in ${doseUnitLabel(_unit)}'),
              NumberField(
                key: const Key('amount'),
                controller: _amount,
                suffix: doseUnitLabel(_unit),
                large: true,
                onChanged: (_) => setState(() {}),
              ),
              if (_converted case final dose?) ...[
                const SizedBox(height: 10),
                Text(
                  '= ${conversionLine(dose, _unit, drugWord(_med)).split(' = ').skip(1).join(' = ')}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                for (final line in additiveLines(_supply.additives, dose.volumeMl))
                  Text(line, style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(mathLine(dose, _unit, _strength!), style: muted),
              ],
            ],
            if (_showProblem && _value == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Enter the amount.',
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                ),
              ),
            if (check != null) ...[const SizedBox(height: 12), InfoBox(check.text, warning: check.warning)],
            if (!_isPill) ...[
              const FieldLabel('Injection site'),
              Card(
                child: ListTile(
                  title: Text(_site.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(_siteNote(context)),
                  trailing: TextButton(onPressed: _chooseSite, child: const Text('Choose another')),
                ),
              ),
            ],
            const FieldLabel('When'),
            PickerField(text: formatWhen(context, _when), onTap: _chooseWhen),
            if (!_isPill) ...[
              FieldLabel('Pain  $_pain/10'),
              Slider(
                value: _pain.toDouble(),
                max: 10,
                divisions: 10,
                label: '$_pain',
                onChanged: (v) => setState(() => _pain = v.round()),
              ),
            ],
            const FieldLabel('Note'),
            TextField(controller: _note, maxLines: 2, textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('save'),
              onPressed: _saving ? null : _save,
              child: Text(_isPill ? 'Took it' : 'Save'),
            ),
            TextButton(
              onPressed: _saving ? null : () => _save(skipped: true),
              child: Text(_isPill ? 'Skipped today' : 'Skip this dose'),
            ),
            const SizedBox(height: 8),
            Text(
              _isPill
                  ? 'Aloft records what you took. It never suggests a dose.'
                  : 'Aloft converts what your label says. It never suggests a dose.',
              textAlign: TextAlign.center,
              style: muted,
            ),
          ],
        ),
      ),
    );
  }

  String _siteNote(BuildContext context) {
    final last = widget.siteHistory.firstOrNull;
    return [
      if (_site == _suggested) 'Next in your rotation',
      if (last != null) 'last: ${last.site.label.toLowerCase()}, ${formatDay(context, last.takenAt)}',
    ].join(' · ');
  }

  Future<void> _chooseSite() async {
    final picked = await showModalBottomSheet<InjectionSite>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final site in InjectionSite.values)
              ListTile(
                title: Text(site.label),
                subtitle: site == _suggested ? const Text('Next in your rotation') : null,
                trailing: site == _site ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, site),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _site = picked);
  }

  Future<void> _chooseWhen() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (time == null) return;
    setState(() => _when = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
}
