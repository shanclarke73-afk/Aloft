import '../../data/database.dart';

/// A medication the person can pick instead of typing. Names only: no doses, since Aloft
/// never suggests one.
class KnownDrug {
  const KnownDrug(this.label, this.ingredient, {this.isGlp1 = true});
  final String label;
  final String ingredient;
  final bool isGlp1;
}

const brandPens = [
  KnownDrug('Ozempic®', 'semaglutide'),
  KnownDrug('Wegovy®', 'semaglutide'),
  KnownDrug('Mounjaro®', 'tirzepatide'),
  KnownDrug('Zepbound®', 'tirzepatide'),
  KnownDrug('Saxenda®', 'liraglutide'),
  KnownDrug('Victoza®', 'liraglutide'),
  KnownDrug('Trulicity®', 'dulaglutide'),
];

/// Retatrutide is deliberately not listed: it is not an approved drug, and both stores bar apps
/// from promoting unapproved substances. Any name can still be typed in.
const compoundedDrugs = [
  KnownDrug('Semaglutide', 'semaglutide'),
  KnownDrug('Tirzepatide', 'tirzepatide'),
  KnownDrug('Liraglutide', 'liraglutide'),
  KnownDrug('NAD+', 'nad', isGlp1: false),
  KnownDrug('B12 (cyanocobalamin)', 'b12', isGlp1: false),
  KnownDrug('L-carnitine', 'lcarnitine', isGlp1: false),
  KnownDrug('Glutathione', 'glutathione', isGlp1: false),
  KnownDrug('Lipo-B / MIC', 'lipoB', isGlp1: false),
];

const pills = [KnownDrug('Rybelsus®', 'semaglutide'), KnownDrug('Wegovy® pill', 'semaglutide')];

/// Extra ingredients suggested when adding one to a vial.
const commonAdditives = ['Cyanocobalamin (B12)', 'Glycine', 'L-carnitine', 'Pyridoxine (B6)', 'Niacinamide'];

List<KnownDrug> drugsFor(MedicationForm form) => switch (form) {
  MedicationForm.brandPen => brandPens,
  MedicationForm.compoundedVial => compoundedDrugs,
  MedicationForm.oral => pills,
  MedicationForm.other => const [],
};

/// "tirzepatide" for known ingredients, otherwise the medication's own name in lower case.
String drugWord(Medication m) =>
    const {'semaglutide', 'tirzepatide', 'retatrutide', 'liraglutide', 'dulaglutide'}.contains(m.activeIngredient)
    ? m.activeIngredient
    : m.name.toLowerCase();
