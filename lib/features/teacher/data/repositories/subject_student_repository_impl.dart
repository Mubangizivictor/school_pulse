import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/entities/subject_enrollment.dart';
import '../../domain/repositories/subject_student_repository.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/subject_teacher_local_data_source.dart';
import '../datasources/subject_teacher_remote_data_source.dart';
import '../models/subject_teacher_isar_models.dart';

class SubjectStudentRepositoryImpl implements SubjectStudentRepository {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectTeacherLocalDataSource localDataSource;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  SubjectStudentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.auditService,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<SubjectStudentSummary>>> getSubjectStudents({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  }) async {
    if (!context.can(Permission.subjectStudentsView)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to view this subject\'s students.',
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
      final enrollments = await _loadEnrollments(
        context: context,
        subjectId: subjectId,
        classId: classId,
        forceRefresh: forceRefresh,
      );

      final active =
          enrollments.where((e) => e.isActive).map((e) => e.studentId).toSet();
      if (active.isEmpty) return const Right([]);

      final roster = await remoteDataSource.getClassRoster(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );

      final mandatoryBy = {
        for (final e in enrollments) e.studentId: e.isMandatory,
      };

      // The intersection is the point: a student appears only if they are
      // both on the class roster and enrolled in this subject. Being in the
      // class is not enough, which is what keeps an elective's teacher from
      // seeing the students who did not take it.
      final students = roster
          .where((s) => active.contains(s.studentId))
          .map((s) => SubjectStudentSummary(
                studentId: s.studentId,
                name: s.name,
                admissionNumber: s.admissionNumber,
                photoUrl: s.photoUrl,
                classId: s.classId,
                className: s.className,
                streamId: s.streamId,
                streamName: s.streamName,
                isMandatory: mandatoryBy[s.studentId] ?? false,
              ))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return Right(students);
    } on NetworkFailureException {
      return const Left(NetworkFailure(
        'You are offline. Pull down again when you have a connection.',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EligibleStudent>>> getEligibleStudents({
    required ActiveResponsibilityContext context,
  }) async {
    if (!context.can(Permission.subjectStudentEnroll)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to add students to this subject.',
      ));
    }

    final subjectId = context.subjectId;
    final classId = context.classId;
    if (subjectId == null || classId == null) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a subject and class.',
      ));
    }

    if (!await networkInfo.isConnected) {
      // Enrolling from a stale roster risks adding a student who has since
      // transferred out, so this one needs a live read.
      return const Left(OfflineNotAllowedFailure(
        'Adding students needs an internet connection.',
      ));
    }

