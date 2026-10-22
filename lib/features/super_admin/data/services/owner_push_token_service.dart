import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// FCM device-token registration for **owner-only** notifications.
///
/// This is a thin client over the pre-existing, already-deployed canonical
/// registry: the `registerOwnerNotificationDevice` /
/// `unregisterOwnerNotificationDevice` callables
/// (`public_functions/owner_device_registry.js`), which is the *only* token
/// source `owner_notification_engine.js`'s send path actually reads
/// (`platform_owner_device_tokens`, plus a `users/{uid}/tokens` mirror for
/// rule-independent lookup). Writing anywhere else would be invisible to
/// the server's push send — this client intentionally does not maintain a
/// separate Firestore token store of its own.
///
/// The push payload contract this implies:
///  * data-only messages (no `notification` block) so the client fully
///    controls lock-screen text;
///  * lock-screen text is a redacted category label only — never a tenant
///    record, payment reference, amount, credential, raw error or stack
///    trace (enforced server-side in `pushData()`).
class OwnerPushTokenService {
  OwnerPushTokenService({
    FirebaseAuth? auth,
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  String? get _ownerId => _auth.currentUser?.uid;

  String get _platformTag {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
      if (Platform.isMacOS) return 'macos';
    } catch (_) {}
    return 'other';
  }

  /// Registers this device's FCM token for the signed-in owner via the
  /// canonical `registerOwnerNotificationDevice` callable. No-ops when
  /// nobody is signed in or no token is available yet. Safe to call on
  /// every owner-console entry and on token refresh.
  Future<void> registerCurrentDevice() async {
    if (_ownerId == null) return;
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (_) {
      return;
    }
    if (token == null || token.isEmpty) return;
    await _register(token);
  }

  /// Keeps the token fresh. Wire this to
  /// `FirebaseMessaging.onTokenRefresh` from the owner shell.
  Stream<void> get onTokenRefresh =>
      _messaging.onTokenRefresh.asyncMap((token) async {
        if (_ownerId == null || token.isEmpty) return;
        await _register(token);
      });

  Future<void> _register(String token) async {
    String appVersion = '';
    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      // Best-effort only; the callable accepts an empty appVersion.
    }
    try {
      await _functions.httpsCallable('registerOwnerNotificationDevice').call({
        'token': token,
        'platform': _platformTag,
        'appVersion': appVersion,
      });
    } catch (_) {
      // Best-effort: a transient failure here should never block opening
      // the owner console.
    }
  }

  /// Removes this device's token via `unregisterOwnerNotificationDevice`.
  /// Call on logout / account switch / role loss / session revocation so a
  /// former owner device stops receiving owner push.
  Future<void> unregisterCurrentDevice() async {
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (_) {
      token = null;
    }
    if (token == null || token.isEmpty) return;
    try {
      await _functions
          .httpsCallable('unregisterOwnerNotificationDevice')
          .call({'token': token});
    } catch (_) {
      // Best-effort; a denied call after role loss is expected and fine.
    }
  }
}
