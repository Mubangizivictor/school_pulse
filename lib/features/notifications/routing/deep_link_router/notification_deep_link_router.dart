import 'package:flutter/foundation.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

import '../../domain/entities/notification_model.dart';
import '../authorization/notification_authorization.dart';
import 'notification_destination.dart';

/// Resolves a notification into a safe, concrete navigation target.
///
/// This is the single place notification routing happens. Route parsing is
/// deliberately not spread across widgets: a push payload is attacker-
/// influenced input, and centralising resolution means every navigation from a
/// notification passes the same authentication, tenancy, permission and
/// existence checks.
///
/// The router never navigates. It returns a [DeepLinkResolution] and lets the
/// caller drive go_router, which keeps it pure and unit-testable.
class NotificationDeepLinkRouter {
  const NotificationDeepLinkRouter();

  /// Resolves [notification] for [user].
  ///
  /// [grantedPermissions] is the user's effective permission set, used for
  /// action-level checks. [targetExists] lets the caller confirm the underlying
  /// record still exists before navigating; when omitted, existence is assumed
  /// and the destination screen handles its own missing-record state.
  Future<DeepLinkResolution> resolve({
    required NotificationItem notification,
    required UserEntity? user,
    Set<String> grantedPermissions = const {},
    Future<bool> Function(NotificationDestinationKind kind, String? id)?
    targetExists,
  }) async {
    // 1. Authentication. The caller stashes the notification and replays it
    //    after login rather than dropping it.
    if (user == null) {
      return const DeepLinkResolution.refused(
        DeepLinkRefusal.notAuthenticated,
        'Please sign in to open this notification.',
      );
    }

    // 2. Tenancy. Checked before anything else that could reveal content.
    if (!NotificationAuthorization.isSameTenant(user, notification)) {
      return const DeepLinkResolution.refused(
        DeepLinkRefusal.wrongTenant,
        'This notification belongs to a different school.',
      );
    }

    // 3. Addressing - a notification meant for someone else is never openable,
    //    even within the same school.
    if (!NotificationAuthorization.isRecipient(user, notification)) {
      return const DeepLinkResolution.refused(
        DeepLinkRefusal.wrongTenant,
        'This notification is not available for your account.',
      );
    }

    // 4. Expiry. Expired notifications still open their own details screen so
    //    the user can read what it said; only the onward link is withheld.
    if (notification.isExpired) {
      return DeepLinkResolution.allowed(
        _detailsDestination(user, notification),
      );
    }

    // 5. Work out where this notification wants to go.
    final kind = _kindFor(notification);
    if (kind == NotificationDestinationKind.notificationDetails) {
      return DeepLinkResolution.allowed(
        _detailsDestination(user, notification),
      );
    }

    // 6. Permission for that specific destination.
    final permitted = NotificationAuthorization.canOpen(
      user: user,
      kind: kind,
      notification: notification,
    );
    if (!permitted) {
      return const DeepLinkResolution.refused(
        DeepLinkRefusal.notPermitted,
        'You do not have permission to open this item.',
      );
    }

    // 7. Build the concrete route. A destination whose required id is missing
    //    degrades to the details screen rather than pushing a broken route.
    final destination = _buildRoute(user, notification, kind);
    if (destination == null) {
      return DeepLinkResolution.allowed(
        _detailsDestination(user, notification),
      );
    }

    // 8. Existence, where the caller can check it. A report card withdrawn
    //    after the notification was sent should say so, not open an empty
    //    screen.
    if (targetExists != null) {
      final exists = await targetExists(kind, notification.sourceEntityId);
      if (!exists) {
        return const DeepLinkResolution.refused(
          DeepLinkRefusal.targetMissing,
          'The item this notification refers to is no longer available.',
        );
      }
    }

    return DeepLinkResolution.allowed(destination);
  }

  /// The notification's own details screen, on the correct side of the app.
  NotificationDestination _detailsDestination(
    UserEntity user,
    NotificationItem notification,
  ) {
    final base = _isParentSide(user) ? '/parent' : '/staff';
    return NotificationDestination(
      kind: NotificationDestinationKind.notificationDetails,
      route: '$base/notifications/${notification.id}',
      extra: notification,
    );
  }

