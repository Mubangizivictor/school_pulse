import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event_type.dart';

/// Display order for the legend, matching the reference mockup layout.
const calendarEventTypeLegendOrder = CalendarEventType.values;

Color calendarEventTypeColor(CalendarEventType type) {
  switch (type) {
    case CalendarEventType.schoolDay:
      return Colors.black;
    case CalendarEventType.event:
      return Colors.black;
    case CalendarEventType.holiday:
      return Colors.black;
    case CalendarEventType.breakDay:
      return Colors.black;
    case CalendarEventType.examination:
      return Colors.black;
    case CalendarEventType.staffTraining:
      return Colors.black;
    case CalendarEventType.meeting:
      return Colors.black;
    case CalendarEventType.sports:
      return Colors.black;
    case CalendarEventType.other:
      return Colors.black;
  }
}
