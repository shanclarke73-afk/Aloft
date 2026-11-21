import 'package:aloft/dose/dose_math.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const b12 = Additive(name: 'cyanocobalamin (B12)', amountPerMl: 0.5);

  group('units, mL and mg', () {
    test('the spec example: 25 units of 10 mg/mL is 0.25 mL and 2.5 mg, plus 0.125 mg B12', () {
      final dose = convertVialDose(amount: 25, unit: DoseUnit.units, concentrationMgPerMl: 10);
      expect(dose.units, 25);
      expect(dose.volumeMl, 0.25);
      expect(dose.drugMg, 2.5);
      expect(additiveAmount(b12, dose.volumeMl), 0.125);
    });

    test('entering mg or mL gives the same dose as entering units', () {
      final fromMg = convertVialDose(amount: 2.5, unit: DoseUnit.mg, concentrationMgPerMl: 10);
      expect((fromMg.units, fromMg.volumeMl, fromMg.drugMg), (25, 0.25, 2.5));
      final fromMl = convertVialDose(amount: 0.25, unit: DoseUnit.ml, concentrationMgPerMl: 10);
      expect((fromMl.units, fromMl.volumeMl, fromMl.drugMg), (25, 0.25, 2.5));
    });

    test('odd strengths and in-between doses', () {
      // Semaglutide 2.5 mg/mL, 0.25 mg dose = 10 units.
      final sema = convertVialDose(amount: 0.25, unit: DoseUnit.mg, concentrationMgPerMl: 2.5);
      expect(sema.units, closeTo(10, 1e-9));
      // Tirzepatide 17 mg/mL, 37 units.
      final tirz = convertVialDose(amount: 37, unit: DoseUnit.units, concentrationMgPerMl: 17);
      expect(tirz.volumeMl, closeTo(0.37, 1e-12));
      expect(tirz.drugMg, closeTo(6.29, 1e-9));
      // 7.5 units is allowed (micro dose).
      expect(convertVialDose(amount: 7.5, unit: DoseUnit.units, concentrationMgPerMl: 5).drugMg, closeTo(0.375, 1e-12));
    });

    test('what was typed is kept exactly', () {
      for (final typed in [0.1, 0.3, 7.3, 33.3]) {
        expect(convertVialDose(amount: typed, unit: DoseUnit.units, concentrationMgPerMl: 3).units, typed);
        expect(convertVialDose(amount: typed, unit: DoseUnit.mg, concentrationMgPerMl: 3).drugMg, typed);
      }
    });

    test('a zero or missing strength, or a negative amount, is refused', () {
      expect(() => convertVialDose(amount: 25, unit: DoseUnit.units, concentrationMgPerMl: 0), throwsArgumentError);
      expect(() => convertVialDose(amount: -1, unit: DoseUnit.units, concentrationMgPerMl: 10), throwsArgumentError);
      expect(() => convertVialDose(amount: 1, unit: DoseUnit.tablets, concentrationMgPerMl: 10), throwsArgumentError);
    });
  });

  group('showing amounts', () {
    test('mg to 2 decimals, mL to 3, units to 1, with no trailing zeros', () {
      expect(formatDoseAmount(2.5, DoseUnit.mg), '2.5');
      expect(formatDoseAmount(6.2899999, DoseUnit.mg), '6.29');
      expect(formatDoseAmount(0.25, DoseUnit.ml), '0.25');
      expect(formatDoseAmount(0.0625, DoseUnit.ml), '0.063');
      expect(formatDoseAmount(25, DoseUnit.units), '25');
      expect(formatDoseAmount(7.5, DoseUnit.units), '7.5');
      expect(formatDoseAmount(100, DoseUnit.units), '100');
      expect(formatDoseAmount(0, DoseUnit.mg), '0');
    });

    test('the conversion line says "=" and never tells anyone what to take', () {
      final dose = convertVialDose(amount: 25, unit: DoseUnit.units, concentrationMgPerMl: 10);
      expect(conversionLine(dose, DoseUnit.units, 'tirzepatide'), '25 units = 0.25 mL = 2.5 mg tirzepatide');
      expect(conversionLine(dose, DoseUnit.mg, 'tirzepatide'), '2.5 mg tirzepatide = 25 units = 0.25 mL');
      expect(mathLine(dose, DoseUnit.units, 10), '25 units ÷ 100 = 0.25 mL × 10 mg/mL');
      expect(additiveLines([b12], dose.volumeMl), ['+ 0.125 mg cyanocobalamin (B12)']);
      for (final unit in [DoseUnit.units, DoseUnit.ml, DoseUnit.mg]) {
        final text = '${conversionLine(dose, unit, 'x')} ${mathLine(dose, unit, 10)}'.toLowerCase();
        for (final word in ['take', 'draw', 'should', 'inject']) {
          expect(text, isNot(contains(word)));
        }
      }
    });

    test('one unit and one tablet are singular', () {
      expect(describeAmount(1, DoseUnit.units), '1 unit');
      expect(describeAmount(1, DoseUnit.tablets), '1 tablet');
      expect(describeAmount(0.5, DoseUnit.tablets), '0.5 tablets');
    });
  });

  group('vial supply', () {
    test('a 2 mL vial at 25 units holds 8 doses', () {
      expect(dosesIn(2, 0.25), 8);
      expect(dosesIn(1, 0.3), 3);
      expect(dosesIn(0, 0.25), 0);
      expect(dosesIn(2, 0), isNull);
    });
  });

  group('mismatch checks', () {
    test('more than 50% away from the last dose counts as very different', () {
      expect(differsALot(50, 25), isTrue);
      expect(differsALot(37.5, 25), isFalse, reason: 'exactly 50% is not more than 50%');
      expect(differsALot(38, 25), isTrue);
      expect(differsALot(12, 25), isTrue);
      expect(differsALot(25, 0), isFalse);
    });

    test('amounts that show the same are treated as the same', () {
      expect(differs(2.5, 2.5000001), isFalse);
      expect(differs(2.5, 2.51), isTrue);
    });
  });

  test('typed numbers: comma decimals are fine, zero and junk are not', () {
    expect(parseAmount('2,5'), 2.5);
    expect(parseAmount(' 25 '), 25);
    expect(parseAmount('0'), isNull);
    expect(parseAmount('-3'), isNull);
    expect(parseAmount('abc'), isNull);
    expect(parseAmount(''), isNull);
  });

  group('injection site rotation', () {
    test('with no history, starts at the abdomen and goes round its corners', () {
      expect(suggestSite([]), InjectionSite.abdomenLowerLeft);
      expect(suggestSite([InjectionSite.abdomenLowerLeft]), InjectionSite.abdomenLowerRight);
    });

    test('rotates through the sites the person uses, longest ago first', () {
      const left = InjectionSite.abdomenLowerLeft, right = InjectionSite.abdomenLowerRight;
      expect(suggestSite([left, right, left, right]), right);
      const thigh = InjectionSite.thighLeft;
      expect(suggestSite([left, thigh, right, left]), right, reason: 'right was used longest ago');
    });

    test('never suggests the site used last', () {
      for (final last in InjectionSite.values) {
        expect(suggestSite([last]), isNot(last));
        expect(suggestSite([last, InjectionSite.thighRight, last]), isNot(last));
      }
    });
  });
}
