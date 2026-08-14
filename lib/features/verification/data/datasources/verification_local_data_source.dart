import '../../domain/entities/verification_cache_records.dart';

/// No Isar/isar-model import here on purpose - see
/// verification_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// verification_local_data_source_factory.dart's conditional import.
///
/// Mobile is designed to answer instantly with zero network at a gate
/// (NFC/QR verification cache + offline event queue). Web has no offline
/// gate-scanning use case in the same sense - writes go straight to
/// Firestore via the existing collections these mirror
/// (schools/{schoolId}/credentials, revoked_credentials,
/// verification_events), and getUnsyncedEvents/markEventSynced are
/// no-ops/empty since nothing is ever queued on web.
abstract class VerificationLocalDataSource {
  Future<CachedCredential?> findCredential(
    String credentialValue,
    String schoolId,
  );
  Future<void> cacheCredential(CachedCredential credential);

  Future<CachedCredential?> findCredentialByIdentity(
    String identityId,
    String schoolId,
  );

  Future<RevokedCredential?> findRevocation(
    String credentialValue,
    String schoolId,
  );
  Future<void> saveRevocation(RevokedCredential revocation);
  Future<void> deleteRevocation(String credentialValue, String schoolId);

  Future<OperatorPermissionSnapshot?> getPermissionSnapshot(String operatorId);
  Future<void> savePermissionSnapshot(OperatorPermissionSnapshot snapshot);
  Future<void> clearPermissionSnapshot(String operatorId);

  Future<AuthorizedDevice?> findDevice(String deviceId, String schoolId);

  Future<void> saveVerificationEvent(VerificationEvent event);
  Future<List<VerificationEvent>> getUnsyncedEvents();
  Future<void> markEventSynced(String eventId);
  Future<List<VerificationEvent>> getTodayEventsForGate(
    String gateId,
    String schoolId,
  );
}
