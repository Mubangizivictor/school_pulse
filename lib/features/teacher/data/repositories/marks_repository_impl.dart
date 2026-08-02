import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/subject_assessment.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/policies/marks_entry_policy.dart';
import '../../domain/repositories/marks_repository.dart';
import '../../domain/repositories/subject_student_repository.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/subject_teacher_remote_data_source.dart';

class MarksRepositoryImpl implements MarksRepository {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectStudentRepository studentRepository;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final MarksEntryPolicy policy;

  MarksRepositoryImpl({
    required this.remoteDataSource,
    required this.studentRepository,
    required this.auditService,
    required this.networkInfo,
    this.policy = const MarksEntryPolicy(),
  });

  @override
  Future<Either<Failure, List<SubjectAssessment>>> getAssessments({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  }) async {
    if (!context.can(Permission.subjectMarksView)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to view marks for this subject.',
      ));
    }
    final subjectId = context.subjectId;
    final classId = context.classId;
    if (subjectId == null || classId == null) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a subject and class.',
      ));
    }

    try {
      final assessments = await remoteDataSource.getAssessments(
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        academicYearId: context.academicYearId,
        termId: context.termId.isEmpty ? null : context.termId,
      );
      // Drafts belong to whoever is still preparing them, not to the teacher
      // entering marks.
      return Right(assessments
          .where((a) => a.status != AssessmentAvailability.draft)
          .toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentMarkEntry>>> getMarks({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
  }) async {
    final scopeFailure = _checkScope(context, assessment);
    if (scopeFailure != null) return Left(scopeFailure);

    try {
      final marks = await remoteDataSource.getMarks(
        schoolId: context.schoolId,
        assessmentId: assessment.id,
        componentId: component.id,
      );
      return Right(marks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDraft({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
  }) async {
    if (!context.can(Permission.subjectMarksEnter)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to enter marks for this subject.',
      ));
    }
    final scopeFailure = _checkScope(context, assessment);
    if (scopeFailure != null) return Left(scopeFailure);

    // Individually invalid rows are rejected even in a draft: storing 300/40
    // and discovering it at submission time wastes the teacher's evening.
    for (final entry in entries) {
      final rejection =
          policy.validateEntry(entry: entry, component: component);
      if (rejection != null) {
        return Left(ValidationFailure(
          rejection.messageFor(component.maximumMark),
          field: entry.studentId,
        ));
      }
    }

    try {
      await remoteDataSource.saveMarks(
        schoolId: context.schoolId,
        assessment: assessment,
        component: component,
        entries: entries,
        roleAssignmentId: context.roleAssignmentId,
        staffId: context.staffId,
        markStatus: 'draft',
      );

      await auditService.record(
        context: context,
        action: SubjectAuditAction.marksDraftSaved,
        entityType: 'student_marks',
        entityId: '${assessment.id}_${component.id}',
        newValue: {'entered': entries.where((e) => e.status.isResolved).length},
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarksSubmissionReport>> review({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
  }) async {
    final students =
        await studentRepository.getSubjectStudents(context: context);

    return students.fold(
      Left.new,
      (list) => Right(policy.review(
        context: context,
        assessment: assessment,
        component: component,
        entries: entries,
        // The enrolled set comes from the repository, not from the entry
        // list, so a student the teacher never scrolled to still counts as
        // pending rather than silently vanishing.
        enrolledStudentIds: list.map((s) => s.studentId).toSet(),
      )),
    );
  }

  @override
  Future<Either<Failure, void>> submit({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
  }) async {
    if (!await networkInfo.isConnected) {
      // Submission hands marks to the academic office. Replaying that from a
      // device that has been offline for a week, against an assessment that
      // may since have been approved, is not safe.
      return const Left(OfflineNotAllowedFailure(
        'Submitting marks needs an internet connection.',
      ));
    }

    final reviewResult = await review(
      context: context,
      assessment: assessment,
      component: component,
      entries: entries,
    );

    return reviewResult.fold<Future<Either<Failure, void>>>(
      (failure) async => Left(failure),
      (report) async {
        // Re-run rather than trusting a report the UI computed earlier: the
        // enrolled set may have changed since the screen was drawn.
        if (!report.canSubmit) {
          return Left(_refusalFailure(report));
        }

        try {
          await remoteDataSource.saveMarks(
            schoolId: context.schoolId,
            assessment: assessment,
            component: component,
            entries: entries,
            roleAssignmentId: context.roleAssignmentId,
            staffId: context.staffId,
            markStatus: 'submitted',
          );

          await auditService.record(
            context: context,
            action: SubjectAuditAction.marksSubmitted,
            entityType: 'student_marks',
            entityId: '${assessment.id}_${component.id}',
            newValue: {
              'total': report.totalStudents,
              'entered': report.entered,
              'absent': report.absent,
              'exempted': report.exempted,
            },
          );
          return const Right(null);
        } catch (e) {
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  @override
  Future<Either<Failure, StudentMarkEntry>> editMark({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required StudentMarkEntry entry,
    required String reason,
  }) async {
    if (!policy.canEdit(context: context, status: assessment.status)) {
      return Left(PermissionDeniedFailure(
        assessment.status == AssessmentAvailability.approved ||
                assessment.status == AssessmentAvailability.published
            // Approved marks feed report cards; the route back is a
            // correction request, not an edit.
            ? 'These marks have been approved. Ask the academic office for a correction.'
            : 'You do not have permission to change submitted marks.',
      ));
    }
    if (policy.requiresReasonToEdit(assessment.status) && reason.trim().isEmpty) {
      return const Left(ValidationFailure(
        'Give a reason for changing this mark.',
        field: 'reason',
      ));
    }

    final rejection = policy.validateEntry(entry: entry, component: component);
    if (rejection != null) {
      return Left(ValidationFailure(
        rejection.messageFor(component.maximumMark),
        field: entry.studentId,
      ));
    }
    if (!await networkInfo.isConnected) {
      return const Left(OfflineNotAllowedFailure(
        'Changing a submitted mark needs an internet connection.',
      ));
    }

    try {
      final existing = await remoteDataSource.getMarks(
        schoolId: context.schoolId,
        assessmentId: assessment.id,
        componentId: component.id,
      );
      final previous =
          existing.where((e) => e.studentId == entry.studentId).firstOrNull;

      await remoteDataSource.saveMarks(
        schoolId: context.schoolId,
        assessment: assessment,
        component: component,
        entries: [entry],
        roleAssignmentId: context.roleAssignmentId,
        staffId: context.staffId,
        markStatus: assessment.status == AssessmentAvailability.returned
            ? 'draft'
            : 'submitted',
      );

      await auditService.record(
        context: context,
        action: SubjectAuditAction.marksEdited,
        entityType: 'student_marks',
        entityId: '${assessment.id}_${component.id}_${entry.studentId}',
        previousValue: {
          'score': previous?.score,
          'status': previous?.status.name,
        },
        newValue: {'score': entry.score, 'status': entry.status.name},
        reason: reason.trim(),
      );

      return Right(entry);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _refusalFailure(MarksSubmissionReport report) {
    return switch (report.refusal!) {
      SubmissionRefusal.noPermission => const PermissionDeniedFailure(
          'You do not have permission to submit marks.',
        ),
      SubmissionRefusal.outsideScope => const PermissionDeniedFailure(
          'This assessment is outside your current responsibility.',
        ),
      SubmissionRefusal.assessmentLocked => const ValidationFailure(
          'These marks have been approved and can no longer be submitted.',
        ),
      SubmissionRefusal.assessmentNotOpen => const ValidationFailure(
          'This assessment is not open for marks entry.',
        ),
      SubmissionRefusal.entryNotOpenYet => const ValidationFailure(
          'Marks entry has not opened for this assessment yet.',
        ),
      SubmissionRefusal.missingMarks => ValidationFailure(
          '${report.pending} student(s) still have no mark.',
        ),
      SubmissionRefusal.invalidMarks => ValidationFailure(
          '${report.invalid} mark(s) are outside the allowed range.',
        ),
      SubmissionRefusal.noStudents => const ValidationFailure(
          'No students are enrolled in this subject for this class.',
        ),
    };
  }

  Failure? _checkScope(
    ActiveResponsibilityContext context,
    SubjectAssessment assessment,
  ) {
    if (!context.permissionScope.covers(
      subjectId: assessment.subjectId,
      classId: assessment.classId,
      streamId: assessment.streamId,
      academicYearId: assessment.academicYearId,
    )) {
      return const PermissionDeniedFailure(
        'This assessment is outside your current responsibility.',
      );
    }
    return null;
  }
}
