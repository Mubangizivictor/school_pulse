import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

import 'domain/repositories/notification_repository.dart';
import 'local/channels/notification_channels.dart';
import 'push/handlers/notification_push_handler.dart';
import 'push/notification_badge_service.dart';
import 'push/token_management/notification_token_manager.dart';
import 'routing/deep_link_router/notification_deep_link_router.dart';

/// Single entry point that starts and stops the notification pipeline.
///
/// Exists so `main.dart` and the auth listener have one thing to call rather
/// than five, and so the ordering constraints between them (channels before
/// display, token before push, session before deep-link replay) live in one
/// place instead of being reimplemented at each call site.
class NotificationCoordinator {
  final FlutterLocalNotificationsPlugin plugin;
  final NotificationTokenManager tokenManager;
  final NotificationBadgeService badgeService;
  final NotificationRepository repository;
  final NotificationPushHandler pushHandler;

  /// The signed-in user, or null. Held here rather than re-read from the auth
  /// bloc because a push can arrive on either side of login, and because the
  /// deep-link router needs the full entity (roles, linked children) to decide
  /// what this user may open.
  UserEntity? _user;

  bool _channelsRegistered = false;

  NotificationCoordinator({
    required this.plugin,
    required this.tokenManager,
    required this.badgeService,
    required this.repository,
    required this.pushHandler,
  });

  UserEntity? get user => _user;

  /// Tenant/recipient pair the push handler matches inbound messages against.
  ({String schoolId, String userId})? get session {
    final current = _user;
    if (current == null) return null;
    return (schoolId: current.schoolId, userId: current.id);
  }

  /// Startup work that does not need a signed-in user.
  ///
  /// Called before `runApp`, so it must stay fast and must not throw - a
  /// failure here would otherwise block the app from painting at all.
  Future<void> initialize() async {
    try {
      await NotificationChannels.registerAll(plugin);
      _channelsRegistered = true;
    } catch (e) {
      _log('channel registration failed', e);
    }

    try {
      pushHandler.start();
    } catch (e) {
      _log('push handler failed to start', e);
    }
  }

  /// Handles a cold launch caused by tapping a notification.
  ///
  /// Kept out of [initialize] and awaited separately so a slow or hanging FCM
  /// call cannot delay first paint.
  Future<void> checkInitialMessage() => pushHandler.checkInitialMessage();

  /// Called when a user signs in, and on session restore.
  ///
  /// Ordering matters: the session is recorded first so an inbound push can be
  /// matched against it, then the device registers, then the badge starts, and
  /// only then is a stashed deep link replayed - by which point navigation has
  /// somewhere valid to go.
  Future<void> onSignedIn(UserEntity user) async {
    // Re-running for the same user (a session restore, or a rebuild) would
    // otherwise re-request permission and restart the badge stream.
    if (_user?.id == user.id) return;

    _user = user;
    final schoolId = user.schoolId;
    final userId = user.id;

    if (!_channelsRegistered) {
      // A first run that failed above still gets channels once the user is in.
      await initialize();
    }

    unawaited(_registerDevice(schoolId: schoolId, userId: userId));

    badgeService.start(schoolId: schoolId, userId: userId);

    // Push whatever the user did while offline, then drop rows past their
    // retention window.
    unawaited(repository.syncPendingStateChanges(
      schoolId: schoolId,
      recipientUserId: userId,
    ));
    unawaited(repository.purgeExpired(
      schoolId: schoolId,
      recipientUserId: userId,
    ));

    unawaited(pushHandler.replayPendingDeepLink());
  }

  Future<void> _registerDevice({
    required String schoolId,
    required String userId,
  }) async {
    try {
      // Finish any revocation that could not reach the server during a
      // previous offline sign-out, before publishing a new token.
      await tokenManager.drainPendingRevocations();

      final granted = await tokenManager.requestPermission();
      if (!granted) {
        _log('push permission not granted', 'in-app notifications still work');
        return;
      }

      await tokenManager.registerDevice(schoolId: schoolId, userId: userId);
      tokenManager.startListening(
        currentUserId: () => _user?.id ?? '',
        currentSchoolId: () => _user?.schoolId ?? '',
      );
    } catch (e) {
      _log('device registration failed', e);
    }
  }

  /// Called on sign-out.
  ///
  /// Revoking the token is what actually stops delivery, and clearing the tray
  /// is what stops the next person on a shared device seeing the previous
  /// user's alerts.
  Future<void> onSignedOut() async {
    final previous = _user;
    _user = null;

    await badgeService.clear();
    await badgeService.dispose();
    PendingDeepLink.clear();

    if (previous == null) return;

    try {
      await tokenManager.revokeForUser(previous.id);
    } catch (e) {
      _log('token revocation failed', e);
    }
  }

  /// Clears transient notifications for a source - the hook the messaging
  /// module calls when a conversation is opened, so its chat pings stop
  /// cluttering the centre and the tray.
  Future<void> clearTransientForSource({
    required String sourceModule,
    required String sourceEntityId,
  }) {
    return pushHandler.clearForSource(
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
    );
  }

  Future<void> dispose() async {
    await pushHandler.dispose();
    await badgeService.dispose();
    await tokenManager.dispose();
  }

  static void _log(String message, Object detail) {
    if (kDebugMode) debugPrint('[notifications] $message: $detail');
  }
}
