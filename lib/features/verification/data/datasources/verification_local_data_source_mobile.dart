import 'package:isar/isar.dart';
import '../../domain/entities/verification_cache_records.dart';
import '../models/verification_isar_models.dart';
import 'verification_local_data_source.dart';

VerificationLocalDataSource create({dynamic isar, dynamic remote}) =>
    VerificationLocalDataSourceImpl(isar as Isar);

CachedCredential _credentialToPlain(CachedCredentialIsar c) => CachedCredential(
  credentialValue: c.credentialValue,
  credentialType: c.credentialType,
  identityId: c.identityId,
  identityType: c.identityType,
  schoolId: c.schoolId,
  status: c.status,
  updatedAt: c.updatedAt,
);

CachedCredentialIsar _credentialToIsar(CachedCredential c) =>
    CachedCredentialIsar()
      ..credentialValue = c.credentialValue
      ..credentialType = c.credentialType
      ..identityId = c.identityId
      ..identityType = c.identityType
      ..schoolId = c.schoolId
      ..status = c.status
      ..updatedAt = c.updatedAt;

RevokedCredential _revocationToPlain(RevokedCredentialIsar r) =>
    RevokedCredential(
      credentialValue: r.credentialValue,
      schoolId: r.schoolId,
      revokedAt: r.revokedAt,
      reason: r.reason,
    );

RevokedCredentialIsar _revocationToIsar(RevokedCredential r) =>
    RevokedCredentialIsar()
      ..credentialValue = r.credentialValue
      ..schoolId = r.schoolId
      ..revokedAt = r.revokedAt
      ..reason = r.reason;

OperatorPermissionSnapshot _snapshotToPlain(OperatorPermissionSnapshotIsar s) =>
    OperatorPermissionSnapshot(
      operatorId: s.operatorId,
      schoolId: s.schoolId,
      permissionIds: s.permissionIds,
      version: s.version,
      expiresAt: s.expiresAt,
    );

OperatorPermissionSnapshotIsar _snapshotToIsar(OperatorPermissionSnapshot s) =>
    OperatorPermissionSnapshotIsar()
      ..operatorId = s.operatorId
      ..schoolId = s.schoolId
      ..permissionIds = s.permissionIds
      ..version = s.version
      ..expiresAt = s.expiresAt;

AuthorizedDevice _deviceToPlain(AuthorizedDeviceIsar d) => AuthorizedDevice(
  deviceId: d.deviceId,
  schoolId: d.schoolId,
  gateId: d.gateId,
  label: d.label,
  isActive: d.isActive,
  registeredAt: d.registeredAt,
);

VerificationEvent _eventToPlain(VerificationEventIsar e) => VerificationEvent(
  eventId: e.eventId,
  schoolId: e.schoolId,
  gateId: e.gateId,
  operatorId: e.operatorId,
  credentialKind: e.credentialKind,
  identityId: e.identityId,
  identityType: e.identityType,
  outcome: e.outcome,
  reasonCode: e.reasonCode,
  direction: e.direction,
  timestamp: e.timestamp,
  deviceId: e.deviceId,
  isSynced: e.isSynced,
);

VerificationEventIsar _eventToIsar(VerificationEvent e) =>
    VerificationEventIsar()
      ..eventId = e.eventId
      ..schoolId = e.schoolId
      ..gateId = e.gateId
      ..operatorId = e.operatorId
      ..credentialKind = e.credentialKind
      ..identityId = e.identityId
      ..identityType = e.identityType
      ..outcome = e.outcome
      ..reasonCode = e.reasonCode
      ..direction = e.direction
      ..timestamp = e.timestamp
      ..deviceId = e.deviceId
      ..isSynced = e.isSynced;

class VerificationLocalDataSourceImpl implements VerificationLocalDataSource {
  final Isar isar;

  VerificationLocalDataSourceImpl(this.isar);

