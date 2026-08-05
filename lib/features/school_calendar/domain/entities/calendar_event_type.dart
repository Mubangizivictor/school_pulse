/// Matches the mockup's Event Type picker categories exactly - Holiday and
/// Break are their own types (not sub-categories of a generic "event") so
/// the Holidays screen can filter on `type` alone.
enum CalendarEventType {
  schoolDay,
  holiday,
  breakDay,
  examination,
  event,
  staffTraining,
  meeting,
  sports,
  other,
}

extension CalendarEventTypeLabel on CalendarEventType {
  String get label {
    switch (this) {
      case CalendarEventType.schoolDay:
        return 'School Day';
      case CalendarEventType.holiday:
        return 'Holiday';
      case CalendarEventType.breakDay:
        return 'Break';
      case CalendarEventType.examination:
        return 'Examination';
      case CalendarEventType.event:
        return 'Event';
      case CalendarEventType.staffTraining:
        return 'Staff Training';
      case CalendarEventType.meeting:
        return 'Meeting';
      case CalendarEventType.sports:
        return 'Sports';
      case CalendarEventType.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case CalendarEventType.schoolDay:
        return 'Regular school day';
      case CalendarEventType.holiday:
        return 'Public holiday';
      case CalendarEventType.breakDay:
        return 'School break';
      case CalendarEventType.examination:
        return 'Examination period';
      case CalendarEventType.event:
        return 'School event';
      case CalendarEventType.staffTraining:
        return 'Professional development';
      case CalendarEventType.meeting:
        return 'Meeting or conference';
      case CalendarEventType.sports:
        return 'Sports activity';
      case CalendarEventType.other:
        return 'Other event';
    }
  }
}
