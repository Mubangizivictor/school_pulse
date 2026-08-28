import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/parent_offline/data/datasources/parent_cache_data_source.dart';
import 'package:school_pulse/features/parent_offline/data/datasources/parent_local_pin_store.dart';

/// Single entry point the Parent Portal's screens/BLoCs use to participate
/// in offline caching, instead of talking to [ParentCacheDataSource]
/// directly. Every read/write is scoped by (tenantId, parentId,
/// learnerId) so a bug elsewhere in the app can never leak one parent's or
/// tenant's cached data to another - see [ParentCacheDataSource] docs for
/// the storage-layer enforcement this wraps.
class ParentOfflineCacheService {
  final ParentCacheDataSource _cache;
  final ParentLocalPinStore _pinStore;
  final NetworkInfo _networkInfo;

  ParentOfflineCacheService({
    required ParentCacheDataSource cache,
    required ParentLocalPinStore pinStore,
    required NetworkInfo networkInfo,
  }) : _cache = cache,
       _pinStore = pinStore,
       _networkInfo = networkInfo;

  Future<bool> get isOnline => _networkInfo.isConnected;

  Future<void> save({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
    required String payloadJson,
  }) => _cache.put(
    tenantId: tenantId,
    parentId: parentId,
    learnerId: learnerId,
    cacheKey: cacheKey,
    payloadJson: payloadJson,
  );

  Future<ParentCacheReadResult?> read({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
  }) => _cache.get(
    tenantId: tenantId,
    parentId: parentId,
    learnerId: learnerId,
    cacheKey: cacheKey,
  );

  /// Call the moment a learner link is removed on sync - immediately drops
  /// that learner's cached data so nothing stale/unlinked can surface
  /// offline afterward.
  Future<void> onLearnerUnlinked({
    required String tenantId,
    required String parentId,
    required String learnerId,
  }) => _cache.clearLearner(
    tenantId: tenantId,
    parentId: parentId,
    learnerId: learnerId,
  );

  /// Call on logout, account removal, tenant switch, school-link removal,
  /// or user switch - clears every cached record and the local PIN gate
  /// for this parent so a subsequent user of the device can never read the
  /// previous parent's data or unlock with their PIN.
  Future<void> clearAllForParent({
    required String tenantId,
    required String parentId,
  }) async {
    await _cache.clearParent(tenantId: tenantId, parentId: parentId);
    await _pinStore.clear(parentId);
  }

  Future<bool> hasOfflineGate(String parentId) => _pinStore.hasPin(parentId);

  Future<void> setOfflineGatePin({
    required String parentId,
    required String pin,
  }) => _pinStore.setPin(parentId: parentId, pin: pin);

  Future<bool> verifyOfflineGatePin({
    required String parentId,
    required String pin,
  }) => _pinStore.verifyPin(parentId: parentId, pin: pin);
}
