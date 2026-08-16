import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import '../../domain/entities/calendar_event.dart';
import '../widgets/calendar_format.dart';
import '../widgets/event_card.dart';

/// "Events on {date}" screen reached by tapping a day in the month grid,
/// matching the reference mockup's Day Events screen.
class DayEventsScreen extends StatelessWidget {
  final DateTime day;
  final List<CalendarEvent> events;
  final bool canManage;
  final VoidCallback onAdd;
  final ValueChanged<CalendarEvent> onOpen;
  const DayEventsScreen({
    super.key,
    required this.day,
    required this.events,
    required this.canManage,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Events on ${formatDate(day)}'),
      actions: [
        if (canManage)
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${events.length} ${events.length == 1 ? 'Event' : 'Events'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                formatDate(day),
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            ],
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No events scheduled',
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                      if (canManage) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Event'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => EventCard(
                    event: events[i],
                    onTap: () => onOpen(events[i]),
                  ),
                ),
        ),
      ],
    ),
  );
}
