import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_report_entry.dart';
import '../../domain/policies/class_report_policy.dart';
import '../../domain/repositories/class_report_repository.dart';
import '../../domain/repositories/class_student_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/class_teacher_remote_data_source.dart';

class ClassReportRepositoryImpl implements ClassReportRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassStudentRepository studentRepository;
  final ClassTeacherAssignmentService assignmentService;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;

  ClassReportRepositoryImpl({
    required this.remoteDataSource,
    required this.studentRepository,
    required this.assignmentService,
    required this.auditService,
    required this.networkInfo,
  });

  /// What a school gets before it has configured anything. Deliberately
  /// permissive on completeness: refusing to generate a report against a
  /// profile the school never set up would be the app's opinion, not theirs.
  static const ReportProfile _fallbackProfile = ReportProfile(
    id: 'default',
    name: 'Default report',
    enabledSections: {
      ReportSection.teacherComment,
      ReportSection.attendanceVerification,
    },
    commentMinLength: 20,
    requiresCompleteness: false,
  );

  @override
  Future<Either<Failure, ReportProfile>> getProfile({
    required ActiveResponsibilityContext context,
  }) async {
    try {
      final profile = await remoteDataSource.getReportProfile(
        schoolId: context.schoolId,
        academicYearId: context.academicYearId,
      );
      return Right(profile ?? _fallbackProfile);
    } catch (_) {
      return const Right(_fallbackProfile);
    }
  }

  @override
  Future<Either<Failure, List<ClassReportEntry>>> getEntries({
    required ActiveResponsibilityContext context,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classReportEntry,
    );
    if (guard.isLeft()) return guard.fold(Left.new, (_) => const Right([]));

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    if (context.termId.isEmpty) {
      return const Left(
        ValidationFailure(
          'Your school has not opened a term yet, so there is no report period '
          'to work in.',
        ),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('You are offline. Report entry needs a connection.'),
      );
    }

    try {
      final existing = await remoteDataSource.getReportEntries(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        termId: context.termId,
      );
      final byStudent = {for (final e in existing) e.studentId: e};

      final roster = await studentRepository.getClassStudents(context: context);
      final students = roster.getOrElse(() => const []);

      // A blank entry per student who has none, so opening reports for the
      // first time shows the class rather than an empty list the teacher has
      // to seed by guessing.
      return Right(
        students
            .map(
              (student) =>
                  byStudent[student.studentId] ??
                  ClassReportEntry(
                    id: '${student.studentId}_${context.termId}',
                    schoolId: context.schoolId,
                    campusId: context.campusId,
                    classId: classId,
                    streamId: context.streamId,
                    academicYearId: context.academicYearId,
                    termId: context.termId,
                    studentId: student.studentId,
                    studentName: student.name,
                  ),
            )
            .toList(),
      );
    } catch (_) {
      return const Left(
        ServerFailure('Could not load report entries. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, ClassReportEntry>> saveEntry({
    required ActiveResponsibilityContext context,
    required ClassReportEntry entry,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classReportEntry,
      classId: entry.classId,
      academicYearId: entry.academicYearId,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final decision = ClassReportPolicy.canEdit(entry: entry);
    if (!decision.isAllowed) {
      return Left(PermissionDeniedFailure(decision.message!));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Saving report entry needs an internet connection.',
        ),
      );
    }

    // A save moves a blank entry to in-progress, so the dashboard's pending
    // count reflects work actually started.
    final prepared = entry.copyWith(
      status: entry.status == ReportEntryStatus.draft
          ? ReportEntryStatus.inProgress
          : entry.status,
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await remoteDataSource.saveReportEntry(prepared);
      await auditService.record(
        context: context,
        action: 'report.draft_saved',
        entityType: 'class_report_entry',
        entityId: prepared.id,
        newValue: {
          'studentId': prepared.studentId,
          'status': prepared.status.name,
        },
      );
      return Right(prepared);
    } catch (_) {
      return const Left(ServerFailure('Could not save this report entry.'));
    }
  }

  @override
  Future<Either<Failure, ClassReportEntry>> submitEntry({
    required ActiveResponsibilityContext context,
    required ClassReportEntry entry,
  }) async {
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classReportSubmit,
      classId: entry.classId,
      academicYearId: entry.academicYearId,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final profileResult = await getProfile(context: context);
    final profile = profileResult.getOrElse(() => _fallbackProfile);

    final decision = ClassReportPolicy.canSubmit(
      entry: entry,
      profile: profile,
    );
    if (!decision.isAllowed) {
      return Left(
        decision.refusal == ReportRefusal.notEditable
            ? PermissionDeniedFailure(decision.message!)
            : ValidationFailure(decision.message!),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Submitting a report needs an internet connection.',
        ),
      );
    }

    final submitted = entry.copyWith(
      status: ReportEntryStatus.classTeacherCompleted,
      submittedAt: DateTime.now(),
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await remoteDataSource.saveReportEntry(submitted);
      await auditService.record(
        context: context,
        action: 'report.submitted',
        entityType: 'class_report_entry',
        entityId: submitted.id,
        previousValue: {'status': entry.status.name},
        newValue: {'status': submitted.status.name},
      );
      return Right(submitted);
    } catch (_) {
      return const Left(ServerFailure('Could not submit this report.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> unapprovedSubjects({
    required ActiveResponsibilityContext context,
  }) async {
    final classId = context.classId;
    if (classId == null || classId.isEmpty) return const Right([]);

    try {
      // Every subject the class has approved marks in. Anything on the
      // timetable but absent from this list has marks still in flight.
      final approved = await remoteDataSource.getApprovedClassMarks(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        termId: context.termId,
        streamId: context.streamId,
      );
      final approvedSubjects = approved.map((m) => m.subjectId).toSet();

      final schedule = await remoteDataSource.getClassSchedule(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        date: DateTime.now(),
        streamId: context.streamId,
      );

      final taught = <String, String>{
        for (final lesson in schedule)
          if (lesson.subjectId.isNotEmpty)
            lesson.subjectId: lesson.subjectName.isEmpty
                ? lesson.subjectId
                : lesson.subjectName,
      };

      return Right(
        taught.entries
            .where((e) => !approvedSubjects.contains(e.key))
            .map((e) => e.value)
            .toList()
          ..sort(),
      );
    } catch (_) {
      // Not knowing must not block the teacher; the school's completeness
      // setting still governs whether generation proceeds.
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, int>> generateReports({
    required ActiveResponsibilityContext context,
    required List<ClassReportEntry> entries,
  }) async {
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classReportGenerate,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final profileResult = await getProfile(context: context);
    final profile = profileResult.getOrElse(() => _fallbackProfile);
    final unapproved = await unapprovedSubjects(context: context);

    final decision = ClassReportPolicy.canGenerate(
      entries: entries,
      profile: profile,
      unapprovedSubjects: unapproved.getOrElse(() => const []),
      hasGeneratePermission: context.can(Permission.classReportGenerate),
    );
    if (!decision.isAllowed) {
      return Left(
        decision.refusal == ReportRefusal.generateNotPermitted
            ? PermissionDeniedFailure(decision.message!)
            : ValidationFailure(decision.message!),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Generating reports needs an internet connection.',
        ),
      );
    }

    try {
      // Marks the entries as ready and hands off. The Report Card Engine
      // computes grades and renders the PDF; publication remains the academic
      // office's decision, which is why nothing here sets a published status.
      for (final entry in entries) {
        if (entry.status == ReportEntryStatus.classTeacherCompleted) continue;
        await remoteDataSource.saveReportEntry(
          entry.copyWith(
            status: ReportEntryStatus.classTeacherCompleted,
            submittedAt: DateTime.now(),
            updatedBy: context.userId,
            updatedAt: DateTime.now(),
            roleAssignmentId: context.roleAssignmentId,
          ),
        );
      }

      await auditService.record(
        context: context,
        action: 'report.generated',
        entityType: 'class_report_entry',
        entityId: context.classId ?? '',
        newValue: {'studentCount': entries.length, 'termId': context.termId},
      );

      return Right(entries.length);
    } catch (_) {
      return const Left(ServerFailure('Could not generate these reports.'));
    }
  }
}
