import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_validation_service.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

void main() {
  final service = StructureValidationService();

  test('an empty state has no validation issues', () {
    expect(service.validate(const StructureState()), isEmpty);
  });

  test('flags a stream referencing a non-existent class', () {
    final state = StructureState(
      streams: [
        const ClassStream(
          id: 's1',
          schoolId: 'sch1',
          name: 'East',
          classId: 'missing-class',
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Streams / Sections'), true);
  });

  test('does not flag a stream referencing an active class', () {
    final state = StructureState(
      classes: [const SchoolClass(id: 'c1', schoolId: 'sch1', name: 'P1')],
      streams: [
        const ClassStream(
          id: 's1',
          schoolId: 'sch1',
          name: 'East',
          classId: 'c1',
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Streams / Sections'), false);
  });

  test('flags a class with no valid educational level', () {
    final state = StructureState(
      classes: [
        const SchoolClass(
          id: 'c1',
          schoolId: 'sch1',
          name: 'P1',
          levelId: 'missing-level',
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Classes'), true);
  });

  test('flags overlapping grade bands within the same grading system', () {
    final state = StructureState(
      gradingSystems: [
        const GradingSystemDef(id: 'g1', schoolId: 'sch1', name: 'Letter'),
      ],
      gradeBands: [
        const GradeBand(
          id: 'b1',
          schoolId: 'sch1',
          gradingSystemId: 'g1',
          grade: 'A',
          minScore: 70,
          maxScore: 100,
        ),
        const GradeBand(
          id: 'b2',
          schoolId: 'sch1',
          gradingSystemId: 'g1',
          grade: 'B',
          minScore: 60,
          maxScore: 75,
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Grading Systems'), true);
  });

  test('does not flag non-overlapping grade bands', () {
    final state = StructureState(
      gradingSystems: [
        const GradingSystemDef(id: 'g1', schoolId: 'sch1', name: 'Letter'),
      ],
      gradeBands: [
        const GradeBand(
          id: 'b1',
          schoolId: 'sch1',
          gradingSystemId: 'g1',
          grade: 'A',
          minScore: 80,
          maxScore: 100,
        ),
        const GradeBand(
          id: 'b2',
          schoolId: 'sch1',
          gradingSystemId: 'g1',
          grade: 'B',
          minScore: 60,
          maxScore: 79,
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Grading Systems'), false);
  });

  test('flags a term whose dates fall outside its academic year range', () {
    final state = StructureState(
      academicYears: [
        AcademicYear(
          id: 'y1',
          schoolId: 'sch1',
          name: '2026',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31),
        ),
      ],
      academicTerms: [
        AcademicTerm(
          id: 't1',
          schoolId: 'sch1',
          academicYearId: 'y1',
          name: 'Term 1',
          startDate: DateTime(2025, 12, 1),
          endDate: DateTime(2026, 3, 1),
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Terms'), true);
  });

  test('flags a term referencing a non-existent academic year', () {
    final state = StructureState(
      academicTerms: [
        AcademicTerm(
          id: 't1',
          schoolId: 'sch1',
          academicYearId: 'missing-year',
          name: 'Term 1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 3, 1),
        ),
      ],
    );
    final issues = service.validate(state);
    expect(issues.any((i) => i.category == 'Terms'), true);
  });
}
