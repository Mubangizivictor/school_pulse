import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/policies/lesson_start_policy.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/subject_teacher_local_data_source.dart';
import '../datasources/subject_teacher_remote_data_source.dart';
import '../models/subject_teacher_isar_models.dart';

class LessonRepositoryImpl implements LessonRepository {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectTeacherLocalDataSource localDataSource;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final DeviceIdService deviceIdService;
  final LessonStartPolicy startPolicy;
  final Uuid uuid;

  LessonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.auditService,
    required this.networkInfo,
    required this.deviceIdService,
    this.startPolicy = const LessonStartPolicy(),
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<Lesson>>> getLessons({
    required ActiveResponsibilityContext context,
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  }) async {
    if (!context.can(Permission.subjectLessonView)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to view lessons for this subject.',
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
      if (await networkInfo.isConnected) {
        final remote = await remoteDataSource.getLessons(
          schoolId: context.schoolId,
          subjectId: subjectId,
          classId: classId,
          academicYearId: context.academicYearId,
          from: from,
          to: to,
        );
        await localDataSource.cacheLessons(
          remote.map(LessonIsar.fromEntity).toList(),
        );
        return Right(_mine(remote, context));
      }

      if (forceRefresh) {
        return const Left(NetworkFailure(
          'You are offline. Pull down again when you have a connection.',
        ));
      }

      final cached = await localDataSource.getLessons(
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        from: from,
        to: to,
      );
      return Right(_mine(cached.map((e) => e.toEntity()).toList(), context));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// A class can have more than one teacher for the same subject, and the
  /// query cannot filter on "teacher or substitute" server-side without a
  /// second round trip, so the ownership filter happens here.
  List<Lesson> _mine(List<Lesson> lessons, ActiveResponsibilityContext context) {
    final mine = lessons.where((l) => l.isTaughtBy(context.staffId)).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    return mine;
  }

  @override
  Future<Either<Failure, List<Lesson>>> getTodaysLessons({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return getLessons(
      context: context,
      from: start,
      to: start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<Either<Failure, Lesson?>> getLesson({
    required ActiveResponsibilityContext context,
    required String lessonId,
  }) async {
    if (!context.can(Permission.subjectLessonView)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to view this lesson.',
      ));
    }

    try {
      if (await networkInfo.isConnected) {
        final lesson = await remoteDataSource.getLesson(
          schoolId: context.schoolId,
          lessonId: lessonId,
        );
        if (lesson != null) {
          await localDataSource.cacheLessons([LessonIsar.fromEntity(lesson)]);
        }
        return Right(lesson);
      }
      final cached = await localDataSource.getLesson(lessonId);
      return Right(cached?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Lesson>> startLesson({
    required ActiveResponsibilityContext context,
    required Lesson lesson,
  }) async {
    // The same rule that greys out the button decides here too, so a stale
    // screen or a replayed tap cannot get past it.
    final refusal = startPolicy.evaluate(lesson: lesson, context: context);
    if (refusal != null) {
      return Left(refusal == LessonStartRefusal.noPermission
          ? PermissionDeniedFailure(refusal.message)
          : ValidationFailure(refusal.message));
    }

    // Recorded from the device clock at the moment of the tap, not from
    // whenever the write eventually reaches the server.
    final started = lesson.copyWith(
      status: LessonStatus.ongoing,
      actualStart: DateTime.now(),
    );

    try {
      await localDataSource.cacheLessons([LessonIsar.fromEntity(started)]);

      if (await networkInfo.isConnected) {
        await remoteDataSource.updateLesson(
          started,
          roleAssignmentId: context.roleAssignmentId,
        );
      } else {
        await _queue(context, started, OfflineOperationType.lessonStart);
      }

      await auditService.record(
        context: context,
        action: SubjectAuditAction.lessonStarted,
        entityType: 'lesson',
        entityId: lesson.id,
        previousValue: {'status': lesson.status.name},
        newValue: {
          'status': started.status.name,
          'actualStart': started.actualStart?.toIso8601String(),
        },
      );

      return Right(started);
    } catch (e) {
      // The lesson is open on the device; queue the write rather than
      // stranding the teacher in front of a class.
      await _queue(context, started, OfflineOperationType.lessonStart);
      return Right(started);
    }
  }

  @override
  Future<Either<Failure, Lesson>> completeLesson({
    required ActiveResponsibilityContext context,
    required Lesson lesson,
    required LessonCompletion completion,
  }) async {
    if (!context.can(Permission.subjectLessonComplete)) {
      return const Left(PermissionDeniedFailure(
        'You do not have permission to complete lessons.',
      ));
    }
    if (!lesson.isTaughtBy(context.staffId)) {
      return const Left(PermissionDeniedFailure(
        'This lesson is assigned to another teacher.',
      ));
    }
    if (lesson.status != LessonStatus.ongoing) {
      return const Left(ValidationFailure(
        'Start the lesson before completing it.',
      ));
    }

    final completed = lesson.copyWith(
      status: LessonStatus.completed,
      actualEnd: DateTime.now(),
      topic: completion.topicsCovered ?? lesson.topic,
    );

    try {
      await localDataSource.cacheLessons([LessonIsar.fromEntity(completed)]);

      if (await networkInfo.isConnected) {
        await remoteDataSource.updateLesson(
          completed,
          roleAssignmentId: context.roleAssignmentId,
        );
      } else {
        await _queue(context, completed, OfflineOperationType.lessonComplete);
      }

      await auditService.record(
        context: context,
        action: SubjectAuditAction.lessonCompleted,
        entityType: 'lesson',
        entityId: lesson.id,
        previousValue: {'status': lesson.status.name},
        newValue: {
          'status': completed.status.name,
          'actualEnd': completed.actualEnd?.toIso8601String(),
          'topicsCovered': completion.topicsCovered,
          'homeworkAssigned': completion.homeworkAssigned,
          'followUpRequired': completion.followUpRequired,
        },
      );

      return Right(completed);
    } catch (e) {
      await _queue(context, completed, OfflineOperationType.lessonComplete);
      return Right(completed);
    }
  }

  Future<void> _queue(
    ActiveResponsibilityContext context,
    Lesson lesson,
    String operationType,
  ) async {
    final operation = OfflineOperation(
      // Keyed on the lesson so a repeat replaces the queued write.
      operationId: '${operationType}_${lesson.id}',
      entityType: operationType,
      entityId: lesson.id,
      action: operationType,
      payload: {'lessonId': lesson.id},
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
