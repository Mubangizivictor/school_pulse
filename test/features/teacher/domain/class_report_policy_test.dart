import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_report_policy.dart';

const _fullProfile = ReportProfile(
  id: 'p1',
  enabledSections: {
    ReportSection.competencies,
    ReportSection.conduct,
    ReportSection.teacherComment,
    ReportSection.recommendations,
    ReportSection.attendanceVerification,
  },
  commentMinLength: 20,
);

const _commentOnlyProfile = ReportProfile(
  id: 'p2',
  enabledSections: {ReportSection.teacherComment},
  commentMinLength: 20,
);

ClassReportEntry _entry({
  ReportEntryStatus status = ReportEntryStatus.inProgress,
  bool competenciesDone = false,
  bool conductDone = false,
  String? comment,
  List<String> recommendations = const [],
  bool attendanceVerified = false,
}) {
  return ClassReportEntry(
    id: 'e1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    termId: '2026-t2',
    studentId: 's1',
    studentName: 'Abalo Peter',
    status: status,
    competencies: [
      CompetencyEntry(
        domainId: 'communication',
        levelCode: competenciesDone ? 'achieved' : null,
      ),
    ],
    conduct: [
      ConductEntry(
        criterionId: 'respect',
        ratingCode: conductDone ? 'good' : null,
      ),
    ],
    teacherComment: comment,
    recommendations: recommendations,
    attendanceVerified: attendanceVerified,
  );
}

ClassReportEntry _completeEntry({
  ReportEntryStatus status = ReportEntryStatus.inProgress,
}) {
  return _entry(
    status: status,
    competenciesDone: true,
    conductDone: true,
    comment: 'A steady term with clear improvement in written work.',
    recommendations: const ['Keep up daily reading'],
    attendanceVerified: true,
  );
}

