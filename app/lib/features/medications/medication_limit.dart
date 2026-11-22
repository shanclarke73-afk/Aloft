import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../pro/pro.dart';
import '../../settings/settings.dart';

/// "Zepbound", "Zepbound and NAD+", "Zepbound, NAD+ and B12".
String joinNames(List<String> names) =>
    names.length < 2 ? names.join() : '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';

/// Why the Pro screen came up when a second medication was about to become active.
/// [resuming] is the paused medication being resumed; null when adding a new one.
String secondMedicationReason(List<String> active, {String? resuming}) =>
    'Track ${resuming ?? 'another medication'} alongside ${joinNames(active)} with Pro. '
    'One medication at a time is free: pause ${active.length == 1 ? active.single : 'the others'} first '
    'to switch without Pro. Pausing keeps all its history.';

/// Whether one more medication may become active. Free covers one active medication at a
/// time; a second alongside it is Pro (SPEC 6.2). Without Pro and with one already active
/// this shows the Pro screen, and answers whether the person has Pro when it closes.
///
/// Nothing already in Aloft is ever paused or hidden by this: if Pro ends, the medications
/// stay as they are and only adding or resuming another one asks.
Future<bool> allowAnotherActive(BuildContext context, WidgetRef ref, {Medication? resuming}) async {
  if (ref.read(proProvider)) return true;
  final db = ref.read(databaseProvider);
  final active = await (db.select(db.medications)..where((m) => m.status.equalsValue(MedicationStatus.active))).get();
  if (active.isEmpty) return true;
  if (!context.mounted) return false;
  return requirePro(
    context,
    ref,
    reason: secondMedicationReason([for (final m in active) m.name], resuming: resuming?.name),
  );
}