  @override
  Future<CachedCredential?> findCredential(
    String credentialValue,
    String schoolId,
  ) async {
    final found = await isar.cachedCredentialIsars
        .filter()
        .credentialValueEqualTo(credentialValue)
        .schoolIdEqualTo(schoolId)
        .findFirst();
    return found == null ? null : _credentialToPlain(found);
  }

  @override
  Future<void> cacheCredential(CachedCredential credential) async {
    await isar.writeTxn(() async {
      await isar.cachedCredentialIsars.put(_credentialToIsar(credential));
    });
  }

  @override
  Future<CachedCredential?> findCredentialByIdentity(
    String identityId,
    String schoolId,
  ) async {
    final found = await isar.cachedCredentialIsars
        .filter()
        .identityIdEqualTo(identityId)
        .schoolIdEqualTo(schoolId)
        .sortByUpdatedAtDesc()
        .findFirst();
    return found == null ? null : _credentialToPlain(found);
  }

  @override
  Future<RevokedCredential?> findRevocation(
    String credentialValue,
    String schoolId,
  ) async {
    final found = await isar.revokedCredentialIsars
        .filter()
        .credentialValueEqualTo(credentialValue)
        .schoolIdEqualTo(schoolId)
        .findFirst();
    return found == null ? null : _revocationToPlain(found);
  }

  @override
  Future<void> saveRevocation(RevokedCredential revocation) async {
    await isar.writeTxn(() async {
      await isar.revokedCredentialIsars.put(_revocationToIsar(revocation));
    });
  }

  @override
  Future<void> deleteRevocation(String credentialValue, String schoolId) async {
    final existing = await isar.revokedCredentialIsars
        .filter()
        .credentialValueEqualTo(credentialValue)
        .schoolIdEqualTo(schoolId)
        .findFirst();
    if (existing == null) return;
    await isar.writeTxn(() async {
      await isar.revokedCredentialIsars.delete(existing.id);
    });
  }

  @override
  Future<OperatorPermissionSnapshot?> getPermissionSnapshot(
    String operatorId,
  ) async {
    final found = await isar.operatorPermissionSnapshotIsars
        .filter()
        .operatorIdEqualTo(operatorId)
        .findFirst();
    return found == null ? null : _snapshotToPlain(found);
  }

  @override
  Future<void> savePermissionSnapshot(
    OperatorPermissionSnapshot snapshot,
  ) async {
    await isar.writeTxn(() async {
      await isar.operatorPermissionSnapshotIsars.put(_snapshotToIsar(snapshot));
    });
  }

  @override
  Future<AuthorizedDevice?> findDevice(String deviceId, String schoolId) async {
    final found = await isar.authorizedDeviceIsars
        .filter()
        .deviceIdEqualTo(deviceId)
        .schoolIdEqualTo(schoolId)
        .findFirst();
    return found == null ? null : _deviceToPlain(found);
  }

  @override
  Future<void> saveVerificationEvent(VerificationEvent event) async {
    await isar.writeTxn(() async {
      await isar.verificationEventIsars.put(_eventToIsar(event));
    });
  }

  @override
  Future<List<VerificationEvent>> getUnsyncedEvents() async {
    final found = await isar.verificationEventIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return found.map(_eventToPlain).toList();
  }

  @override
  Future<void> markEventSynced(String eventId) async {
    final event = await isar.verificationEventIsars
        .filter()
        .eventIdEqualTo(eventId)
        .findFirst();
    if (event == null) return;
    event.isSynced = true;
    await isar.writeTxn(() async {
      await isar.verificationEventIsars.put(event);
    });
  }

  @override
  Future<List<VerificationEvent>> getTodayEventsForGate(
    String gateId,
    String schoolId,
  ) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final found = await isar.verificationEventIsars
        .filter()
        .gateIdEqualTo(gateId)
        .schoolIdEqualTo(schoolId)
        .timestampGreaterThan(startOfDay)
        .findAll();
    return found.map(_eventToPlain).toList();
  }
}
