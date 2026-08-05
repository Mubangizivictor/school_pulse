import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event_type.dart';

Color calendarEventTypeColor(CalendarEventType type) {
  switch (type) {
    case CalendarEventType.schoolDay:
      return const Color(0xFF4CAF50);
    case CalendarEventType.event:
      return const Color(0xFF2196F3);
    case CalendarEventType.holiday:
      return const Color(0xFFE53935);
    case CalendarEventType.breakDay:
      return const Color(0xFFFF9800);
    case CalendarEventType.examination:
      return const Color(0xFF9C27B0);
    case CalendarEventType.staffTraining:
      return const Color(0xFF00BCD4);
    case CalendarEventType.meeting:
      return const Color(0xFFFF9800);
    case CalendarEventType.sports:
      return const Color(0xFF9C27B0);
    case CalendarEventType.other:
      return const Color(0xFF8792A6);
  }
}