    try {
      final roster = await remoteDataSource.getClassRoster(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );

      final enrollments = await remoteDataSource.getEnrollments(
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );
      final alreadyEnrolled = enrollments
          .where((e) => e.isActive)
          .map((e) => e.studentId)
          .toSet();

      return Right(
        roster.where((s) => !alreadyEnrolled.contains(s.studentId)).toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enrollStudents({
    required ActiveResponsibilityContext context,
    required List<String> studentIds,
  }) async {
    if (!context.can(Permission.subjectStudentEnroll)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to add students to this subject.',
      ));
    }
    if (studentIds.isEmpty) {
      return const Left(ValidationFailure('Select at least one student.'));
    }

    final subjectId = context.subjectId;
    final classId = context.classId;
    if (subjectId == null || classId == null) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a subject and class.',
      ));
    }

    if (!await networkInfo.isConnected) {
      return const Left(OfflineNotAllowedFailure(
        'Adding students needs an internet connection.',
      ));
    }

    try {
      final now = DateTime.now();
      final enrollments = studentIds
          .map((studentId) => SubjectEnrollment(
                id: '',
                schoolId: context.schoolId,
                campusId: context.campusId,
                studentId: studentId,
                subjectId: subjectId,
                classId: classId,
                streamId: context.streamId,
                academicYearId: context.academicYearId,
                roleAssignmentId: context.roleAssignmentId,
                enrolledAt: now,
                enrolledBy: context.staffId,
                effectiveFrom: now,
              ))
          .toList();

      await remoteDataSource.createEnrollments(enrollments);
      await localDataSource.cacheEnrollments(
        enrollments.map(SubjectEnrollmentIsar.fromEntity).toList(),
      );

      for (final studentId in studentIds) {
        await auditService.record(
          context: context,
          action: SubjectAuditAction.studentAddedToSubject,
          entityType: 'subject_enrollment',
          entityId: studentId,
          newValue: {
            'subjectId': subjectId,
            'classId': classId,
            'academicYearId': context.academicYearId,
          },
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubjectEnrollmentStatus>> removeStudent({
    required ActiveResponsibilityContext context,
    required String studentId,
    required String reason,
    required bool requiresApproval,
  }) async {
    if (!context.can(Permission.subjectStudentRemove)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to remove students from this subject.',
      ));
    }
    if (reason.trim().isEmpty) {
      return const Left(ValidationFailure(
        'Give a reason for removing this student.',
        field: 'reason',
      ));
    }
    if (!await networkInfo.isConnected) {
      return const Left(OfflineNotAllowedFailure(
        'Removing a student needs an internet connection.',
      ));
    }

    final existing = await getEnrollment(context: context, studentId: studentId);
    return existing.fold(
      (failure) async => Left(failure),
      (enrollment) async {
        if (enrollment == null) {
          return const Left(ValidationFailure(
            'This student is not enrolled in the subject.',
          ));
        }
        // A mandatory subject is not the teacher's to drop, whatever their
        // own permission says - that decision belongs to the academic office.
        if (enrollment.isMandatory && !requiresApproval) {
          return const Left(ValidationFailure(
            'This subject is mandatory. Removal needs approval from the '
            'academic office.',
          ));
        }

        final now = DateTime.now();
        // Historical marks stay attached to the enrollment row, so removal
        // closes the row rather than deleting it.
        final updated = enrollment.copyWith(
          // Restamped with the responsibility doing the removing, not the one
          // that created the enrollment - that is what the rules check.
          roleAssignmentId: context.roleAssignmentId,
          status: requiresApproval
              ? SubjectEnrollmentStatus.pendingRemoval
              : SubjectEnrollmentStatus.removed,
          removedAt: requiresApproval ? null : now,
          removedBy: context.staffId,
          removalReason: reason.trim(),
          effectiveTo: requiresApproval ? null : now,
        );

        try {
          await remoteDataSource.updateEnrollment(updated);
          await localDataSource
              .cacheEnrollments([SubjectEnrollmentIsar.fromEntity(updated)]);

          await auditService.record(
            context: context,
            action: requiresApproval
                ? SubjectAuditAction.studentRemovalRequested
                : SubjectAuditAction.studentRemoved,
            entityType: 'subject_enrollment',
            entityId: studentId,
            previousValue: {'status': enrollment.status.name},
            newValue: {'status': updated.status.name},
            reason: reason.trim(),
          );

          return Right(updated.status);
        } catch (e) {
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  @override
  Future<Either<Failure, SubjectEnrollment?>> getEnrollment({
    required ActiveResponsibilityContext context,
    required String studentId,
  }) async {
    final subjectId = context.subjectId;
    if (subjectId == null) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a subject.',
      ));
    }

    try {
      final enrollments = await remoteDataSource.getEnrollmentsForStudent(
        schoolId: context.schoolId,
        studentId: studentId,
        academicYearId: context.academicYearId,
      );
      return Right(
        enrollments.where((e) => e.subjectId == subjectId).firstOrNull,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Reads enrollment from the server when possible and falls back to the
  /// cache, so the register still works in a classroom with no signal.
  Future<List<SubjectEnrollment>> _loadEnrollments({
    required ActiveResponsibilityContext context,
    required String subjectId,
    required String classId,
    required bool forceRefresh,
  }) async {
    if (await networkInfo.isConnected) {
      final remote = await remoteDataSource.getEnrollments(
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );
      await localDataSource.cacheEnrollments(
        remote.map(SubjectEnrollmentIsar.fromEntity).toList(),
      );
      return remote;
    }

    if (forceRefresh) throw const NetworkFailureException();

    final cached = await localDataSource.getEnrollments(
      schoolId: context.schoolId,
      subjectId: subjectId,
      classId: classId,
      academicYearId: context.academicYearId,
      streamId: context.streamId,
    );
    return cached.map((e) => e.toEntity()).toList();
  }
}

/// Thrown when a caller insisted on fresh data that connectivity cannot
/// supply. Caught by the repository and mapped to a Failure.
class NetworkFailureException implements Exception {
  const NetworkFailureException();
}
