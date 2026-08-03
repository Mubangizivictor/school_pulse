import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

/// Single entry point for new Phase 3+ call sites that need an
/// access decision scoped to the caller's active responsibility (subject,
/// class, stream, department) when one exists, falling back to their
/// role's default permission set otherwise.
///
/// Existing `.role`-based call sites are unaffected - this is additive,
/// not a replacement for [PermissionEvaluator] or
/// [ActiveResponsibilityService], both of which it wraps unchanged.
class EffectiveAccessResolver {
  final PermissionEvaluator permissionEvaluator;
  final ActiveResponsibilityService responsibilityService;

  EffectiveAccessResolver({
    required this.permissionEvaluator,
    required this.responsibilityService,
  });

  /// Whether [operatorUser] may perform [permissionId], optionally scoped to
  /// a specific subject/class/stream/department/academic year.
  ///
  /// Tries the active responsibility context first - if one is loaded and it
  /// both grants the permission and covers the supplied coordinates, access
  /// is allowed without consulting role defaults. Otherwise falls back to
  /// [PermissionEvaluator.can], which checks role-level (or admin-overridden)
  /// permissions with no scoping.
  Future<Either<Failure, bool>> can(
    String permissionId,
    UserEntity operatorUser, {
    String? subjectId,
    String? classId,
    String? streamId,
    String? departmentId,
    String? academicYearId,
  }) async {
    final active = responsibilityService.current;
    if (active != null &&
        active.userId == operatorUser.id &&
        active.can(
          permissionId,
          subjectId: subjectId,
          classId: classId,
          streamId: streamId,
          academicYearId: academicYearId,
        )) {
      return const Right(true);
    }

    return permissionEvaluator.can(permissionId, operatorUser);
  }
}
