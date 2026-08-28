import 'parent_cache_data_source.dart';

ParentCacheDataSource create({required dynamic isar}) =>
    const ParentCacheDataSourceWeb();

/// Parent Portal is online-only on web (no Isar, no IndexedDB persistence,
/// no cached sensitive parent/learner records) - every call here is a
/// deliberate no-op so any code shared between mobile/web that calls
/// through [ParentCacheDataSource] degrades to "nothing cached" on web
/// instead of throwing.
class ParentCacheDataSourceWeb implements ParentCacheDataSource {
  const ParentCacheDataSourceWeb();

  @override
  Future<void> put({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
    required String payloadJson,
  }) async {}

  @override
  Future<ParentCacheReadResult?> get({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
  }) async => null;

  @override
  Future<void> clearLearner({
    required String tenantId,
    required String parentId,
    required String learnerId,
  }) async {}

  @override
  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  }) async {}
}
