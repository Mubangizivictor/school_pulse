import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';

import '../domain/entities/notification_model.dart';
import '../domain/repositories/notification_repository.dart';

/// Keeps the app-icon badge in step with the unread count.
///
/// Driven from the local cache stream rather than by counting server-side:
/// recomputing a badge with a Firestore aggregation query every time a
/// notification is read would bill a read per update for a number the device
/// already knows.
///
/// The badge is debounced because marking several notifications read in quick
/// succession (or a "mark all read") would otherwise produce a burst of
/// platform calls for intermediate values nobody sees.
class NotificationBadgeService {
  final NotificationRepository repository;
  final FlutterLocalNotificationsPlugin plugin;
  final MessagingBloc messagingBloc;

  StreamSubscription<NotificationCounts>? _notificationsSub;
  StreamSubscription<MessagingState>? _messagesSub;
  Timer? _debounce;
  int _lastPublished = -1;
  int _notificationUnread = 0;
  int _messageUnread = 0;

  static const _appBadgeChannel = MethodChannel('school_pulse/app_badge');

  NotificationBadgeService({
    required this.repository,
    required this.plugin,
    required this.messagingBloc,
  });

  void start({required String schoolId, required String userId}) {
    _notificationsSub?.cancel();
    _messagesSub?.cancel();
    _notificationUnread = 0;
    _messageUnread = messagingBloc.state.totalUnreadCount;
    _notificationsSub = repository
        .watchCounts(schoolId: schoolId, recipientUserId: userId)
        .listen((counts) {
          // Message notifications are represented by the messaging inbox as
          // well. Count that source once, rather than double-badging it.
          _notificationUnread =
              (counts.unread -
                      (counts.unreadByCategory[NotificationCategory.messages] ??
                          0))
                  .clamp(0, counts.unread)
                  .toInt();
          _scheduleUpdate();
        }, onError: (Object e) => _log('counts stream error', e));
    _messagesSub = messagingBloc.stream.listen((state) {
      _messageUnread = state.totalUnreadCount;
      _scheduleUpdate();
    });
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_publish(_notificationUnread + _messageUnread));
    });
  }

  Future<void> _publish(int unread) async {
    if (unread == _lastPublished) return;
    _lastPublished = unread;

    try {
      // iOS exposes a real launcher-badge API. The native handler is a no-op
      // on platforms whose launchers do not support numeric app badges.
      await _appBadgeChannel.invokeMethod<void>('setBadgeCount', unread);
    } catch (e) {
      _log('badge update failed', e);
    }

    // Existing notifications may still carry an old iOS badge. Once no item
    // needs attention, remove them so the launcher never retains a stale dot.
    if (unread == 0) {
      try {
        await plugin.cancelAll();
      } catch (e) {
        _log('badge clear failed', e);
      }
    }
  }

  /// Clears the badge and every displayed notification - used on sign-out so a
  /// shared device does not show the previous user's count.
  Future<void> clear() async {
    _debounce?.cancel();
    _lastPublished = 0;
    try {
      await _appBadgeChannel.invokeMethod<void>('setBadgeCount', 0);
      await plugin.cancelAll();
    } catch (e) {
      _log('badge clear failed', e);
    }
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _notificationsSub?.cancel();
    await _messagesSub?.cancel();
    _notificationsSub = null;
    _messagesSub = null;
  }

  static void _log(String message, Object error) {
    if (kDebugMode) debugPrint('[notifications] $message: $error');
  }
}
