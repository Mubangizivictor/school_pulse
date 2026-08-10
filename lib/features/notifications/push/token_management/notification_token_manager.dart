import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../data/models/notification_token_isar.dart';

/// Owns this device's FCM registration token.
///
/// Tokens live at `users/{uid}/tokens/{token}`. Registration intentionally
/// performs a cheap merge on every authenticated session: an old version
/// trusted the Isar cache and could skip the Firestore write even when the
/// server token document had been deleted, leaving push permanently broken.
class NotificationTokenManager {
  final FirebaseMessaging messaging;
  final FirebaseFirestore firestore;
  final Isar isar;

  StreamSubscription<String>? _refreshSub;

  NotificationTokenManager({
    required this.messaging,
    required this.firestore,
    required this.isar,
  });

  void startListening({
    required String Function() currentUserId,
    required String Function() currentSchoolId,
  }) {
    _refreshSub?.cancel();
    _refreshSub = messaging.onTokenRefresh.listen((token) async {
      final uid = currentUserId();
      if (uid.isEmpty) return;
      await _publish(token: token, userId: uid, schoolId: currentSchoolId());
    });
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      _log('permission request failed', e);
      return false;
    }
  }

  Future<bool> registerDevice({
    required String userId,
    required String schoolId,
  }) async {
    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      _log('FCM token unavailable', e);
      return false;
    }
    if (token == null || token.isEmpty) return false;

    // Always refresh the server registration on sign-in/session restore.
    // This is deliberately self-healing if a server token doc was cleaned up.
    return _publish(token: token, userId: userId, schoolId: schoolId);
  }

  Future<bool> _publish({
    required String token,
    required String userId,
    required String schoolId,
  }) async {
    final now = DateTime.now();
    final row = NotificationTokenIsar.create(
      token: token,
      userId: userId,
      schoolId: schoolId,
      platform: _platformName,
      lastSeenAt: now,
    );

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('tokens')
          .doc(token)
          .set({
            'token': token,
            'schoolId': schoolId,
            'platform': _platformName,
            'app': 'school_pulse',
            'enabled': true,
            'lastSeenAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      row.publishedAt = now;
      _log('FCM token registered', '$userId / $_platformName');
    } catch (e) {
      _log('FCM token publish failed', e);
    }

    await isar.writeTxn(() async {
      final existing = await isar.notificationTokenIsars
          .filter()
          .tokenEqualTo(token)
          .and()
          .userIdEqualTo(userId)
          .findFirst();
      if (existing != null) {
        existing.lastSeenAt = now;
        existing.publishedAt = row.publishedAt ?? existing.publishedAt;
        existing.pendingRevocation = false;
        await isar.notificationTokenIsars.put(existing);
      } else {
        await isar.notificationTokenIsars.put(row);
      }
    });

    return row.publishedAt != null;
  }

  Future<void> revokeForUser(String userId) async {
    final rows = await isar.notificationTokenIsars
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    if (rows.isEmpty) return;

    for (final row in rows) {
      var revoked = false;
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('tokens')
            .doc(row.token)
            .delete();
        revoked = true;
      } catch (e) {
        _log('token revocation deferred for $userId', e);
      }

      await isar.writeTxn(() async {
        if (revoked) {
          await isar.notificationTokenIsars.delete(row.id);
        } else {
          row.pendingRevocation = true;
          await isar.notificationTokenIsars.put(row);
        }
      });
    }

    for (final row in rows) {
      for (final topic in row.subscribedTopics) {
        try {
          await messaging.unsubscribeFromTopic(topic);
        } catch (e) {
          _log('topic unsubscribe failed for $topic', e);
        }
      }
    }
  }

  Future<int> drainPendingRevocations() async {
    final pending = await isar.notificationTokenIsars
        .filter()
        .pendingRevocationEqualTo(true)
        .findAll();

    var drained = 0;
    for (final row in pending) {
      try {
        await firestore
            .collection('users')
            .doc(row.userId)
            .collection('tokens')
            .doc(row.token)
            .delete();
        await isar.writeTxn(() async {
          await isar.notificationTokenIsars.delete(row.id);
        });
        drained++;
      } catch (e) {
        _log('revocation retry failed', e);
      }
    }
    return drained;
  }

  Future<void> syncTopics({
    required String userId,
    required Set<String> desiredTopics,
  }) async {
    final row = await isar.notificationTokenIsars
        .filter()
        .userIdEqualTo(userId)
        .sortByLastSeenAtDesc()
        .findFirst();
    if (row == null) return;

    final current = row.subscribedTopics.toSet();
    final toAdd = desiredTopics.difference(current);
    final toRemove = current.difference(desiredTopics);
    final applied = <String>{...current};

    for (final topic in toAdd) {
      try {
        await messaging.subscribeToTopic(topic);
        applied.add(topic);
      } catch (e) {
        _log('subscribe failed for $topic', e);
      }
    }
    for (final topic in toRemove) {
      try {
        await messaging.unsubscribeFromTopic(topic);
        applied.remove(topic);
      } catch (e) {
        _log('unsubscribe failed for $topic', e);
      }
    }

    await isar.writeTxn(() async {
      row.subscribedTopics = applied.toList();
      await isar.notificationTokenIsars.put(row);
    });
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
  }

  static String get _platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static void _log(String message, Object detail) {
    if (kDebugMode) debugPrint('[notifications] $message: $detail');
  }
}
