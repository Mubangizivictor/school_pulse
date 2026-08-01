import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/staff_role_assignment.dart';

/// What the panel knows about the teacher's responsibilities at one moment.
class ResponsibilityResolution {
  /// Every assignment that currently grants access, in switcher order.
  final List<StaffRoleAssignment> available;

  /// The one in effect. Null when the teacher holds no valid assignment at
  /// all - a real state the dashboard renders as an empty state, not an error.
  final ActiveResponsibilityContext? active;

  /// Set when the previously selected assignment could not be restored, so
  /// the UI can explain the switch instead of silently changing subject
  /// underneath the teacher.
  final String? switchReason;

  const ResponsibilityResolution({
    this.available = const [],
    this.active,
    this.switchReason,
  });

  bool get hasActive => active != null;

  /// Subject Teacher assignments only - what the "Change Class/Subject"
  /// control offers.
  List<StaffRoleAssignment> get subjectAssignments => available
      .where((a) => a.roleType == StaffResponsibilityType.subjectTeacher)
      .toList();

  /// The other responsibilities the same account holds, reached through the
  /// role switcher rather than the subject one.
  List<StaffRoleAssignment> get otherResponsibilities => available
      .where((a) => a.roleType != StaffResponsibilityType.subjectTeacher)
      .toList();
}

/// Resolves and switches the teacher's active responsibility.
///
/// One account, many responsibilities: this is what decides which of them the
/// panel is currently acting under, and it is the only thing allowed to
/// decide that. Every screen reads the resulting context; none of them build
/// their own.
abstract class ActiveResponsibilityService {
  /// Current context, or null before the first resolve.
  ActiveResponsibilityContext? get current;

  /// Emits whenever the active responsibility changes - including when it is
  /// forced to change because an admin revoked the one in use.
  Stream<ActiveResponsibilityContext?> get changes;

  /// Loads the teacher's assignments and picks one: the last-used assignment
  /// when it is still valid, otherwise the first valid one.
  Future<Either<Failure, ResponsibilityResolution>> resolve({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  });

  /// Switches to [assignmentId] after re-verifying it against the server.
  /// Fails rather than switching if the assignment has been suspended,
  /// removed or expired since the switcher was drawn.
  Future<Either<Failure, ActiveResponsibilityContext>> switchTo({
    required String assignmentId,
    required String schoolId,
    required String userId,
  });

  /// Re-checks the active assignment without changing it. Called before
  /// sensitive writes so a permission revoked mid-session is caught before
  /// the write, not after.
  Future<Either<Failure, ActiveResponsibilityContext>> revalidate();

  /// Clears the active context and cached assignments, on logout or when the
  /// user switches school.
  Future<void> clear({String? schoolId});
}
