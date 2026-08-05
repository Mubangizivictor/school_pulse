import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  StreamSubscription<NotificationCounts>? _sub;
  Timer? _debounce;
  int _lastPublished = -1;

  NotificationBadgeService({required this.repository, required this.plugin});

  void start({required String schoolId, required String userId}) {
    _sub?.cancel();
    _sub = repository
        .watchCounts(schoolId: schoolId, recipientUserId: userId)
        .listen(
          (counts) => _scheduleUpdate(counts.unread),
          onError: (Object e) => _log('counts stream error', e),
        );
  }

  void _scheduleUpdate(int unread) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_publish(unread));
    });
  }

  Future<void> _publish(int unread) async {
    if (unread == _lastPublished) return;
    _lastPublished = unread;

    try {
      final ios = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        // iOS has no direct "set badge" call in this plugin; the badge is
        // carried by delivered notifications. Clearing every delivered
        // notification when the count reaches zero is what actually removes
        // the badge from the home screen.
        if (unread == 0) await plugin.cancelAll();
      }
    } catch (e) {
      _log('badge update failed', e);
    }
  }

  /// Clears the badge and every displayed notification - used on sign-out so a
  /// shared device does not show the previous user's count.
  Future<void> clear() async {
    _debounce?.cancel();
    _lastPublished = 0;
    try {
      await plugin.cancelAll();
    } catch (e) {
      _log('badge clear failed', e);
    }
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _sub?.cancel();
    _sub = null;
  }

  static void _log(String message, Object error) {
    if (kDebugMode) debugPrint('[notifications] $message: $error');
  }
}
