import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

import '../../domain/entities/notification_model.dart';
import '../deep_link_router/notification_destination.dart';

/// Decides whether a given user may open a given notification destination.
///
/// Kept separate from the router so the rules are unit-testable in isolation
/// and so the same checks can be reused by the details screen when deciding
/// which action buttons to render (the spec requires never showing an action
/// the user cannot perform).
///
/// This is a client-side guard. It is not the security boundary - Firestore
/// rules are - but it prevents a crafted push payload from navigating a user
/// into a screen that would then fail or leak a shape of data it shouldn't.
class NotificationAuthorization {
  const NotificationAuthorization._();

  static const _staffRoles = <UserRole>{
    UserRole.director,
    UserRole.headTeacher,
    UserRole.deputyHead,
    UserRole.deanOfStudies,
    UserRole.schoolAdmin,
    UserRole.bursar,
    UserRole.classTeacher,
    UserRole.subjectTeacher,
    UserRole.librarian,
    UserRole.nurse,
    UserRole.boardingMatron,
    UserRole.boardingPatron,
    UserRole.transportCoordinator,
    UserRole.guidanceDiscipline,
    UserRole.storeInventory,
    UserRole.gatekeeper,
    UserRole.securityHead,
    UserRole.gamesMaster,
    UserRole.cateringManager,
    UserRole.religiousLeader,
    UserRole.receptionist,
    UserRole.hrOfficer,
  };

  static bool isStaff(UserEntity user) =>
      user.roles.any(_staffRoles.contains);

  static bool isParent(UserEntity user) => user.roles.contains(UserRole.parent);

  static bool isStudent(UserEntity user) =>
      user.roles.contains(UserRole.student);

  /// School leadership and admin - the roles permitted to see cross-student
  /// welfare, discipline and medical detail.
  static bool isLeadership(UserEntity user) => user.roles.any(const {
        UserRole.director,
        UserRole.headTeacher,
        UserRole.deputyHead,
        UserRole.deanOfStudies,
        UserRole.schoolAdmin,
      }.contains);

  /// Whether [user] is entitled to see data about [studentId].
  ///
  /// Parents are restricted to their own linked children; students to
  /// themselves; staff may see students in their school (finer per-module
  /// scoping is the responsibility of the destination screen).
  static bool canAccessStudent(UserEntity user, String? studentId) {
    if (studentId == null) return true;
    if (isParent(user)) return user.studentIds.contains(studentId);
    if (isStudent(user)) return user.studentId == studentId;
    return isStaff(user);
  }

  /// Whether the notification itself is addressed to this user.
  ///
  /// A notification with no explicit recipient (a school-wide broadcast) is
  /// treated as addressed to everyone in the tenant.
  static bool isRecipient(UserEntity user, NotificationItem notification) {
    final recipient = notification.recipientUserId;
    if (recipient == null || recipient.isEmpty) return true;
    return recipient == user.id;
  }

  /// Same-school check. Notifications never cross tenants, so a mismatch is
  /// always a refusal regardless of the user's role.
  static bool isSameTenant(UserEntity user, NotificationItem notification) {
    final schoolId = notification.schoolId;
    if (schoolId == null || schoolId.isEmpty) return true;
    return schoolId == user.schoolId;
  }

