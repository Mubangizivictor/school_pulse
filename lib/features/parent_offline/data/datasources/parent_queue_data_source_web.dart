import 'package:school_pulse/features/parent_offline/data/models/parent_queue_item_isar.dart';
import 'parent_queue_data_source.dart';

/// Parent Portal is online-only on web - actions submit directly and are
/// never queued, so this implementation is never actually reached in
/// practice, but exists so shared call sites compile identically on both
/// platforms.
ParentQueueDataSource create({required dynamic isar}) =>
    const ParentQueueDataSourceWeb();

class ParentQueueDataSourceWeb implements ParentQueueDataSource {
  const ParentQueueDataSourceWeb();

  @override
  Future<void> enqueue({
    required String idempotencyKey,
    required String tenantId,
    required String parentId,
    String? learnerId,
    required ParentQueueActionType actionType,
    required int payloadVersion,
    required String payloadJson,
  }) async {}

  @override
  Future<List<ParentQueueItemIsar>> pending({
    required String tenantId,
    required String parentId,
  }) async => const [];

  @override
  Future<void> markSyncing(String idempotencyKey) async {}

  @override
  Future<void> markDone(String idempotencyKey) async {}

  @override
  Future<void> markFailed(String idempotencyKey, String error) async {}

  @override
  Future<void> discard(String idempotencyKey) async {}

  @override
  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  }) async {}
}
