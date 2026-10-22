/// Tenant + parent + learner-scoped read/write cache for the mobile Parent
/// Portal. Every implementation MUST reject a read/write whose
/// (tenantId, parentId) does not match the currently authenticated parent -
/// see [ParentCacheDataSourceMobile] for the enforcement point.
abstract class ParentCacheDataSource {
  Future<void> put({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
    required String payloadJson,
  });

  /// Returns null if nothing is cached for this exact scope.
  Future<ParentCacheReadResult?> get({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
  });

  /// Deletes every cache entry for one learner (tenant+parent scoped) -
  /// called immediately when a learner link is removed on sync.
  Future<void> clearLearner({
    required String tenantId,
    required String parentId,
    required String learnerId,
  });

  /// Deletes every cache entry for one parent - called on logout, account
  /// removal, tenant switch, or user switch.
  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  });
}

class ParentCacheReadResult {
  final String payloadJson;
  final DateTime updatedAt;

  const ParentCacheReadResult({
    required this.payloadJson,
    required this.updatedAt,
  });
}