void main() {
  group('section completeness', () {
    test('only counts sections the school switched on', () {
      // The same entry is incomplete under a full profile and complete under
      // a comment-only one.
      final entry = _entry(
        comment: 'A steady term with clear improvement in written work.',
      );

      expect(
        ClassReportPolicy.missingSections(entry: entry, profile: _fullProfile),
        isNotEmpty,
      );
      expect(
        ClassReportPolicy.missingSections(
          entry: entry,
          profile: _commentOnlyProfile,
        ),
        isEmpty,
      );
    });

    test('a one-word comment does not count as a comment', () {
      final entry = _entry(comment: 'Good');

      expect(
        ClassReportPolicy.missingSections(
          entry: entry,
          profile: _commentOnlyProfile,
        ),
        contains(ReportSection.teacherComment),
      );
    });

    test('an unrated competency leaves the section incomplete', () {
      expect(
        ClassReportPolicy.missingSections(
          entry: _completeEntry().copyWith(
            competencies: const [CompetencyEntry(domainId: 'communication')],
          ),
          profile: _fullProfile,
        ),
        contains(ReportSection.competencies),
      );
    });
  });

  group('editing', () {
    test('is allowed while the report is still the teacher\'s', () {
      expect(ClassReportPolicy.canEdit(entry: _entry()).isAllowed, isTrue);
    });

    test(
      'is allowed on a returned report - that is the point of returning it',
      () {
        expect(
          ClassReportPolicy.canEdit(
            entry: _entry(status: ReportEntryStatus.returnedForCorrection),
          ).isAllowed,
          isTrue,
        );
      },
    );

    test('is refused once the academic office has approved it', () {
      final decision = ClassReportPolicy.canEdit(
        entry: _entry(status: ReportEntryStatus.academicOfficeApproved),
      );

      expect(decision.refusal, ReportRefusal.notEditable);
      expect(decision.message, contains('approved'));
    });

    test('is refused while under review', () {
      final decision = ClassReportPolicy.canEdit(
        entry: _entry(status: ReportEntryStatus.submittedForReview),
      );

      expect(decision.refusal, ReportRefusal.notEditable);
    });
  });

  group('submitting', () {
    test('names the single missing section', () {
      final decision = ClassReportPolicy.canSubmit(
        entry: _completeEntry().copyWith(attendanceVerified: false),
        profile: _fullProfile,
      );

      expect(decision.refusal, ReportRefusal.sectionsIncomplete);
      expect(decision.missingSections, [ReportSection.attendanceVerification]);
      expect(decision.message, contains('Attendance'));
    });

    test('counts several missing sections', () {
      final decision = ClassReportPolicy.canSubmit(
        entry: _entry(),
        profile: _fullProfile,
      );

      expect(decision.missingSections.length, greaterThan(1));
    });

    test('is allowed once every enabled section is done', () {
      expect(
        ClassReportPolicy.canSubmit(
          entry: _completeEntry(),
          profile: _fullProfile,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('generating', () {
    test('is refused without the permission', () {
      final decision = ClassReportPolicy.canGenerate(
        entries: [_completeEntry()],
        profile: _fullProfile,
        unapprovedSubjects: const [],
        hasGeneratePermission: false,
      );

      expect(decision.refusal, ReportRefusal.generateNotPermitted);
    });

    test('is refused with no students selected', () {
      final decision = ClassReportPolicy.canGenerate(
        entries: const [],
        profile: _fullProfile,
        unapprovedSubjects: const [],
        hasGeneratePermission: true,
      );

      expect(decision.refusal, ReportRefusal.noStudentsSelected);
    });

    test('names the subjects whose marks are not approved', () {
      // The teacher cannot fix these; naming them says who to chase.
      final decision = ClassReportPolicy.canGenerate(
        entries: [_completeEntry()],
        profile: _fullProfile,
        unapprovedSubjects: const ['Mathematics', 'Science'],
        hasGeneratePermission: true,
      );

      expect(decision.refusal, ReportRefusal.marksNotApproved);
      expect(decision.unapprovedSubjects, ['Mathematics', 'Science']);
    });

    test('a school that allows incomplete reports gets them', () {
      const permissive = ReportProfile(
        id: 'p3',
        enabledSections: {ReportSection.teacherComment},
        requiresCompleteness: false,
      );

      expect(
        ClassReportPolicy.canGenerate(
          entries: [_entry()],
          profile: permissive,
          unapprovedSubjects: const ['Mathematics'],
          hasGeneratePermission: true,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('sharing', () {
    test('is refused before publication, whatever the teacher holds', () {
      final decision = ClassReportPolicy.canShare(
        entry: _completeEntry(status: ReportEntryStatus.classTeacherCompleted),
        hasSharePermission: true,
        releaseAllowedByPolicy: true,
      );

      expect(decision.refusal, ReportRefusal.shareBeforePublication);
    });

    test('respects a school hold on release', () {
      // Fee-related holds belong to Finance; the class teacher cannot
      // generate their way around one.
      final decision = ClassReportPolicy.canShare(
        entry: _completeEntry(status: ReportEntryStatus.published),
        hasSharePermission: true,
        releaseAllowedByPolicy: false,
      );

      expect(decision.refusal, ReportRefusal.shareBeforePublication);
    });

    test('is allowed for a published report with no hold', () {
      expect(
        ClassReportPolicy.canShare(
          entry: _completeEntry(status: ReportEntryStatus.published),
          hasSharePermission: true,
          releaseAllowedByPolicy: true,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('class progress', () {
    test('counts complete, returned and published separately', () {
      final progress = ClassReportPolicy.progressOf([
        _completeEntry(),
        _entry(status: ReportEntryStatus.returnedForCorrection),
        _completeEntry(status: ReportEntryStatus.published),
      ], _fullProfile);

      expect(progress.total, 3);
      expect(progress.complete, 2);
      expect(progress.returned, 1);
      expect(progress.published, 1);
      expect(progress.pending, 1);
    });

    test('an empty class has no completion rate rather than zero', () {
      expect(
        ClassReportPolicy.progressOf(const [], _fullProfile).completionRate,
        isNull,
      );
    });
  });
}
