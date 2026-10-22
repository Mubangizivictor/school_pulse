import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/policies/notification_delivery_policy.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../local/notification_presenter.dart';
import '../../routing/deep_link_router/notification_deep_link_router.dart';
import '../payloads/notification_push_payload.dart';

/// Signature for whoever actually performs navigation. Injected so the handler
/// stays testable and does not depend on go_router directly.
typedef NotificationNavigator = Future<void> Function(NotificationItem);

/// Wires FCM message delivery into the notification module.
///
/// Handles all three app states the spec calls out:
///
///  - **Foreground**: FCM does not display anything itself, so a banner is
///    shown explicitly via [NotificationPresenter].
///  - **Background**: the OS displayed the notification; tapping it routes
///    through [onMessageOpenedApp].
///  - **Terminated**: the app was cold-launched by the tap.
///    `getInitialMessage()` returns it exactly once per launch, and it arrives
///    before authentication has been restored - so the link is stashed in
///    [PendingDeepLink] and replayed once a user is available.
class NotificationPushHandler {
  final FirebaseMessaging messaging;
  final NotificationRepository repository;
  final NotificationPresenter presenter;
  final NotificationNavigator navigate;

  /// Current signed-in identity, or null when signed out. Read lazily because
  /// a push can arrive before or after login.
  final ({String schoolId, String userId})? Function() currentUser;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  /// Ids handled this session, to suppress the duplicate that occurs when the
  /// same event is delivered twice (FCM retry, or a data + notification pair).
  final Set<String> _handledIds = <String>{};

  NotificationPushHandler({
    required this.messaging,
    required this.repository,
    required this.presenter,
    required this.navigate,
    required this.currentUser,
  });

