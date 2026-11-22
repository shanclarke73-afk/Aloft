import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../util/format.dart';
import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/medication_store.dart';
import '../../dose/dose_math.dart';
import '../../level/level_model.dart';
import '../../schedule/schedule.dart';
import '../../settings/settings.dart';
import '../../theme/aloft_theme.dart';

/// One estimated-level series: an injected ingredient with built-in numbers.
class LevelSeries {
  const LevelSeries({required this.ingredient, required this.kinetics, required this.doses, required this.nextDue});
  final String ingredient;
  final Kinetics kinetics;
  final List<LoggedDose> doses;

  /// The next scheduled dose, to end the projection at. Null when nothing is scheduled.
  final DateTime? nextDue;

  double now(DateTime at) => estimateAt(doses, kinetics, at);
}

/// Groups logged shots by ingredient. Shots of the same ingredient share one curve (Zepbound
/// then compounded tirzepatide), pills are never mixed in, and ingredients without
/// prescribing-information numbers get no curve.
List<LevelSeries> levelSeries(List<HistoryEntry> history, List<MedicationDetail> medications) {
  final byIngredient = <String, List<LoggedDose>>{};
  for (final entry in history) {
    final m = entry.medication, dose = entry.dose;
    if (dose.skipped || dose.drugMg == null || m.form == MedicationForm.oral) continue;
    if (!kineticsByIngredient.containsKey(m.activeIngredient)) continue;
    byIngredient.putIfAbsent(m.activeIngredient, () => []).add(LoggedDose(dose.takenAt, dose.drugMg!));
  }
  return [
    for (final MapEntry(key: ingredient, value: doses) in byIngredient.entries)
      LevelSeries(
        ingredient: ingredient,
        kinetics: kineticsByIngredient[ingredient]!,
        doses: doses,
        nextDue: [
          for (final d in medications)
            if (d.medication.activeIngredient == ingredient &&
                d.medication.form != MedicationForm.oral &&
                d.medication.status == MedicationStatus.active)
              ?DoseSchedule.of(d.medication).nextDue(lastLogged: d.lastLogged?.takenAt),
        ].fold<DateTime?>(null, (soonest, due) => soonest == null || due.isBefore(soonest) ? due : soonest),
      ),
  ];
}

final levelSeriesProvider = Provider<List<LevelSeries>>(
  (ref) => levelSeries(ref.watch(historyProvider).value ?? const [], ref.watch(medicationsProvider).value ?? const []),
);

const levelDisclaimer = 'An estimate based on your logged doses and the drug\'s typical half-life. Not a blood level.';

/// Charts tab (mockups/Charts): estimated level and weight. Body and Effects tabs come later.
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key, this.now});
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final at = now ?? DateTime.now();
    final series = ref.watch(levelSeriesProvider);
    final weights = ref.watch(weightsProvider).value ?? const <Weight>[];
    final unit = ref.watch(settingsProvider.select((s) => s.weightUnit));
    final muted = TextStyle(fontSize: 13, height: 1.4, color: scheme.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(title: const Text('Charts')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          if (series.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated level', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Appears after your first logged shot of semaglutide, tirzepatide, liraglutide or '
                      'dulaglutide. Pills and other medications don\'t get a level chart.',
                      style: muted,
                    ),
                  ],
                ),
              ),
            ),
          for (final s in series) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated ${s.ingredient} level',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    Text('${describeAmount(s.now(at), DoseUnit.mg)} now · estimate only', style: muted),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: LevelChart(series: s, now: at),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Legend(color: scheme.secondary, label: 'From your shots'),
                        const SizedBox(width: 16),
                        _Legend(color: scheme.secondary.withValues(alpha: 0.45), label: 'Projected'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(levelDisclaimer, style: muted),
                    Text('Half-life and time to peak: ${s.kinetics.source}.', style: muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weight', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  if (weights.length < 2)
                    Text('Appears once you\'ve logged two weights.', style: muted)
                  else ...[
                    Text(
                      '${formatWeightChange(weights.last.kg, weights.first.kg, unit)} since '
                      '${formatMonthDay(context, weights.last.measuredAt)}',
                      style: muted,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: WeightChart(weights: weights, unit: unit),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

FlTitlesData _titles(BuildContext context, {required Widget Function(double, TitleMeta) bottom, double? leftInterval}) {
  final style = TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant);
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: leftInterval,
        getTitlesWidget: (value, meta) =>
            value == meta.max || value == meta.min ? const SizedBox.shrink() : Text(meta.formattedValue, style: style),
      ),
    ),
    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: bottom)),
  );
}

