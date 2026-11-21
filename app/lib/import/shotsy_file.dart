/// Reads Shotsy's CSV export (docs/shotsy-import.md). Pure parsing: nothing is saved here.
library;

import '../data/database.dart';
import '../dose/injection_sites.dart';

class ShotsyShot {
  const ShotsyShot({
    required this.medication,
    required this.mg,
    required this.at,
    this.site,
    this.siteText,
    this.note,
    this.pain = 0,
  });
  final String medication;
  final double mg;
  final DateTime at;
  final InjectionSite? site;

  /// The original site text when Aloft has no matching site.
  final String? siteText;
  final String? note;
  final int pain;
}

class ShotsyDay {
  ShotsyDay(this.date);
  final DateTime date;
  ShotsyShot? shot;
  double? weightLb;
  final notes = <String>[];
  final effects = <SideEffectType, int>{};
  bool hasFood = false;
}

class ShotsyFile {
  ShotsyFile(this.days);
  final List<ShotsyDay> days;

  Iterable<ShotsyShot> get shots => days.map((d) => d.shot).nonNulls;
  int get shotCount => shots.length;
  int get weightCount => days.where((d) => d.weightLb != null).length;
  int get noteCount => days.fold(0, (n, d) => n + d.notes.length);
  int get effectCount => days.fold(0, (n, d) => n + d.effects.length);
  int get foodDays => days.where((d) => d.hasFood).length;

  /// Medication names in the order they first appear.
  List<String> get medications => {for (final s in shots) s.medication}.toList();
}

const _sites = {
  'left arm': InjectionSite.armLeft,
  'right arm': InjectionSite.armRight,
  'left thigh': InjectionSite.thighLeft,
  'right thigh': InjectionSite.thighRight,
  'stomach - upper left': InjectionSite.abdomenUpperLeft,
  'stomach - upper right': InjectionSite.abdomenUpperRight,
  'stomach - upper mid': InjectionSite.abdomenUpperMiddle,
  'stomach - lower left': InjectionSite.abdomenLowerLeft,
  'stomach - lower right': InjectionSite.abdomenLowerRight,
  'stomach - lower mid': InjectionSite.abdomenLowerMiddle,
};

const _symptoms = {
  'nausea': SideEffectType.nausea,
  'heartburn': SideEffectType.heartburn,
  'food noise': SideEffectType.foodNoise,
  'suppressed appetite': SideEffectType.lowAppetite,
  'constipation': SideEffectType.constipation,
  'diarrhea': SideEffectType.diarrhea,
  'belching': SideEffectType.burps,
  'injection site reaction': SideEffectType.injectionSite,
  'mood swings': SideEffectType.mood,
  'indigestion': SideEffectType.indigestion,
  'metallic taste': SideEffectType.metallicTaste,
  'stomach pain': SideEffectType.stomachPain,
  'hair loss': SideEffectType.hairShedding,
  'fatigue': SideEffectType.fatigue,
  'migraine': SideEffectType.headache,
};

/// Splits CSV text into rows of fields. Handles quotes, doubled quotes, commas and line breaks
/// inside quotes, and Windows line endings.
List<List<String>> parseCsv(String text) {
  if (text.startsWith('﻿')) text = text.substring(1);
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(field.toString());
      field.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field.clear();
      rows.add(row);
      row = <String>[];
    } else {
      field.write(c);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return [
    for (final r in rows)
      if (r.any((f) => f.trim().isNotEmpty)) r,
  ];
}

double? _number(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

/// Returns null when the text isn't a Shotsy export (recognised by its header row).
ShotsyFile? parseShotsy(String text) {
  final rows = parseCsv(text);
  if (rows.isEmpty) return null;
  final header = [for (final h in rows.first) h.trim().toLowerCase()];
  int col(String name) => header.indexOf(name);
  final date = col('date'), shot = col('shot'), time = col('time'), site = col('site');
  final weight = col('recorded weight (lbs)');
  if ([date, shot, time, site, weight].any((i) => i < 0)) return null;
  final shotNotes = col('shot notes'), pain = col('pain level'), dayNotes = col('day notes');
  final food = [col('calories'), col('protein'), col('water')].where((i) => i >= 0).toList();

  final days = <ShotsyDay>[];
  for (final row in rows.skip(1)) {
    String at(int index) => index >= 0 && index < row.length ? row[index].trim() : '';
    final day = DateTime.tryParse(at(date));
    if (day == null) continue;
    final entry = ShotsyDay(DateTime(day.year, day.month, day.day));

    final shotText = at(shot);
    if (shotText.isNotEmpty) {
      final match = RegExp(r'^(.*?)\s+(\d+(?:[.,]\d+)?)\s*mg$', caseSensitive: false).firstMatch(shotText);
      final mg = match == null ? null : _number(match.group(2)!);
      if (match == null || mg == null || mg <= 0) {
        // Not "<name> <number> mg": kept as a note rather than guessed at.
        entry.notes.add('Shot (from Shotsy): $shotText');
      } else {
        final clock = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(at(time));
        final hour = clock == null ? 12 : int.parse(clock.group(1)!).clamp(0, 23);
        final minute = clock == null ? 0 : int.parse(clock.group(2)!).clamp(0, 59);
        final siteText = at(site);
        final known = _sites[siteText.toLowerCase()];
        final painValue = _number(at(pain))?.round() ?? 0;
        final note = at(shotNotes);
        entry.shot = ShotsyShot(
          medication: match.group(1)!.trim(),
          mg: mg,
          at: DateTime(day.year, day.month, day.day, hour, minute),
          site: known,
          siteText: known == null && siteText.isNotEmpty ? siteText : null,
          note: note.isEmpty ? null : note,
          pain: painValue.clamp(0, 10),
        );
      }
    }

    final pounds = _number(at(weight));
    if (pounds != null && pounds > 0) entry.weightLb = pounds;

    final dayNote = at(dayNotes);
    if (dayNote.isNotEmpty) entry.notes.add(dayNote);

    for (final MapEntry(key: name, value: type) in _symptoms.entries) {
      final value = at(col(name));
      if (value.isEmpty) continue;
      final severity = _number(value);
      if (severity != null && severity == severity.roundToDouble() && severity >= 1 && severity <= 10) {
        entry.effects[type] = severity.round();
      } else {
        entry.notes.add('${header[col(name)]} (from Shotsy): $value');
      }
    }

    entry.hasFood = food.any((i) => at(i).isNotEmpty);
    if (entry.shot != null ||
        entry.weightLb != null ||
        entry.notes.isNotEmpty ||
        entry.effects.isNotEmpty ||
        entry.hasFood) {
      days.add(entry);
    }
  }
  return ShotsyFile(days);
}