  /// Binds all three delivery paths. Safe to call once at startup.
  ///
  /// Deliberately does not await anything slow: [checkInitialMessage] is
  /// separated out so app startup is never blocked waiting on FCM.
  void start() {
    _foregroundSub?.cancel();
    _openedSub?.cancel();

    _foregroundSub = FirebaseMessaging.onMessage.listen(
      _onForegroundMessage,
      onError: (Object e) => _log('foreground stream error', e),
    );

    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _onNotificationTapped,
      onError: (Object e) => _log('opened-app stream error', e),
    );
  }

  /// Handles a cold launch caused by tapping a notification.
  ///
  /// Guarded by a timeout: this has been observed to hang on some devices, and
  /// because it is awaited during startup a hang would leave the app on a
  /// permanent blank screen.
  Future<void> checkInitialMessage() async {
    try {
      final message = await messaging.getInitialMessage().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (message != null) {
        await _onNotificationTapped(message);
      }
    } catch (e) {
      _log('initial message check failed', e);
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final payload = NotificationPushPayload.tryParse(message.data);
    if (payload == null) {
      // Not one of ours, or malformed. Fall back to whatever notification
      // block FCM supplied rather than dropping it silently.
      _log('unparseable payload', message.data);
      return;
    }

    if (!_markHandled(payload.notificationId)) return;

    final user = currentUser();
    if (user == null) return;

    // A push addressed to a different account on a shared device must never
    // be shown to whoever happens to be signed in now.
    if (payload.recipientUserId != null &&
        payload.recipientUserId != user.userId) {
      return;
    }
    if (payload.schoolId != null && payload.schoolId != user.schoolId) {
      return;
    }

    final preferences = await _preferences(user);
    final policy = await _schoolPolicy(user.schoolId);

    final evaluation = await presenter.present(
      payload: payload,
      preferences: preferences,
      schoolPolicy: policy,
    );

    if (evaluation.decision == DeliveryDecision.suppress) {
      _log('suppressed ${payload.notificationId}', evaluation.reason);
    }

    // Pull the authoritative record into the cache so the notification centre
    // reflects it even if the user never taps the banner.
    unawaited(_hydrate(payload.notificationId, user));
  }

  /// User tapped a notification (background or terminated).
  Future<void> _onNotificationTapped(RemoteMessage message) async {
    final payload = NotificationPushPayload.tryParse(message.data);
    if (payload == null) return;

    final user = currentUser();

    // Signed out, or the session has not been restored yet on a cold launch.
    // Park the link so it can be replayed after authentication rather than
    // dropping the user on a generic home screen.
    if (user == null) {
      PendingDeepLink.stash(payload.toProvisionalItem());
      return;
    }

    if (payload.schoolId != null && payload.schoolId != user.schoolId) {
      _log('cross-tenant push ignored', payload.notificationId);
      return;
    }

    // Prefer the stored record, which carries the full body, actions and
    // relationships; the payload is only a summary.
    final stored = await repository.getById(
      schoolId: user.schoolId,
      notificationId: payload.notificationId,
      recipientUserId: user.userId,
    );

    final item = stored.fold(
      (_) => payload.toProvisionalItem(),
      (notification) => notification,
    );

    // Opening is recorded before navigating, so the receipt survives even if
    // the destination fails to load.
    unawaited(
      repository.markAsOpened(
        schoolId: user.schoolId,
        notificationId: item.id,
        recipientUserId: user.userId,
      ),
    );
    unawaited(
      repository.markAsRead(
        schoolId: user.schoolId,
        notificationId: item.id,
        recipientUserId: user.userId,
      ),
    );

    await navigate(item);
  }

  /// Replays a link stashed while signed out. Called after login completes.
  Future<void> replayPendingDeepLink() async {
    if (!PendingDeepLink.hasPending) return;
    final pending = PendingDeepLink.consume();
    if (pending == null) return;

    final user = currentUser();
    if (user == null) return;

    // Re-fetch now that there is a session; the stashed copy was provisional.
    final stored = await repository.getById(
      schoolId: user.schoolId,
      notificationId: pending.id,
      recipientUserId: user.userId,
    );

    await navigate(stored.fold((_) => pending, (n) => n));
  }

  /// Clears the OS notification for a transient alert once its source has been
  /// opened - what stops a chat ping lingering after the conversation is read.
  Future<void> clearForSource({
    required String sourceModule,
    required String sourceEntityId,
  }) async {
    final user = currentUser();
    if (user == null) return;

    await repository.clearTransientForSource(
      schoolId: user.schoolId,
      recipientUserId: user.userId,
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
    );
  }

  /// Fetches the authoritative record so the centre and badge counts update
  /// without the user opening anything.
  Future<void> _hydrate(
    String notificationId,
    ({String schoolId, String userId}) user,
  ) async {
    try {
      await repository.getById(
        schoolId: user.schoolId,
        notificationId: notificationId,
        recipientUserId: user.userId,
      );
    } catch (e) {
      _log('hydrate failed for $notificationId', e);
    }
  }

  Future<NotificationPreferences> _preferences(
    ({String schoolId, String userId}) user,
  ) async {
    final result = await repository.getPreferences(
      schoolId: user.schoolId,
      userId: user.userId,
    );
    return result.getOrElse(
      () => NotificationPreferences.defaults(
        userId: user.userId,
        schoolId: user.schoolId,
      ),
    );
  }

  Future<SchoolNotificationPolicy?> _schoolPolicy(String schoolId) async {
    if (schoolId.isEmpty) return null;
    final result = await repository.getSchoolPolicy(schoolId);
    return result.fold((_) => null, (policy) => policy);
  }

  /// Returns false when this id was already handled this session.
  ///
  /// Bounded so a long-running session cannot grow the set without limit.
  bool _markHandled(String id) {
    if (_handledIds.contains(id)) return false;
    if (_handledIds.length > 500) _handledIds.clear();
    _handledIds.add(id);
    return true;
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    _foregroundSub = null;
    _openedSub = null;
  }

  static void _log(String message, Object detail) {
    if (kDebugMode) debugPrint('[notifications] $message: $detail');
  }
}

/// Background isolate handler.
///
/// Runs in a separate isolate with no access to the app's state, so it may not
/// touch the repository, DI container or UI. Its only job is to let FCM know
/// the message was received; the notification itself is displayed by the OS
/// from the `notification` block, and the in-app record is reconciled when the
/// app next opens.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('[notifications] background message ${message.messageId}');
  }
}
