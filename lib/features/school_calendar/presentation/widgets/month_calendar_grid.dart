import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event.dart';
import 'event_type_colors.dart';

/// Month grid matching the mockup's Calendar View - dots colored by event
/// type under each day that has an event, current day highlighted.
class MonthCalendarGrid extends StatelessWidget {
  final DateTime month;
  final List<CalendarEvent> events;
  final void Function(DateTime day)? onDayTap;

  const MonthCalendarGrid({
    super.key,
    required this.month,
    required this.events,
    this.onDayTap,
  });

  List<CalendarEvent> _eventsOn(DateTime day) {
    return events.where((e) {
      final start = DateTime(
        e.startDate.year,
        e.startDate.month,
        e.startDate.day,
      );
      final end = DateTime(e.endDate.year, e.endDate.month, e.endDate.day);
      final target = DateTime(day.year, day.month, day.day);
      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = (firstOfMonth.weekday - DateTime.monday) % 7;
    final today = DateTime.now();
    final colors = Theme.of(context).colorScheme;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(month.year, month.month, d);
      final dayEvents = _eventsOn(day);
      final isToday =
          day.year == today.year &&
          day.month == today.month &&
          day.day == today.day;

      cells.add(
        InkWell(
          onTap: onDayTap == null ? null : () => onDayTap!(day),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: isToday
                      ? BoxDecoration(
                          color: colors.onSurface,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Text(
                    '$d',
                    style: TextStyle(
                      color: isToday ? colors.surface : colors.onSurface,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (dayEvents.isNotEmpty)
                  Wrap(
                    spacing: 2,
                    children: dayEvents
                        .take(3)
                        .map(
                          (e) => Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: calendarEventTypeColor(e.type),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          childAspectRatio: 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }
}
