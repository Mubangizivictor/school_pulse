import 'dart:io';

import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../../domain/entities/calendar_event_type.dart';
import '../../../domain/entities/recurrence_rule.dart';

/// A locally-staged attachment awaiting upload once the event document
/// exists, mirroring the Add Staff wizard's StagedDocument pattern.
class StagedCalendarAttachment {
  final File file;
  final String fileName;
  final int sizeBytes;
  const StagedCalendarAttachment({
    required this.file,
    required this.fileName,
    required this.sizeBytes,
  });
}

/// Mutable draft accumulated across the Add Event wizard steps, mirroring
/// the Add Staff wizard's AddStaffDraft pattern.
class AddEventDraft {
  CalendarEventType type = CalendarEventType.event;
  String title = '';
  String description = '';
  DateTime? startDate;
  DateTime? endDate;
  bool allDay = true;
  String colorHex = '4CAF50';
  String category = '';
  String location = '';
  String organizer = 'School Administration';
  NotificationAudienceKind audienceKind = NotificationAudienceKind.school;
  List<String> audienceRoles = [];
  String reminder = 'None';
  String notes = '';

  /// Attachments already uploaded (when editing an existing event) plus any
  /// newly staged locally for upload on save.
  List<CalendarAttachment> existingAttachments = [];
  List<StagedCalendarAttachment> stagedAttachments = [];

  bool repeats = false;
  RecurrenceFrequency frequency = RecurrenceFrequency.weekly;
  List<Weekday> repeatsOn = [];
  RecurrenceEndType endType = RecurrenceEndType.never;
  DateTime? recurrenceEndDate;
  int occurrences = 0;

  NotificationAudience buildAudience() => NotificationAudience(
    kind: audienceKind,
    roles: audienceKind == NotificationAudienceKind.roles
        ? audienceRoles
        : const [],
  );

  RecurrenceRule? buildRecurrence() {
    if (!repeats) return null;
    return RecurrenceRule(
      frequency: frequency,
      repeatsOn: repeatsOn,
      endType: endType,
      endDate: recurrenceEndDate,
      occurrences: occurrences > 0 ? occurrences : null,
    );
  }
}
