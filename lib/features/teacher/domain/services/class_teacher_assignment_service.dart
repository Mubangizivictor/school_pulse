import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/staff_role_assignment.dart';

/// Why a proposed Class Teacher assignment was refused, or what it would take
/// to allow it. Returned rather than thrown so the admin screen can explain
/// the conflict instead of showing a bare failure.
class ClassTeacherAssignability {
  /// True when the assignment may be created as requested.
  final bool isAllowed;

  /// The assignments already held that clash with the proposed one. Empty
  /// when [isAllowed] is true for reasons other than an override.
  final List<StaffRoleAssignment> conflicting;

  /// True when the only thing standing in the way is the default
  /// one-class-per-year rule, and an override would clear it.
  final bool overrideWouldAllow;

  /// User-facing explanation. Null when allowed with no caveat.
  final String? reason;

  const ClassTeacherAssignability({
    required this.isAllowed,
    this.conflicting = const [],
    this.overrideWouldAllow = false,
    this.reason,
  });

  const ClassTeacherAssignability.allowed()
    : isAllowed = true,
      conflicting = const [],
      overrideWouldAllow = false,
      reason = null;
}

/// Everything the app is allowed to decide about Class Teacher assignments.
///
/// Two jobs, deliberately together because they answer the same question from
/// opposite ends: the admin side asks "may this staff member be given this
/// class", and the panel side asks "is the class this screen is about actually
/// the one this teacher was given". Both reduce to the assignment rows, and
/// neither is ever answered from a job title.
abstract class ClassTeacherAssignmentService {
  /// The Class Teacher assignment currently granting access, or null when the
  /// teacher holds none. Null is a real state - a Subject Teacher with no
  /// class responsibility - and not an error.
  Future<Either<Failure, StaffRoleAssignment?>> resolveActiveAssignment({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  });

  /// Same resolution [resolveActiveAssignment] does, but against a list the
  /// caller already fetched - so a screen that just loaded every assignment
  /// to populate a switcher does not pay for a second identical Firestore
  /// round trip just to find the one that is a Class Teacher row.
  StaffRoleAssignment? resolveActiveAssignmentFrom(
    List<StaffRoleAssignment> assignments,
  );

  /// Every Class Teacher row on the profile including suspended and expired
  /// ones, so the panel can say why a class disappeared rather than just
  /// dropping it.
  Future<Either<Failure, List<StaffRoleAssignment>>>
  getClassTeacherAssignments({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  });

  /// The default one-Class-Teacher-per-staff-member rule.
  ///
  /// A staff member may hold only one *active* Class Teacher assignment inside
  /// the same academic year and campus. Subject Teacher rows are never counted
  /// here - teaching six subjects across four classes stays unrestricted.
  ///
  /// A school may allow a second concurrent class, but only deliberately:
  /// [overrideRequested] must be set, the assigning admin must hold
  /// [Permission.classTeacherMultiAssignOverride], and [overrideReason] must
  /// be given. The caller is responsible for auditing an allowed override.
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
  });

  /// The guard every Class Teacher read and write passes through.
  ///
  /// Checks, in order: that a context exists, that it is a Class Teacher
  /// context, that the assignment is still active and in date, that the
  /// permission is granted, and that the class/stream the caller wants to
  /// touch is the one the assignment names. A caller that hands in a
  /// `classId` from the widget tree gets a failure rather than a widened
  /// query, which is the whole point of routing through here.
  Either<Failure, ActiveResponsibilityContext> authorize(
    ActiveResponsibilityContext? context, {
    required String permission,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? termId,
  });

  /// Re-reads the active assignment from the server and re-applies [authorize].
  /// Called immediately before sensitive writes so a permission an admin
  /// removed while the screen was open cannot be spent.
  Future<Either<Failure, ActiveResponsibilityContext>> authorizeFresh({
    required String permission,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? termId,
  });
}
