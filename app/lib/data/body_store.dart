import 'package:drift/drift.dart';

import 'database.dart';

const kgPerLb = 0.45359237;

double toKg(double value, WeightUnit unit) => unit == WeightUnit.kg ? value : value * kgPerLb;
double fromKg(double kg, WeightUnit unit) => unit == WeightUnit.kg ? kg : kg / kgPerLb;

/// "184.6 lb". One decimal, always shown, so a column of weights lines up.
String formatWeight(double kg, WeightUnit unit) => '${fromKg(kg, unit).toStringAsFixed(1)} ${unit.name}';

/// "−12.4 lb", "+0.8 lb" or "no change", for the difference between two weights.
String formatWeightChange(double fromKgValue, double toKgValue, WeightUnit unit) {
  final change = fromKg(toKgValue, unit) - fromKg(fromKgValue, unit);
  final text = change.abs().toStringAsFixed(1);
  if (text == '0.0') return 'no change';
  return '${change < 0 ? '−' : '+'}$text ${unit.name}';
}

/// "Goal 150 lb · 12.4 lb from goal · BMI 31.8" for a weight, from whichever of the goal and the
/// height have been set; null when neither has. States the numbers only: no praise, no
/// category, and "from goal" is the plain distance whichever side of the goal the weight is.
String? describeGoalAndBmi(double kg, {required double? goalKg, required double? heightCm, required WeightUnit unit}) {
  final parts = <String>[];
  if (goalKg != null) {
    final toGo = (fromKg(kg, unit) - fromKg(goalKg, unit)).abs().toStringAsFixed(1);
    final goal = fromKg(goalKg, unit).toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    parts.add('Goal $goal ${unit.name}');
    parts.add(toGo == '0.0' ? 'reached' : '$toGo ${unit.name} from goal');
  }
  if (heightCm != null) parts.add('BMI ${formatBmi(kg, heightCm)}');
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Plain words for the 1 to 10 scale. Describes the number; it isn't an assessment.
String severityWord(int severity) => severity <= 3 ? 'mild' : (severity <= 6 ? 'moderate' : 'strong');

String sideEffectName(SideEffect e) =>
    e.type == SideEffectType.custom ? (e.customName ?? SideEffectType.custom.label) : e.type.label;

const cmPerInch = 2.54;

/// Body mass index: kg divided by height in metres squared. A plain calculation; Aloft
/// shows the number and never a category or a judgement.
double bmi(double kg, double heightCm) => kg / ((heightCm / 100) * (heightCm / 100));

String formatBmi(double kg, double heightCm) => bmi(kg, heightCm).toStringAsFixed(1);

extension BodyStore on AloftDatabase {
  Future<Weight> logWeight({required double kg, required DateTime measuredAt, String? notes}) {
    final clean = notes?.trim();
    return into(weights).insertReturning(
      WeightsCompanion.insert(
        measuredAt: measuredAt,
        kg: kg,
        notes: Value(clean == null || clean.isEmpty ? null : clean),
      ),
    );
  }

  Future<void> updateWeight(Weight weight, {required double kg, required DateTime measuredAt, String? notes}) {
    final clean = notes?.trim();
    return (update(weights)..where((w) => w.id.equals(weight.id))).write(
      WeightsCompanion(
        kg: Value(kg),
        measuredAt: Value(measuredAt),
        notes: Value(clean == null || clean.isEmpty ? null : clean),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteWeight(Weight weight) => (delete(weights)..where((w) => w.id.equals(weight.id))).go();
  Future<void> restoreWeight(Weight weight) => into(weights).insert(weight);

  /// Newest first.
  Stream<List<Weight>> watchWeights() => (select(weights)..orderBy([(w) => OrderingTerm.desc(w.measuredAt)])).watch();

  /// Saves one row per side effect picked, all at the same time.
  Future<void> logSideEffects({
    required Map<SideEffectType, int> severities,
    String? customName,
    required DateTime occurredAt,
    String? medicationId,
    String? notes,
  }) {
    final clean = notes?.trim();
    return batch((b) {
      b.insertAll(sideEffects, [
        for (final entry in severities.entries)
          SideEffectsCompanion.insert(
            occurredAt: occurredAt,
            type: entry.key,
            customName: Value(entry.key == SideEffectType.custom ? customName?.trim() : null),
            severity: entry.value,
            medicationId: Value(medicationId),
            notes: Value(clean == null || clean.isEmpty ? null : clean),
          ),
      ]);
    });
  }

  Future<void> deleteSideEffect(SideEffect e) => (delete(sideEffects)..where((x) => x.id.equals(e.id))).go();
  Future<void> restoreSideEffect(SideEffect e) => into(sideEffects).insert(e);

  /// Newest first.
  Stream<List<SideEffect>> watchSideEffects() =>
      (select(sideEffects)..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])).watch();
}
