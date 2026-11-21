/// Dose math (SPEC section 5). Aloft converts what the label and prescription say; it never
/// suggests a dose. Wording rule for anything built on this: "X units equals Y mg", never
/// "take" or "draw".
library;

/// How an amount was entered. `units` always means U-100 syringe units, never pills.
enum DoseUnit { units, ml, mg, tablets }

/// US insulin syringes are U-100: 100 units = 1 mL, whatever the barrel size.
const unitsPerMl = 100.0;

/// An extra ingredient mixed into a compounded vial, e.g. cyanocobalamin 0.5 mg/mL.
class Additive {
  const Additive({required this.name, required this.amountPerMl, this.unit = 'mg'});
  final String name;
  final double amountPerMl;

  /// "mg" or "mcg".
  final String unit;

  factory Additive.fromJson(Map<String, dynamic> json) => Additive(
    name: json['name'] as String,
    amountPerMl: (json['amountPerMl'] as num).toDouble(),
    unit: json['unit'] as String? ?? 'mg',
  );
  Map<String, dynamic> toJson() => {'name': name, 'amountPerMl': amountPerMl, 'unit': unit};

  @override
  bool operator ==(Object other) =>
      other is Additive && other.name == name && other.amountPerMl == amountPerMl && other.unit == unit;
  @override
  int get hashCode => Object.hash(name, amountPerMl, unit);
}

/// One dose drawn from a vial, in all three units. Values are exact, not rounded; round
/// only when showing them.
class VialDose {
  const VialDose({required this.units, required this.volumeMl, required this.drugMg});
  final double units;
  final double volumeMl;
  final double drugMg;

  double amountIn(DoseUnit unit) => switch (unit) {
    DoseUnit.units => units,
    DoseUnit.ml => volumeMl,
    DoseUnit.mg => drugMg,
    DoseUnit.tablets => throw ArgumentError('A vial dose is never in tablets'),
  };
}

/// Converts an amount entered in units, mL or mg for a vial of the given strength.
VialDose convertVialDose({required double amount, required DoseUnit unit, required double concentrationMgPerMl}) {
  if (amount.isNaN || amount < 0) throw ArgumentError.value(amount, 'amount');
  if (concentrationMgPerMl.isNaN || concentrationMgPerMl <= 0) {
    throw ArgumentError.value(concentrationMgPerMl, 'concentrationMgPerMl');
  }
  final volumeMl = switch (unit) {
    DoseUnit.units => amount / unitsPerMl,
    DoseUnit.ml => amount,
    DoseUnit.mg => amount / concentrationMgPerMl,
    DoseUnit.tablets => throw ArgumentError('A vial dose is never in tablets'),
  };
  return VialDose(
    // Keep exactly what was typed, so 25 units never comes back as 24.999.
    units: unit == DoseUnit.units ? amount : volumeMl * unitsPerMl,
    volumeMl: volumeMl,
    drugMg: unit == DoseUnit.mg ? amount : volumeMl * concentrationMgPerMl,
  );
}

/// How much of an extra ingredient is in a dose of this volume.
double additiveAmount(Additive additive, double volumeMl) => volumeMl * additive.amountPerMl;

/// Whole doses a volume holds at this dose. Null when the dose is zero.
int? dosesIn(double volumeMl, double doseVolumeMl) {
  if (doseVolumeMl <= 0 || volumeMl <= 0) return doseVolumeMl <= 0 ? null : 0;
  // A hair of tolerance so 2 mL at 0.25 mL is 8 doses, not 7, after floating-point division.
  return (volumeMl / doseVolumeMl + 1e-9).floor();
}

/// Display rounding: mg to 2 decimals, mL to 3, units to 1, tablets to 1. Trailing zeros dropped.
String formatDoseAmount(double value, DoseUnit unit) => formatNumber(value, switch (unit) {
  DoseUnit.mg => 2,
  DoseUnit.ml => 3,
  DoseUnit.units => 1,
  DoseUnit.tablets => 1,
});

String formatNumber(double value, int decimals) {
  var text = value.toStringAsFixed(decimals);
  if (text.contains('.')) text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  return text == '-0' ? '0' : text;
}

String doseUnitLabel(DoseUnit unit, {double amount = 2}) => switch (unit) {
  DoseUnit.units => amount == 1 ? 'unit' : 'units',
  DoseUnit.ml => 'mL',
  DoseUnit.mg => 'mg',
  DoseUnit.tablets => amount == 1 ? 'tablet' : 'tablets',
};

/// "25 units", "0.25 mL", "2.5 mg", "1 tablet".
String describeAmount(double value, DoseUnit unit) =>
    '${formatDoseAmount(value, unit)} ${doseUnitLabel(unit, amount: value)}';

/// "25 units = 0.25 mL = 2.5 mg tirzepatide", starting with the unit that was typed.
String conversionLine(VialDose dose, DoseUnit entered, String drugName) {
  final order = switch (entered) {
    DoseUnit.ml => [DoseUnit.ml, DoseUnit.units, DoseUnit.mg],
    DoseUnit.mg => [DoseUnit.mg, DoseUnit.units, DoseUnit.ml],
    _ => [DoseUnit.units, DoseUnit.ml, DoseUnit.mg],
  };
  final parts = [
    for (final unit in order)
      unit == DoseUnit.mg
          ? '${describeAmount(dose.drugMg, unit)} $drugName'
          : describeAmount(dose.amountIn(unit), unit),
  ];
  return parts.join(' = ');
}

/// The math, shown so the person can check it: "25 units ÷ 100 = 0.25 mL × 10 mg/mL".
String mathLine(VialDose dose, DoseUnit entered, double concentrationMgPerMl) {
  final strength = '${formatNumber(concentrationMgPerMl, 3)} mg/mL';
  return switch (entered) {
    DoseUnit.mg =>
      '${describeAmount(dose.drugMg, DoseUnit.mg)} ÷ $strength = '
          '${describeAmount(dose.volumeMl, DoseUnit.ml)} × 100',
    DoseUnit.ml => '${describeAmount(dose.volumeMl, DoseUnit.ml)} × $strength, and × 100 for units',
    _ =>
      '${describeAmount(dose.units, DoseUnit.units)} ÷ 100 = ${describeAmount(dose.volumeMl, DoseUnit.ml)} × $strength',
  };
}

/// "+ 0.125 mg cyanocobalamin (B12)" for each extra ingredient.
List<String> additiveLines(List<Additive> additives, double volumeMl) => [
  for (final a in additives) '+ ${formatNumber(additiveAmount(a, volumeMl), 3)} ${a.unit} ${a.name}',
];

/// True when two amounts differ by more than 50% of the earlier one (mismatch warning).
bool differsALot(double entered, double previous) => previous > 0 && (entered - previous).abs() / previous > 0.5;

/// True when two amounts aren't the same once rounded for display.
bool differs(double a, double b, {int decimals = 2}) => a.toStringAsFixed(decimals) != b.toStringAsFixed(decimals);

/// Reads a typed number. Accepts a comma as the decimal mark. Null unless it's above zero.
double? parseAmount(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  return value == null || value.isNaN || value.isInfinite || value <= 0 ? null : value;
}
