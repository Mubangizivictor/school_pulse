import 'package:isar/isar.dart';

import 'package:school_pulse/features/parent_offline/data/models/parent_cache_entry_isar.dart';
import 'parent_cache_data_source.dart';

ParentCacheDataSource create({required dynamic isar}) =>
    ParentCacheDataSourceMobile(isar: isar as Isar);

class ParentCacheDataSourceMobile implements ParentCacheDataSource {
  final Isar isar;

  ParentCacheDataSourceMobile({required this.isar});

  @override
  Future<void> put({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
    required String payloadJson,
  }) async {
    final entry = ParentCacheEntryIsar()
      ..compositeKey = ParentCacheEntryIsar.buildCompositeKey(
        tenantId: tenantId,
        parentId: parentId,
        learnerId: learnerId,
        cacheKey: cacheKey,
      )
      ..tenantId = tenantId
      ..parentId = parentId
      ..learnerId = learnerId
      ..cacheKey = cacheKey
      ..payloadJson = payloadJson
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.parentCacheEntryIsars.put(entry));
  }

  @override
  Future<ParentCacheReadResult?> get({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
  }) async {
    final key = ParentCacheEntryIsar.buildCompositeKey(
      tenantId: tenantId,
      parentId: parentId,
      learnerId: learnerId,
      cacheKey: cacheKey,
    );
    final entry = await isar.parentCacheEntryIsars
        .filter()
        .compositeKeyEqualTo(key)
        // Belt-and-braces tenant/parent check even though compositeKey
        // already encodes both - guards against a future caller that
        // constructs the key by hand incorrectly.
        .tenantIdEqualTo(tenantId)
        .parentIdEqualTo(parentId)
        .findFirst();
    if (entry == null) return null;
    return ParentCacheReadResult(
      payloadJson: entry.payloadJson,
      updatedAt: entry.updatedAt,
    );
  }

  @override
  Future<void> clearLearner({
    required String tenantId,
    required String parentId,
    required String learnerId,
  }) async {
    await isar.writeTxn(
      () => isar.parentCacheEntryIsars
          .filter()
          .tenantIdEqualTo(tenantId)
          .parentIdEqualTo(parentId)
          .learnerIdEqualTo(learnerId)
          .deleteAll(),
    );
  }

  @override
  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  }) async {
    await isar.writeTxn(
      () => isar.parentCacheEntryIsars
          .filter()
          .tenantIdEqualTo(tenantId)
          .parentIdEqualTo(parentId)
          .deleteAll(),
    );
  }
}
