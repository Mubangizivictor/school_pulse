import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../data/models/notification_token_isar.dart';

/// Owns this device's FCM registration token.
///
/// Responsibilities:
///  - publish the token under the signed-in user so server-side fan-out can
///    target them,
///  - keep it fresh across token rotation,
///  - support several devices per user and several users per device,
///  - revoke it on sign-out so the next person on a shared device does not
///    receive the previous user's notifications.
///
/// Tokens live at `users/{uid}/tokens/{token}`, matching where the existing
/// Cloud Functions already look them up.
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

  /// Starts listening for token rotation. FCM rotates tokens on reinstall,
  /// restore and periodically; without this the server keeps pushing to a
  /// token the device no longer answers to.
  void startListening({
    required String Function() currentUserId,
    required String Function() currentSchoolId,
  }) {
    _refreshSub?.cancel();
    _refreshSub = messaging.onTokenRefresh.listen((token) async {
      final uid = currentUserId();
      if (uid.isEmpty) return;
      await _publish(
        token: token,
        userId: uid,
        schoolId: currentSchoolId(),
      );
    });
  }

  /// Requests notification permission from the OS.
  ///
  /// Returns whether push may be used. A denial is a normal outcome, not an
  /// error - the in-app notification centre still works without it.
  Future<bool> requestPermission() async {
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      _log('permission request failed', e);
      return false;
    }
  }

  /// Registers the current device for [userId].
  ///
  /// Skips the Firestore write when this exact token is already published for
  /// this user - otherwise every cold start costs a write per user for no
  /// change.
  Future<bool> registerDevice({
    required String userId,
    required String schoolId,
  }) async {
    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      // Expected on iOS simulators, which have no APNs token. Not a failure
      // worth surfacing - the rest of the app works fine without push.
      _log('token unavailable (expected on simulators)', e);
      return false;
    }

    if (token == null || token.isEmpty) return false;

    final cached = await isar.notificationTokenIsars
        .filter()
        .tokenEqualTo(token)
        .and()
        .userIdEqualTo(userId)
        .findFirst();

    if (cached != null && !cached.needsPublishing) {
      // Already published; just record that it is still live.
      await isar.writeTxn(() async {
        cached.lastSeenAt = DateTime.now();
        await isar.notificationTokenIsars.put(cached);
      });
      return true;
    }

    return _publish(token: token, userId: userId, schoolId: schoolId);
  }

  Future<bool> _publish({
    required String token,
    required String userId,
    required String schoolId,
  }) async {
    final row = NotificationTokenIsar.create(
      token: token,
      userId: userId,
      schoolId: schoolId,
      platform: _platformName,
      lastSeenAt: DateTime.now(),
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
        'updatedAt': FieldValue.serverTimestamp(),
        // Written on first publish only, so the server can age out tokens that
        // have not been seen for a long time.
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      row.publishedAt = DateTime.now();
    } catch (e) {
      // Leave publishedAt null so the next registerDevice retries.
      _log('token publish failed, will retry', e);
    }

    await isar.writeTxn(() async {
      await isar.notificationTokenIsars.put(row);
    });

    return row.publishedAt != null;
  }

  /// Removes this device's token for [userId] on sign-out.
  ///
  /// Deleting the server document is what actually stops delivery. If that
  /// write fails (offline sign-out), the row is flagged so
  /// [drainPendingRevocations] finishes the job once connectivity returns -
  /// otherwise a signed-out user keeps receiving another tenant's alerts.
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

    // Unsubscribe from topics so broadcasts stop reaching this device too.
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

  /// Completes revocations that could not reach the server earlier.
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

  /// Applies the difference between current and desired topic subscriptions.
  ///
  /// Only the delta is applied, so a cold start does not re-subscribe to every
  /// topic - each subscribe is a network round trip.
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

  static void _log(String message, Object error) {
    if (kDebugMode) debugPrint('[notifications] $message: $error');
  }
}
