/// Estimated amount of medication in the body over time (SPEC 6.6).
///
/// A one-compartment model with first-order absorption and elimination, added up over every
/// logged dose. It is an illustration built from typical published numbers, not a blood level,
/// and nothing in the app uses it to suggest a dose or a time.
library;

import 'dart:math' as math;

/// Typical half-life and time to peak for one ingredient, injected under the skin.
class Kinetics {
  const Kinetics({required this.halfLifeHours, required this.tmaxHours, required this.source});
  final double halfLifeHours;
  final double tmaxHours;

  /// Where the numbers were read.
  final String source;

  double get _ke => math.ln2 / halfLifeHours;

  /// Absorption rate that puts the peak of a single dose at [tmaxHours]: solves
  /// tmax = ln(ka / ke) / (ka − ke) for ka > ke.
  double get _ka {
    final ke = _ke;
    double tmaxFor(double ka) => math.log(ka / ke) / (ka - ke);
    var low = ke * 1.000001, high = ke * 1e6;
    for (var i = 0; i < 200; i++) {
      final mid = math.sqrt(low * high);
      tmaxFor(mid) > tmaxHours ? low = mid : high = mid;
    }
    return math.sqrt(low * high);
  }

  /// Amount left from one dose of [mg], [hours] after it was taken.
  double remaining(double mg, double hours) {
    if (hours <= 0) return 0;
    final ke = _ke, ka = _ka;
    return mg * ka / (ka - ke) * (math.exp(-ke * hours) - math.exp(-ka * hours));
  }
}

/// Section 12.3 of each US prescribing information, read on DailyMed on November 21, 2026.
/// Where a label gives a range for time to peak, the label's median or the middle is used.
/// Re-check before each release (SPEC 6.6).
const kineticsByIngredient = <String, Kinetics>{
  // Ozempic and Wegovy: "elimination half-life of approximately 1 week"; peak "1 to 3 days post dose".
  'semaglutide': Kinetics(halfLifeHours: 168, tmaxHours: 48, source: 'Ozempic and Wegovy prescribing information'),
  // Mounjaro: "approximately 5 days"; Zepbound: median time to peak 24 hours (range 8 to 72).
  'tirzepatide': Kinetics(halfLifeHours: 120, tmaxHours: 24, source: 'Mounjaro and Zepbound prescribing information'),
  // Victoza and Saxenda: "approximately 13 hours"; peak at 8 to 12 hours (Saxenda: 11 hours).
  'liraglutide': Kinetics(halfLifeHours: 13, tmaxHours: 11, source: 'Victoza and Saxenda prescribing information'),
  // Trulicity: "approximately 5 days"; time to peak 24 to 72 hours, median 48.
  'dulaglutide': Kinetics(halfLifeHours: 120, tmaxHours: 48, source: 'Trulicity prescribing information'),
};

class LoggedDose {
  const LoggedDose(this.at, this.mg);
  final DateTime at;
  final double mg;
}

/// Estimated amount in the body at [at], from every dose before it.
double estimateAt(List<LoggedDose> doses, Kinetics kinetics, DateTime at) {
  var total = 0.0;
  for (final dose in doses) {
    total += kinetics.remaining(dose.mg, at.difference(dose.at).inMinutes / 60);
  }
  return total;
}

class LevelPoint {
  const LevelPoint(this.at, this.mg);
  final DateTime at;
  final double mg;
}

/// The curve from [from] to [to], one point every [step].
List<LevelPoint> levelCurve(
  List<LoggedDose> doses,
  Kinetics kinetics, {
  required DateTime from,
  required DateTime to,
  Duration step = const Duration(hours: 6),
}) {
  final points = <LevelPoint>[];
  for (var t = from; !t.isAfter(to); t = t.add(step)) {
    points.add(LevelPoint(t, estimateAt(doses, kinetics, t)));
  }
  return points;
}
