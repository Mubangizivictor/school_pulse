import 'package:equatable/equatable.dart';

/// Failure cases for the notification module.
///
/// Each carries a [userMessage] written for display, because the spec requires
/// professional messaging on every error path rather than a raw exception
/// string leaking into the UI.
abstract class NotificationFailure extends Equatable {
  final String userMessage;

  /// Technical detail for logs. Never rendered.
  final String? debugDetail;

  const NotificationFailure(this.userMessage, {this.debugDetail});

  @override
  List<Object?> get props => [userMessage, debugDetail];
}

class NotificationNetworkFailure extends NotificationFailure {
  const NotificationNetworkFailure({String? debugDetail})
      : super(
          'You appear to be offline. Showing saved notifications.',
          debugDetail: debugDetail,
        );
}

class NotificationServerFailure extends NotificationFailure {
  const NotificationServerFailure({String? debugDetail})
      : super(
          'We could not reach School Pulse just now. Please try again.',
          debugDetail: debugDetail,
        );
}

class NotificationCacheFailure extends NotificationFailure {
  const NotificationCacheFailure({String? debugDetail})
      : super(
          'Saved notifications could not be loaded on this device.',
          debugDetail: debugDetail,
        );
}

class NotificationNotFoundFailure extends NotificationFailure {
  const NotificationNotFoundFailure({String? debugDetail})
      : super(
          'This notification is no longer available.',
          debugDetail: debugDetail,
        );
}

/// The signed-in user lacks the permission a send/manage action needs.
class NotificationPermissionFailure extends NotificationFailure {
  const NotificationPermissionFailure({String? debugDetail})
      : super(
          'You do not have permission to do this.',
          debugDetail: debugDetail,
        );
}

/// The notification belongs to a different school than the active tenant.
/// Treated as not-found in the UI so a cross-tenant probe cannot distinguish
/// "exists elsewhere" from "does not exist".
class NotificationTenantMismatchFailure extends NotificationFailure {
  const NotificationTenantMismatchFailure({String? debugDetail})
      : super(
          'This notification is not available for the current school.',
          debugDetail: debugDetail,
        );
}

/// The notification's target record was deleted after the notification was
/// sent (a withdrawn report card, a cancelled appointment).
class NotificationTargetMissingFailure extends NotificationFailure {
  const NotificationTargetMissingFailure({String? debugDetail})
      : super(
          'The item this notification refers to is no longer available.',
          debugDetail: debugDetail,
        );
}

class NotificationExpiredFailure extends NotificationFailure {
  const NotificationExpiredFailure({String? debugDetail})
      : super(
          'This notification has expired.',
          debugDetail: debugDetail,
        );
}

/// OS-level notification permission is switched off.
class NotificationDevicePermissionFailure extends NotificationFailure {
  const NotificationDevicePermissionFailure({String? debugDetail})
      : super(
          'Notifications are turned off for School Pulse. Enable them in your device settings.',
          debugDetail: debugDetail,
        );
}

/// No usable FCM token - simulator, revoked token, or push not provisioned.
class NotificationTokenFailure extends NotificationFailure {
  const NotificationTokenFailure({String? debugDetail})
      : super(
          'This device is not registered for push notifications yet.',
          debugDetail: debugDetail,
        );
}

class NotificationImageFailure extends NotificationFailure {
  const NotificationImageFailure({String? debugDetail})
      : super(
          'The image attached to this notification could not be loaded.',
          debugDetail: debugDetail,
        );
}

class NotificationAttachmentFailure extends NotificationFailure {
  const NotificationAttachmentFailure({String? debugDetail})
      : super(
          'This attachment is unavailable.',
          debugDetail: debugDetail,
        );
}

/// User is signed out, or the session expired while a deep link was pending.
class NotificationAuthRequiredFailure extends NotificationFailure {
  const NotificationAuthRequiredFailure({String? debugDetail})
      : super(
          'Please sign in to open this notification.',
          debugDetail: debugDetail,
        );
}

class NotificationRateLimitFailure extends NotificationFailure {
  const NotificationRateLimitFailure({String? debugDetail})
      : super(
          'Too many notifications have been sent recently. Please wait a moment.',
          debugDetail: debugDetail,
        );
}

class NotificationUnknownFailure extends NotificationFailure {
  const NotificationUnknownFailure({String? debugDetail})
      : super(
          'Something went wrong with notifications. Please try again.',
          debugDetail: debugDetail,
        );
}
