import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'token_local_cache.dart';

/// Owns this device's FCM registration token.
///
/// Every authenticated device is mirrored at `users/{uid}/tokens/{token}`.
/// SaaS Owner devices are ALSO registered through an authenticated Cloud
/// Function into `platform_owner_device_tokens`; this removes Firestore-rule
/// drift from the critical application/payment push path.
class NotificationTokenManager {
  final FirebaseMessaging messaging;
  final FirebaseFirestore firestore;
  final TokenLocalCache localCache;

  StreamSubscription<String>? _refreshSub;

  NotificationTokenManager({
    required this.messaging,
    required this.firestore,
    required this.localCache,
  });

  void startListening({
    required String Function() currentUserId,
    required String Function() currentSchoolId,
    bool Function()? isPlatformOwner,
  }) {
    _refreshSub?.cancel();
    _refreshSub = messaging.onTokenRefresh.listen((token) async {
      final uid = currentUserId();
      if (uid.isEmpty) return;
      await _publish(
        token: token,
        userId: uid,
        schoolId: currentSchoolId(),
        platformOwner: isPlatformOwner?.call() ?? false,
      );
    });
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      _log('notification permission', settings.authorizationStatus.name);
      return granted;
    } catch (e) {
      _log('permission request failed', e);
      return false;
    }
  }

  Future<bool> registerDevice({
    required String userId,
    required String schoolId,
    bool platformOwner = false,
  }) async {
    // On Apple platforms Firebase cannot mint an FCM token until APNs has
    // assigned one. A one-shot getToken() during startup races that handshake
    // and was a frequent reason owner devices never registered at all.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsReady = await _waitForApnsToken();
      if (!apnsReady) {
        _log('APNs token unavailable', 'push registration deferred');
        return false;
      }
    }

    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      _log('FCM token unavailable', e);
      return false;
    }
    if (token == null || token.isEmpty) return false;

    return _publish(
      token: token,
      userId: userId,
      schoolId: schoolId,
      platformOwner: platformOwner,
    );
  }

  Future<bool> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 12; attempt++) {
      try {
        final token = await messaging.getAPNSToken();
        if (token != null && token.isNotEmpty) {
          _log('APNs token ready', 'attempt ${attempt + 1}');
          return true;
        }
      } catch (e) {
        if (attempt == 11) _log('APNs token lookup failed', e);
      }
      await Future<void>.delayed(const Duration(milliseconds: 750));
    }
    return false;
  }

  Future<bool> _publish({
    required String token,
    required String userId,
    required String schoolId,
    required bool platformOwner,
  }) async {
    final now = DateTime.now();

    var normalPublished = false;
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
            'app': platformOwner ? 'school_pulse_owner' : 'school_pulse',
            'enabled': true,
            'lastSeenAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      normalPublished = true;
      _log('FCM token registered', '$userId / $_platformName');
    } catch (e) {
      _log('FCM token Firestore publish failed', e);
    }

    var ownerPublished = !platformOwner;
    if (platformOwner) {
      ownerPublished = await _registerOwnerToken(token);
    }

    final publishedAt = (normalPublished || ownerPublished) ? now : null;

    final existing = await localCache.findByTokenAndUser(token, userId);
    if (existing != null) {
      existing.lastSeenAt = now;
      existing.publishedAt = publishedAt ?? existing.publishedAt;
      existing.pendingRevocation = false;
      await localCache.upsert(existing);
    } else {
      await localCache.upsert(
        TokenRecord(
          token: token,
          userId: userId,
          schoolId: schoolId,
          platform: _platformName,
          lastSeenAt: now,
          publishedAt: publishedAt,
        ),
      );
    }

    return platformOwner ? ownerPublished : normalPublished;
  }

  Future<bool> _registerOwnerToken(String token) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('registerOwnerNotificationDevice');
      final result = await callable.call<Map<String, dynamic>>({
        'token': token,
        'platform': _platformName,
      });
      final ok = result.data['ok'] == true;
      _log('SaaS Owner token registry', ok ? 'registered' : result.data);
      return ok;
    } catch (e) {
      _log('SaaS Owner token registry failed', e);
      return false;
    }
  }

  Future<void> revokeForUser(String userId) async {
    final rows = await localCache.findByUser(userId);
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

      // This call only succeeds while Firebase Auth is still valid. If logout
      // has already completed, the invalid/expired FCM token cleanup in the
      // server fan-out remains the final safety net.
      try {
        final callable = FirebaseFunctions.instanceFor(
          region: 'europe-west1',
        ).httpsCallable('unregisterOwnerNotificationDevice');
        await callable.call<Map<String, dynamic>>({'token': row.token});
      } catch (_) {}

      if (revoked) {
        await localCache.deleteByToken(row.token, userId);
      } else {
        row.pendingRevocation = true;
        await localCache.upsert(row);
      }
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
    final pending = await localCache.findPendingRevocations();

    var drained = 0;
    for (final row in pending) {
      try {
        await firestore
            .collection('users')
            .doc(row.userId)
            .collection('tokens')
            .doc(row.token)
            .delete();
        await localCache.deleteByToken(row.token, row.userId);
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
    final row = await localCache.mostRecentForUser(userId);
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

    row.subscribedTopics = applied.toList();
    await localCache.upsert(row);
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
