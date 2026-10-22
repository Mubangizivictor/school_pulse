import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_integrity_validator.dart';

void main() {
  const validator = StructureIntegrityValidator();

  group('class and stream capacity enforcement', () {
    const level = EducationalLevel(
      id: 'primary',
      schoolId: 'school-a',
      name: 'Primary',
      code: 'PRI',
    );
    const schoolClass = SchoolClass(
      id: 'p5',
      schoolId: 'school-a',
      name: 'Primary 5',
      code: 'P5',
      levelId: 'primary',
      capacity: 50,
    );

    test('30 + 25 is rejected when class capacity is 50', () {
      const existing = [
        ClassStream(
          id: 'blue',
          name: 'Blue',
          classId: 'p5',
          schoolId: 'school-a',
          capacity: 30,
        ),
      ];
      const red = ClassStream(
        id: 'red',
        name: 'Red',
        classId: 'p5',
        schoolId: 'school-a',
        capacity: 25,
      );

      final error = validator.validateStream(
        red,
        classes: const [schoolClass],
        streams: existing,
      );

      expect(error, isNotNull);
      expect(error, contains('Class capacity: 50'));
      expect(error, contains('already allocated: 30'));
      expect(error, contains('available: 20'));
    });

    test('30 + 20 is accepted when class capacity is 50', () {
      const existing = [
        ClassStream(
          id: 'blue',
          name: 'Blue',
          classId: 'p5',
          schoolId: 'school-a',
          capacity: 30,
        ),
      ];
      const red = ClassStream(
        id: 'red',
        name: 'Red',
        classId: 'p5',
        schoolId: 'school-a',
        capacity: 20,
      );

      expect(
        validator.validateStream(
          red,
          classes: const [schoolClass],
          streams: existing,
        ),
        isNull,
      );
    });

    test('class capacity cannot be reduced below active stream allocation', () {
      const streams = [
        ClassStream(
          id: 'blue',
          name: 'Blue',
          classId: 'p5',
          schoolId: 'school-a',
          capacity: 30,
        ),
        ClassStream(
          id: 'red',
          name: 'Red',
          classId: 'p5',
          schoolId: 'school-a',
          capacity: 20,
        ),
      ];
      const reduced = SchoolClass(
        id: 'p5',
        schoolId: 'school-a',
        name: 'Primary 5',
        code: 'P5',
        levelId: 'primary',
        capacity: 40,
      );

      final error = validator.validateClass(
        reduced,
        levels: const [level],
        classes: const [schoolClass],
        streams: streams,
      );

      expect(error, contains('active streams already allocate 50 places'));
    });

    test('inactive stream is excluded from active capacity allocation', () {
      const streams = [
        ClassStream(
          id: 'blue',
          schoolId: 'school-a',
          name: 'Blue',
          classId: 'p5',
          capacity: 30,
          isActive: false,
        ),
        ClassStream(
          id: 'red',
          name: 'Red',
          classId: 'p5',
          schoolId: 'school-a',
          capacity: 20,
        ),
      ];
      const reduced = SchoolClass(
        id: 'p5',
        schoolId: 'school-a',
        name: 'Primary 5',
        code: 'P5',
        levelId: 'primary',
        capacity: 40,
      );

      expect(
        validator.validateClass(
          reduced,
          levels: const [level],
          classes: const [schoolClass],
          streams: streams,
        ),
        isNull,
      );
    });
  });

  group('academic calendar integrity', () {
    final year = AcademicYear(
      id: '2026',
      schoolId: 'school-a',
      name: '2026',
      startDate: DateTime(2026, 1, 20),
      endDate: DateTime(2026, 12, 10),
      isCurrent: true,
    );

    test('term outside academic year is rejected', () {
      final invalid = AcademicTerm(
        id: 'term1',
        schoolId: 'school-a',
        academicYearId: '2026',
        name: 'Term 1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );

      expect(
        validator.validateAcademicTerm(invalid, [year], const []),
        contains('must fall inside 2026'),
      );
    });

    test('overlapping term is rejected', () {
      final existing = AcademicTerm(
        id: 'term1',
        schoolId: 'school-a',
        academicYearId: '2026',
        name: 'Term 1',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 5, 1),
      );
      final overlapping = AcademicTerm(
        id: 'term2',
        schoolId: 'school-a',
        academicYearId: '2026',
        name: 'Term 2',
        startDate: DateTime(2026, 4, 20),
        endDate: DateTime(2026, 8, 1),
      );

      expect(
        validator.validateAcademicTerm(overlapping, [year], [existing]),
        contains('overlaps'),
      );
    });

    test('terms and semesters cannot be mixed within one academic year', () {
      final term = AcademicTerm(
        id: 'term1',
        schoolId: 'school-a',
        academicYearId: '2026',
        name: 'Term 1',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 5, 1),
      );
      final semester = AcademicTerm(
        id: 'semester1',
        schoolId: 'school-a',
        academicYearId: '2026',
        name: 'Semester 1',
        startDate: DateTime(2026, 5, 2),
        endDate: DateTime(2026, 9, 1),
        periodType: AcademicPeriodType.semester,
      );
      expect(
        validator.validateAcademicTerm(semester, [year], [term]),
        contains('cannot be mixed'),
      );
    });
  });
}
