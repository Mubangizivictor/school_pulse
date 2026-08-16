import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import '../../domain/entities/calendar_event.dart';
import 'calendar_format.dart';
import 'event_type_colors.dart';

/// The date/color-bar/title/time list-item used in both List View and Day
/// Events, matching the reference mockup's event card.
class EventCard extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTap;
  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Column(
                children: [
                  Text(
                    '${event.startDate.day}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    monthAbbrev[event.startDate.month - 1],
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: calendarEventTypeColor(event.type),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatEventTime(event),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  if (event.location.isNotEmpty)
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: calendarEventTypeColor(event.type),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
