import 'package:flutter/foundation.dart';

/// The set of places a notification is allowed to send the user.
///
/// This is a closed enum on purpose. A push payload arrives from outside the
/// app and cannot be trusted, so the router never navigates to an arbitrary
/// string: it resolves the payload onto one of these known destinations, or
/// refuses. Adding a destination is a deliberate code change, which keeps the
/// reachable surface auditable.
enum NotificationDestinationKind {
  /// The notification's own details screen - the default when a notification
  /// has no more specific target.
  notificationDetails,
  studentProfile,
  childProfile,
  attendanceDetails,
  subjectAttendance,
  gateLog,
  reportCard,
  results,
  feeStatement,
  receipt,
  paymentFlow,
  conversation,
  appointment,
  visitorDetails,
  transportTrip,
  libraryLoan,
  homework,
  assignment,
  examTimetable,
  medicalAlert,
  disciplineCase,
  event,
  announcement,
  supportTicket,
  billing,
  subscription,

  /// Recognised but not reachable for this user or in this app build - the
  /// caller shows a professional fallback instead of navigating.
  unavailable,
}

/// A validated navigation target.
///
/// Only produced by the router after authentication, tenancy and permission
/// checks have passed, so holding one of these means navigation is safe.
@immutable
class NotificationDestination {
  final NotificationDestinationKind kind;

  /// Concrete go_router path to push, already parameter-substituted.
  final String route;

  /// Passed as go_router `extra` where the target screen needs an object
  /// rather than path parameters.
  final Object? extra;

  const NotificationDestination({
    required this.kind,
    required this.route,
    this.extra,
  });

  bool get isNavigable => kind != NotificationDestinationKind.unavailable;
}

/// Why a deep link could not be opened. Each maps to a specific message so the
/// user is told what actually happened rather than a generic error.
enum DeepLinkRefusal {
  /// No signed-in user. The link is stashed and replayed after login.
  notAuthenticated,

  /// Notification belongs to a school the user is not currently in.
  wrongTenant,

  /// User's role lacks the permission this destination requires.
  notPermitted,

  /// Target record was deleted after the notification was sent.
  targetMissing,

  /// Notification's own expiry has passed.
  expired,

  /// Route was not recognised, or its required parameters were absent.
  unroutable,
}

/// Outcome of resolving a notification into a destination.
///
/// A sealed-style result rather than a nullable return, so callers must handle
/// refusal explicitly instead of silently doing nothing on a failed tap.
@immutable
class DeepLinkResolution {
  final NotificationDestination? destination;
  final DeepLinkRefusal? refusal;

  /// Message to show when [refusal] is set. Written for display.
  final String? message;

  const DeepLinkResolution.allowed(NotificationDestination this.destination)
    : refusal = null,
      message = null;

  const DeepLinkResolution.refused(this.refusal, this.message)
    : destination = null;

  bool get isAllowed => destination != null;
}
