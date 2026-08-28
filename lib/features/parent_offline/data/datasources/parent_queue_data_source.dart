import 'package:school_pulse/features/parent_offline/data/models/parent_queue_item_isar.dart';

abstract class ParentQueueDataSource {
  Future<void> enqueue({
    required String idempotencyKey,
    required String tenantId,
    required String parentId,
    String? learnerId,
    required ParentQueueActionType actionType,
    required int payloadVersion,
    required String payloadJson,
  });

  Future<List<ParentQueueItemIsar>> pending({
    required String tenantId,
    required String parentId,
  });

  Future<void> markSyncing(String idempotencyKey);

  Future<void> markDone(String idempotencyKey);

  Future<void> markFailed(String idempotencyKey, String error);

  Future<void> discard(String idempotencyKey);

  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  });
}
