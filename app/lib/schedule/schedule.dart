/// When doses are due (SPEC 6.10). Pure date logic: nothing here suggests when anyone should
/// take anything, it only reads the schedule the person entered.
library;

import '../data/database.dart';

/// The schedule fields of a medication.
class DoseSchedule {
  const DoseSchedule({
    required this.type,
    this.days = const [],
    this.interval,
    this.timeOfDayMinutes,
    required this.startDate,
  });

  factory DoseSchedule.of(Medication m) => DoseSchedule(
    type: m.scheduleType,
    days: m.scheduleDays,
    interval: m.scheduleInterval,
    timeOfDayMinutes: m.timeOfDayMinutes,
    startDate: m.startDate,
  );

  final ScheduleType type;

  /// Weekdays, 1 (Monday) to 7 (Sunday).
  final List<int> days;
  final int? interval;
  final int? timeOfDayMinutes;
  final DateTime startDate;

  int get _minutes => timeOfDayMinutes ?? 9 * 60;

  DateTime _at(DateTime day) => DateTime(day.year, day.month, day.day, _minutes ~/ 60, _minutes % 60);

  bool _onDay(DateTime day) => switch (type) {
    ScheduleType.daily => true,
    ScheduleType.weekly || ScheduleType.daysOfWeek => days.contains(day.weekday),
    _ => false,
  };

  /// The first scheduled time after [after], for schedules tied to the calendar.
  DateTime? _nextCalendar(DateTime after) {
    if (type == ScheduleType.daily ||
        ((type == ScheduleType.weekly || type == ScheduleType.daysOfWeek) && days.isNotEmpty)) {
      var day = DateTime(after.year, after.month, after.day);
      for (var i = 0; i < 9; i++) {
        final at = _at(day);
        if (_onDay(day) && at.isAfter(after)) return at;
        day = DateTime(day.year, day.month, day.day + 1);
      }
    }
    return null;
  }

  /// The last scheduled time at or before [at], for schedules tied to the calendar.
  DateTime? _previousCalendar(DateTime at) {
    var day = DateTime(at.year, at.month, at.day);
    for (var i = 0; i < 9; i++) {
      final time = _at(day);
      if (_onDay(day) && !time.isAfter(at)) return time;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return null;
  }

  /// The dose that's due next (it may already be in the past, which means it's late), given
  /// the time of the last dose that was logged or skipped. Null for "as needed".
  ///
  /// A logged dose counts for the scheduled time on the same day, or else the one closest to
  /// it, so a shot taken a day early or two days late doesn't shift the schedule.
  DateTime? nextDue({DateTime? lastLogged}) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    switch (type) {
      case ScheduleType.asNeeded:
        return null;
      case ScheduleType.everyNDays:
        final n = interval ?? 1;
        if (lastLogged == null) return _at(start);
        return _at(DateTime(lastLogged.year, lastLogged.month, lastLogged.day + n));
      case ScheduleType.daily || ScheduleType.weekly || ScheduleType.daysOfWeek:
        final first = _nextCalendar(start.subtract(const Duration(minutes: 1)));
        if (lastLogged == null || first == null) return first;
        final before = _previousCalendar(lastLogged);
        final after = _nextCalendar(lastLogged);
        if (after == null) return null;
        bool sameDay(DateTime a) => a.year == lastLogged.year && a.month == lastLogged.month && a.day == lastLogged.day;
        final DateTime covered;
        if (before != null && sameDay(before)) {
          covered = before;
        } else if (sameDay(after)) {
          covered = after;
        } else {
          covered = before == null || after.difference(lastLogged) < lastLogged.difference(before) ? after : before;
        }
        final next = _nextCalendar(covered);
        return next != null && next.isBefore(first) ? first : next;
    }
  }

  /// Scheduled times from [from] on, starting with [nextDue], for reminders.
  List<DateTime> upcoming({required DateTime? lastLogged, required DateTime from, int count = 12}) {
    final result = <DateTime>[];
    var due = nextDue(lastLogged: lastLogged);
    var guard = 0;
    while (due != null && result.length < count && guard++ < 500) {
      if (!due.isBefore(from)) result.add(due);
      due = type == ScheduleType.everyNDays
          ? DateTime(due.year, due.month, due.day + (interval ?? 1), due.hour, due.minute)
          : _nextCalendar(due);
    }
    return result;
  }
}

/// Where a due dose stands today.
enum DueState { today, upcoming, late }

class DueStatus {
  const DueStatus(this.state, this.due, this.days);
  final DueState state;
  final DateTime due;

  /// Whole calendar days until the dose (upcoming) or since it (late); 0 for today.
  final int days;
}

/// Compares by calendar day, so a shot due at 8 PM is "today" all day, and one due yesterday
/// evening is "late" this morning.
DueStatus? dueStatus(DateTime? due, DateTime now) {
  if (due == null) return null;
  final days = DateTime(due.year, due.month, due.day).difference(DateTime(now.year, now.month, now.day)).inHours / 24;
  final whole = days.round();
  if (whole == 0) return DueStatus(DueState.today, due, 0);
  return whole > 0 ? DueStatus(DueState.upcoming, due, whole) : DueStatus(DueState.late, due, -whole);
}
