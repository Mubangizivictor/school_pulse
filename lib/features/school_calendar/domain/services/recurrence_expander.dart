import '../entities/recurrence_rule.dart';

/// A hard ceiling on how many occurrences one recurring event can expand
/// into. Protects against a mistaken "never ends" weekly/daily rule turning
/// into an unbounded Firestore write.
const int kMaxRecurrenceOccurrences = 200;

/// Expands a [RecurrenceRule] anchored at [start] into the list of dates its
/// occurrences fall on, always including [start] itself as the first entry.
///
/// Pure and Firestore-agnostic so it can be unit tested directly and reused
/// by both the write path (materializing documents) and any future read-side
/// display logic.
List<DateTime> expandRecurrenceDates({
  required DateTime start,
  required RecurrenceRule rule,
}) {
  final dates = <DateTime>[];
  final cap = rule.endType == RecurrenceEndType.afterOccurrences
      ? (rule.occurrences ?? 1).clamp(1, kMaxRecurrenceOccurrences)
      : kMaxRecurrenceOccurrences;
  final endDate = rule.endType == RecurrenceEndType.onDate
      ? rule.endDate
      : null;

  bool withinEnd(DateTime d) =>
      endDate == null ||
      !d.isAfter(DateTime(endDate.year, endDate.month, endDate.day, 23, 59));

  switch (rule.frequency) {
    case RecurrenceFrequency.daily:
      var cursor = start;
      while (dates.length < cap && withinEnd(cursor)) {
        dates.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      break;

    case RecurrenceFrequency.weekly:
      final weekdays = rule.repeatsOn.isEmpty
          ? {_weekdayOf(start)}
          : rule.repeatsOn.toSet();
      // Walk day-by-day from the anchor so mixed weekday selections
      // (e.g. Mon/Wed/Fri) interleave in real calendar order rather than
      // producing every Monday, then every Wednesday, etc.
      var cursor = start;
      var guard = 0;
      // 7x the occurrence cap is a generous bound on how many days it could
      // take to find `cap` matching weekdays, even with a single weekday
      // selected - stops a malformed rule from looping forever.
      final dayGuardLimit = cap * 7 + 7;
      while (dates.length < cap && guard < dayGuardLimit) {
        if (weekdays.contains(_weekdayOf(cursor))) {
          if (!withinEnd(cursor)) break;
          dates.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
        guard++;
      }
      break;

    case RecurrenceFrequency.monthly:
      var cursor = start;
      while (dates.length < cap && withinEnd(cursor)) {
        dates.add(cursor);
        cursor = _addMonths(cursor, 1);
      }
      break;

    case RecurrenceFrequency.yearly:
      var cursor = start;
      while (dates.length < cap && withinEnd(cursor)) {
        dates.add(cursor);
        cursor = DateTime(
          cursor.year + 1,
          cursor.month,
          cursor.day,
          cursor.hour,
          cursor.minute,
        );
      }
      break;
  }

  return dates.isEmpty ? [start] : dates;
}

Weekday _weekdayOf(DateTime d) => Weekday.values[d.weekday - 1];

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > daysInMonth ? daysInMonth : date.day;
  return DateTime(year, month, day, date.hour, date.minute);
}
