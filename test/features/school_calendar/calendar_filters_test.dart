import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event_type.dart';
import 'package:school_pulse/features/school_calendar/presentation/screens/filters_sheet.dart';

void main() {
  group('CalendarFilters', () {
    test('default filters are empty', () {
      const filters = CalendarFilters();
      expect(filters.isEmpty, isTrue);
    });

    test('a search term makes filters non-empty', () {
      const filters = CalendarFilters(search: 'exam');
      expect(filters.isEmpty, isFalse);
    });

    test('copyWith merges without losing untouched fields', () {
      const filters = CalendarFilters(search: 'sports day');
      final updated = filters.copyWith(
        types: {CalendarEventType.sports},
        audience: NotificationAudienceKind.allStaff,
      );
      expect(updated.search, 'sports day');
      expect(updated.types, {CalendarEventType.sports});
      expect(updated.audience, NotificationAudienceKind.allStaff);
    });

    test('clearAudience/clearFrom/clearTo actually null the field out', () {
      final filters = const CalendarFilters(
        audience: NotificationAudienceKind.allParents,
      ).copyWith(from: DateTime(2026, 1, 1), to: DateTime(2026, 12, 31));
      final cleared = filters.copyWith(
        clearAudience: true,
        clearFrom: true,
        clearTo: true,
      );
      expect(cleared.audience, isNull);
      expect(cleared.from, isNull);
      expect(cleared.to, isNull);
    });

    test('reset (a fresh CalendarFilters) clears every field', () {
      const reset = CalendarFilters();
      expect(reset.isEmpty, isTrue);
    });
  });
}
