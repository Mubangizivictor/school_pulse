import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_announcement.dart';
import '../../domain/policies/class_communication_policy.dart';
import '../../domain/repositories/class_communication_repository.dart';
import '../../domain/repositories/class_student_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/class_teacher_remote_data_source.dart';

class ClassCommunicationRepositoryImpl implements ClassCommunicationRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassStudentRepository studentRepository;
  final ClassTeacherAssignmentService assignmentService;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  ClassCommunicationRepositoryImpl({
    required this.remoteDataSource,
    required this.studentRepository,
    required this.assignmentService,
    required this.auditService,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<ClassAnnouncement>>> getAnnouncements({
    required ActiveResponsibilityContext context,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classAnnouncementCreate,
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
        NetworkFailure('You are offline. Announcements need a connection.'),
      );
    }

    try {
      final announcements = await remoteDataSource.getAnnouncements(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );
      return Right(announcements);
    } catch (_) {
      return const Left(
        ServerFailure('Could not load announcements. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, ClassAnnouncement>> saveAnnouncement({
    required ActiveResponsibilityContext context,
    required ClassAnnouncement announcement,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classAnnouncementCreate,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final isNew = announcement.id.isEmpty;
    final decision = ClassCommunicationPolicy.canSaveAnnouncement(
      title: announcement.title,
      body: announcement.body,
      existing: isNew ? null : announcement,
      scheduledFor: announcement.scheduledFor,
      expiresAt: announcement.expiresAt,
      now: DateTime.now(),
    );
    if (!decision.isAllowed) {
      return Left(ValidationFailure(decision.message ?? 'Could not save.'));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Saving an announcement needs an internet connection.',
        ),
      );
    }

    final prepared = isNew
        ? _withIdentity(context, announcement, uuid.v4())
        : announcement.copyWith(
            updatedBy: context.userId,
            updatedAt: DateTime.now(),
            roleAssignmentId: context.roleAssignmentId,
          );

    try {
      await remoteDataSource.saveAnnouncement(prepared);
      await auditService.record(
        context: context,
        action: 'announcement.created',
        entityType: 'class_announcement',
        entityId: prepared.id,
        newValue: {'title': prepared.title, 'status': prepared.status.name},
      );
      return Right(prepared);
    } catch (_) {
      return const Left(ServerFailure('Could not save this announcement.'));
    }
  }

  @override
  Future<Either<Failure, ClassAnnouncement>> publishAnnouncement({
    required ActiveResponsibilityContext context,
    required ClassAnnouncement announcement,
  }) async {
    // Re-verified: publishing reaches every guardian in the class, and a
    // notification cannot be recalled once it has gone out.
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classAnnouncementPublish,
      classId: announcement.classId,
      academicYearId: announcement.academicYearId,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Sending an announcement needs an internet connection.',
        ),
      );
    }

    // Resolved from the live roster, not from anything stored on the draft:
    // a student who transferred out between drafting and sending must not
    // receive it, and one admitted since should.
    final roster = await studentRepository.getClassStudents(context: context);
    final recipients = ClassCommunicationPolicy.recipientsFor(
      announcement: announcement,
      roster: roster.getOrElse(() => const []),
    );

    final decision = ClassCommunicationPolicy.canPublishAnnouncement(
      announcement: announcement,
      hasPublishPermission: context.can(Permission.classAnnouncementPublish),
      recipientCount: recipients.reach,
    );
    if (!decision.isAllowed) {
      return Left(
        decision.refusal == CommunicationRefusal.publishNotPermitted
            ? PermissionDeniedFailure(decision.message!)
            : ValidationFailure(decision.message!),
      );
    }

    final published = announcement.copyWith(
      status: ClassAnnouncementStatus.published,
      publishedAt: DateTime.now(),
      recipientCount: recipients.reach,
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await remoteDataSource.saveAnnouncement(published);
      await auditService.record(
        context: context,
        action: 'announcement.published',
        entityType: 'class_announcement',
        entityId: published.id,
        previousValue: {'status': announcement.status.name},
        newValue: {
          'status': published.status.name,
          'audience': published.audience.name,
          'recipientCount': published.recipientCount,
        },
      );
      return Right(published);
    } catch (_) {
      return const Left(ServerFailure('Could not send this announcement.'));
    }
  }

  @override
  Future<Either<Failure, ClassAnnouncement>> archiveAnnouncement({
    required ActiveResponsibilityContext context,
    required ClassAnnouncement announcement,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classAnnouncementCreate,
      classId: announcement.classId,
      academicYearId: announcement.academicYearId,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    // Archived rather than deleted: parents already saw it, and a notice that
    // silently vanishes is worse than one marked closed.
    final archived = announcement.copyWith(
      status: ClassAnnouncementStatus.archived,
      updatedBy: context.userId,
      updatedAt: DateTime.now(),
    );

    try {
      await remoteDataSource.saveAnnouncement(archived);
      await auditService.record(
        context: context,
        action: 'announcement.archived',
        entityType: 'class_announcement',
        entityId: archived.id,
        previousValue: {'status': announcement.status.name},
        newValue: {'status': archived.status.name},
      );
      return Right(archived);
    } catch (_) {
      return const Left(ServerFailure('Could not archive this announcement.'));
    }
  }

  @override
  Future<Either<Failure, void>> assertCanMessageAbout({
    required ActiveResponsibilityContext context,
    required String studentId,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classParentMessage,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final roster = await studentRepository.getClassStudents(context: context);
    final decision = ClassCommunicationPolicy.canMessageAbout(
      studentId: studentId,
      roster: roster.getOrElse(() => const []),
    );

    if (!decision.isAllowed) {
      return Left(PermissionDeniedFailure(decision.message!));
    }
    return const Right(null);
  }

  /// Stamps a new announcement with the coordinates from the verified context,
  /// so a screen cannot post to a class it does not hold.
  ClassAnnouncement _withIdentity(
    ActiveResponsibilityContext context,
    ClassAnnouncement announcement,
    String id,
  ) {
    return ClassAnnouncement(
      id: id,
      schoolId: context.schoolId,
      campusId: context.campusId,
      classId: context.classId ?? '',
      className: context.className ?? '',
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      title: announcement.title,
      body: announcement.body,
      status: announcement.status,
      audience: announcement.audience,
      attachments: announcement.attachments,
      scheduledFor: announcement.scheduledFor,
      expiresAt: announcement.expiresAt,
      createdBy: context.userId,
      createdAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );
  }
}
