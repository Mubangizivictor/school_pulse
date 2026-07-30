import 'package:flutter/material.dart';
import 'package:school_pulse/features/calendar/domain/entities/school_event.dart';

/// Visual identity + reminder timing for each [SchoolEventType], kept in one
/// place so the event card, the add/edit dialog and the detail screen never
/// drift out of sync with each other.
extension SchoolEventTypeStyle on SchoolEventType {
  String get label {
    switch (this) {
      case SchoolEventType.general:
        return 'General';
      case SchoolEventType.staffMeeting:
        return 'Staff Meeting';
      case SchoolEventType.parentMeeting:
        return 'Parent Meeting';
      case SchoolEventType.exam:
        return 'Exam';
      case SchoolEventType.holiday:
        return 'Holiday';
      case SchoolEventType.sportsEvent:
        return 'Sports Event';
      case SchoolEventType.trip:
        return 'School Trip';
      case SchoolEventType.deadline:
        return 'Deadline';
      case SchoolEventType.assembly:
        return 'Assembly';
      case SchoolEventType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case SchoolEventType.general:
        return Icons.event;
      case SchoolEventType.staffMeeting:
        return Icons.groups;
      case SchoolEventType.parentMeeting:
        return Icons.family_restroom;
      case SchoolEventType.exam:
        return Icons.assignment;
      case SchoolEventType.holiday:
        return Icons.beach_access;
      case SchoolEventType.sportsEvent:
        return Icons.sports_soccer;
      case SchoolEventType.trip:
        return Icons.directions_bus;
      case SchoolEventType.deadline:
        return Icons.alarm;
      case SchoolEventType.assembly:
        return Icons.campaign;
      case SchoolEventType.other:
        return Icons.event_note;
    }
  }

  Color get color {
    switch (this) {
      case SchoolEventType.general:
        return Colors.blue;
      case SchoolEventType.staffMeeting:
        return Colors.orange;
      case SchoolEventType.parentMeeting:
        return Colors.teal;
      case SchoolEventType.exam:
        return Colors.red;
      case SchoolEventType.holiday:
        return Colors.green;
      case SchoolEventType.sportsEvent:
        return Colors.deepPurple;
      case SchoolEventType.trip:
        return Colors.indigo;
      case SchoolEventType.deadline:
        return Colors.pink;
      case SchoolEventType.assembly:
        return Colors.brown;
      case SchoolEventType.other:
        return Colors.blueGrey;
    }
  }

  /// How long before the event date a reminder notification should ring.
  /// Every event type rings a day before and again an hour before, so
  /// nothing depends on remembering per-type schedules.
  List<Duration> get reminderLeadTimes => const [Duration(days: 1), Duration(hours: 1)];
}
