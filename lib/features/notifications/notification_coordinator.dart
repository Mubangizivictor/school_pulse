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
class NotificationCoordinator {
  final FlutterLocalNotificationsPlugin plugin;
  final NotificationTokenManager tokenManager;
  final NotificationBadgeService badgeService;
  final NotificationRepository repository;
  final NotificationPushHandler pushHandler;

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

  ({String schoolId, String userId})? get session {
    final current = _user;
    if (current == null) return null;
    return (schoolId: current.schoolId, userId: current.id);
  }

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

  Future<void> checkInitialMessage() => pushHandler.checkInitialMessage();

  Future<void> onSignedIn(UserEntity user) async {
    if (_user?.id == user.id) return;

    _user = user;
    final schoolId = user.schoolId;
    final userId = user.id;

    if (!_channelsRegistered) await initialize();

    unawaited(
      _registerDevice(
        schoolId: schoolId,
        userId: userId,
        platformOwner: user.roles.contains(UserRole.superAdmin),
      ),
    );

    badgeService.start(schoolId: schoolId, userId: userId);

    unawaited(
      repository.syncPendingStateChanges(
        schoolId: schoolId,
        recipientUserId: userId,
      ),
    );
    unawaited(
      repository.purgeExpired(schoolId: schoolId, recipientUserId: userId),
    );
    unawaited(pushHandler.replayPendingDeepLink());
  }

  Future<void> _registerDevice({
    required String schoolId,
    required String userId,
    required bool platformOwner,
  }) async {
    try {
      await tokenManager.drainPendingRevocations();

      final granted = await tokenManager.requestPermission();
      if (!granted) {
        _log('push permission not granted', 'in-app notifications still work');
        return;
      }

      final registered = await tokenManager.registerDevice(
        schoolId: schoolId,
        userId: userId,
        platformOwner: platformOwner,
      );
      _log(
        platformOwner ? 'SaaS Owner push registration' : 'push registration',
        registered ? 'ready' : 'not ready',
      );

      tokenManager.startListening(
        currentUserId: () => _user?.id ?? '',
        currentSchoolId: () => _user?.schoolId ?? '',
        isPlatformOwner: () =>
            _user?.roles.contains(UserRole.superAdmin) ?? false,
      );
    } catch (e) {
      _log('device registration failed', e);
    }
  }

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