  /// Parents and students use the parent-side shell; everyone else is staff.
  static bool _isParentSide(UserEntity user) =>
      NotificationAuthorization.isParent(user) ||
      NotificationAuthorization.isStudent(user);

  /// Maps a notification onto its destination kind.
  ///
  /// Driven by the typed [NotificationType] rather than by parsing
  /// [NotificationItem.deepLinkRoute], because the type is set by trusted
  /// server code while the route string may have come from a push payload.
  NotificationDestinationKind _kindFor(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.newMessage:
      case NotificationType.groupMessage:
      case NotificationType.messageRequest:
        return NotificationDestinationKind.conversation;

      case NotificationType.gateEntry:
      case NotificationType.gateExit:
        return NotificationDestinationKind.gateLog;

      case NotificationType.lateArrival:
      case NotificationType.studentAbsent:
      case NotificationType.boardingRollCall:
        return NotificationDestinationKind.attendanceDetails;

      case NotificationType.subjectAttendance:
        return NotificationDestinationKind.subjectAttendance;

      case NotificationType.busBoarded:
      case NotificationType.busDropOff:
      case NotificationType.busDelayed:
      case NotificationType.transportIncident:
        return NotificationDestinationKind.transportTrip;

      case NotificationType.paymentReceived:
      case NotificationType.receiptGenerated:
        return NotificationDestinationKind.receipt;

      case NotificationType.paymentFailed:
        return NotificationDestinationKind.paymentFlow;

      case NotificationType.feeReminder:
        return NotificationDestinationKind.feeStatement;

      case NotificationType.reportCardPublished:
        return NotificationDestinationKind.reportCard;

      case NotificationType.resultsPublished:
        return NotificationDestinationKind.results;

      case NotificationType.homeworkAssigned:
        return NotificationDestinationKind.homework;

      case NotificationType.assignmentDue:
        return NotificationDestinationKind.assignment;

      case NotificationType.examScheduled:
      case NotificationType.timetableUpdated:
        return NotificationDestinationKind.examTimetable;

      case NotificationType.bookOverdue:
      case NotificationType.bookDueSoon:
        return NotificationDestinationKind.libraryLoan;

      case NotificationType.nurseAlert:
      case NotificationType.medicalAlert:
        return NotificationDestinationKind.medicalAlert;

      case NotificationType.appointmentApproved:
      case NotificationType.appointmentChanged:
      case NotificationType.appointmentReminder:
        return NotificationDestinationKind.appointment;

      case NotificationType.visitorArrived:
        return NotificationDestinationKind.visitorDetails;

      case NotificationType.disciplineCase:
        return NotificationDestinationKind.disciplineCase;

      case NotificationType.eventNotice:
      case NotificationType.clubNotice:
      case NotificationType.sportsNotice:
        return NotificationDestinationKind.event;

      case NotificationType.subscriptionNotice:
        return NotificationDestinationKind.subscription;

      case NotificationType.supportTicketUpdate:
        return NotificationDestinationKind.supportTicket;

      // Everything else is best read on the notification's own screen: the
      // announcement body, emergency instructions, counselling and meal or
      // hostel notices are the content, not a pointer to it.
      case NotificationType.announcement:
      case NotificationType.platformAnnouncement:
      case NotificationType.emergencyAlert:
      case NotificationType.securityAlert:
      case NotificationType.counsellingNote:
      case NotificationType.mealEligibility:
      case NotificationType.hostelNotice:
      case NotificationType.systemMaintenance:
      case NotificationType.custom:
        return NotificationDestinationKind.notificationDetails;
    }
  }

  /// Builds the concrete go_router path for [kind].
  ///
  /// Returns null when a required identifier is absent, so the caller can fall
  /// back to the details screen instead of pushing a malformed route.
  NotificationDestination? _buildRoute(
    UserEntity user,
    NotificationItem notification,
    NotificationDestinationKind kind,
  ) {
    final parentSide = _isParentSide(user);
    final studentId = notification.relatedStudentId;
    final entityId = notification.sourceEntityId;

    String? route;

    switch (kind) {
      case NotificationDestinationKind.conversation:
        final chatId = notification.relatedConversationId ?? entityId;
        if (chatId == null) return null;
        route = '/messages/chat/$chatId';
        break;

      case NotificationDestinationKind.attendanceDetails:
      case NotificationDestinationKind.subjectAttendance:
      case NotificationDestinationKind.gateLog:
        route = parentSide
            ? '/parent/academics/attendance'
            : '/staff/attendance';
        break;

      case NotificationDestinationKind.reportCard:
      case NotificationDestinationKind.results:
        route = parentSide ? '/parent/academics/report-card' : '/staff/marks';
        break;

      case NotificationDestinationKind.feeStatement:
        route = parentSide ? '/parent/fees' : '/staff/bursar';
        break;

      case NotificationDestinationKind.receipt:
        route = parentSide ? '/parent/fees/history' : '/staff/bursar';
        break;

      case NotificationDestinationKind.paymentFlow:
        // Only parents can actually pay; staff land on the statement instead.
        route = parentSide ? '/parent/fees/pay' : '/staff/bursar';
        break;

      case NotificationDestinationKind.transportTrip:
        route = parentSide ? '/parent/transport' : '/staff/transport';
        break;

      case NotificationDestinationKind.libraryLoan:
        route = parentSide ? '/parent/library' : '/staff/librarian';
        break;

      case NotificationDestinationKind.homework:
      case NotificationDestinationKind.assignment:
        route = parentSide ? '/parent/academics' : '/staff/homework';
        break;

      case NotificationDestinationKind.examTimetable:
        route = parentSide ? '/parent/calendar' : '/staff/calendar';
        break;

      case NotificationDestinationKind.medicalAlert:
        route = parentSide ? '/parent/health' : '/staff/nurse';
        break;

      case NotificationDestinationKind.disciplineCase:
        route = parentSide ? '/parent/discipline' : '/staff/discipline';
        break;

      case NotificationDestinationKind.visitorDetails:
        route = '/staff/security';
        break;

      case NotificationDestinationKind.appointment:
        route = parentSide ? '/parent/more' : '/staff/admin';
        break;

      case NotificationDestinationKind.event:
        route = parentSide ? '/parent/calendar' : '/staff/calendar';
        break;

      case NotificationDestinationKind.studentProfile:
        if (studentId == null) return null;
        route = '/staff/dashboard';
        break;

      case NotificationDestinationKind.childProfile:
        route = '/parent/profile';
        break;

      case NotificationDestinationKind.subscription:
      case NotificationDestinationKind.billing:
        route = '/staff/admin';
        break;

      case NotificationDestinationKind.supportTicket:
        route = '/staff/more';
        break;

      case NotificationDestinationKind.announcement:
      case NotificationDestinationKind.notificationDetails:
      case NotificationDestinationKind.unavailable:
        return null;
    }

    return NotificationDestination(kind: kind, route: route);
  }
}

/// Holds a deep link that arrived before the app could act on it.
///
/// A push tapped from a terminated state reaches the app before authentication
/// has been restored. Rather than dropping it, the handler parks it here and
/// the router replays it once a user is available - which is what makes
/// "tap notification while logged out, then sign in, land on the right screen"
/// work.
class PendingDeepLink {
  static NotificationItem? _pending;

  /// Guards against replaying a link the user has already been taken to, e.g.
  /// after a hot restart during development.
  static String? _lastConsumedId;

  static void stash(NotificationItem notification) {
    if (notification.id == _lastConsumedId) return;
    _pending = notification;
    if (kDebugMode) {
      debugPrint('[notifications] deep link stashed: ${notification.id}');
    }
  }

  static bool get hasPending => _pending != null;

  /// Returns the stashed link and clears it, so a replay can only happen once.
  static NotificationItem? consume() {
    final pending = _pending;
    _pending = null;
    if (pending != null) _lastConsumedId = pending.id;
    return pending;
  }

  static void clear() {
    _pending = null;
    _lastConsumedId = null;
  }
}
