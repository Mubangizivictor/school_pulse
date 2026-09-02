import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Dedicated FCM device-token store for **owner-only** notifications.
///
/// Completely separate from `NotificationService` / `NotificationTokenManager`
/// and the `users/{uid}/tokens/{token}` path they use for school-role
/// devices. Owner push tokens live at:
///
///   `super_admin_notification_tokens/{ownerUid}/devices/{token}`
///
/// Rules deny read/write to every non-superAdmin, and only permit a
/// superAdmin to touch the subtree under their *own* uid. Nothing here is
/// ever consulted by a school-role code path.
///
/// The push payload contract this store implies:
///  * data-only messages (no `notification` block) so the client fully
///    controls lock-screen text;
///  * lock-screen text is a redacted category label only — never a tenant
///    record, payment reference, amount, credential, raw error or stack
///    trace.
class OwnerPushTokenService {
  OwnerPushTokenService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;

  static const rootCollection = 'super_admin_notification_tokens';
  static const devicesSub = 'devices';

  String? get _ownerId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _devices(String ownerId) =>
      _firestore.collection(rootCollection).doc(ownerId).collection(devicesSub);

  String get _platformTag {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
      if (Platform.isMacOS) return 'macos';
    } catch (_) {}
    return 'other';
  }

  /// Registers this device's FCM token for the signed-in owner. No-ops when
  /// nobody is signed in or no token is available yet. Safe to call on every
  /// owner-console entry and on token refresh.
  Future<void> registerCurrentDevice() async {
    final ownerId = _ownerId;
    if (ownerId == null) return;
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (_) {
      return;
    }
    if (token == null || token.isEmpty) return;
    await _devices(ownerId).doc(token).set({
      'token': token,
      'ownerId': ownerId,
      'platform': _platformTag,
      'dataOnly': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Keeps the token fresh. Wire this to
  /// `FirebaseMessaging.onTokenRefresh` from the owner shell.
  Stream<void> get onTokenRefresh =>
      _messaging.onTokenRefresh.asyncMap((token) async {
        final ownerId = _ownerId;
        if (ownerId == null || token.isEmpty) return;
        await _devices(ownerId).doc(token).set({
          'token': token,
          'ownerId': ownerId,
          'platform': _platformTag,
          'dataOnly': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

  /// Removes this device's token for [ownerId] (defaults to the signed-in
  /// owner). Call on logout / account switch / role loss / session
  /// revocation so a former owner device stops receiving owner push.
  Future<void> unregisterCurrentDevice({String? ownerId}) async {
    final id = ownerId ?? _ownerId;
    if (id == null) return;
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (_) {
      token = null;
    }
    try {
      if (token != null && token.isNotEmpty) {
        await _devices(id).doc(token).delete();
      } else {
        // Token unavailable (already deleted) — drop the whole device set
        // for this owner from this client's perspective.
        final snap = await _devices(id).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }
    } catch (_) {
      // Best-effort; a denied delete after role loss is expected and fine.
    }
  }
}
