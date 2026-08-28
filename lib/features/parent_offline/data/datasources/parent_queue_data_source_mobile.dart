import 'package:isar/isar.dart';

import 'package:school_pulse/features/parent_offline/data/models/parent_queue_item_isar.dart';
import 'parent_queue_data_source.dart';

ParentQueueDataSource create({required dynamic isar}) =>
    ParentQueueDataSourceMobile(isar: isar as Isar);

class ParentQueueDataSourceMobile implements ParentQueueDataSource {
  final Isar isar;

  ParentQueueDataSourceMobile({required this.isar});

  @override
  Future<void> enqueue({
    required String idempotencyKey,
    required String tenantId,
    required String parentId,
    String? learnerId,
    required ParentQueueActionType actionType,
    required int payloadVersion,
    required String payloadJson,
  }) async {
    final item = ParentQueueItemIsar()
      ..idempotencyKey = idempotencyKey
      ..tenantId = tenantId
      ..parentId = parentId
      ..learnerId = learnerId
      ..createdAt = DateTime.now()
      ..actionType = actionType
      ..payloadVersion = payloadVersion
      ..payloadJson = payloadJson
      ..retryCount = 0
      ..status = ParentQueueStatus.pending;
    await isar.writeTxn(() => isar.parentQueueItemIsars.put(item));
  }

  @override
  Future<List<ParentQueueItem>> pending({
    required String tenantId,
    required String parentId,
  }) async {
    final items = await isar.parentQueueItemIsars
        .filter()
        .tenantIdEqualTo(tenantId)
        .parentIdEqualTo(parentId)
        .not()
        .statusEqualTo(ParentQueueStatus.done)
        .sortByCreatedAt()
        .findAll();
    return items.map(_toItem).toList();
  }

  ParentQueueItem _toItem(ParentQueueItemIsar item) => ParentQueueItem(
    idempotencyKey: item.idempotencyKey,
    tenantId: item.tenantId,
    parentId: item.parentId,
    learnerId: item.learnerId,
    createdAt: item.createdAt,
    actionType: item.actionType,
    payloadVersion: item.payloadVersion,
    payloadJson: item.payloadJson,
    retryCount: item.retryCount,
    status: item.status,
    lastError: item.lastError,
  );

  Future<ParentQueueItemIsar?> _find(String idempotencyKey) {
    return isar.parentQueueItemIsars
        .filter()
        .idempotencyKeyEqualTo(idempotencyKey)
        .findFirst();
  }

  @override
  Future<void> markSyncing(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = ParentQueueStatus.syncing;
    await isar.writeTxn(() => isar.parentQueueItemIsars.put(item));
  }

  @override
  Future<void> markDone(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = ParentQueueStatus.done;
    await isar.writeTxn(() => isar.parentQueueItemIsars.put(item));
  }

  @override
  Future<void> markFailed(String idempotencyKey, String error) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = ParentQueueStatus.failed;
    item.retryCount += 1;
    item.lastError = error;
    await isar.writeTxn(() => isar.parentQueueItemIsars.put(item));
  }

  @override
  Future<void> discard(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    await isar.writeTxn(() => isar.parentQueueItemIsars.delete(item.id));
  }

  @override
  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  }) async {
    await isar.writeTxn(
      () => isar.parentQueueItemIsars
          .filter()
          .tenantIdEqualTo(tenantId)
          .parentIdEqualTo(parentId)
          .deleteAll(),
    );
  }
}
