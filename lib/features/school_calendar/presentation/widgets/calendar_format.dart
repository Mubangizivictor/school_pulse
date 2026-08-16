import '../../domain/entities/calendar_event.dart';

/// Shared date/time text formatting used across the calendar screens.
const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const monthAbbrev = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

String monthLabel(DateTime date) =>
    '${monthNames[date.month - 1]} ${date.year}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')} ${monthAbbrev[value.month - 1]} ${value.year}';

String formatEventTime(CalendarEvent event) => event.allDay
    ? 'All day'
    : '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')} – '
          '${event.endDate.hour.toString().padLeft(2, '0')}:${event.endDate.minute.toString().padLeft(2, '0')}';
