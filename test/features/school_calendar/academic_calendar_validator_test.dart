import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/academic_calendar_configuration.dart';
import 'package:school_pulse/features/school_calendar/domain/services/academic_calendar_validator.dart';

void main() {
  const validator = AcademicCalendarValidator();
  final year = AcademicCalendarYear(
    id: 'year',
    institutionId: 'school',
    name: 'Rolling 2026',
    startDate: DateTime(2026, 2, 1),
    endDate: DateTime(2027, 1, 31),
  );

  group('AcademicCalendarValidator', () {
    test('allows different scoped calendars to overlap', () {
      final existing = year.copyWithScope(
        const CalendarScope(divisionId: 'secondary'),
      );
      final candidate = AcademicCalendarYear(
        id: 'university',
        institutionId: 'school',
        name: 'Semester 2026',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2027, 5, 30),
        scope: const CalendarScope(divisionId: 'university'),
        isCurrent: true,
      );
      expect(validator.validateYear(candidate, [existing]), isEmpty);
    });

    test('rejects overlapping periods only in the same scope', () {
      final first = AcademicCalendarPeriod(
        id: 'term-1',
        institutionId: 'school',
        academicYearId: year.id,
        name: 'Term One',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 5, 1),
        scope: const CalendarScope(divisionId: 'primary'),
      );
      final overlapping = AcademicCalendarPeriod(
        id: 'term-2',
        institutionId: 'school',
        academicYearId: year.id,
        name: 'Term Two',
        startDate: DateTime(2026, 4, 20),
        endDate: DateTime(2026, 7, 1),
        scope: const CalendarScope(divisionId: 'primary'),
      );
      expect(
        validator
            .validatePeriod(overlapping, year, [first])
            .map((issue) => issue.code),
        contains('period_overlap'),
      );
    });

    test('accepts a weekend programme without assuming weekdays', () {
      final saturday = DateTime(2026, 2, 7);
      expect(
        validator.isTeachingDay(saturday, const [
          TeachingDay(weekday: DateTime.saturday, enabled: true),
        ], const []),
        isTrue,
      );
    });

    test('a closure suppresses an otherwise enabled teaching day', () {
      final monday = DateTime(2026, 2, 2);
      final closure = CalendarClosure(
        id: 'closure',
        institutionId: 'school',
        title: 'Maintenance',
        kind: CalendarClosureKind.maintenance,
        startDate: monday,
        endDate: monday,
      );
      expect(
        validator.isTeachingDay(
          monday,
          const [TeachingDay(weekday: DateTime.monday, enabled: true)],
          [closure],
        ),
        isFalse,
      );
    });

    test('enforces deadline ordering and period range', () {
      final period = AcademicCalendarPeriod(
        id: 'semester',
        institutionId: 'school',
        academicYearId: year.id,
        name: 'Semester',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 6, 1),
      );
      final deadline = CalendarDeadline(
        id: 'marks',
        institutionId: 'school',
        academicYearId: year.id,
        academicPeriodId: period.id,
        kind: CalendarDeadlineKind.marksEntry,
        title: 'Marks',
        opensAt: DateTime(2026, 5, 20),
        dueAt: DateTime(2026, 5, 10),
      );
      expect(
        validator.validateDeadline(deadline, period).map((issue) => issue.code),
        contains('deadline_opens_after_due'),
      );
    });
  });
}

extension on AcademicCalendarYear {
  AcademicCalendarYear copyWithScope(CalendarScope scope) =>
      AcademicCalendarYear(
        id: id,
        institutionId: institutionId,
        name: name,
        code: code,
        startDate: startDate,
        endDate: endDate,
        scope: scope,
        status: status,
        isCurrent: isCurrent,
        order: order,
        version: version,
      );
}
