import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/domain/policies/marks_entry_policy.dart';

const _policy = MarksEntryPolicy();

const _component = AssessmentComponent(
  id: 'c1',
  assessmentId: 'as1',
  name: 'Paper 1',
  maximumMark: 40,
);

SubjectAssessment _assessment({
  AssessmentAvailability status = AssessmentAvailability.open,
  String subjectId = 'maths',
  String classId = 'g10a',
  DateTime? entryOpensAt,
}) {
  return SubjectAssessment(
    id: 'as1',
    schoolId: 'school1',
    academicYearId: '2026',
    termId: 't2',
    subjectId: subjectId,
    classId: classId,
    maximumMark: 40,
    status: status,
    entryOpensAt: entryOpensAt,
    components: const [_component],
  );
}

ActiveResponsibilityContext _context({
  Set<String> permissions = const {
    Permission.subjectMarksEnter,
    Permission.subjectMarksSubmit,
    Permission.subjectMarksEdit,
  },
  String subjectId = 'maths',
}) {
  return ActiveResponsibilityContext(
    schoolId: 'school1',
    academicYearId: '2026',
    termId: 't2',
    staffId: 'staff1',
    userId: 'user1',
    roleAssignmentId: 'a1',
    roleType: StaffResponsibilityType.subjectTeacher,
    subjectId: subjectId,
    classId: 'g10a',
    permissionScope: PermissionScope(
      permissions: permissions,
      subjectId: subjectId,
      classId: 'g10a',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

StudentMarkEntry _entry(
  String studentId, {
  double? score,
  MarkEntryStatus status = MarkEntryStatus.scored,
}) {
  return StudentMarkEntry(
    studentId: studentId,
    componentId: 'c1',
    score: score,
    status: status,
  );
}

void main() {
  group('validating one mark', () {
    test('accepts a mark inside the range', () {
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: 32),
          component: _component,
        ),
        isNull,
      );
    });

    test('accepts the maximum exactly', () {
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: 40),
          component: _component,
        ),
        isNull,
      );
    });

    test('rejects a negative mark', () {
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: -1),
          component: _component,
        ),
        MarkRejection.belowZero,
      );
    });

    test('rejects a mark above the component maximum', () {
      // 45 out of 40 is the classic slip - the paper is out of 40, not 100.
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: 45),
          component: _component,
        ),
        MarkRejection.aboveMaximum,
      );
    });

    test('names the actual maximum in the message', () {
      expect(MarkRejection.aboveMaximum.messageFor(40), contains('40'));
    });

    test('rejects a student who is not enrolled in the subject', () {
      expect(
        _policy.validateEntry(
          entry: _entry('outsider', score: 20),
          component: _component,
          enrolledStudentIds: {'s1', 's2'},
        ),
        MarkRejection.studentNotEnrolled,
      );
    });

    test('accepts absent with no score', () {
      expect(
        _policy.validateEntry(
          entry: _entry('s1', status: MarkEntryStatus.absent),
          component: _component,
        ),
        isNull,
      );
    });

    test('rejects absent carrying a score', () {
      // "Absent, 45" is ambiguous and would be averaged inconsistently.
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: 45, status: MarkEntryStatus.absent),
          component: _component,
        ),
        MarkRejection.statusWithScore,
      );
    });

    test('rejects a bare number with no status', () {
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: 20, status: MarkEntryStatus.notEntered),
          component: _component,
        ),
        MarkRejection.scoreWithoutStatus,
      );
    });

    test('rejects scored with no number', () {
      expect(
        _policy.validateEntry(entry: _entry('s1'), component: _component),
        MarkRejection.scoreWithoutStatus,
      );
    });

    test('rejects NaN', () {
      expect(
        _policy.validateEntry(
          entry: _entry('s1', score: double.nan),
          component: _component,
        ),
        MarkRejection.notANumber,
      );
    });
  });

  group('parsing typed input', () {
    test('reads a whole number', () => expect(_policy.parseScore('32'), 32));
    test('reads a decimal', () => expect(_policy.parseScore('32.5'), 32.5));
    test(
      'ignores surrounding space',
      () => expect(_policy.parseScore('  18 '), 18),
    );
    test(
      'treats blank as clearing the cell',
      () => expect(_policy.parseScore('   '), isNull),
    );
    test('refuses letters', () => expect(_policy.parseScore('abc'), isNull));
  });

  group('review before submission', () {
    final enrolled = {'s1', 's2', 's3'};

    MarksSubmissionReport review(
      List<StudentMarkEntry> entries, {
      SubjectAssessment? assessment,
      ActiveResponsibilityContext? context,
    }) {
      return _policy.review(
        context: context ?? _context(),
        assessment: assessment ?? _assessment(),
        component: _component,
        entries: entries,
        enrolledStudentIds: enrolled,
      );
    }

    test('allows submission once every student has an answer', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', status: MarkEntryStatus.absent),
        _entry('s3', score: 12),
      ]);

      expect(report.canSubmit, isTrue);
      expect(report.entered, 2);
      expect(report.absent, 1);
      expect(report.pending, 0);
    });

    test('blocks submission while marks are missing', () {
      final report = review([_entry('s1', score: 30)]);

      expect(report.refusal, SubmissionRefusal.missingMarks);
      expect(report.pending, 2);
    });

    test('counts a student with no row at all as pending', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', score: 20),
        _entry('s3', status: MarkEntryStatus.notEntered),
      ]);

      expect(report.pending, 1);
    });

    test('blocks submission on an invalid mark', () {
      final report = review([
        _entry('s1', score: 300),
        _entry('s2', score: 20),
        _entry('s3', score: 10),
      ]);

      expect(report.refusal, SubmissionRefusal.invalidMarks);
      expect(report.invalid, 1);
    });

    test('ignores rows for students who are not enrolled', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', score: 20),
        _entry('s3', score: 10),
        _entry('ghost', score: 999),
      ]);

      expect(report.canSubmit, isTrue);
      expect(report.totalStudents, 3);
    });

    test('refuses without the submit permission', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', score: 20),
        _entry('s3', score: 10),
      ], context: _context(permissions: const {Permission.subjectMarksEnter}));

      expect(report.refusal, SubmissionRefusal.noPermission);
    });

    test('refuses an assessment for a subject the teacher is not on', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', score: 20),
        _entry('s3', score: 10),
      ], assessment: _assessment(subjectId: 'physics'));

      expect(report.refusal, SubmissionRefusal.outsideScope);
    });

    test('refuses an approved assessment', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', score: 20),
        _entry('s3', score: 10),
      ], assessment: _assessment(status: AssessmentAvailability.approved));

      expect(report.refusal, SubmissionRefusal.assessmentLocked);
    });

    test('refuses before the entry window opens', () {
      final report = review(
        [
          _entry('s1', score: 30),
          _entry('s2', score: 20),
          _entry('s3', score: 10),
        ],
        assessment: _assessment(
          entryOpensAt: DateTime.now().add(const Duration(days: 7)),
        ),
      );

      expect(report.refusal, SubmissionRefusal.entryNotOpenYet);
    });

    test('accepts a returned assessment so corrections can be resubmitted', () {
      final report = review([
        _entry('s1', score: 30),
        _entry('s2', score: 20),
        _entry('s3', score: 10),
      ], assessment: _assessment(status: AssessmentAvailability.returned));

      expect(report.canSubmit, isTrue);
    });
  });

  group('editing after submission', () {
    test('an open assessment needs only the ordinary edit permission', () {
      expect(
        _policy.canEdit(
          context: _context(permissions: const {Permission.subjectMarksEdit}),
          status: AssessmentAvailability.open,
        ),
        isTrue,
      );
    });

    test('a submitted assessment needs the elevated permission', () {
      expect(
        _policy.canEdit(
          context: _context(permissions: const {Permission.subjectMarksEdit}),
          status: AssessmentAvailability.submitted,
        ),
        isFalse,
      );
      expect(
        _policy.canEdit(
          context: _context(
            permissions: const {Permission.subjectMarksEditSubmitted},
          ),
          status: AssessmentAvailability.submitted,
        ),
        isTrue,
      );
    });

    test('approved and published marks are closed to everyone', () {
      // These feed report cards; changing one is a correction request.
      for (final status in [
        AssessmentAvailability.approved,
        AssessmentAvailability.published,
        AssessmentAvailability.locked,
      ]) {
        expect(
          _policy.canEdit(
            context: _context(
              permissions: const {
                Permission.subjectMarksEdit,
                Permission.subjectMarksEditSubmitted,
              },
            ),
            status: status,
          ),
          isFalse,
          reason: '$status should not be directly editable',
        );
      }
    });

    test('a submitted mark always needs a reason', () {
      expect(
        _policy.requiresReasonToEdit(AssessmentAvailability.submitted),
        isTrue,
      );
      expect(
        _policy.requiresReasonToEdit(AssessmentAvailability.open),
        isFalse,
      );
    });
  });

  group('averaging', () {
    test('only scored entries count towards an average', () {
      expect(MarkEntryStatus.scored.countsTowardsAverage, isTrue);
      // An absent student must not be averaged in as having scored nothing.
      expect(MarkEntryStatus.absent.countsTowardsAverage, isFalse);
      expect(MarkEntryStatus.exempted.countsTowardsAverage, isFalse);
      expect(MarkEntryStatus.missing.countsTowardsAverage, isFalse);
    });

    test('a percentage is only produced for a real score', () {
      expect(_entry('s1', score: 20).percentageOf(40), 50);
      expect(
        _entry('s1', status: MarkEntryStatus.absent).percentageOf(40),
        isNull,
      );
    });
  });
}
