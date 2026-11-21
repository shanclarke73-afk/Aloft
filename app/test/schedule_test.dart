import 'package:aloft/data/database.dart';
import 'package:aloft/schedule/schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // November 2026: the 19th is a Thursday.
  final start = DateTime(2026, 11, 2);
  final thursdays8pm = DoseSchedule(
    type: ScheduleType.weekly,
    days: const [4],
    timeOfDayMinutes: 20 * 60,
    startDate: start,
  );

  group('weekly', () {
    test('before anything is logged, the first shot is the first Thursday', () {
      expect(thursdays8pm.nextDue(), DateTime(2026, 11, 5, 20));
    });

    test('a shot on its day moves the next one a week on', () {
      expect(thursdays8pm.nextDue(lastLogged: DateTime(2026, 11, 19, 20, 4)), DateTime(2026, 11, 26, 20));
      expect(thursdays8pm.nextDue(lastLogged: DateTime(2026, 11, 19, 7)), DateTime(2026, 11, 26, 20));
    });

    test('a shot a day early or two days late keeps the Thursday schedule', () {
      expect(thursdays8pm.nextDue(lastLogged: DateTime(2026, 11, 18, 21)), DateTime(2026, 11, 26, 20));
      expect(thursdays8pm.nextDue(lastLogged: DateTime(2026, 11, 21, 9)), DateTime(2026, 11, 26, 20));
    });

    test('with nothing logged since last week, this week\'s shot is still the one that is due', () {
      expect(thursdays8pm.nextDue(lastLogged: DateTime(2026, 11, 12, 20)), DateTime(2026, 11, 19, 20));
    });

    test('a shot logged before the start date does not put the first dose in the past', () {
      expect(thursdays8pm.nextDue(lastLogged: DateTime(2026, 10, 1, 20)), DateTime(2026, 11, 5, 20));
    });
  });

  test('certain days: Mon, Wed, Fri at 9 AM', () {
    final mwf = DoseSchedule(
      type: ScheduleType.daysOfWeek,
      days: const [1, 3, 5],
      timeOfDayMinutes: 9 * 60,
      startDate: start,
    );
    expect(mwf.nextDue(), DateTime(2026, 11, 2, 9));
    expect(mwf.nextDue(lastLogged: DateTime(2026, 11, 16, 9, 10)), DateTime(2026, 11, 18, 9));
    expect(mwf.nextDue(lastLogged: DateTime(2026, 11, 20, 10)), DateTime(2026, 11, 23, 9));
  });

  test('daily', () {
    final daily = DoseSchedule(type: ScheduleType.daily, timeOfDayMinutes: 7 * 60, startDate: start);
    expect(daily.nextDue(lastLogged: DateTime(2026, 11, 19, 7, 2)), DateTime(2026, 11, 20, 7));
    expect(
      daily.nextDue(lastLogged: DateTime(2026, 11, 19, 22)),
      DateTime(2026, 11, 20, 7),
      reason: 'late the same day',
    );
  });

  test('every N days counts from the last dose', () {
    final every3 = DoseSchedule(type: ScheduleType.everyNDays, interval: 3, timeOfDayMinutes: 9 * 60, startDate: start);
    expect(every3.nextDue(), DateTime(2026, 11, 2, 9));
    expect(every3.nextDue(lastLogged: DateTime(2026, 11, 19, 14)), DateTime(2026, 11, 22, 9));
  });

  test('as needed is never due', () {
    final asNeeded = DoseSchedule(type: ScheduleType.asNeeded, startDate: start);
    expect(asNeeded.nextDue(lastLogged: DateTime(2026, 11, 19)), isNull);
    expect(asNeeded.upcoming(lastLogged: null, from: start), isEmpty);
  });

  test('a month crossing the end of daylight saving still lands on the right clock time', () {
    final sundays = DoseSchedule(
      type: ScheduleType.weekly,
      days: const [7],
      timeOfDayMinutes: 8 * 60,
      startDate: DateTime(2026, 10, 1),
    );
    expect(sundays.nextDue(lastLogged: DateTime(2026, 10, 25, 8)), DateTime(2026, 11, 1, 8));
    expect(sundays.nextDue(lastLogged: DateTime(2026, 11, 1, 8)), DateTime(2026, 11, 8, 8));
  });

  test('upcoming reminders start with the due dose and skip ones already past', () {
    final list = thursdays8pm.upcoming(
      lastLogged: DateTime(2026, 11, 12, 20),
      from: DateTime(2026, 11, 21, 9),
      count: 3,
    );
    expect(list, [DateTime(2026, 11, 26, 20), DateTime(2026, 12, 3, 20), DateTime(2026, 12, 10, 20)]);
  });

  group('status', () {
    final due = DateTime(2026, 11, 19, 20);
    test('due today all day, even after the time has passed', () {
      expect(dueStatus(due, DateTime(2026, 11, 19, 6))!.state, DueState.today);
      expect(dueStatus(due, DateTime(2026, 11, 19, 23))!.state, DueState.today);
    });
    test('late the next morning, by calendar days', () {
      final late = dueStatus(due, DateTime(2026, 11, 21, 9))!;
      expect((late.state, late.days), (DueState.late, 2));
      expect(dueStatus(due, DateTime(2026, 11, 20, 0, 5))!.days, 1);
    });
    test('upcoming counts days', () {
      final soon = dueStatus(due, DateTime(2026, 11, 16, 22))!;
      expect((soon.state, soon.days), (DueState.upcoming, 3));
    });
  });
}