  /// Whether [user] may open [kind] for [notification].
  ///
  /// Ordered from most to least sensitive. Anything not explicitly permitted
  /// below is denied, so a new destination added without a rule fails closed.
  static bool canOpen({
    required UserEntity user,
    required NotificationDestinationKind kind,
    required NotificationItem notification,
  }) {
    final studentId = notification.relatedStudentId;

    switch (kind) {
      // Always available: the notification's own details screen shows only
      // content already delivered to this user.
      case NotificationDestinationKind.notificationDetails:
        return true;

      // Medical, discipline and counselling detail. Parents see only their own
      // child's; among staff only the clinical/welfare owners and leadership.
      case NotificationDestinationKind.medicalAlert:
        if (isParent(user)) return canAccessStudent(user, studentId);
        return user.roles.contains(UserRole.nurse) || isLeadership(user);

      case NotificationDestinationKind.disciplineCase:
        if (isParent(user)) return canAccessStudent(user, studentId);
        if (isStudent(user)) return canAccessStudent(user, studentId);
        return user.roles.contains(UserRole.guidanceDiscipline) ||
            user.roles.contains(UserRole.classTeacher) ||
            isLeadership(user);

      // Financial detail: the paying parent, the bursar, and leadership.
      case NotificationDestinationKind.feeStatement:
      case NotificationDestinationKind.receipt:
      case NotificationDestinationKind.paymentFlow:
        if (isParent(user)) return canAccessStudent(user, studentId);
        return user.roles.contains(UserRole.bursar) || isLeadership(user);

      // Academic records.
      case NotificationDestinationKind.reportCard:
      case NotificationDestinationKind.results:
        if (isParent(user) || isStudent(user)) {
          return canAccessStudent(user, studentId);
        }
        return isStaff(user);

      // Attendance and gate movement.
      case NotificationDestinationKind.attendanceDetails:
      case NotificationDestinationKind.subjectAttendance:
        if (isParent(user) || isStudent(user)) {
          return canAccessStudent(user, studentId);
        }
        return isStaff(user);

      case NotificationDestinationKind.gateLog:
        if (isParent(user)) return canAccessStudent(user, studentId);
        return user.roles.contains(UserRole.gatekeeper) ||
            user.roles.contains(UserRole.securityHead) ||
            isLeadership(user);

      // Visitor records carry a photo and ID detail - staff only.
      case NotificationDestinationKind.visitorDetails:
        return user.roles.contains(UserRole.gatekeeper) ||
            user.roles.contains(UserRole.securityHead) ||
            user.roles.contains(UserRole.receptionist) ||
            isLeadership(user);

      // Student profile. Parents reach their own child's via childProfile.
      case NotificationDestinationKind.studentProfile:
        return isStaff(user) && canAccessStudent(user, studentId);

      case NotificationDestinationKind.childProfile:
        return isParent(user) && canAccessStudent(user, studentId);

      // A conversation is only openable by a participant. The messaging
      // module owns participant checks; here we require the notification to
      // have been addressed to this user, which the fan-out guarantees.
      case NotificationDestinationKind.conversation:
        return isRecipient(user, notification);

      case NotificationDestinationKind.appointment:
        return isRecipient(user, notification) || isStaff(user);

      // Student-scoped operational records.
      case NotificationDestinationKind.transportTrip:
      case NotificationDestinationKind.libraryLoan:
        if (isParent(user) || isStudent(user)) {
          return canAccessStudent(user, studentId);
        }
        return isStaff(user);

      case NotificationDestinationKind.homework:
      case NotificationDestinationKind.assignment:
      case NotificationDestinationKind.examTimetable:
        if (isParent(user) || isStudent(user)) {
          return canAccessStudent(user, studentId);
        }
        return isStaff(user);

      // School-wide content carries no personal data.
      case NotificationDestinationKind.event:
      case NotificationDestinationKind.announcement:
        return true;

      // Platform/tenant administration.
      case NotificationDestinationKind.billing:
      case NotificationDestinationKind.subscription:
        return user.roles.contains(UserRole.superAdmin) ||
            user.roles.contains(UserRole.director) ||
            user.roles.contains(UserRole.schoolAdmin);

      case NotificationDestinationKind.supportTicket:
        return isStaff(user) || user.roles.contains(UserRole.superAdmin);

      case NotificationDestinationKind.unavailable:
        return false;
    }
  }

  /// Filters a notification's action buttons down to those [user] may invoke.
  /// The details screen renders only what this returns, so an unauthorised
  /// action is never offered in the first place.
  static List<NotificationAction> permittedActions({
    required UserEntity user,
    required NotificationItem notification,
    required Set<String> grantedPermissions,
  }) {
    return notification.actions.where((action) {
      final required = action.requiredPermission;
      if (required != null && !grantedPermissions.contains(required)) {
        return false;
      }
      // Acknowledgement is always available to the recipient of an alert that
      // requires it - it is a confirmation, not a privileged operation.
      if (action.isAcknowledgement) return isRecipient(user, notification);
      return true;
    }).toList();
  }
}
