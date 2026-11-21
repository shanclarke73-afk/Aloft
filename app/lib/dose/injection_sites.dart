/// Injection sites and rotation (SPEC section 4, Dose).
library;

enum InjectionSite {
  abdomenUpperLeft('Abdomen, upper left'),
  abdomenUpperMiddle('Abdomen, upper middle'),
  abdomenUpperRight('Abdomen, upper right'),
  abdomenLowerLeft('Abdomen, lower left'),
  abdomenLowerMiddle('Abdomen, lower middle'),
  abdomenLowerRight('Abdomen, lower right'),
  thighLeft('Thigh, left'),
  thighRight('Thigh, right'),
  armLeft('Back of upper arm, left'),
  armRight('Back of upper arm, right'),
  buttockLeft('Buttock, left'),
  buttockRight('Buttock, right');

  const InjectionSite(this.label);
  final String label;
}

/// Used until the person has their own pattern of at least two sites.
const defaultRotation = [
  InjectionSite.abdomenLowerLeft,
  InjectionSite.abdomenLowerRight,
  InjectionSite.abdomenUpperRight,
  InjectionSite.abdomenUpperLeft,
];

/// The next site in rotation. [history] is every logged site across all medications, newest
/// first, so two shots never land on the same spot.
///
/// Rotates through the sites the person already uses (so someone who only uses their abdomen
/// is never sent to a thigh), picking the one used longest ago. With fewer than two sites in
/// their history it goes round the four corners of the abdomen.
InjectionSite suggestSite(List<InjectionSite> history) {
  final used = <InjectionSite>[];
  for (final site in history) {
    if (!used.contains(site)) used.add(site);
  }
  if (used.length >= 2) return used.last;
  return defaultRotation.firstWhere((site) => !used.contains(site));
}
