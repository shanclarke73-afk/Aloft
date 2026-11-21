import '../data/database.dart';
import '../data/medication_store.dart';
import '../dose/dose_math.dart';
import '../schedule/schedule.dart';

/// One local notification to schedule.
class PlannedReminder {
  const PlannedReminder({required this.at, required this.title, required this.body, required this.channel});
  final DateTime at;
  final String title;
  final String body;
  final ReminderChannel channel;

  @override
  String toString() => '$at · $title · $body';
}

enum ReminderChannel {
  shots('shots', 'Shot and dose reminders', 'On the days and times you set for each medication'),
  supply('supply', 'Supply reminders', 'When a vial is running low or its use-by date is near');

  const ReminderChannel(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;
}

/// Reorder reminder when this many doses or fewer are left (SPEC 6.5).
const reorderAtDoses = 2;

/// Whole doses left in the active vial or bottle at the usual dose. Null when it can't be known.
int? dosesLeft(MedicationDetail d) {
  final supply = d.supply, usual = d.usualDose;
  if (supply == null || usual == null) return null;
  if (d.remainingPills != null && usual.unit == DoseUnit.tablets) {
    return usual.prescribedDose <= 0 ? null : (d.remainingPills! / usual.prescribedDose + 1e-9).floor();
  }
  if (d.remainingMl == null || supply.concentrationMgPerMl == null || usual.unit == DoseUnit.tablets) return null;
  final dose = convertVialDose(
    amount: usual.prescribedDose,
    unit: usual.unit,
    concentrationMgPerMl: supply.concentrationMgPerMl!,
  );
  return dosesIn(d.remainingMl!, dose.volumeMl);
}

/// Every reminder that should be pending right now. The whole set is rebuilt and replaced each
/// time the app opens or anything changes, so it never needs to remember what it scheduled.
///
/// iOS keeps at most 64 pending notifications, so this returns the soonest 60.
List<PlannedReminder> planReminders({
  required List<MedicationDetail> medications,
  required AppSettings settings,
  required DateTime now,
  String Function(DateTime day)? formatDay,
}) {
  final active = [
    for (final d in medications)
      if (d.medication.status == MedicationStatus.active) d,
  ];
  final several = active.length > 1;
  final perMedication = active.isEmpty ? 0 : (48 ~/ active.length).clamp(4, 14);
  final plan = <PlannedReminder>[];

  for (final d in active) {
    final m = d.medication;
    final pill = m.form == MedicationForm.oral;

    if (settings.remindShots) {
      final times = DoseSchedule.of(m).upcoming(lastLogged: d.lastLogged?.takenAt, from: now, count: perMedication);
      for (final at in times) {
        plan.add(
          PlannedReminder(
            at: at,
            title: pill ? 'Time for your dose' : 'Shot day',
            // The medication is only named when there's more than one, to keep the lock screen discreet.
            body: several ? '${m.name}. Tap to log it.' : 'Tap to log it in Aloft.',
            channel: ReminderChannel.shots,
          ),
        );
      }
    }

    final supply = d.supply;
    if (supply == null) continue;
    final container = pill ? 'bottle' : 'vial';

    // The morning after the dose that brought it down to the last couple of doses. Worked out
    // from the dose itself, so it's the same every time and only ever fires once.
    final left = dosesLeft(d);
    final last = d.lastDose;
    if (settings.remindReorder &&
        left != null &&
        left <= reorderAtDoses &&
        last != null &&
        last.supplyId == supply.id) {
      final at = DateTime(last.takenAt.year, last.takenAt.month, last.takenAt.day + 1, 9);
      if (at.isAfter(now)) {
        plan.add(
          PlannedReminder(
            at: at,
            title: 'Running low',
            body: left == 0
                ? 'Your ${m.name} $container has less than one dose left.'
                : 'About $left ${left == 1 ? 'dose' : 'doses'} left in your ${m.name} $container.',
            channel: ReminderChannel.supply,
          ),
        );
      }
    }

    final useBy = supply.beyondUseDate;
    if (settings.remindUseBy && useBy != null) {
      final at = DateTime(useBy.year, useBy.month, useBy.day - 7, 9);
      if (at.isAfter(now)) {
        plan.add(
          PlannedReminder(
            at: at,
            title: 'Use-by date in a week',
            body:
                'Your ${m.name} $container is marked use by ${formatDay?.call(useBy) ?? '${useBy.month}/${useBy.day}'}.',
            channel: ReminderChannel.supply,
          ),
        );
      }
    }
  }

  plan.sort((a, b) => a.at.compareTo(b.at));
  return plan.take(60).toList();
}
