import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/owner_session.dart';

/// Reads and writes the SaaS owner's device/session registry, nested under
/// the existing `super_admin_settings/{ownerId}` doc as a `sessions`
/// subcollection - same ownership convention as the sibling `security`
/// sub-map on the parent doc, just one level deeper since this is a list of
/// records rather than a single map of preferences.
abstract class OwnerSessionRemoteDataSource {
  /// Streams all known devices for [ownerId], most-recently-active first.
  Stream<List<OwnerSession>> watchSessions(String ownerId);

  /// Creates or updates the session doc for this device on sign-in / resume.
  /// `createdAt` is only set with `FieldValue.serverTimestamp()` the first
  /// time (via `SetOptions(merge: true)` plus a conditional field), so
  /// repeat calls only bump `lastActiveAt`.
  Future<void> upsertSession({
    required String ownerId,
    required String deviceId,
    required String platform,
    required String deviceName,
    required bool isNewSession,
  });

  /// Cheap heartbeat - only touches `lastActiveAt`.
  Future<void> touchLastActive({
    required String ownerId,
    required String deviceId,
  });

  /// Security-sensitive: routed through the owner-only `setOwnerDeviceTrust`
  /// callable, which re-checks the canonical owner boundary and writes an
  /// audit record. [deviceName] optionally renames the device on the same
  /// write.
  Future<void> setTrusted({
    required String ownerId,
    required String deviceId,
    required bool trusted,
    String? deviceName,
  });

  /// Removes a device doc entirely, revoking its trust and dropping it from
  /// the registry. Security-sensitive: routed through the owner-only
  /// `revokeOwnerDevice` callable (audit + owner-token disable). The current
  /// device cannot be revoked here.
  Future<void> removeSession({
    required String ownerId,
    required String deviceId,
    String? currentDeviceId,
  });
}

class OwnerSessionRemoteDataSourceImpl implements OwnerSessionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  OwnerSessionRemoteDataSourceImpl({
    required this.firestore,
    FirebaseFunctions? functions,
  }) : functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  CollectionReference<Map<String, dynamic>> _sessions(String ownerId) =>
      firestore
          .collection('super_admin_settings')
          .doc(ownerId)
          .collection('sessions');

  @override
  Stream<List<OwnerSession>> watchSessions(String ownerId) {
    return _sessions(ownerId)
        .orderBy('lastActiveAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OwnerSession.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> upsertSession({
    required String ownerId,
    required String deviceId,
    required String platform,
    required String deviceName,
    required bool isNewSession,
  }) async {
    final doc = _sessions(ownerId).doc(deviceId);
    final data = <String, dynamic>{
      'platform': platform,
      'deviceName': deviceName,
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    if (isNewSession) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['trusted'] = false;
    }
    await doc.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> touchLastActive({
    required String ownerId,
    required String deviceId,
  }) async {
    await _sessions(ownerId).doc(deviceId).set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> setTrusted({
    required String ownerId,
    required String deviceId,
    required bool trusted,
    String? deviceName,
  }) async {
    await functions.httpsCallable('setOwnerDeviceTrust').call({
      'deviceId': deviceId,
      'trusted': trusted,
      if (deviceName != null && deviceName.trim().isNotEmpty)
        'deviceName': deviceName.trim(),
    });
  }

  @override
  Future<void> removeSession({
    required String ownerId,
    required String deviceId,
    String? currentDeviceId,
  }) async {
    final payload = <String, dynamic>{'deviceId': deviceId};
    if (currentDeviceId != null) payload['currentDeviceId'] = currentDeviceId;
    await functions.httpsCallable('revokeOwnerDevice').call(payload);
  }
}
