import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/staff_role_assignment.dart';

/// Reads the responsibilities an admin attached to a staff profile.
///
/// This repository is the only place the panel learns what a teacher is
/// allowed to be. Nothing else in the feature constructs a
/// [StaffRoleAssignment] or infers one from a job title.
abstract class StaffAssignmentRepository {
  /// Every assignment on the profile, including suspended ones, so the
  /// switcher can explain why a responsibility disappeared instead of just
  /// dropping it.
  Future<Either<Failure, List<StaffRoleAssignment>>> getAssignments({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  });

  /// Only the assignments that grant access right now: active status, inside
  /// their date range, and belonging to [academicYearId] when one is given.
  Future<Either<Failure, List<StaffRoleAssignment>>> getValidAssignments({
    required String schoolId,
    required String userId,
    String? academicYearId,
    bool forceRefresh = false,
  });

  /// Pushes assignment changes as the admin makes them, so a suspension
  /// reaches an open panel without a restart.
  Stream<List<StaffRoleAssignment>> watchAssignments({
    required String schoolId,
    required String userId,
  });

  /// Re-reads one assignment from the server and confirms it still grants
  /// access. Called before every sensitive write, so a permission revoked
  /// mid-session cannot be used by a screen that was already open.
  Future<Either<Failure, StaffRoleAssignment>> verifyAssignment({
    required String schoolId,
    required String assignmentId,
    required String userId,
  });

  /// Remembers which responsibility the teacher last chose, so the panel
  /// comes back up on the same one after a restart.
  Future<Either<Failure, void>> persistSelectedAssignment(String assignmentId);

  Future<Either<Failure, String?>> getPersistedAssignmentId();

  /// Drops all cached responsibilities. Used on logout and school switch.
  Future<Either<Failure, void>> clearCache({String? schoolId});
}
