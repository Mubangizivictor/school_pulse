import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/repositories/staff_assignment_repository.dart';
import '../../domain/services/active_responsibility_service.dart';
import '../../domain/services/class_teacher_assignment_service.dart';

class ClassTeacherAssignmentServiceImpl
    implements ClassTeacherAssignmentService {
  final StaffAssignmentRepository assignmentRepository;
  final ActiveResponsibilityService responsibilityService;

  ClassTeacherAssignmentServiceImpl({
    required this.assignmentRepository,
    required this.responsibilityService,
  });

  @override
  Future<Either<Failure, StaffRoleAssignment?>> resolveActiveAssignment({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  }) async {
    final result = await assignmentRepository.getValidAssignments(
      schoolId: schoolId,
      userId: userId,
      forceRefresh: forceRefresh,
    );

    return result.map(resolveActiveAssignmentFrom);
  }

  @override
  StaffRoleAssignment? resolveActiveAssignmentFrom(
    List<StaffRoleAssignment> assignments,
  ) {
    final classRows = assignments
        .where((a) => a.roleType == StaffResponsibilityType.classTeacher)
        .where((a) => a.isCurrentlyValid())
        .toList();
    if (classRows.isEmpty) return null;

    // The default rule allows exactly one. When a school has granted the
    // override there may legitimately be two, and the most recently
    // assigned one wins as the panel's default - the teacher can still
    // switch to the other through the responsibility switcher.
    classRows.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
    return classRows.first;
  }

  @override
  Future<Either<Failure, List<StaffRoleAssignment>>>
  getClassTeacherAssignments({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  }) async {
    final result = await assignmentRepository.getAssignments(
      schoolId: schoolId,
      userId: userId,
      forceRefresh: forceRefresh,
    );

    return result.map(
      (assignments) => assignments
          .where((a) => a.roleType == StaffResponsibilityType.classTeacher)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, ClassTeacherAssignability>> validateAssignable({
    required String schoolId,
    required String campusId,
    required String staffId,
    required String userId,
    required String academicYearId,
    String? excludeAssignmentId,
    bool overrideRequested = false,
    String? overrideReason,
    Set<String> assignerPermissions = const {},
  }) async {
    if (academicYearId.isEmpty) {
      return const Left(
        ValidationFailure(
          'An academic year is required before a class can be assigned.',
          field: 'academicYearId',
        ),
      );
    }

    final result = await assignmentRepository.getAssignments(
      schoolId: schoolId,
      userId: userId,
      forceRefresh: true,
    );

    return result.map((assignments) {
      // Only *active* Class Teacher rows in the same year and campus count.
      // Suspended and expired ones do not hold the slot, and Subject Teacher
      // rows are irrelevant here no matter how many there are.
      final conflicting = assignments.where((a) {
        if (a.roleType != StaffResponsibilityType.classTeacher) return false;
        if (a.id == excludeAssignmentId) return false;
        if (a.staffId != staffId) return false;
        if (a.academicYearId != academicYearId) return false;
        if (a.campusId != campusId) return false;
        return a.status == AssignmentStatus.active;
      }).toList();

      if (conflicting.isEmpty) return const ClassTeacherAssignability.allowed();

      final held = conflicting.map((a) => a.displayLabel).join(', ');

      if (!overrideRequested) {
        return ClassTeacherAssignability(
          isAllowed: false,
          conflicting: conflicting,
          overrideWouldAllow: true,
          reason:
              'This staff member is already Class Teacher for $held '
              'in this academic year. A second class needs an override.',
        );
      }

      if (!assignerPermissions.contains(
        Permission.classTeacherMultiAssignOverride,
      )) {
        return ClassTeacherAssignability(
          isAllowed: false,
          conflicting: conflicting,
          reason:
              'Assigning a second class needs the multi-class override '
              'permission, which your account does not hold.',
        );
      }

      if (overrideReason == null || overrideReason.trim().length < 10) {
        return ClassTeacherAssignability(
          isAllowed: false,
          conflicting: conflicting,
          overrideWouldAllow: true,
          reason: 'Give a reason of at least 10 characters for the override.',
        );
      }

      return ClassTeacherAssignability(
        isAllowed: true,
        conflicting: conflicting,
        overrideWouldAllow: true,
        reason:
            'Override applied: this staff member will hold '
            '${conflicting.length + 1} classes this year.',
      );
    });
  }

  @override
  Either<Failure, ActiveResponsibilityContext> authorize(
    ActiveResponsibilityContext? context, {
    required String permission,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? termId,
  }) {
    if (context == null) {
      return const Left(
        AssignmentInvalidFailure(
          'No class responsibility is active. Switch to your class first.',
        ),
      );
    }

    if (!context.isClassTeacher) {
      return const Left(
        AssignmentInvalidFailure(
          'This action belongs to your Class Teacher responsibility. '
          'Switch to it to continue.',
        ),
      );
    }

    if (context.assignmentStatus != AssignmentStatus.active) {
      return const Left(AssignmentInvalidFailure());
    }

    // The class the caller named must be the class the assignment names. A
    // screen holding a stale or tampered id fails here rather than reaching
    // the repository with a widened scope.
    if (classId != null &&
        classId.isNotEmpty &&
        context.classId != null &&
        context.classId!.isNotEmpty &&
        classId != context.classId) {
      return const Left(
        PermissionDeniedFailure(
          'That class is not the one you are Class Teacher for.',
        ),
      );
    }

    if (streamId != null &&
        streamId.isNotEmpty &&
        context.streamId != null &&
        context.streamId!.isNotEmpty &&
        streamId != context.streamId) {
      return const Left(
        PermissionDeniedFailure(
          'That stream is not the one you are Class Teacher for.',
        ),
      );
    }

    if (!context.can(
      permission,
      classId: classId ?? context.classId,
      streamId: streamId ?? context.streamId,
      academicYearId: academicYearId,
      termId: termId,
    )) {
      return const Left(PermissionDeniedFailure());
    }

    return Right(context);
  }

  @override
  Future<Either<Failure, ActiveResponsibilityContext>> authorizeFresh({
    required String permission,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? termId,
  }) async {
    final revalidated = await responsibilityService.revalidate();
    return revalidated.fold(
      Left.new,
      (context) => authorize(
        context,
        permission: permission,
        classId: classId,
        streamId: streamId,
        academicYearId: academicYearId,
        termId: termId,
      ),
    );
  }
}
