import 'package:flutter/material.dart';

import '../data/database.dart';
import '../util/format.dart';
import 'form_widgets.dart';

/// The schedule being edited: how often, which days, what time.
class ScheduleDraft {
  ScheduleDraft({required this.type, Iterable<int>? days, int? interval, int? timeOfDayMinutes})
    : days = {...?days},
      interval = TextEditingController(text: '${interval ?? 3}'),
      time = timeOfDayMinutes ?? 8 * 60 {
    if (this.days.isEmpty) this.days.add(DateTime.now().weekday);
  }

  factory ScheduleDraft.of(Medication m) => ScheduleDraft(
    type: m.scheduleType,
    days: m.scheduleDays,
    interval: m.scheduleInterval,
    timeOfDayMinutes: m.timeOfDayMinutes,
  );

  ScheduleType type;
  final Set<int> days;
  final TextEditingController interval;
  int time;

  bool get _usesDays => type == ScheduleType.weekly || type == ScheduleType.daysOfWeek;

  List<String> get problems => [
    if (_usesDays && days.isEmpty) 'Choose a day.',
    if (type == ScheduleType.everyNDays && (int.tryParse(interval.text.trim()) ?? 0) < 2)
      'Enter how many days apart (2 or more).',
  ];

  List<int> get scheduleDays => _usesDays ? (days.toList()..sort()) : const [];
  int? get scheduleInterval => type == ScheduleType.everyNDays ? int.parse(interval.text.trim()) : null;
  int? get timeOfDayMinutes => type == ScheduleType.asNeeded ? null : time;

  void dispose() => interval.dispose();
}

/// "How often", day chips and time. Used when adding a medication and when editing its schedule.
class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({super.key, required this.draft, required this.onChanged, this.pill = false});
  final ScheduleDraft draft;
  final VoidCallback onChanged;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final type = draft.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('How often'),
        DropdownMenu<ScheduleType>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: type,
          requestFocusOnTap: false,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: ScheduleType.weekly, label: 'Weekly'),
            DropdownMenuEntry(value: ScheduleType.daysOfWeek, label: 'Certain days (e.g. Mon, Wed, Fri)'),
            DropdownMenuEntry(value: ScheduleType.everyNDays, label: 'Every N days'),
            DropdownMenuEntry(value: ScheduleType.daily, label: 'Daily'),
            DropdownMenuEntry(value: ScheduleType.asNeeded, label: 'As needed'),
          ],
          onSelected: (picked) {
            draft.type = picked!;
            if (picked == ScheduleType.weekly && draft.days.length > 1) {
              final first = draft.days.first;
              draft.days
                ..clear()
                ..add(first);
            }
            onChanged();
          },
        ),
        if (type == ScheduleType.weekly || type == ScheduleType.daysOfWeek) ...[
          FieldLabel(type == ScheduleType.weekly ? (pill ? 'Day' : 'Shot day') : 'Days'),
          Wrap(
            spacing: 6,
            children: [
              for (var day = 1; day <= 7; day++)
                ChoiceChip(
                  label: Text(weekdayShort[day - 1]),
                  showCheckmark: false,
                  selected: draft.days.contains(day),
                  onSelected: (on) {
                    if (type == ScheduleType.weekly) {
                      draft.days
                        ..clear()
                        ..add(day);
                    } else if (on) {
                      draft.days.add(day);
                    } else {
                      draft.days.remove(day);
                    }
                    onChanged();
                  },
                ),
            ],
          ),
        ],
        if (type == ScheduleType.everyNDays) ...[
          const FieldLabel('Days apart'),
          NumberField(controller: draft.interval, suffix: 'days', onChanged: (_) => onChanged(), wholeNumber: true),
        ],
        if (type != ScheduleType.asNeeded) ...[
          const FieldLabel('Time'),
          PickerField(
            text: formatTime(context, draft.time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: draft.time ~/ 60, minute: draft.time % 60),
              );
              if (picked != null) {
                draft.time = picked.hour * 60 + picked.minute;
                onChanged();
              }
            },
          ),
        ],
      ],
    );
  }
}
