import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event_type.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/recurrence_rule.dart';

void main() {
  group('NotificationAudience.fromMap round-trip', () {
    test('school audience round-trips', () {
      const audience = NotificationAudience.school();
      final restored = NotificationAudience.fromMap(audience.toMap());
      expect(restored.kind, NotificationAudienceKind.school);
    });

    test('roles audience preserves role list', () {
      const audience = NotificationAudience(
        kind: NotificationAudienceKind.roles,
        roles: ['Teacher', 'Accountant'],
      );
      final restored = NotificationAudience.fromMap(audience.toMap());
      expect(restored.kind, NotificationAudienceKind.roles);
      expect(restored.roles, ['Teacher', 'Accountant']);
    });

    test('legacy label map "All School" resolves to school kind', () {
      final restored = NotificationAudience.fromMap({'kind': 'school'});
      expect(restored.kind, NotificationAudienceKind.school);
    });

    test('null map defaults to school-wide audience (fail-open to visible, not silent)', () {
      final restored = NotificationAudience.fromMap(null);
      expect(restored.kind, NotificationAudienceKind.school);
    });
  });

  group('CalendarEventType', () {
    test('has exactly the 9 spec-required values', () {
      expect(CalendarEventType.values.length, 9);
      expect(CalendarEventType.values, contains(CalendarEventType.schoolDay));
      expect(CalendarEventType.values, contains(CalendarEventType.holiday));
      expect(CalendarEventType.values, contains(CalendarEventType.breakDay));
      expect(
        CalendarEventType.values,
        contains(CalendarEventType.examination),
      );
      expect(CalendarEventType.values, contains(CalendarEventType.event));
      expect(
        CalendarEventType.values,
        contains(CalendarEventType.staffTraining),
      );
      expect(CalendarEventType.values, contains(CalendarEventType.meeting));
      expect(CalendarEventType.values, contains(CalendarEventType.sports));
      expect(CalendarEventType.values, contains(CalendarEventType.other));
    });

    test('every type has a non-empty label and description', () {
      for (final type in CalendarEventType.values) {
        expect(type.label, isNotEmpty);
        expect(type.description, isNotEmpty);
      }
    });
  });

  group('RecurrenceRule', () {
    test('weekly rule with weekdays and occurrence limit is equatable', () {
      const a = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        repeatsOn: [Weekday.monday, Weekday.wednesday],
        endType: RecurrenceEndType.afterOccurrences,
        occurrences: 10,
      );
      const b = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        repeatsOn: [Weekday.monday, Weekday.wednesday],
        endType: RecurrenceEndType.afterOccurrences,
        occurrences: 10,
      );
      expect(a, b);
    });
  });
}
