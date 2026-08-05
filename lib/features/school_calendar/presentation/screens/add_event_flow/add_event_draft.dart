import '../../../domain/entities/calendar_event_type.dart';
import '../../../domain/entities/recurrence_rule.dart';

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

  bool repeats = false;
  RecurrenceFrequency frequency = RecurrenceFrequency.weekly;
  List<Weekday> repeatsOn = [];
  RecurrenceEndType endType = RecurrenceEndType.never;
  DateTime? recurrenceEndDate;
  int occurrences = 0;

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
