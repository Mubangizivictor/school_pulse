import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/recurrence_rule.dart';
import 'package:school_pulse/features/school_calendar/domain/services/recurrence_expander.dart';

void main() {
  group('expandRecurrenceDates', () {
    test('daily rule with a fixed occurrence count produces exactly that '
        'many consecutive days', () {
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 1),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          endType: RecurrenceEndType.afterOccurrences,
          occurrences: 5,
        ),
      );
      expect(dates.length, 5);
      expect(dates.first, DateTime(2026, 1, 1));
      expect(dates.last, DateTime(2026, 1, 5));
    });

    test('weekly rule on Mon/Wed/Fri interleaves in real calendar order, '
        'not grouped by weekday', () {
      // 2026-01-05 is a Monday.
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 5),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          repeatsOn: [Weekday.monday, Weekday.wednesday, Weekday.friday],
          endType: RecurrenceEndType.afterOccurrences,
          occurrences: 6,
        ),
      );
      expect(dates.length, 6);
      expect(dates, [
        DateTime(2026, 1, 5), // Mon
        DateTime(2026, 1, 7), // Wed
        DateTime(2026, 1, 9), // Fri
        DateTime(2026, 1, 12), // Mon
        DateTime(2026, 1, 14), // Wed
        DateTime(2026, 1, 16), // Fri
      ]);
    });

    test('weekly rule with no explicit weekdays repeats on the anchor '
        "date's own weekday", () {
      // 2026-01-06 is a Tuesday.
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 6),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          endType: RecurrenceEndType.afterOccurrences,
          occurrences: 3,
        ),
      );
      expect(dates, [
        DateTime(2026, 1, 6),
        DateTime(2026, 1, 13),
        DateTime(2026, 1, 20),
      ]);
    });

    test('monthly rule anchored on the 31st clamps to the shorter month '
        'instead of overflowing into the next one', () {
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 31),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          endType: RecurrenceEndType.afterOccurrences,
          occurrences: 3,
        ),
      );
      expect(dates, [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28), // February has no 31st
        DateTime(2026, 3, 28), // clamps consistently, doesn't snap back to 31
      ]);
    });

    test('yearly rule advances by exactly one year per occurrence', () {
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 3, 15),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.yearly,
          endType: RecurrenceEndType.afterOccurrences,
          occurrences: 3,
        ),
      );
      expect(dates, [
        DateTime(2026, 3, 15),
        DateTime(2027, 3, 15),
        DateTime(2028, 3, 15),
      ]);
    });

    test('an end date stops expansion at the first occurrence past it', () {
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 1),
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          endType: RecurrenceEndType.onDate,
          endDate: DateTime(2026, 1, 3),
        ),
      );
      expect(dates, [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
      ]);
    });

    test('a never-ending rule is capped at kMaxRecurrenceOccurrences, '
        'never expands unbounded', () {
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 1),
        rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );
      expect(dates.length, kMaxRecurrenceOccurrences);
    });

    test(
      'occurrences count is clamped to the cap even if requested higher',
      () {
        final dates = expandRecurrenceDates(
          start: DateTime(2026, 1, 1),
          rule: const RecurrenceRule(
            frequency: RecurrenceFrequency.daily,
            endType: RecurrenceEndType.afterOccurrences,
            occurrences: 10000,
          ),
        );
        expect(dates.length, kMaxRecurrenceOccurrences);
      },
    );

    test('the anchor date is always the first entry, even for a malformed '
        'zero-occurrence request', () {
      final dates = expandRecurrenceDates(
        start: DateTime(2026, 1, 1),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          endType: RecurrenceEndType.afterOccurrences,
          occurrences: 0,
        ),
      );
      expect(dates, [DateTime(2026, 1, 1)]);
    });
  });
}
