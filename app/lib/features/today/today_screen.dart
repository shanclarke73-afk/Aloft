import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../progress/add_photos_screen.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../reminders/reminder_plan.dart';
import '../../schedule/schedule.dart';
import '../../settings/settings.dart';
import '../../theme/aloft_theme.dart';
import '../../util/format.dart';
import '../body/log_side_effect_screen.dart';
import '../charts/charts_screen.dart';
import '../body/log_weight_screen.dart';
import '../log/log_dose_screen.dart';
import '../medications/medication_setup_screen.dart';

/// Today tab (mockups/Main, TodayLate, MainTwoMeds). Estimated level, weight and photo cards
/// arrive with those features.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key, this.now});

  /// Fixed clock for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider);
    final at = now ?? DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      floatingActionButton: medications.value?.isNotEmpty ?? false
          ? FloatingActionButton(
              tooltip: 'Add to your log',
              backgroundColor: AloftColors.teal,
              foregroundColor: Colors.white,
              onPressed: () => showQuickAdd(context, medications.value!, at),
              child: const Icon(Icons.add),
            )
          : null,
      body: medications.when(
        loading: () => const SizedBox.shrink(),
        error: (error, _) =>
            Center(child: Text('Couldn\'t load your medications.\n$error', textAlign: TextAlign.center)),
        data: (all) {
          if (all.isEmpty) return const _NoMedication();
          final active = [
            for (final d in all)
              if (d.medication.status == MedicationStatus.active) d,
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              if (active.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Your medications are paused. Resume one in More → My medications.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              for (final d in active) ...[
                DueCard(detail: d, now: at),
                const SizedBox(height: 12),
                if (SupplyCard.hasSomethingToShow(d)) ...[SupplyCard(detail: d), const SizedBox(height: 12)],
              ],
              for (final series in ref.watch(levelSeriesProvider)) ...[
                LevelCard(series: series, now: at),
                const SizedBox(height: 12),
              ],
              const WeightCard(),
            ],
          );
        },
      ),
    );
  }
}

/// Quick-add menu from the + button (mockups/QuickAdd). Only what's built so far is listed.
Future<void> showQuickAdd(BuildContext context, List<MedicationDetail> medications, DateTime now) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add to your log',
                style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          for (final d in medications)
            if (d.supply != null && d.medication.status == MedicationStatus.active)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  d.medication.form == MedicationForm.oral ? Icons.medication_outlined : Icons.vaccines_outlined,
                ),
                title: Text(
                  '${d.medication.form == MedicationForm.oral ? 'Log dose' : 'Log shot'}'
                  '${medications.length > 1 ? ' · ${d.medication.name}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: switch (dueStatus(
                  DoseSchedule.of(d.medication).nextDue(lastLogged: d.lastLogged?.takenAt),
                  now,
                )) {
                  null => null,
                  final status => Text(describeDue(sheet, status)),
                },
                onTap: () {
                  Navigator.pop(sheet);
                  openLogDose(context, d);
                },
              ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.monitor_weight_outlined),
            title: const Text('Weight', style: TextStyle(fontWeight: FontWeight.w700)),
            onTap: () {
              Navigator.pop(sheet);
              openLogWeight(context);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.sick_outlined),
            title: const Text('Side effect', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Nausea, fatigue…'),
            onTap: () {
              Navigator.pop(sheet);
              openLogSideEffect(context);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Progress photos', style: TextStyle(fontWeight: FontWeight.w700)),
            onTap: () {
              Navigator.pop(sheet);
              startAddPhotos(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// "Due today, 8:00 PM", "Due Thursday, 8:00 PM", "Thursday's dose · 2 days ago".
String describeDue(BuildContext context, DueStatus status) {
  final time = formatTime(context, status.due.hour * 60 + status.due.minute);
  final weekday = weekdayLong[status.due.weekday - 1];
  return switch (status.state) {
    DueState.today => 'Due today, $time',
    DueState.upcoming => status.days == 1 ? 'Next: tomorrow, $time' : 'Next: $weekday, $time',
    DueState.late => 'Not logged yet · due ${status.days == 1 ? 'yesterday' : '${status.days} days ago'}',
  };
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
          const Text(
            'Add your medication',
            style: TextStyle(fontFamily: displayFont, fontSize: 22, fontWeight: FontWeight.w800),
          ),
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

/// The navy card: when this medication is due, and the Log button. When a dose is late it
/// offers the three ways to record what happened; it never says what to do about a late dose.
class DueCard extends ConsumerWidget {
  const DueCard({super.key, required this.detail, required this.now});
  final MedicationDetail detail;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = detail.medication;
    final pill = m.form == MedicationForm.oral;
    final noun = pill ? 'dose' : 'shot';
    final status = dueStatus(DoseSchedule.of(m).nextDue(lastLogged: detail.lastLogged?.takenAt), now);
    final time = status == null ? '' : formatTime(context, status.due.hour * 60 + status.due.minute);
    final weekday = status == null ? '' : weekdayLong[status.due.weekday - 1];
    final (label, headline) = switch (status?.state) {
      null => ('As needed', 'Log when you take it'),
      DueState.today => (pill ? 'Dose today' : 'Shot day', 'Today, $time'),
      DueState.upcoming => ('Next $noun', status!.days == 1 ? 'Tomorrow, $time' : '$weekday, $time'),
      DueState.late => (
        'Not logged yet',
        '$weekday\'s $noun · ${status!.days == 1 ? 'yesterday' : '${status.days} days ago'}',
      ),
    };
    final week = now.difference(DateUtils.dateOnly(m.startDate)).inDays ~/ 7 + 1;
    const soft = TextStyle(fontSize: 13, height: 1.4, color: AloftColors.mist);
    final late = status?.state == DueState.late;

    return Container(
      decoration: BoxDecoration(color: AloftColors.navy, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AloftColors.tealLight),
                ),
              ),
              Text('Week $week', style: soft),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            headline,
            style: const TextStyle(
              fontFamily: displayFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (status != null && status.state == DueState.upcoming && status.days > 1)
            Text('in ${status.days} days', style: soft),
          const SizedBox(height: 8),
          Text([m.name, describeSupply(detail)].join(' · '), style: soft),
          if (describeUsualDose(detail) case final dose?) Text('Usual dose: $dose', style: soft),
          if (detail.lastDose case final last?)
            Text('Last $noun: ${formatWhen(context, last.takenAt, now: now)}', style: soft),
          const SizedBox(height: 14),
          if (detail.supply == null)
            const Text('Start a new vial in More → My medications to log again.', style: soft)
          else if (late) ...[
            _LateChoice(
              title: 'Taking it now',
              subtitle: 'Logs it for today',
              onTap: () => openLogDose(context, detail),
            ),
            _LateChoice(
              title: 'I took it, just didn\'t log it',
              subtitle: 'Logs it for $weekday, or the day you pick',
              onTap: () => openLogDose(context, detail, when: status!.due),
            ),
            _LateChoice(
              title: pill ? 'Skipped it' : 'Skipped this one',
              subtitle: 'Keeps your schedule',
              onTap: () => ref
                  .read(databaseProvider)
                  .logDose(
                    medication: m,
                    supply: detail.supply!,
                    amount: 0,
                    unit:
                        detail.usualDose?.unit ??
                        detail.lastDose?.unitEntered ??
                        (pill ? DoseUnit.tablets : DoseUnit.mg),
                    takenAt: status!.due,
                    skipped: true,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Not sure what to do about a late dose? Check your medication\'s instructions or ask your '
              'prescriber. Aloft only keeps your record.',
              style: soft,
            ),
          ] else if (status?.state == DueState.upcoming)
            // Nothing is due, so the button stays quiet: a bright one reads as "you haven't logged this".
            OutlinedButton(
              key: const Key('log-early'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AloftColors.mist),
              ),
              onPressed: () => openLogDose(context, detail),
              child: Text(pill ? 'Log a dose early' : 'Log a shot early'),
            )
          else
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AloftColors.navy),
              onPressed: () => openLogDose(context, detail),
              child: Text(pill ? 'Log dose' : 'Log shot'),
            ),
        ],
      ),
    );
  }
}

