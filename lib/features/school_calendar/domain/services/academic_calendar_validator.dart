import '../entities/academic_calendar_configuration.dart';

class CalendarValidationIssue {
  final String code;
  final String message;
  const CalendarValidationIssue(this.code, this.message);
}

/// Pure validation shared by create, activation, import preview and future
/// server actions. This is intentionally scope-aware: mixed calendars can
/// coexist, while conflicting active records in the same scope cannot.
class AcademicCalendarValidator {
  const AcademicCalendarValidator();

  List<CalendarValidationIssue> validateYear(
    AcademicCalendarYear year,
    Iterable<AcademicCalendarYear> existing,
  ) {
    final issues = <CalendarValidationIssue>[];
    if (!year.endDate.isAfter(year.startDate)) {
      issues.add(
        const CalendarValidationIssue(
          'year_range',
          'Academic year end date must be after its start date.',
        ),
      );
    }
    if (year.isCurrent || year.status == AcademicCalendarStatus.active) {
      final conflict = existing.any(
        (other) =>
            other.id != year.id &&
            other.isCurrent &&
            other.scope.overlaps(year.scope) &&
            _overlaps(
              year.startDate,
              year.endDate,
              other.startDate,
              other.endDate,
            ),
      );
      if (conflict) {
        issues.add(
          const CalendarValidationIssue(
            'current_year_conflict',
            'Another current academic year overlaps this calendar scope.',
          ),
        );
      }
    }
    return issues;
  }

  List<CalendarValidationIssue> validatePeriod(
    AcademicCalendarPeriod period,
    AcademicCalendarYear year,
    Iterable<AcademicCalendarPeriod> existing,
  ) {
    final issues = <CalendarValidationIssue>[];
    if (!period.endDate.isAfter(period.startDate)) {
      issues.add(
        const CalendarValidationIssue(
          'period_range',
          'Academic period end date must be after its start date.',
        ),
      );
    }
    if (period.startDate.isBefore(year.startDate) ||
        period.endDate.isAfter(year.endDate)) {
      issues.add(
        const CalendarValidationIssue(
          'outside_year',
          'Academic period must sit within its academic year.',
        ),
      );
    }
    if (period.teachingStartDate != null && period.teachingEndDate != null) {
      if (!period.teachingEndDate!.isAfter(period.teachingStartDate!) ||
          period.teachingStartDate!.isBefore(period.startDate) ||
          period.teachingEndDate!.isAfter(period.endDate)) {
        issues.add(
          const CalendarValidationIssue(
            'teaching_range',
            'Teaching dates must be ordered and sit within the academic period.',
          ),
        );
      }
    }
    final conflict = existing.any(
      (other) =>
          other.id != period.id &&
          other.academicYearId == period.academicYearId &&
          other.scope.overlaps(period.scope) &&
          _overlaps(
            period.startDate,
            period.endDate,
            other.startDate,
            other.endDate,
          ),
    );
    if (conflict) {
      issues.add(
        const CalendarValidationIssue(
          'period_overlap',
          'Academic periods in the same calendar scope cannot overlap.',
        ),
      );
    }
    return issues;
  }

  List<CalendarValidationIssue> validateDeadline(
    CalendarDeadline deadline,
    AcademicCalendarPeriod period,
  ) {
    final issues = <CalendarValidationIssue>[];
    if (deadline.opensAt != null &&
        deadline.dueAt.isBefore(deadline.opensAt!)) {
      issues.add(
        const CalendarValidationIssue(
          'deadline_opens_after_due',
          'A deadline cannot be due before it opens.',
        ),
      );
    }
    if (deadline.lockAt != null && deadline.lockAt!.isBefore(deadline.dueAt)) {
      issues.add(
        const CalendarValidationIssue(
          'deadline_lock_before_due',
          'A deadline lock date cannot precede its due date.',
        ),
      );
    }
    if (deadline.dueAt.isBefore(period.startDate) ||
        deadline.dueAt.isAfter(period.endDate.add(const Duration(days: 1)))) {
      issues.add(
        const CalendarValidationIssue(
          'deadline_outside_period',
          'Deadline must fall within its academic period.',
        ),
      );
    }
    return issues;
  }

  bool isTeachingDay(
    DateTime date,
    Iterable<TeachingDay> days,
    Iterable<CalendarClosure> closures, {
    CalendarScope scope = const CalendarScope(),
  }) {
    final enabled = days.any(
      (day) =>
          day.weekday == date.weekday &&
          day.enabled &&
          day.scope.overlaps(scope),
    );
    final closed = closures.any(
      (closure) =>
          closure.teachingSuspended &&
          closure.scope.overlaps(scope) &&
          !date.isBefore(_dateOnly(closure.startDate)) &&
          !date.isAfter(_dateOnly(closure.endDate)),
    );
    return enabled && !closed;
  }

  static bool _overlaps(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) => aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
