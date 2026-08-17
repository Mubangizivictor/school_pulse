import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/verification_cache_records.dart';
import 'verification_local_data_source.dart';

VerificationLocalDataSource create({dynamic isar, dynamic remote}) =>
    VerificationLocalDataSourceWeb(remote as FirebaseFirestore);

/// No local database on web, no offline gate-scanning use case - reads and
/// writes go straight to the same Firestore collections the mobile Isar
/// cache mirrors (schools/{schoolId}/credentials, revoked_credentials,
/// verification_events). Device authorization and permission snapshots are
/// mobile-only offline-continuity concerns with no web equivalent, so
/// those two return null/no-op. getUnsyncedEvents/markEventSynced are
/// no-ops/empty since every write already went straight to the server.
class VerificationLocalDataSourceWeb implements VerificationLocalDataSource {
  final FirebaseFirestore firestore;

  VerificationLocalDataSourceWeb(this.firestore);

  CollectionReference<Map<String, dynamic>> _credentials(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('credentials');

  CollectionReference<Map<String, dynamic>> _revocations(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('revoked_credentials');

  CollectionReference<Map<String, dynamic>> _events(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('verification_events');

  @override
  Future<CachedCredential?> findCredential(
    String credentialValue,
    String schoolId,
  ) async {
    final doc = await _credentials(schoolId).doc(credentialValue).get();
    if (!doc.exists) return null;
    return _credentialFromMap(doc.data()!);
  }

  @override
  Future<void> cacheCredential(CachedCredential credential) async {
    await _credentials(
      credential.schoolId,
    ).doc(credential.credentialValue).set({
      'credentialValue': credential.credentialValue,
      'credentialType': credential.credentialType,
      'identityId': credential.identityId,
      'identityType': credential.identityType,
      'schoolId': credential.schoolId,
      'status': credential.status,
      'updatedAt': credential.updatedAt.toIso8601String(),
      'credentialVersion': credential.credentialVersion,
    });
  }

  @override
  Future<CachedCredential?> findCredentialByIdentity(
    String identityId,
    String schoolId,
  ) async {
    final snapshot = await _credentials(schoolId)
        .where('identityId', isEqualTo: identityId)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _credentialFromMap(snapshot.docs.first.data());
  }

  CachedCredential _credentialFromMap(Map<String, dynamic> data) =>
      CachedCredential(
        credentialValue: data['credentialValue'] as String,
        credentialType: data['credentialType'] as String,
        identityId: data['identityId'] as String,
        identityType: data['identityType'] as String,
        schoolId: data['schoolId'] as String,
        status: data['status'] as String,
        updatedAt: DateTime.parse(data['updatedAt'] as String),
        credentialVersion: data['credentialVersion'] as int? ?? 1,
      );

  @override
  Future<RevokedCredential?> findRevocation(
    String credentialValue,
    String schoolId,
  ) async {
    final doc = await _revocations(schoolId).doc(credentialValue).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return RevokedCredential(
      credentialValue: data['credentialValue'] as String,
      schoolId: data['schoolId'] as String,
      revokedAt: DateTime.parse(data['revokedAt'] as String),
      reason: data['reason'] as String,
    );
  }

  @override
  Future<void> saveRevocation(RevokedCredential revocation) async {
    await _revocations(
      revocation.schoolId,
    ).doc(revocation.credentialValue).set({
      'credentialValue': revocation.credentialValue,
      'schoolId': revocation.schoolId,
      'revokedAt': revocation.revokedAt.toIso8601String(),
      'reason': revocation.reason,
    });
  }

  @override
  Future<void> deleteRevocation(String credentialValue, String schoolId) async {
    await _revocations(schoolId).doc(credentialValue).delete();
  }

  @override
  Future<OperatorPermissionSnapshot?> getPermissionSnapshot(
    String operatorId,
  ) async => null;

  @override
  Future<void> savePermissionSnapshot(
    OperatorPermissionSnapshot snapshot,
  ) async {}

  @override
  Future<void> clearPermissionSnapshot(String operatorId) async {}

  @override
  Future<AuthorizedDevice?> findDevice(
    String deviceId,
    String schoolId,
  ) async => null;

  @override
  Future<void> saveVerificationEvent(VerificationEvent event) async {
    await _events(event.schoolId).doc(event.eventId).set({
      'eventId': event.eventId,
      'schoolId': event.schoolId,
      'gateId': event.gateId,
      'operatorId': event.operatorId,
      'credentialKind': event.credentialKind,
      'identityId': event.identityId,
      'identityType': event.identityType,
      'outcome': event.outcome,
      'reasonCode': event.reasonCode,
      'direction': event.direction,
      'timestamp': event.timestamp.toIso8601String(),
      'deviceId': event.deviceId,
      'isSynced': true,
    });
  }

  @override
  Future<List<VerificationEvent>> getUnsyncedEvents() async => [];

  @override
  Future<void> markEventSynced(String eventId) async {}

  @override
  Future<List<VerificationEvent>> getTodayEventsForGate(
    String gateId,
    String schoolId,
  ) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final snapshot = await _events(schoolId)
        .where('gateId', isEqualTo: gateId)
        .where('timestamp', isGreaterThan: startOfDay.toIso8601String())
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VerificationEvent(
        eventId: data['eventId'] as String,
        schoolId: data['schoolId'] as String,
        gateId: data['gateId'] as String,
        operatorId: data['operatorId'] as String,
        credentialKind: data['credentialKind'] as String,
        identityId: data['identityId'] as String,
        identityType: data['identityType'] as String,
        outcome: data['outcome'] as String,
        reasonCode: data['reasonCode'] as String?,
        direction: data['direction'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
        deviceId: data['deviceId'] as String,
        isSynced: true,
      );
    }).toList();
  }
}
