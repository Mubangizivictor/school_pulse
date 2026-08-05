import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_performance.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_performance_policy.dart';

StudentPerformanceSummary _student({
  String id = 's1',
  Map<String, double> subjects = const {'maths': 70, 'english': 65},
  int missingSubjects = 0,
  double? attendanceRate,
  int followUps = 0,
  double? previousAverage,
}) {
  return StudentPerformanceSummary(
    studentId: id,
    studentName: 'Student $id',
    subjectPercentages: subjects,
    missingSubjects: missingSubjects,
    attendanceRate: attendanceRate,
    openBehaviourFollowUps: followUps,
    previousAverage: previousAverage,
  );
}

void main() {
  const thresholds = AttentionThresholds.defaults;

  group('averages', () {
    test('are null with no approved marks, never zero', () {
      // Zero would read as total failure; the truth is nothing is approved.
      expect(_student(subjects: const {}).average, isNull);
    });

    test('mean across subjects with approved marks only', () {
      expect(
        _student(subjects: const {'maths': 80, 'english': 60}).average,
        70,
      );
    });

    test('a class average ignores students with nothing approved', () {
      final summary = ClassPerformanceSummary(
        students: [
          _student(id: 's1', subjects: const {'maths': 80}),
          _student(id: 's2', subjects: const {}),
        ],
      );

      expect(summary.classAverage, 80);
      expect(summary.studentsAwaitingMarks, 1);
    });

    test('a class with nothing approved has no average or pass rate', () {
      final summary = ClassPerformanceSummary(
        students: [_student(id: 's1', subjects: const {})],
      );

      expect(summary.classAverage, isNull);
      expect(summary.passRate, isNull);
    });

    test('pass rate measures against the school\'s own pass mark', () {
      final summary = ClassPerformanceSummary(
        passMark: 60,
        students: [
          _student(id: 's1', subjects: const {'maths': 65}),
          _student(id: 's2', subjects: const {'maths': 55}),
        ],
      );

      expect(summary.passRate, 50);
    });
  });

  group('subject coverage', () {
    test('reports how much of the class an average actually covers', () {
      const subject = SubjectPerformanceSummary(
        subjectId: 'maths',
        average: 72,
        studentsWithMarks: 10,
        studentsExpected: 30,
      );

      // An average over a third of the class is not the class's average.
      expect(subject.coverage, closeTo(0.333, 0.01));
      expect(subject.isComplete, isFalse);
    });
  });

  group('students needing attention', () {
    test('a low average is surfaced', () {
      final reasons = ClassPerformancePolicy.reasonsFor(
        _student(subjects: const {'maths': 30}),
        thresholds,
      );

      expect(reasons, contains(AttentionReason.lowAverage));
    });

    test('a slip against last term is surfaced', () {
      final reasons = ClassPerformancePolicy.reasonsFor(
        _student(subjects: const {'maths': 60}, previousAverage: 78),
        thresholds,
      );

      expect(reasons, contains(AttentionReason.decliningTrend));
    });

    test('a small dip is not', () {
      final reasons = ClassPerformancePolicy.reasonsFor(
        _student(subjects: const {'maths': 72}, previousAverage: 75),
        thresholds,
      );

      expect(reasons, isNot(contains(AttentionReason.decliningTrend)));
    });

    test('low attendance is surfaced', () {
      final reasons = ClassPerformancePolicy.reasonsFor(
        _student(attendanceRate: 62),
        thresholds,
      );

      expect(reasons, contains(AttentionReason.lowAttendance));
    });

    test('missing marks are surfaced as incomplete data, not as failure', () {
      final reasons = ClassPerformancePolicy.reasonsFor(
        _student(missingSubjects: 4),
        thresholds,
      );

      expect(reasons, contains(AttentionReason.missingMarks));
      expect(reasons, isNot(contains(AttentionReason.lowAverage)));
    });

    test('an open behaviour follow-up is surfaced', () {
      final reasons = ClassPerformancePolicy.reasonsFor(
        _student(followUps: 1),
        thresholds,
      );

      expect(reasons, contains(AttentionReason.behaviourFollowUp));
    });

    test('a student doing fine is not surfaced at all', () {
      expect(
        ClassPerformancePolicy.reasonsFor(
          _student(attendanceRate: 96),
          thresholds,
        ),
        isEmpty,
      );
    });

    test('thresholds are the school\'s, not the app\'s', () {
      // The same student is fine under one school's bar and flagged under
      // another's.
      final student = _student(subjects: const {'maths': 45});

      expect(
        ClassPerformancePolicy.reasonsFor(student, thresholds),
        isNot(contains(AttentionReason.lowAverage)),
      );
      expect(
        ClassPerformancePolicy.reasonsFor(
          student,
          const AttentionThresholds(lowAverage: 50),
        ),
        contains(AttentionReason.lowAverage),
      );
    });
  });

  group('ordering', () {
    test('concerns about the child outrank gaps in the paperwork', () {
      final flagged = ClassPerformancePolicy.needingAttention([
        _student(id: 'paperwork', missingSubjects: 4),
        _student(id: 'struggling', subjects: const {'maths': 25}),
      ], thresholds);

      expect(flagged.first.student.studentId, 'struggling');
      expect(flagged.last.isDataOnly, isTrue);
    });

    test('more reasons sort higher', () {
      final flagged = ClassPerformancePolicy.needingAttention([
        _student(id: 'one', subjects: const {'maths': 30}),
        _student(
          id: 'several',
          subjects: const {'maths': 30},
          attendanceRate: 50,
          followUps: 2,
        ),
      ], thresholds);

      expect(flagged.first.student.studentId, 'several');
    });

    test('reasons read as situations, never as labels on the child', () {
      // These strings reach the screen.
      expect(AttentionReason.lowAverage.label, 'Needs academic support');
      expect(AttentionReason.missingMarks.label, 'Incomplete data');
      expect(AttentionReason.lowAttendance.label, 'Attendance concern');
    });
  });
}
