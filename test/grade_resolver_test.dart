import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/services/grade_resolver.dart';

void main() {
  const system = GradingSystemDef(
    id: 'system',
    schoolId: 'school-a',
    name: 'Configured',
  );
  const ranges = [
    GradeBand(
      id: 'a',
      schoolId: 'school-a',
      gradingSystemId: 'system',
      grade: 'A',
      minScore: 80,
      maxScore: 100,
      isPassing: true,
    ),
    GradeBand(
      id: 'b',
      schoolId: 'school-a',
      gradingSystemId: 'system',
      grade: 'B',
      minScore: 70,
      maxScore: 79,
      isPassing: true,
    ),
  ];
  const resolver = GradeResolver();
  test('resolves inclusive numeric boundaries deterministically', () {
    expect(
      resolver
          .resolveScore(score: 100, system: system, ranges: ranges)
          .gradeCode,
      'A',
    );
    expect(
      resolver
          .resolveScore(score: 80, system: system, ranges: ranges)
          .gradeCode,
      'A',
    );
    expect(
      resolver
          .resolveScore(score: 79, system: system, ranges: ranges)
          .gradeCode,
      'B',
    );
    expect(
      resolver
          .resolveScore(score: 70, system: system, ranges: ranges)
          .gradeCode,
      'B',
    );
  });
  test('supports descriptor-only and configured pass/fail levels', () {
    const level = GradeBand(
      id: 'm',
      schoolId: 'school-a',
      gradingSystemId: 'system',
      grade: 'ME',
      label: 'Meeting expectation',
      remarks: 'On track',
      hasNumericBoundary: false,
      isPassing: false,
    );
    final resolution = resolver.resolveDescriptor(
      gradeCode: 'ME',
      system: system,
      ranges: [level],
    );
    expect(resolution.gradeLabel, 'Meeting expectation');
    expect(resolution.isPassing, isFalse);
  });

  test('a score outside every configured range is unresolved', () {
    final resolution = resolver.resolveScore(
      score: 40,
      system: system,
      ranges: ranges,
    );
    expect(resolution.gradeCode, isNull);
    expect(resolution.rawScore, 40);
  });

  test('an empty range list never throws and is unresolved', () {
    final resolution = resolver.resolveScore(
      score: 85,
      system: system,
      ranges: const [],
    );
    expect(resolution.gradeCode, isNull);
  });

  test('an unknown descriptor code resolves to unresolved', () {
    final resolution = resolver.resolveDescriptor(
      gradeCode: 'ZZ',
      system: system,
      ranges: ranges,
    );
    expect(resolution.gradeCode, isNull);
    expect(resolution.rawScore, isNull);
  });

  test('a shared boundary between two bands resolves by declared order, '
      'never ambiguously', () {
    const tied = [
      GradeBand(
        id: 'x',
        schoolId: 'school-a',
        gradingSystemId: 'system',
        grade: 'X',
        order: 0,
        minScore: 70,
        maxScore: 80,
        isPassing: true,
      ),
      GradeBand(
        id: 'y',
        schoolId: 'school-a',
        gradingSystemId: 'system',
        grade: 'Y',
        order: 1,
        minScore: 80,
        maxScore: 90,
        isPassing: true,
      ),
    ];
    // 80 is in both bands' inclusive range; order breaks the tie so a score
    // never ambiguously matches two grades.
    expect(
      resolver.resolveScore(score: 80, system: system, ranges: tied).gradeCode,
      'X',
    );
  });

  test('bands belonging to another grading system never leak into a '
      'resolution, even when passed in the same ranges list', () {
    const otherSystem = GradingSystemDef(
      id: 'other-system',
      schoolId: 'school-a',
      name: 'Other',
    );
    final resolution = resolver.resolveScore(
      score: 50,
      system: otherSystem,
      ranges:
          ranges, // all tagged gradingSystemId: 'system', not 'other-system'
    );
    expect(resolution.gradeCode, isNull);
  });

  test('a cross-tenant gradingSystemId collision never leaks another '
      "school's band into this resolution (defense-in-depth beyond "
      'Firestore-level schoolId scoping)', () {
    const crossTenantSystem = GradingSystemDef(
      id: 'system', // same id as `system`, different tenant
      schoolId: 'school-b',
      name: 'Colliding id from another school',
    );
    final resolution = resolver.resolveScore(
      score: 90,
      system: crossTenantSystem,
      ranges: ranges, // school-a's bands
    );
    expect(resolution.gradeCode, isNull);
  });
}
