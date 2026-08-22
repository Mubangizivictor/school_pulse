import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/services/grade_resolver.dart';

/// Proves the Dart [GradeResolver] (used client-side and in any future
/// on-device preview) resolves the exact same fixtures identically to the
/// server-side `resolveGrade()` in functions/report_card_engine.js.
///
/// Cloud Functions cannot execute Dart, so the Report Card Engine ported the
/// same band-matching contract (inclusive bounds, lowest `order` wins an
/// overlap, no match is unresolved rather than fabricated) into JavaScript.
/// This test and functions/report_card_engine.test.js's "parity fixtures"
/// share the same (score, expectedGrade) pairs against an equivalent
/// GradingSystemDef/GradeBand fixture - keep both lists in sync when either
/// changes, so the two implementations can never silently drift apart.
void main() {
  const resolver = GradeResolver();
  const system = GradingSystemDef(
    id: 'gs1',
    schoolId: 'schoolA',
    name: 'O-Level Test Fixture',
    version: 3,
  );
  const gradeBands = [
    GradeBand(
      id: 'b1',
      schoolId: 'schoolA',
      gradingSystemId: 'gs1',
      grade: 'D1',
      label: 'Distinction 1',
      minScore: 90,
      maxScore: 100,
      order: 1,
      gradePoint: 1,
      isPassing: true,
    ),
    GradeBand(
      id: 'b2',
      schoolId: 'schoolA',
      gradingSystemId: 'gs1',
      grade: 'C3',
      label: 'Credit 3',
      minScore: 70,
      maxScore: 89.999,
      order: 2,
      gradePoint: 3,
      isPassing: true,
    ),
    GradeBand(
      id: 'b3',
      schoolId: 'schoolA',
      gradingSystemId: 'gs1',
      grade: 'P7',
      label: 'Pass 7',
      minScore: 40,
      maxScore: 69.999,
      order: 3,
      gradePoint: 7,
      isPassing: true,
    ),
    GradeBand(
      id: 'b4',
      schoolId: 'schoolA',
      gradingSystemId: 'gs1',
      grade: 'F9',
      label: 'Fail 9',
      minScore: 0,
      maxScore: 39.999,
      order: 4,
      gradePoint: 9,
      isPassing: false,
    ),
  ];

  group('GradeResolver / server parity fixtures', () {
    const fixtures = <(double, String)>[
      (100, 'D1'),
      (90, 'D1'),
      (89.999, 'C3'),
      (70, 'C3'),
      (69.999, 'P7'),
      (40, 'P7'),
      (39.999, 'F9'),
      (0, 'F9'),
    ];

    for (final (score, expectedGrade) in fixtures) {
      test('score $score resolves to $expectedGrade', () {
        final result = resolver.resolveScore(
          score: score,
          system: system,
          ranges: gradeBands,
        );
        expect(result.gradeCode, expectedGrade);
      });
    }

    test('a score with no configured grading system is unresolved', () {
      final result = resolver.resolveScore(
        score: 55,
        system: const GradingSystemDef(
          id: 'none',
          schoolId: 'schoolA',
          name: 'x',
        ),
        ranges: const [],
      );
      expect(result.gradeCode, isNull);
      expect(result.rawScore, 55);
    });

    test('a score outside every band is unresolved', () {
      final result = resolver.resolveScore(
        score: -5,
        system: system,
        ranges: gradeBands,
      );
      expect(result.gradeCode, isNull);
    });

    test(
      'an overlapping pair of bands resolves to the lowest order, deterministically',
      () {
        final overlapping = [
          ...gradeBands,
          const GradeBand(
            id: 'bonus',
            schoolId: 'schoolA',
            gradingSystemId: 'gs1',
            grade: 'BONUS',
            minScore: 85,
            maxScore: 95,
            order: 0,
          ),
        ];
        final result = resolver.resolveScore(
          score: 92,
          system: system,
          ranges: overlapping,
        );
        expect(result.gradeCode, 'BONUS');
      },
    );
  });
}
