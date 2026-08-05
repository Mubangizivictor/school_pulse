import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_behaviour.dart';
import '../../domain/entities/class_homework.dart';
import '../../domain/policies/class_work_policy.dart';
import '../../domain/repositories/class_work_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/class_teacher_remote_data_source.dart';

class ClassWorkRepositoryImpl implements ClassWorkRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassTeacherAssignmentService assignmentService;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  ClassWorkRepositoryImpl({
    required this.remoteDataSource,
    required this.assignmentService,
    required this.auditService,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<ClassHomework>>> getHomework({
    required ActiveResponsibilityContext context,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classHomeworkCreate,
    );
    if (guard.isLeft()) return guard.fold(Left.new, (_) => const Right([]));

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('You are offline. Class work needs a connection.'),
      );
    }

    try {
      final homework = await remoteDataSource.getHomework(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );
      return Right(homework);
    } catch (_) {
      return const Left(
        ServerFailure('Could not load class work. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, ClassHomework>> saveHomework({
    required ActiveResponsibilityContext context,
    required ClassHomework homework,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: homework.id.isEmpty
          ? Permission.classHomeworkCreate
          : Permission.classHomeworkEdit,
      classId: homework.classId,
      academicYearId: homework.academicYearId,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final existing = homework.id.isEmpty ? null : homework;
    final decision = ClassWorkPolicy.canSaveHomework(
      title: homework.title,
      dueDate: homework.dueDate,
      existing: existing,
      now: DateTime.now(),
    );
    if (!decision.isAllowed) {
      return Left(ValidationFailure(decision.message ?? 'Could not save.'));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Setting class work needs an internet connection.',
        ),
      );
    }

    final isNew = homework.id.isEmpty;
    final prepared = isNew
        ? _withIdentity(context, homework, uuid.v4())
        : homework.copyWith(
            updatedBy: context.userId,
            updatedAt: DateTime.now(),
            roleAssignmentId: context.roleAssignmentId,
          );

    try {
      await remoteDataSource.saveHomework(prepared);
      await auditService.record(
        context: context,
        action: isNew ? 'homework.created' : 'homework.edited',
        entityType: 'class_homework',
        entityId: prepared.id,
        newValue: {'title': prepared.title, 'status': prepared.status.name},
      );
      return Right(prepared);
    } catch (_) {
      return const Left(ServerFailure('Could not save this assignment.'));
    }
  }

  @override
  Future<Either<Failure, ClassHomework>> publishHomework({
    required ActiveResponsibilityContext context,
    required ClassHomework homework,
  }) async {
    // Re-verified against the server: publishing reaches every parent in the
    // class, so a permission removed mid-session must be caught before it is
    // spent, not after the notification has gone out.
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classHomeworkPublish,
      classId: homework.classId,
      academicYearId: homework.academicYearId,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final decision = ClassWorkPolicy.canPublish(
      homework: homework,
      hasPublishPermission: context.can(Permission.classHomeworkPublish),
    );
    if (!decision.isAllowed) {
      return Left(
        decision.refusal == ClassWorkRefusal.publishNotPermitted
            ? PermissionDeniedFailure(decision.message!)
            : ValidationFailure(decision.message!),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Publishing class work needs an internet connection.',
        ),
      );
    }

    final published = homework.copyWith(
      status: ClassHomeworkStatus.published,
      publishedAt: DateTime.now(),
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await remoteDataSource.saveHomework(published);
      await auditService.record(
        context: context,
        action: 'homework.published',
        entityType: 'class_homework',
        entityId: published.id,
        previousValue: {'status': homework.status.name},
        newValue: {'status': published.status.name, 'title': published.title},
      );
      return Right(published);
    } catch (_) {
      return const Left(ServerFailure('Could not publish this assignment.'));
    }
  }

  @override
  Future<Either<Failure, ClassHomework>> cancelHomework({
    required ActiveResponsibilityContext context,
    required ClassHomework homework,
    required String reason,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classHomeworkEdit,
      classId: homework.classId,
      academicYearId: homework.academicYearId,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    if (reason.trim().length < 5) {
      return const Left(
        ValidationFailure(
          'Give a reason for cancelling this assignment.',
          field: 'reason',
        ),
      );
    }

    // Cancelled rather than deleted: students and parents already saw it, and
    // a piece of work that silently vanishes is worse than one marked off.
    final cancelled = homework.copyWith(
      status: ClassHomeworkStatus.cancelled,
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await remoteDataSource.saveHomework(cancelled);
      await auditService.record(
        context: context,
        action: 'homework.cancelled',
        entityType: 'class_homework',
        entityId: cancelled.id,
        previousValue: {'status': homework.status.name},
        newValue: {'status': cancelled.status.name},
        reason: reason,
      );
      return Right(cancelled);
    } catch (_) {
      return const Left(ServerFailure('Could not cancel this assignment.'));
    }
  }

  @override
  Future<Either<Failure, List<BehaviourCategory>>> getBehaviourCategories({
    required ActiveResponsibilityContext context,
  }) async {
    try {
      final configured = await remoteDataSource.getBehaviourCategories(
        schoolId: context.schoolId,
      );
      return Right(BehaviourCategoryResolver.from(configured));
    } catch (_) {
      // A form with no categories would be unusable, so a failed config read
      // still yields a working set.
      return const Right(BehaviourCategoryResolver.defaults);
    }
  }

  @override
  Future<Either<Failure, List<ClassBehaviourRecord>>> getBehaviourRecords({
    required ActiveResponsibilityContext context,
    String? studentId,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classBehaviourView,
    );
    if (guard.isLeft()) return guard.fold(Left.new, (_) => const Right([]));

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('You are offline. Behaviour records need a connection.'),
      );
    }

    try {
      final records = await remoteDataSource.getBehaviourRecords(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        studentId: studentId,
      );
      return Right(records);
    } catch (_) {
      return const Left(
        ServerFailure('Could not load behaviour records. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, ClassBehaviourRecord>> recordBehaviour({
    required ActiveResponsibilityContext context,
    required ClassBehaviourRecord record,
    required List<String> rosterStudentIds,
  }) async {
    final categories = await getBehaviourCategories(context: context);
    final resolved = categories.getOrElse(
      () => BehaviourCategoryResolver.defaults,
    );

    final isAchievement =
        resolved
            .where((c) => c.code == record.categoryCode)
            .firstOrNull
            ?.valence ==
        BehaviourValence.achievement;

    final fresh = await assignmentService.authorizeFresh(
      permission: isAchievement
          ? Permission.classAchievementRecord
          : Permission.classBehaviourRecord,
      classId: record.classId,
      academicYearId: record.academicYearId,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final decision = ClassWorkPolicy.canRecordBehaviour(
      studentId: record.studentId,
      rosterStudentIds: rosterStudentIds,
      categoryCode: record.categoryCode,
      categories: resolved,
      note: record.note,
    );
    if (!decision.isAllowed) {
      return Left(
        decision.refusal == ClassWorkRefusal.studentNotInClass
            ? PermissionDeniedFailure(decision.message!)
            : ValidationFailure(decision.message!),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Recording behaviour needs an internet connection.',
        ),
      );
    }

    final prepared = ClassBehaviourRecord(
      id: record.id.isEmpty ? uuid.v4() : record.id,
      schoolId: context.schoolId,
      campusId: context.campusId,
      classId: record.classId,
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      studentId: record.studentId,
      studentName: record.studentName,
      categoryCode: record.categoryCode,
      note: record.note,
      recommendation: record.recommendation,
      followUpRequired:
          record.followUpRequired ||
          ClassWorkPolicy.defaultFollowUpFor(record.categoryCode, resolved),
      followUpClosed: false,
      recordedBy: context.userId,
      // Stamped by the app, never typed by the teacher.
      recordedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await remoteDataSource.saveBehaviourRecord(prepared);
      await auditService.record(
        context: context,
        action: isAchievement ? 'achievement.recorded' : 'behaviour.recorded',
        entityType: 'class_behaviour_record',
        entityId: prepared.id,
        newValue: {
          'studentId': prepared.studentId,
          'category': prepared.categoryCode,
          'followUpRequired': prepared.followUpRequired,
        },
      );
      return Right(prepared);
    } catch (_) {
      return const Left(ServerFailure('Could not save this record.'));
    }
  }

  @override
  Future<Either<Failure, ClassBehaviourRecord>> updateBehaviour({
    required ActiveResponsibilityContext context,
    required ClassBehaviourRecord record,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classBehaviourRecord,
      classId: record.classId,
      academicYearId: record.academicYearId,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final decision = ClassWorkPolicy.canUpdateBehaviour(record: record);
    if (!decision.isAllowed) {
      return Left(PermissionDeniedFailure(decision.message!));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Updating a behaviour record needs an internet connection.',
        ),
      );
    }

    final updated = record.copyWith(
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
    );

    try {
      await remoteDataSource.saveBehaviourRecord(updated);
      await auditService.record(
        context: context,
        action: 'behaviour.updated',
        entityType: 'class_behaviour_record',
        entityId: updated.id,
        newValue: {
          'followUpClosed': updated.followUpClosed,
          'followUpNote': updated.followUpNote,
        },
      );
      return Right(updated);
    } catch (_) {
      return const Left(ServerFailure('Could not update this record.'));
    }
  }

  /// Stamps a new assignment with the coordinates from the verified context,
  /// so a screen cannot file work against a class it does not hold.
  ClassHomework _withIdentity(
    ActiveResponsibilityContext context,
    ClassHomework homework,
    String id,
  ) {
    return ClassHomework(
      id: id,
      schoolId: context.schoolId,
      campusId: context.campusId,
      classId: context.classId ?? '',
      className: context.className ?? '',
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      title: homework.title,
      description: homework.description,
      instructions: homework.instructions,
      subjectName: homework.subjectName,
      dueDate: homework.dueDate,
      status: homework.status,
      priority: homework.priority,
      attachments: homework.attachments,
      createdBy: context.userId,
      createdAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );
  }
}