/// The last nine weeks of the estimate, then a lighter line out to the next scheduled dose.
class LevelChart extends StatelessWidget {
  const LevelChart({super.key, required this.series, required this.now});
  final LevelSeries series;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final first = series.doses.map((d) => d.at).reduce((a, b) => a.isBefore(b) ? a : b);
    final nineWeeksAgo = now.subtract(const Duration(days: 63));
    final from = first.isAfter(nineWeeksAgo) ? first : nineWeeksAgo;
    final due = series.nextDue;
    final to = due != null && due.isAfter(now) ? due : now.add(const Duration(days: 7));
    // x is days from now: negative is the past.
    double x(DateTime t) => t.difference(now).inMinutes / 1440;
    List<FlSpot> spots(DateTime a, DateTime b) => [
      for (final p in levelCurve(series.doses, series.kinetics, from: a, to: b, step: const Duration(hours: 2)))
        FlSpot(x(p.at), p.mg),
      FlSpot(x(b), estimateAt(series.doses, series.kinetics, b)),
    ];
    final dates = MaterialLocalizations.of(context);
    final style = TextStyle(fontSize: 11, color: scheme.onSurfaceVariant);
    final span = x(to) - x(from);

    return LineChart(
      LineChartData(
        minY: 0,
        minX: x(from),
        maxX: x(to),
        lineTouchData: const LineTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        titlesData:
            _titles(
              context,
              bottom: (value, meta) {
                if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                return Text(
                  dates.formatShortMonthDay(now.add(Duration(minutes: (value * 1440).round()))),
                  style: style,
                );
              },
            ).copyWith(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: span <= 0 ? 1 : (span / 3).clamp(1, 100).ceilToDouble(),
                  getTitlesWidget: (value, meta) => value == meta.min || value == meta.max
                      ? const SizedBox.shrink()
                      : Text(
                          dates.formatShortMonthDay(now.add(Duration(minutes: (value * 1440).round()))),
                          style: style,
                        ),
                ),
              ),
            ),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(x: 0, color: scheme.onSurfaceVariant, strokeWidth: 1, dashArray: [3, 3]),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots(from, now),
            color: scheme.secondary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: scheme.secondary.withValues(alpha: 0.10)),
          ),
          LineChartBarData(
            spots: spots(now, to),
            color: scheme.secondary.withValues(alpha: 0.45),
            barWidth: 2.5,
            dashArray: [5, 4],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.weights, required this.unit});

  /// Newest first.
  final List<Weight> weights;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final start = weights.last.measuredAt;
    double x(DateTime t) => t.difference(start).inMinutes / 1440;
    final spots = [for (final w in weights.reversed) FlSpot(x(w.measuredAt), fromKg(w.kg, unit))];
    final values = spots.map((s) => s.y);
    final low = values.reduce((a, b) => a < b ? a : b), high = values.reduce((a, b) => a > b ? a : b);
    final pad = ((high - low) * 0.15).clamp(1.0, 50.0);
    final style = TextStyle(fontSize: 11, color: scheme.onSurfaceVariant);
    final span = spots.last.x - spots.first.x;

    return LineChart(
      LineChartData(
        minY: (low - pad).floorToDouble(),
        maxY: (high + pad).ceilToDouble(),
        lineTouchData: const LineTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        titlesData: _titles(context, bottom: (_, _) => const SizedBox.shrink()).copyWith(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: span <= 0 ? 1 : (span / 3).clamp(1, 1000).ceilToDouble(),
              getTitlesWidget: (value, meta) => value == meta.min || value == meta.max
                  ? const SizedBox.shrink()
                  : Text(formatAxisDate(context, start.add(Duration(minutes: (value * 1440).round()))), style: style),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: AloftColors.peach,
            barWidth: 2.5,
            dotData: FlDotData(show: spots.length <= 30),
          ),
        ],
      ),
    );
  }
}