class _LateChoice extends StatelessWidget {
  const _LateChoice({required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          subtitle: Text(subtitle, style: const TextStyle(color: AloftColors.mist)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// "This vial: 4 doses · Use by Dec 30" (SPEC 6.5).
class SupplyCard extends StatelessWidget {
  const SupplyCard({super.key, required this.detail});
  final MedicationDetail detail;

  static bool hasSomethingToShow(MedicationDetail d) =>
      d.supply != null && (dosesLeft(d) != null || d.supply!.beyondUseDate != null || describeRemaining(d) != null);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final supply = detail.supply!;
    final pill = detail.medication.form == MedicationForm.oral;
    final left = dosesLeft(detail);
    final low = left != null && left <= reorderAtDoses;
    final useBy = supply.beyondUseDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pill ? 'This bottle' : 'This vial',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    left == null ? (describeRemaining(detail) ?? '') : '$left ${left == 1 ? 'dose' : 'doses'} left',
                    style: const TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  if (left != null)
                    if (describeRemaining(detail)?.split(' · ').first case final amount?)
                      Text(amount, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                  if (useBy != null)
                    Text(
                      'Use by ${MaterialLocalizations.of(context).formatShortMonthDay(useBy)}',
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            if (low)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFDEEE6), borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  'Running low',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8A3D17)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Latest weight and the change since the first weigh-in (mockups/Main).
class WeightCard extends ConsumerWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final unit = ref.watch(settingsProvider.select((s) => s.weightUnit));
    final weights = ref.watch(weightsProvider).value ?? const <Weight>[];
    final latest = weights.firstOrNull, first = weights.lastOrNull;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openLogWeight(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      latest == null ? 'Add your starting weight' : formatWeight(latest.kg, unit),
                      style: TextStyle(fontSize: latest == null ? 16 : 20, fontWeight: FontWeight.w800),
                    ),
                    if (latest != null && first != null && first.id != latest.id)
                      Text(
                        '${formatWeightChange(first.kg, latest.kg, unit)} since '
                        '${MaterialLocalizations.of(context).formatShortMonthDay(first.measuredAt)}',
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                      )
                    else if (latest != null)
                      Text('Starting point', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.add_circle_outline, color: scheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Estimated level: 3.1 mg" (mockups/Main). Always labelled as an estimate.
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.series, required this.now});
  final LevelSeries series;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Estimated ${series.ingredient} level',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                  ),
                ),
                Text('Estimate only', style: muted),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              describeAmount(series.now(now), DoseUnit.mg),
              style: const TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text('Not a blood level. See Charts for the curve.', style: muted),
          ],
        ),
      ),
    );
  }
}
