import 'package:aloft/level/level_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 5, 20);
  const tirz = Kinetics(halfLifeHours: 120, tmaxHours: 24, source: 'test');

  test('a single dose starts at zero, peaks at the time to peak, and never exceeds the dose', () {
    expect(tirz.remaining(2.5, 0), 0);
    final peak = tirz.remaining(2.5, 24);
    expect(peak, greaterThan(tirz.remaining(2.5, 23)));
    expect(peak, greaterThan(tirz.remaining(2.5, 25)));
    expect(peak, lessThan(2.5));
    expect(peak, greaterThan(2.0));
  });

  test('long after the peak it halves every half-life', () {
    final a = tirz.remaining(5, 600), b = tirz.remaining(5, 720);
    expect(b / a, closeTo(0.5, 0.001));
  });

  test('the amount scales with the dose, and doses add up', () {
    expect(tirz.remaining(5, 50), closeTo(2 * tirz.remaining(2.5, 50), 1e-9));
    final doses = [LoggedDose(t0, 2.5), LoggedDose(t0.add(const Duration(days: 7)), 2.5)];
    final at = t0.add(const Duration(days: 9));
    expect(estimateAt(doses, tirz, at), closeTo(tirz.remaining(2.5, 216) + tirz.remaining(2.5, 48), 1e-9));
  });

  test('a dose in the future adds nothing', () {
    expect(estimateAt([LoggedDose(t0.add(const Duration(days: 1)), 5)], tirz, t0), 0);
  });

  test('weekly doses build up to a steady pattern', () {
    final doses = [for (var w = 0; w < 12; w++) LoggedDose(t0.add(Duration(days: 7 * w)), 2.5)];
    double trough(int week) => estimateAt(doses, tirz, t0.add(Duration(days: 7 * week)));
    expect(trough(2), greaterThan(trough(1)));
    expect(trough(11) - trough(10), lessThan(0.01));
  });

  test('every built-in ingredient has numbers that give a peak at its time to peak', () {
    for (final k in kineticsByIngredient.values) {
      final peak = k.remaining(1, k.tmaxHours);
      expect(peak, greaterThan(k.remaining(1, k.tmaxHours * 0.9)), reason: k.source);
      expect(peak, greaterThan(k.remaining(1, k.tmaxHours * 1.1)), reason: k.source);
      expect(peak, inExclusiveRange(0, 1));
    }
    expect(kineticsByIngredient.keys, isNot(contains('retatrutide')), reason: 'no prescribing information yet');
  });

  test('the curve covers the range asked for', () {
    final curve = levelCurve([LoggedDose(t0, 2.5)], tirz, from: t0, to: t0.add(const Duration(days: 7)));
    expect((curve.first.at, curve.last.at), (t0, t0.add(const Duration(days: 7))));
    expect(curve.length, 29);
    expect(curve.first.mg, 0);
  });
}
