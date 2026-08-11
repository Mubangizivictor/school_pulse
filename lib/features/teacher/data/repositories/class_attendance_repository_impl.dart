import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/policies/class_attendance_policy.dart';
import '../../domain/repositories/class_attendance_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/class_teacher_local_data_source.dart';
import '../datasources/class_teacher_remote_data_source.dart';
import '../datasources/subject_teacher_local_data_source.dart';

class ClassAttendanceRepositoryImpl implements ClassAttendanceRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassTeacherLocalDataSource localDataSource;
  final SubjectTeacherLocalDataSource queueDataSource;
  final StructureRepository structureRepository;
  final ClassTeacherAssignmentService assignmentService;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final DeviceIdService deviceIdService;
  final Uuid uuid;

  ClassAttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.queueDataSource,
    required this.structureRepository,
    required this.assignmentService,
    required this.auditService,
    required this.networkInfo,
    required this.deviceIdService,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, Map<String, LessonAttendanceStatus>>>
  getStatusesForDate({
    required ActiveResponsibilityContext context,
    required DateTime date,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classAttendanceView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(Left.new, (_) => const Right({}));
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    if (!await networkInfo.isConnected) {
      // An empty map is honest here: nobody is claimed present or absent, so
      // the roster shows every student as unmarked rather than inventing a
      // register the device has not seen.
      return const Right({});
    }

    try {
      final raw = await remoteDataSource.getSessionStatuses(
        schoolId: context.schoolId,
        classId: classId,
        date: date,
        streamId: context.streamId,
      );

      return Right({
        for (final entry in raw.entries)
          entry.key: LessonAttendanceStatus.fromId(entry.value),
      });
    } catch (_) {
      return const Left(
        ServerFailure("Could not load today's register. Pull down to retry."),
      );
    }
  }

  @override
  Future<Either<Failure, List<ClassAttendanceOption>>> getStatusOptions({
    required ActiveResponsibilityContext context,
  }) async {
    try {
      final configured = await structureRepository
          .watchAttendanceTypes(context.schoolId)
          .first;
      return Right(
        AttendanceStatusResolver.optionsFrom(
          configured
              .map(
                (t) => (
                  id: t.id,
                  name: t.name,
                  colorHex: t.colorHex,
                  isActive: t.isActive,
                ),
              )
              .toList(),
        ),
      );
    } catch (_) {
      // A register with no buttons is worse than an opinionated one, so a
      // config read that fails still yields a usable set.
      return const Right(AttendanceStatusResolver.defaults);
    }
  }

  @override
  Future<Either<Failure, ClassAttendanceSession>> resolveSession({
    required ActiveResponsibilityContext context,
    required DateTime date,
    String sessionType = 'daily',
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classAttendanceTake,
    );
    if (authorized.isLeft()) {
      return authorized.fold(
        Left.new,
        (_) => const Left(PermissionDeniedFailure()),
      );
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    final canTake = ClassAttendancePolicy.canTakeFor(
      date: date,
      now: DateTime.now(),
    );
    if (!canTake.isAllowed) {
      return Left(
        ValidationFailure(canTake.message ?? 'Cannot take this register.'),
      );
    }

    final sessionId = classSessionId(
      classId: classId,
      streamId: context.streamId,
      date: date,
      sessionType: sessionType,
    );

    final empty = ClassAttendanceSession(
      id: sessionId,
      schoolId: context.schoolId,
      campusId: context.campusId,
      classId: classId,
      className: context.className ?? '',
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      sessionType: sessionType,
      date: DateTime(date.year, date.month, date.day),
      roleAssignmentId: context.roleAssignmentId,
    );

    if (!await networkInfo.isConnected) {
      final draft = await _cachedDraft(sessionId);
      return Right(draft ?? empty);
    }

    try {
      final existing = await remoteDataSource.getAttendanceSession(
        schoolId: context.schoolId,
        sessionId: sessionId,
      );

      // A local draft newer than the server copy wins, so work done offline
      // is not silently discarded by simply reconnecting.
      final draft = await _cachedDraft(sessionId);
      if (existing == null) return Right(draft ?? empty);
      if (draft != null && existing.isFreelyEditable) return Right(draft);
      return Right(existing);
    } catch (_) {
      final draft = await _cachedDraft(sessionId);
      return Right(draft ?? empty);
    }
  }

  @override
  Future<Either<Failure, ClassAttendanceSession>> saveDraft({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
  }) async {
    final guard = await _guard(
      context,
      Permission.classAttendanceTake,
      session,
    );
    if (guard != null) return Left(guard);

    final decision = ClassAttendancePolicy.canEdit(
      session: session,
      hasEditPermission: context.can(Permission.classAttendanceEdit),
      hasHistoricalPermission: context.can(
        Permission.classAttendanceEditHistorical,
      ),
      reason: 'draft save',
      now: DateTime.now(),
    );
    if (!decision.isAllowed) {
      return Left(_failureFor(decision));
    }

    final prepared = session.copyWith(
      roleAssignmentId: context.roleAssignmentId,
      deviceId: await _deviceId(),
    );

    await _cacheDraft(prepared);

    if (!await networkInfo.isConnected) {
      await _queue(
        context,
        prepared,
        OfflineOperationType.classAttendanceDraft,
      );
      return Right(prepared);
    }

    try {
      await remoteDataSource.saveAttendanceSession(prepared);
      await auditService.record(
        context: context,
        action: SubjectAuditAction.attendanceSaved,
        entityType: 'class_attendance_session',
        entityId: prepared.id,
        newValue: {'markedCount': prepared.entries.length},
      );
      return Right(prepared);
    } catch (_) {
      await _queue(
        context,
        prepared,
        OfflineOperationType.classAttendanceDraft,
      );
      return Right(prepared);
    }
  }

  @override
  Future<Either<Failure, ClassAttendanceSession>> submit({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
    required List<String> rosterStudentIds,
  }) async {
    // Re-verified against the server rather than trusting the context the
    // screen was opened with: submitting a register is exactly the moment a
    // permission removed mid-session must be caught.
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classAttendanceTake,
      classId: session.classId,
      academicYearId: session.academicYearId,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final completeness = ClassAttendancePolicy.canSubmit(
      session: session,
      rosterStudentIds: rosterStudentIds,
    );
    if (!completeness.isAllowed) {
      return Left(_failureFor(completeness));
    }

    final editable = ClassAttendancePolicy.canEdit(
      session: session,
      hasEditPermission: context.can(Permission.classAttendanceEdit),
      hasHistoricalPermission: context.can(
        Permission.classAttendanceEditHistorical,
      ),
      reason: 'submission',
      now: DateTime.now(),
    );
    if (!editable.isAllowed) {
      return Left(_failureFor(editable));
    }

    final submitted = session.copyWith(
      status: ClassAttendanceSessionStatus.submitted,
      // Stamped by the app, never typed by the teacher.
      submittedAt: DateTime.now(),
      submittedBy: context.userId,
      roleAssignmentId: context.roleAssignmentId,
      deviceId: await _deviceId(),
    );

    await _cacheDraft(submitted);

    if (!await networkInfo.isConnected) {
      await _queue(
        context,
        submitted,
        OfflineOperationType.classAttendanceSubmit,
      );
      return Right(submitted);
    }

    try {
      await remoteDataSource.saveAttendanceSession(submitted);
      await auditService.record(
        context: context,
        action: SubjectAuditAction.attendanceSubmitted,
        entityType: 'class_attendance_session',
        entityId: submitted.id,
        newValue: {
          'counts': submitted
              .countsBy(AttendanceStatusResolver.defaults)
              .map((key, value) => MapEntry(key.name, value)),
          'studentCount': rosterStudentIds.length,
        },
      );
      return Right(submitted);
    } catch (_) {
      await _queue(
        context,
        submitted,
        OfflineOperationType.classAttendanceSubmit,
      );
      return Right(submitted);
    }
  }

  @override
  Future<Either<Failure, ClassAttendanceSession>> correct({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
    required String studentId,
    required String newStatusCode,
    required String reason,
  }) async {
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classAttendanceEdit,
      classId: session.classId,
      academicYearId: session.academicYearId,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final decision = ClassAttendancePolicy.canEdit(
      session: session,
      hasEditPermission: context.can(Permission.classAttendanceEdit),
      hasHistoricalPermission: context.can(
        Permission.classAttendanceEditHistorical,
      ),
      reason: reason,
      now: DateTime.now(),
    );
    if (!decision.isAllowed) {
      return Left(_failureFor(decision));
    }

    // Correcting attendance needs a live write: a queued correction replayed
    // days later would overwrite whatever the office decided in the meantime.
    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Correcting a submitted register needs an internet connection.',
        ),
      );
    }

    final previous = session.statusCodeFor(studentId);
    final corrected = session
        .withMark(studentId, newStatusCode)
        .copyWith(lastCorrectedAt: DateTime.now());

    try {
      await remoteDataSource.saveAttendanceSession(corrected);
      // Old and new both recorded: a correction with no previous value is
      // indistinguishable from an original mark when read back years later.
      await auditService.record(
        context: context,
        action: SubjectAuditAction.attendanceEdited,
        entityType: 'class_attendance_session',
        entityId: corrected.id,
        previousValue: {'studentId': studentId, 'status': previous},
        newValue: {'studentId': studentId, 'status': newStatusCode},
        reason: reason,
      );
      await _cacheDraft(corrected);
      return Right(corrected);
    } catch (_) {
      return const Left(ServerFailure('Could not save the correction.'));
    }
  }

  @override
  Future<Either<Failure, void>> requestCorrection({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
    required String studentId,
    required String requestedStatusCode,
    required String reason,
  }) async {
    final guard = await _guard(
      context,
      Permission.classAttendanceView,
      session,
    );
    if (guard != null) return Left(guard);

    if (reason.trim().length < 5) {
      return const Left(
        ValidationFailure(
          'Give a reason for the correction request.',
          field: 'reason',
        ),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Requesting a correction needs an internet connection.',
        ),
      );
    }

    try {
      await remoteDataSource.createCorrectionRequest(
        AttendanceCorrectionRequest(
          id: uuid.v4(),
          schoolId: context.schoolId,
          sessionId: session.id,
          classId: session.classId,
          academicYearId: session.academicYearId,
          studentId: studentId,
          previousStatusCode: session.statusCodeFor(studentId),
          requestedStatusCode: requestedStatusCode,
          reason: reason,
          requestedByUserId: context.userId,
          requestedByStaffId: context.staffId,
          roleAssignmentId: context.roleAssignmentId,
          requestedAt: DateTime.now(),
        ),
      );

      await auditService.record(
        context: context,
        action: 'attendance.correction_requested',
        entityType: 'class_attendance_session',
        entityId: session.id,
        newValue: {'studentId': studentId, 'status': requestedStatusCode},
        reason: reason,
      );

      return const Right(null);
    } catch (_) {
      return const Left(
        ServerFailure('Could not send the correction request.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ClassAttendanceSession>>> getHistory({
    required ActiveResponsibilityContext context,
    required DateTime from,
    required DateTime to,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classAttendanceView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(Left.new, (_) => const Right([]));
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          'You are offline. Attendance history needs a connection.',
        ),
      );
    }

    try {
      final sessions = await remoteDataSource.getAttendanceSessions(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        from: from,
        to: to,
        streamId: context.streamId,
      );
      return Right(sessions);
    } catch (_) {
      return const Left(
        ServerFailure('Could not load attendance history. Pull down to retry.'),
      );
    }
  }

  /// The shared front half of every write: the assignment must authorise the
  /// permission *and* cover the register's own class and year.
  Future<Failure?> _guard(
    ActiveResponsibilityContext context,
    String permission,
    ClassAttendanceSession session,
  ) async {
    final result = assignmentService.authorize(
      context,
      permission: permission,
      classId: session.classId,
      academicYearId: session.academicYearId,
    );
    return result.fold((failure) => failure, (_) => null);
  }

  Failure _failureFor(AttendanceDecision decision) {
    final message = decision.message ?? 'This register cannot be changed.';
    return switch (decision.refusal) {
      AttendanceRefusal.locked ||
      AttendanceRefusal.alreadySubmitted ||
      AttendanceRefusal.outsideCorrectionWindow => PermissionDeniedFailure(
        message,
      ),
      _ => ValidationFailure(message),
    };
  }

  Future<ClassAttendanceSession?> _cachedDraft(String sessionId) async {
    return localDataSource.getAttendanceDraft(sessionId);
  }

  Future<void> _cacheDraft(ClassAttendanceSession session) async {
    await localDataSource.saveAttendanceDraft(session);
  }

  /// Queues the register for replay. The payload carries the whole session
  /// rather than a delta, because a delta replayed against a register that
  /// changed in the meantime is unresolvable.
  Future<void> _queue(
    ActiveResponsibilityContext context,
    ClassAttendanceSession session,
    String type,
  ) async {
    final operation = OfflineOperation(
      operationId: uuid.v4(),
      entityType: type,
      entityId: session.id,
      action: type,
      payload: {'session': jsonEncode(_sessionPayload(session))},
      createdAt: DateTime.now(),
      schoolId: context.schoolId,
      userId: context.userId,
      roleAssignmentId: context.roleAssignmentId,
      deviceId: session.deviceId,
    );

    await queueDataSource.enqueueOperation(operation);
  }

  static Map<String, dynamic> _sessionPayload(ClassAttendanceSession session) =>
      {
        'id': session.id,
        'schoolId': session.schoolId,
        'campusId': session.campusId,
        'classId': session.classId,
        'className': session.className,
        'streamId': session.streamId,
        'academicYearId': session.academicYearId,
        'termId': session.termId,
        'sessionType': session.sessionType,
        'date': session.date.toIso8601String(),
        'status': session.status.name,
        'entries': session.entries
            .map(
              (e) => {
                'studentId': e.studentId,
                'status': e.statusCode,
                'note': e.note,
                'markedAt': e.markedAt?.toIso8601String(),
              },
            )
            .toList(),
        'submittedAt': session.submittedAt?.toIso8601String(),
        'submittedBy': session.submittedBy,
        'roleAssignmentId': session.roleAssignmentId,
        'deviceId': session.deviceId,
      };

  Future<String> _deviceId() async {
    try {
      return await deviceIdService.getDeviceId();
    } catch (_) {
      return '';
    }
  }
}
