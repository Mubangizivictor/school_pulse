import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

enum MessagingRefusal {
  differentSchool,
  actorInactive,
  targetInactive,
  studentToStudentDisallowed,
  studentToStaffDisallowed,
  studentTargetNotOwnParent,
  parentTargetNotStaff,
  groupNotAdmin,
  broadcastNotAuthorized,
}

class MessagingDecision {
  final bool isAllowed;
  final MessagingRefusal? refusal;
  final String? message;

  const MessagingDecision.allowed()
    : isAllowed = true,
      refusal = null,
      message = null;

  const MessagingDecision.refused(this.refusal, this.message) : isAllowed = false;
}

/// Configurable per-school messaging policy. Defaults are the conservative,
/// safeguarding-first posture the spec calls for; a school's admin console
/// can loosen individual switches later without touching this class.
class SchoolMessagingPolicy {
  final bool studentToStudentAllowed;
  final bool studentToTeacherAllowed;
  final bool studentToOwnParentAllowed;

  const SchoolMessagingPolicy({
    this.studentToStudentAllowed = false,
    this.studentToTeacherAllowed = false,
    this.studentToOwnParentAllowed = true,
  });
}

/// Who may start a conversation with whom, and who may broadcast.
///
/// This is the single place "can X message Y" is decided app-side. It exists
/// because permissions were previously inline ad hoc checks scattered across
/// the repository (`_isStaff()`, `canPost()`) with no shared, testable
/// definition — see the messaging module audit. The equivalent enforcement
/// also lives in firestore.rules; this class and the rules must be kept in
/// lockstep, since the client-side decision is UX only, never the security
/// boundary.
///
/// [actor] acts under [actorRole], the role/context currently active for
/// their session (School Pulse supports one account holding multiple roles;
/// the *account* never changes, only which role is active) — not
/// necessarily `actor.roles.first`.
class MessagingPermissionPolicy {
  const MessagingPermissionPolicy._();

  static MessagingDecision canStartConversation({
    required UserEntity actor,
    required UserRole actorRole,
    required UserEntity target,
    SchoolMessagingPolicy policy = const SchoolMessagingPolicy(),
  }) {
    if (actor.schoolId != target.schoolId) {
      return const MessagingDecision.refused(
        MessagingRefusal.differentSchool,
        'You can only message people at your own school.',
      );
    }

    if (!actor.isActive) {
      return const MessagingDecision.refused(
        MessagingRefusal.actorInactive,
        'Your account is inactive.',
      );
    }

    if (!target.isActive) {
      return const MessagingDecision.refused(
        MessagingRefusal.targetInactive,
        'That person is no longer active at this school.',
      );
    }

    final actorIsStudent = actorRole == UserRole.student;
    final targetIsStudent = target.roles.contains(UserRole.student);
    final targetIsParent = target.roles.contains(UserRole.parent);
    final targetIsStaff = !targetIsStudent && !targetIsParent;

    if (actorIsStudent) {
      if (targetIsStudent) {
        return policy.studentToStudentAllowed
            ? const MessagingDecision.allowed()
            : const MessagingDecision.refused(
                MessagingRefusal.studentToStudentDisallowed,
                'Student-to-student messaging is turned off at this school.',
              );
      }
      if (targetIsStaff) {
        return policy.studentToTeacherAllowed
            ? const MessagingDecision.allowed()
            : const MessagingDecision.refused(
                MessagingRefusal.studentToStaffDisallowed,
                'Direct messaging to staff is turned off for students at this school.',
              );
      }
      if (targetIsParent) {
        final isOwnParent = actor.studentId != null &&
            target.studentIds.contains(actor.studentId);
        if (!policy.studentToOwnParentAllowed || !isOwnParent) {
          return const MessagingDecision.refused(
            MessagingRefusal.studentTargetNotOwnParent,
            'You can only message your own parent/guardian.',
          );
        }
        return const MessagingDecision.allowed();
      }
    }

    // Parents may only reach staff directly (parent-to-parent goes through
    // Message Requests, handled separately by the repository; parent-to-
    // student is out of scope here — a parent reaches their child through
    // the linked student's own device/account policy, not this path).
    final actorIsParent = actorRole == UserRole.parent;
    if (actorIsParent && targetIsStudent) {
      return const MessagingDecision.refused(
        MessagingRefusal.parentTargetNotStaff,
        'Parents cannot message students directly.',
      );
    }

    return const MessagingDecision.allowed();
  }

  static MessagingDecision canManageGroup({
    required String actorId,
    required List<String> adminIds,
  }) {
    if (!adminIds.contains(actorId)) {
      return const MessagingDecision.refused(
        MessagingRefusal.groupNotAdmin,
        'Only group admins can do that.',
      );
    }
    return const MessagingDecision.allowed();
  }

  /// Broad institutional roles authorized to send to a whole-school or
  /// whole-audience broadcast (e.g. "All Parents", "All Staff"). Narrower
  /// audiences (a class teacher's own class parents, a bursar's fee-related
  /// thread) are scoped by the caller's existing domain policy — e.g.
  /// ClassCommunicationPolicy for class teachers — not by this list.
  static const _broadcastAuthorizedRoles = {
    UserRole.schoolAdmin,
    UserRole.headTeacher,
    UserRole.deputyHead,
    UserRole.director,
  };

  static MessagingDecision canSendSchoolWideBroadcast({
    required UserRole actorRole,
  }) {
    if (!_broadcastAuthorizedRoles.contains(actorRole)) {
      return const MessagingDecision.refused(
        MessagingRefusal.broadcastNotAuthorized,
        'You are not authorized to send a school-wide announcement.',
      );
    }
    return const MessagingDecision.allowed();
  }
}
