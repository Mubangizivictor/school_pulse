import '../../domain/entities/verification_cache_records.dart';
import 'verification_local_data_source.dart';

VerificationLocalDataSource create({dynamic isar, dynamic remote}) =>
    _VerificationLocalDataSourceStub();

class _VerificationLocalDataSourceStub implements VerificationLocalDataSource {
  @override
  Future<CachedCredential?> findCredential(
    String credentialValue,
    String schoolId,
  ) => _unsupported();
  @override
  Future<void> cacheCredential(CachedCredential credential) => _unsupported();
  @override
  Future<CachedCredential?> findCredentialByIdentity(
    String identityId,
    String schoolId,
  ) => _unsupported();
  @override
  Future<RevokedCredential?> findRevocation(
    String credentialValue,
    String schoolId,
  ) => _unsupported();
  @override
  Future<void> saveRevocation(RevokedCredential revocation) => _unsupported();
  @override
  Future<void> deleteRevocation(String credentialValue, String schoolId) =>
      _unsupported();
  @override
  Future<OperatorPermissionSnapshot?> getPermissionSnapshot(
    String operatorId,
  ) => _unsupported();
  @override
  Future<void> savePermissionSnapshot(OperatorPermissionSnapshot snapshot) =>
      _unsupported();
  @override
  Future<AuthorizedDevice?> findDevice(String deviceId, String schoolId) =>
      _unsupported();
  @override
  Future<void> saveVerificationEvent(VerificationEvent event) => _unsupported();
  @override
  Future<List<VerificationEvent>> getUnsyncedEvents() => _unsupported();
  @override
  Future<void> markEventSynced(String eventId) => _unsupported();
  @override
  Future<List<VerificationEvent>> getTodayEventsForGate(
    String gateId,
    String schoolId,
  ) => _unsupported();

  Never _unsupported() => throw UnimplementedError(
    'No VerificationLocalDataSource for this platform',
  );
}
