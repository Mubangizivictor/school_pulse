import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/entities/subject_enrollment.dart';
import '../../domain/repositories/lesson_attendance_repository.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/subject_teacher_local_data_source.dart';
import '../datasources/subject_teacher_remote_data_source.dart';
import '../models/subject_teacher_isar_models.dart';

class LessonAttendanceRepositoryImpl implements LessonAttendanceRepository {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectTeacherLocalDataSource localDataSource;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final DeviceIdService deviceIdService;
  final Uuid uuid;

  LessonAttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.auditService,
    required this.networkInfo,
    required this.deviceIdService,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, LessonAttendance>> openRegister({
    required ActiveResponsibilityContext context,
    required Lesson lesson,
    required List<SubjectStudentSummary> enrolledStudents,
  }) async {
    if (!context.can(Permission.subjectAttendanceTake)) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to take attendance for this subject.',
        ),
      );
    }
    final scopeFailure = _checkScope(context, lesson);
    if (scopeFailure != null) return Left(scopeFailure);

    try {
      // A draft already on the device wins over a fresh one: it may hold
      // marks taken offline that the server has never seen.
      final cached = await localDataSource.getAttendance(lesson.id);
      if (cached != null) {
        return Right(
          _reconcileWithEnrollment(cached.toEntity(), enrolledStudents),
        );
      }

      if (await networkInfo.isConnected) {
        final remote = await remoteDataSource.getLessonAttendance(
          schoolId: context.schoolId,
          lessonId: lesson.id,
        );
        if (remote != null) {
          await localDataSource.saveAttendance(
            LessonAttendanceIsar.fromEntity(remote),
          );
          return Right(_reconcileWithEnrollment(remote, enrolledStudents));
        }
      }

      // Seeded from enrolled students only. A student sitting in the room who
      // is not enrolled in this subject gets no row, which is the point.
      final register = LessonAttendance(
        id: uuid.v4(),
        schoolId: context.schoolId,
        campusId: context.campusId,
        lessonId: lesson.id,
        academicYearId: context.academicYearId,
        termId: context.termId,
        subjectId: lesson.subjectId,
        classId: lesson.classId,
        streamId: lesson.streamId,
        staffId: context.staffId,
        roleAssignmentId: context.roleAssignmentId,
        entries: enrolledStudents
            .map((s) => LessonAttendanceEntry(studentId: s.studentId))
            .toList(),
        deviceId: await _deviceId(),
        updatedAt: DateTime.now(),
      );
      return Right(register);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LessonAttendance>> saveDraft({
    required ActiveResponsibilityContext context,
    required LessonAttendance attendance,
  }) async {
    if (!context.can(Permission.subjectAttendanceTake)) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to take attendance for this subject.',
        ),
      );
    }
    if (!attendance.isEditable) {
      return const Left(
        ValidationFailure(
          'This register has been submitted. Request a correction to change it.',
        ),
      );
    }

    final draft = attendance.copyWith(
      status: AttendanceRegisterStatus.draft,
      updatedAt: DateTime.now(),
    );

    try {
      // Local first, always. The teacher's marks are safe on the device
      // before any network call is attempted.
      await localDataSource.saveAttendance(
        LessonAttendanceIsar.fromEntity(draft),
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.saveLessonAttendance(draft);
      } else {
        await _queue(context, draft, OfflineOperationType.attendanceDraft);
      }

      await auditService.record(
        context: context,
        action: SubjectAuditAction.attendanceSaved,
        entityType: 'lesson_attendance',
        entityId: attendance.lessonId,
        newValue: {
          'present': draft.presentCount,
          'absent': draft.absentCount,
          'unmarked': draft.unmarkedCount,
        },
      );

      return Right(draft);
    } catch (e) {
      // The draft is on the device even if the write failed, so queue it and
      // report success - losing a register to a flaky connection is not
      // acceptable.
      await _queue(context, draft, OfflineOperationType.attendanceDraft);
      return Right(draft);
    }
  }

  @override
  Future<Either<Failure, LessonAttendance>> submit({
    required ActiveResponsibilityContext context,
    required LessonAttendance attendance,
  }) async {
    if (!context.can(Permission.subjectAttendanceTake)) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to submit attendance for this subject.',
        ),
      );
    }
    if (attendance.status == AttendanceRegisterStatus.submitted ||
        attendance.status == AttendanceRegisterStatus.locked) {
      return const Left(
        ValidationFailure('This register has already been submitted.'),
      );
    }
    if (attendance.entries.isEmpty) {
      return const Left(
        ValidationFailure(
          'No students are enrolled in this subject for this class.',
        ),
      );
    }
    // Refusing here is the whole reason notMarked exists: submitting with
    // gaps would silently record absences nobody actually marked.
    if (attendance.unmarkedCount > 0) {
      return Left(
        ValidationFailure(
          '${attendance.unmarkedCount} student(s) are still unmarked.',
          field: 'entries',
        ),
      );
    }

    final submitted = attendance.copyWith(
      status: AttendanceRegisterStatus.submitted,
      submittedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await localDataSource.saveAttendance(
        LessonAttendanceIsar.fromEntity(submitted),
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.saveLessonAttendance(submitted);
      } else {
        // Submission is queueable: the marks were taken in the room, and
        // holding them hostage to connectivity helps nobody.
        await _queue(context, submitted, OfflineOperationType.attendanceSubmit);
      }

      await auditService.record(
        context: context,
        action: SubjectAuditAction.attendanceSubmitted,
        entityType: 'lesson_attendance',
        entityId: attendance.lessonId,
        newValue: {
          'present': submitted.presentCount,
          'absent': submitted.absentCount,
          'total': submitted.entries.length,
        },
      );

      return Right(submitted);
    } catch (e) {
      await _queue(context, submitted, OfflineOperationType.attendanceSubmit);
      return Right(submitted);
    }
  }

  @override
  Future<Either<Failure, LessonAttendance>> correct({
    required ActiveResponsibilityContext context,
    required LessonAttendance attendance,
    required String studentId,
    required LessonAttendanceStatus newStatus,
    required String reason,
  }) async {
    if (!context.can(Permission.subjectAttendanceEdit)) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to edit submitted attendance.',
        ),
      );
    }
    if (reason.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Give a reason for changing this attendance mark.',
          field: 'reason',
        ),
      );
    }
    if (attendance.status == AttendanceRegisterStatus.locked &&
        !context.can(Permission.subjectAttendanceEditHistorical)) {
      return const Left(
        PermissionDeniedFailure(
          'This register is locked. Ask the academic office to reopen it.',
        ),
      );
    }

    final existing = attendance.entryFor(studentId);
    if (existing == null) {
      return const Left(
        ValidationFailure('That student is not on this register.'),
      );
    }

    // Corrections need connectivity: replaying one against a register the
    // office has since changed is how history gets silently overwritten.
    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Correcting a submitted register needs an internet connection.',
        ),
      );
    }

    final corrected = attendance.copyWith(
      entries: attendance.entries
          .map(
            (e) => e.studentId == studentId
                ? e.copyWith(status: newStatus, markedAt: DateTime.now())
                : e,
          )
          .toList(),
      updatedAt: DateTime.now(),
    );

    try {
      await remoteDataSource.saveLessonAttendance(corrected);
      await localDataSource.saveAttendance(
        LessonAttendanceIsar.fromEntity(corrected),
      );

      // Both values recorded: an attendance history that only shows the
      // current mark cannot be reviewed.
      await auditService.record(
        context: context,
        action: SubjectAuditAction.attendanceEdited,
        entityType: 'lesson_attendance',
        entityId: attendance.lessonId,
        previousValue: {'studentId': studentId, 'status': existing.status.name},
        newValue: {'studentId': studentId, 'status': newStatus.name},
        reason: reason.trim(),
      );

      return Right(corrected);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Keeps a cached register in step with enrollment that has changed since
  /// it was written: newly enrolled students gain an unmarked row, and rows
  /// for students no longer enrolled are dropped rather than submitted.
  LessonAttendance _reconcileWithEnrollment(
    LessonAttendance attendance,
    List<SubjectStudentSummary> enrolledStudents,
  ) {
    final enrolledIds = enrolledStudents.map((s) => s.studentId).toSet();
    final existingIds = attendance.entries.map((e) => e.studentId).toSet();

    // A submitted register is history and is left exactly as it was.
    if (!attendance.isEditable) return attendance;

    final kept = attendance.entries.where(
      (e) => enrolledIds.contains(e.studentId),
    );
    final added = enrolledStudents
        .where((s) => !existingIds.contains(s.studentId))
        .map((s) => LessonAttendanceEntry(studentId: s.studentId));

    return attendance.copyWith(entries: [...kept, ...added]);
  }

  Failure? _checkScope(ActiveResponsibilityContext context, Lesson lesson) {
    if (!context.permissionScope.covers(
      subjectId: lesson.subjectId,
      classId: lesson.classId,
      streamId: lesson.streamId,
      academicYearId: lesson.academicYearId,
    )) {
      return const PermissionDeniedFailure(
        'This lesson is outside your current responsibility.',
      );
    }
    if (!lesson.isTaughtBy(context.staffId)) {
      return const PermissionDeniedFailure(
        'This lesson is assigned to another teacher.',
      );
    }
    return null;
  }

  Future<void> _queue(
    ActiveResponsibilityContext context,
    LessonAttendance attendance,
    String operationType,
  ) async {
    final operation = OfflineOperation(
      // Keyed on the lesson so a re-save replaces the queued write instead of
      // stacking up ten copies of the same register.
      operationId: 'attendance_${attendance.lessonId}',
      entityType: operationType,
      entityId: attendance.lessonId,
      action: operationType,
      payload: {'lessonId': attendance.lessonId},
      createdAt: DateTime.now(),
      schoolId: context.schoolId,
      userId: context.userId,
      roleAssignmentId: context.roleAssignmentId,
      deviceId: await _deviceId(),
    );
    await localDataSource.enqueueOperation(
      SubjectTeacherOfflineOperationIsar.fromEntity(operation),
    );
  }

  Future<String> _deviceId() async {
    try {
      return await deviceIdService.getDeviceId();
    } catch (_) {
      return '';
    }
  }
}
