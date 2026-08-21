import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_task.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/policies/class_task_policy.dart';
import '../../domain/repositories/class_task_repository.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/class_teacher_local_data_source.dart';
import '../datasources/class_teacher_remote_data_source.dart';
import '../datasources/subject_teacher_local_data_source.dart';

class ClassTaskRepositoryImpl implements ClassTaskRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassTeacherLocalDataSource localDataSource;
  final SubjectTeacherLocalDataSource queueDataSource;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  ClassTaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.queueDataSource,
    required this.auditService,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<ClassTask>>> getTasks({
    required ActiveResponsibilityContext context,
  }) async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getTasks(
        schoolId: context.schoolId,
        ownerUserId: context.userId,
      );
      return Right(cached);
    }

    try {
      // Scoped by owner, not class: this is the teacher's own list, and it
      // should follow them across responsibilities rather than emptying when
      // they switch.
      final tasks = await remoteDataSource.getTasks(
        schoolId: context.schoolId,
        ownerUserId: context.userId,
      );
      await localDataSource.cacheTasks(
        tasks,
        schoolId: context.schoolId,
        ownerUserId: context.userId,
      );
      return Right(tasks);
    } catch (_) {
      final cached = await localDataSource.getTasks(
        schoolId: context.schoolId,
        ownerUserId: context.userId,
      );
      if (cached.isNotEmpty) return Right(cached);
      return const Left(
        ServerFailure('Could not load your tasks. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, ClassTask>> saveTask({
    required ActiveResponsibilityContext context,
    required ClassTask task,
  }) async {
    final decision = ClassTaskPolicy.canSave(
      title: task.title,
      dueAt: task.dueAt,
      remindAt: task.remindAt,
      recurrence: task.recurrence,
    );
    if (!decision.isAllowed) {
      return Left(ValidationFailure(decision.message ?? 'Could not save.'));
    }

    final isNew = task.id.isEmpty;
    if (!isNew) {
      final ownership = ClassTaskPolicy.canEdit(
        task: task,
        userId: context.userId,
      );
      if (!ownership.isAllowed) {
        return Left(PermissionDeniedFailure(ownership.message!));
      }
    }

    final prepared = isNew
        ? ClassTask(
            id: uuid.v4(),
            schoolId: context.schoolId,
            campusId: context.campusId,
            classId: context.classId,
            academicYearId: context.academicYearId,
            termId: context.termId,
            title: task.title,
            description: task.description,
            category: task.category,
            priority: task.priority,
            status: task.status,
            dueAt: task.dueAt,
            studentId: task.studentId,
            subjectName: task.subjectName,
            checklist: task.checklist,
            attachments: task.attachments,
            recurrence: task.recurrence,
            remindAt: task.remindAt,
            ownerUserId: context.userId,
            collaboratorUserIds: task.collaboratorUserIds,
            createdAt: DateTime.now(),
            roleAssignmentId: context.roleAssignmentId,
          )
        : task.copyWith(roleAssignmentId: context.roleAssignmentId);

    await localDataSource.saveTaskLocal(prepared);

    if (!await networkInfo.isConnected) {
      await _queue(context, prepared.id, OfflineOperationType.classTaskSave);
      return Right(prepared);
    }

    try {
      await remoteDataSource.saveTask(prepared);
      await auditService.record(
        context: context,
        action: isNew ? 'task.created' : 'task.updated',
        entityType: 'class_task',
        entityId: prepared.id,
        newValue: {'title': prepared.title, 'status': prepared.status.name},
      );
      return Right(prepared);
    } catch (_) {
      await _queue(context, prepared.id, OfflineOperationType.classTaskSave);
      return Right(prepared);
    }
  }

  @override
  Future<Either<Failure, ClassTask>> completeTask({
    required ActiveResponsibilityContext context,
    required ClassTask task,
  }) async {
    final ownership = ClassTaskPolicy.canEdit(
      task: task,
      userId: context.userId,
    );
    if (!ownership.isAllowed) {
      return Left(PermissionDeniedFailure(ownership.message!));
    }

    final completed = task.copyWith(
      status: ClassTaskStatus.completed,
      // Stamped, never typed - the teacher marks it done, the app records when.
      completedAt: DateTime.now(),
      completedBy: context.userId,
    );

    await localDataSource.saveTaskLocal(completed);

    if (!await networkInfo.isConnected) {
      await _queue(
        context,
        completed.id,
        OfflineOperationType.classTaskComplete,
      );
      return Right(completed);
    }

    try {
      await remoteDataSource.saveTask(completed);
      await auditService.record(
        context: context,
        action: 'task.completed',
        entityType: 'class_task',
        entityId: completed.id,
        newValue: {'title': completed.title},
      );
      return Right(completed);
    } catch (_) {
      await _queue(
        context,
        completed.id,
        OfflineOperationType.classTaskComplete,
      );
      return Right(completed);
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required ActiveResponsibilityContext context,
    required ClassTask task,
  }) async {
    // Deletion is the owner's alone - a collaborator may work a task but not
    // remove it from somebody else's list.
    if (task.ownerUserId != context.userId) {
      return const Left(
        PermissionDeniedFailure('Only the owner can delete this task.'),
      );
    }

    await localDataSource.deleteTaskLocal(task.id);

    if (!await networkInfo.isConnected) {
      await _queue(context, task.id, OfflineOperationType.classTaskDelete);
      return const Right(null);
    }

    try {
      await remoteDataSource.deleteTask(
        schoolId: context.schoolId,
        taskId: task.id,
      );
      await auditService.record(
        context: context,
        action: 'task.deleted',
        entityType: 'class_task',
        entityId: task.id,
        previousValue: {'title': task.title},
      );
      return const Right(null);
    } catch (_) {
      await _queue(context, task.id, OfflineOperationType.classTaskDelete);
      return const Right(null);
    }
  }

  Future<void> _queue(
    ActiveResponsibilityContext context,
    String taskId,
    String type,
  ) async {
    final operation = OfflineOperation(
      operationId: uuid.v4(),
      entityType: type,
      entityId: taskId,
      action: type,
      createdAt: DateTime.now(),
      schoolId: context.schoolId,
      userId: context.userId,
      roleAssignmentId: context.roleAssignmentId,
    );

    await queueDataSource.enqueueOperation(operation);
  }
}
