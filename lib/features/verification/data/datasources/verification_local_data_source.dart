import 'package:isar/isar.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';

abstract class VerificationLocalDataSource {
  Future<CachedCredentialIsar?> findCredential(String credentialValue, String schoolId);
  Future<void> cacheCredential(CachedCredentialIsar credential);

  // Reverse lookup: "what card (if any) is/was bound to this identity" -
  // needed so a lost/stolen card can be revoked without the physical card
  // being available to scan. Returns the most recently updated mapping
  // regardless of status (active or revoked), not just active ones.
  Future<CachedCredentialIsar?> findCredentialByIdentity(String identityId, String schoolId);

  Future<RevokedCredentialIsar?> findRevocation(String credentialValue, String schoolId);
  Future<void> saveRevocation(RevokedCredentialIsar revocation);
  Future<void> deleteRevocation(String credentialValue, String schoolId);

  Future<OperatorPermissionSnapshotIsar?> getPermissionSnapshot(String operatorId);
  Future<void> savePermissionSnapshot(OperatorPermissionSnapshotIsar snapshot);

  Future<AuthorizedDeviceIsar?> findDevice(String deviceId, String schoolId);

  Future<void> saveVerificationEvent(VerificationEventIsar event);
  Future<List<VerificationEventIsar>> getUnsyncedEvents();
  Future<void> markEventSynced(String eventId);
  Future<List<VerificationEventIsar>> getTodayEventsForGate(String gateId, String schoolId);
}

class VerificationLocalDataSourceImpl implements VerificationLocalDataSource {
  final Isar isar;

  VerificationLocalDataSourceImpl(this.isar);

  @override
  Future<CachedCredentialIsar?> findCredential(String credentialValue, String schoolId) async {
    return isar.cachedCredentialIsars
        .filter()
        .credentialValueEqualTo(credentialValue)
        .schoolIdEqualTo(schoolId)
        .findFirst();
  }

  @override
  Future<void> cacheCredential(CachedCredentialIsar credential) async {
    await isar.writeTxn(() async {
      await isar.cachedCredentialIsars.put(credential);
    });
  }

  @override
  Future<CachedCredentialIsar?> findCredentialByIdentity(String identityId, String schoolId) async {
    return isar.cachedCredentialIsars
        .filter()
        .identityIdEqualTo(identityId)
        .schoolIdEqualTo(schoolId)
        .sortByUpdatedAtDesc()
        .findFirst();
  }

  @override
  Future<RevokedCredentialIsar?> findRevocation(String credentialValue, String schoolId) async {
    return isar.revokedCredentialIsars
        .filter()
        .credentialValueEqualTo(credentialValue)
        .schoolIdEqualTo(schoolId)
        .findFirst();
  }

  @override
  Future<void> saveRevocation(RevokedCredentialIsar revocation) async {
    await isar.writeTxn(() async {
      await isar.revokedCredentialIsars.put(revocation);
    });
  }

  @override
  Future<void> deleteRevocation(String credentialValue, String schoolId) async {
    final existing = await findRevocation(credentialValue, schoolId);
    if (existing == null) return;
    await isar.writeTxn(() async {
      await isar.revokedCredentialIsars.delete(existing.id);
    });
  }

  @override
  Future<OperatorPermissionSnapshotIsar?> getPermissionSnapshot(String operatorId) async {
    return isar.operatorPermissionSnapshotIsars.filter().operatorIdEqualTo(operatorId).findFirst();
  }

  @override
  Future<void> savePermissionSnapshot(OperatorPermissionSnapshotIsar snapshot) async {
    await isar.writeTxn(() async {
      await isar.operatorPermissionSnapshotIsars.put(snapshot);
    });
  }

  @override
  Future<AuthorizedDeviceIsar?> findDevice(String deviceId, String schoolId) async {
    return isar.authorizedDeviceIsars.filter().deviceIdEqualTo(deviceId).schoolIdEqualTo(schoolId).findFirst();
  }

  @override
  Future<void> saveVerificationEvent(VerificationEventIsar event) async {
    await isar.writeTxn(() async {
      await isar.verificationEventIsars.put(event);
    });
  }

  @override
  Future<List<VerificationEventIsar>> getUnsyncedEvents() async {
    return isar.verificationEventIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markEventSynced(String eventId) async {
    final event = await isar.verificationEventIsars.filter().eventIdEqualTo(eventId).findFirst();
    if (event == null) return;
    event.isSynced = true;
    await isar.writeTxn(() async {
      await isar.verificationEventIsars.put(event);
    });
  }

  @override
  Future<List<VerificationEventIsar>> getTodayEventsForGate(String gateId, String schoolId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return isar.verificationEventIsars
        .filter()
        .gateIdEqualTo(gateId)
        .schoolIdEqualTo(schoolId)
        .timestampGreaterThan(startOfDay)
        .findAll();
  }
}
