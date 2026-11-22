import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/medication_store.dart';
import '../dose/dose_math.dart';

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatTime(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));

/// "Today, 8:04 PM", "Yesterday, 8:04 PM" or "Nov 13, 8:04 PM".
String formatWhen(BuildContext context, DateTime when, {DateTime? now}) {
  final time = formatTime(context, when.hour * 60 + when.minute);
  return '${formatDay(context, when, now: now)}, $time';
}

/// "Nov 20", or "Apr 14, 2025" when it isn't this year, so an older date can't be read as recent.
String formatMonthDay(BuildContext context, DateTime when, {DateTime? now}) {
  final dates = MaterialLocalizations.of(context);
  return when.year == (now ?? DateTime.now()).year ? dates.formatShortMonthDay(when) : dates.formatShortDate(when);
}

/// For a chart axis, where there's little room: "Nov 20", or "Apr '25" when it isn't this year.
String formatAxisDate(BuildContext context, DateTime when, {DateTime? now}) {
  final monthDay = MaterialLocalizations.of(context).formatShortMonthDay(when);
  if (when.year == (now ?? DateTime.now()).year) return monthDay;
  return "${monthDay.split(' ').first} '${(when.year % 100).toString().padLeft(2, '0')}";
}

/// "Thu, Nov 20", or "Mon, Apr 14, 2025" when it isn't this year.
String formatLongDay(BuildContext context, DateTime when, {DateTime? now}) =>
    '${weekdayShort[when.weekday - 1]}, ${formatMonthDay(context, when, now: now)}';

/// "Nov 20, 2026": for dates that may be in another year.
String formatFullDate(BuildContext context, DateTime when) => MaterialLocalizations.of(context).formatShortDate(when);

const weekdayLong = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String formatDay(BuildContext context, DateTime when, {DateTime? now}) {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final days = today.difference(DateUtils.dateOnly(when)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return formatMonthDay(context, when, now: now);
}

/// "Weekly · Thu, 8:00 PM", "Mon, Wed, Fri · 9:00 AM", "Every 3 days · 9:00 AM", "As needed".
String describeSchedule(BuildContext context, Medication m) {
  final time = m.timeOfDayMinutes == null ? null : formatTime(context, m.timeOfDayMinutes!);
  final days = [for (final d in m.scheduleDays) weekdayShort[d - 1]].join(', ');
  return switch (m.scheduleType) {
    ScheduleType.weekly => ['Weekly', if (days.isNotEmpty) days].join(' · ') + (time == null ? '' : ', $time'),
    ScheduleType.daysOfWeek => [days, ?time].join(' · '),
    ScheduleType.everyNDays => ['Every ${m.scheduleInterval} days', ?time].join(' · '),
    ScheduleType.daily => ['Daily', ?time].join(' · '),
    ScheduleType.asNeeded => 'As needed',
  };
}

/// "Compounded vial · 10 mg/mL + Cyanocobalamin (B12) 0.5 mg/mL", "Pen", "7 mg tablet".
String describeSupply(MedicationDetail d) {
  final s = d.supply;
  return switch (d.medication.form) {
    MedicationForm.compoundedVial => [
      'Compounded vial',
      if (s?.concentrationMgPerMl != null)
        [
          '${formatNumber(s!.concentrationMgPerMl!, 3)} mg/mL',
          for (final a in s.additives) '${a.name} ${formatNumber(a.amountPerMl, 3)} ${a.unit}/mL',
        ].join(' + '),
    ].join(' · '),
    MedicationForm.brandPen => 'Brand-name pen',
    MedicationForm.oral => s?.pillStrengthMg == null ? 'Pill' : '${formatNumber(s!.pillStrengthMg!, 2)} mg tablet',
    MedicationForm.other => 'Other',
  };
}

/// The usual dose in words: "25 units = 2.5 mg", "5 mg", "1 tablet = 7 mg".
String? describeUsualDose(MedicationDetail d) {
  final p = d.usualDose;
  if (p == null) return null;
  final typed = describeAmount(p.prescribedDose, p.unit);
  final s = d.supply;
  if (p.unit == DoseUnit.tablets) {
    return s?.pillStrengthMg == null
        ? typed
        : '$typed = ${describeAmount(p.prescribedDose * s!.pillStrengthMg!, DoseUnit.mg)}';
  }
  if (s?.concentrationMgPerMl == null) return typed;
  final dose = convertVialDose(amount: p.prescribedDose, unit: p.unit, concentrationMgPerMl: s!.concentrationMgPerMl!);
  return p.unit == DoseUnit.mg
      ? '$typed = ${describeAmount(dose.units, DoseUnit.units)}'
      : '$typed = ${describeAmount(dose.drugMg, DoseUnit.mg)}';
}

/// "1.0 mL of 2 mL left · about 4 doses" or "29 tablets left".
String? describeRemaining(MedicationDetail d) {
  final s = d.supply;
  if (s == null) return null;
  final p = d.usualDose;
  if (d.remainingPills != null) return '${describeAmount(d.remainingPills!, DoseUnit.tablets)} left';
  if (d.remainingMl == null) return null;
  final left = '${formatNumber(d.remainingMl!, 2)} mL of ${formatNumber(s.volumeMl!, 2)} mL left';
  if (p == null || s.concentrationMgPerMl == null || p.unit == DoseUnit.tablets) return left;
  final usual = convertVialDose(amount: p.prescribedDose, unit: p.unit, concentrationMgPerMl: s.concentrationMgPerMl!);
  final n = dosesIn(d.remainingMl!, usual.volumeMl);
  return n == null ? left : '$left · about $n ${n == 1 ? 'dose' : 'doses'} at your usual dose';
}
