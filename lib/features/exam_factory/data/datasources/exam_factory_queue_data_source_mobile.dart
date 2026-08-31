import 'package:isar/isar.dart';

import 'package:school_pulse/features/exam_factory/data/models/exam_factory_queue_item_isar.dart';
import 'exam_factory_queue_data_source.dart';

ExamFactoryQueueDataSource create({required dynamic isar}) =>
    ExamFactoryQueueDataSourceMobile(isar: isar as Isar);

class ExamFactoryQueueDataSourceMobile implements ExamFactoryQueueDataSource {
  final Isar isar;

  ExamFactoryQueueDataSourceMobile({required this.isar});

  @override
  Future<void> enqueue({
    required String idempotencyKey,
    required String institutionId,
    required String actorId,
    required ExamFactoryQueueActionType actionType,
    required String payloadJson,
  }) async {
    final item = ExamFactoryQueueItemIsar()
      ..idempotencyKey = idempotencyKey
      ..institutionId = institutionId
      ..actorId = actorId
      ..createdAt = DateTime.now()
      ..actionType = actionType
      ..payloadJson = payloadJson
      ..retryCount = 0
      ..status = ExamFactoryQueueStatus.pending;
    await isar.writeTxn(() => isar.examFactoryQueueItemIsars.put(item));
  }

  @override
  Future<List<ExamFactoryQueueItem>> pending({
    required String institutionId,
    required String actorId,
  }) async {
    final items = await isar.examFactoryQueueItemIsars
        .filter()
        .institutionIdEqualTo(institutionId)
        .actorIdEqualTo(actorId)
        .not()
        .statusEqualTo(ExamFactoryQueueStatus.done)
        .sortByCreatedAt()
        .findAll();
    return items.map(_toItem).toList();
  }

  ExamFactoryQueueItem _toItem(ExamFactoryQueueItemIsar item) =>
      ExamFactoryQueueItem(
        idempotencyKey: item.idempotencyKey,
        institutionId: item.institutionId,
        actorId: item.actorId,
        createdAt: item.createdAt,
        actionType: item.actionType,
        payloadJson: item.payloadJson,
        retryCount: item.retryCount,
        status: item.status,
        lastError: item.lastError,
      );

  Future<ExamFactoryQueueItemIsar?> _find(String idempotencyKey) {
    return isar.examFactoryQueueItemIsars
        .filter()
        .idempotencyKeyEqualTo(idempotencyKey)
        .findFirst();
  }

  @override
  Future<void> markSyncing(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = ExamFactoryQueueStatus.syncing;
    await isar.writeTxn(() => isar.examFactoryQueueItemIsars.put(item));
  }

  @override
  Future<void> markDone(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = ExamFactoryQueueStatus.done;
    await isar.writeTxn(() => isar.examFactoryQueueItemIsars.put(item));
  }

  @override
  Future<void> markFailed(String idempotencyKey, String error) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = ExamFactoryQueueStatus.failed;
    item.retryCount += 1;
    item.lastError = error;
    await isar.writeTxn(() => isar.examFactoryQueueItemIsars.put(item));
  }

  @override
  Future<void> discard(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    await isar.writeTxn(() => isar.examFactoryQueueItemIsars.delete(item.id));
  }
}
