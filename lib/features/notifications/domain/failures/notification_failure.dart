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
  const NotificationNetworkFailure({super.debugDetail})
    : super('You appear to be offline. Showing saved notifications.');
}

class NotificationServerFailure extends NotificationFailure {
  const NotificationServerFailure({super.debugDetail})
    : super('We could not reach School Pulse just now. Please try again.');
}

class NotificationCacheFailure extends NotificationFailure {
  const NotificationCacheFailure({super.debugDetail})
    : super('Saved notifications could not be loaded on this device.');
}

class NotificationNotFoundFailure extends NotificationFailure {
  const NotificationNotFoundFailure({super.debugDetail})
    : super('This notification is no longer available.');
}

/// The signed-in user lacks the permission a send/manage action needs.
class NotificationPermissionFailure extends NotificationFailure {
  const NotificationPermissionFailure({super.debugDetail})
    : super('You do not have permission to do this.');
}

/// The notification belongs to a different school than the active tenant.
/// Treated as not-found in the UI so a cross-tenant probe cannot distinguish
/// "exists elsewhere" from "does not exist".
class NotificationTenantMismatchFailure extends NotificationFailure {
  const NotificationTenantMismatchFailure({super.debugDetail})
    : super('This notification is not available for the current school.');
}

/// The notification's target record was deleted after the notification was
/// sent (a withdrawn report card, a cancelled appointment).
class NotificationTargetMissingFailure extends NotificationFailure {
  const NotificationTargetMissingFailure({super.debugDetail})
    : super('The item this notification refers to is no longer available.');
}

class NotificationExpiredFailure extends NotificationFailure {
  const NotificationExpiredFailure({super.debugDetail})
    : super('This notification has expired.');
}

/// OS-level notification permission is switched off.
class NotificationDevicePermissionFailure extends NotificationFailure {
  const NotificationDevicePermissionFailure({super.debugDetail})
    : super(
        'Notifications are turned off for School Pulse. Enable them in your device settings.',
      );
}

/// No usable FCM token - simulator, revoked token, or push not provisioned.
class NotificationTokenFailure extends NotificationFailure {
  const NotificationTokenFailure({super.debugDetail})
    : super('This device is not registered for push notifications yet.');
}

class NotificationImageFailure extends NotificationFailure {
  const NotificationImageFailure({super.debugDetail})
    : super('The image attached to this notification could not be loaded.');
}

class NotificationAttachmentFailure extends NotificationFailure {
  const NotificationAttachmentFailure({super.debugDetail})
    : super('This attachment is unavailable.');
}

/// User is signed out, or the session expired while a deep link was pending.
class NotificationAuthRequiredFailure extends NotificationFailure {
  const NotificationAuthRequiredFailure({super.debugDetail})
    : super('Please sign in to open this notification.');
}

class NotificationRateLimitFailure extends NotificationFailure {
  const NotificationRateLimitFailure({super.debugDetail})
    : super(
        'Too many notifications have been sent recently. Please wait a moment.',
      );
}

class NotificationUnknownFailure extends NotificationFailure {
  const NotificationUnknownFailure({super.debugDetail})
    : super('Something went wrong with notifications. Please try again.');
}
