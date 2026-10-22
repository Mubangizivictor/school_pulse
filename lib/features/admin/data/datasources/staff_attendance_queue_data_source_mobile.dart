import 'package:isar/isar.dart';

import 'package:school_pulse/features/admin/data/models/staff_attendance_queue_item_isar.dart';
import 'staff_attendance_queue_data_source.dart';

StaffAttendanceQueueDataSource create({required dynamic isar}) =>
    StaffAttendanceQueueDataSourceMobile(isar: isar as Isar);

class StaffAttendanceQueueDataSourceMobile
    implements StaffAttendanceQueueDataSource {
  final Isar isar;

  StaffAttendanceQueueDataSourceMobile({required this.isar});

  @override
  Future<void> enqueue({
    required String idempotencyKey,
    required String institutionId,
    required String actorId,
    required StaffAttendanceQueueActionType actionType,
    required String payloadJson,
  }) async {
    final item = StaffAttendanceQueueItemIsar()
      ..idempotencyKey = idempotencyKey
      ..institutionId = institutionId
      ..actorId = actorId
      ..createdAt = DateTime.now()
      ..actionType = actionType
      ..payloadJson = payloadJson
      ..retryCount = 0
      ..status = StaffAttendanceQueueStatus.pending;
    await isar.writeTxn(() => isar.staffAttendanceQueueItemIsars.put(item));
  }

  @override
  Future<List<StaffAttendanceQueueItem>> pending({
    required String institutionId,
    required String actorId,
  }) async {
    final items = await isar.staffAttendanceQueueItemIsars
        .filter()
        .institutionIdEqualTo(institutionId)
        .actorIdEqualTo(actorId)
        .not()
        .statusEqualTo(StaffAttendanceQueueStatus.done)
        .sortByCreatedAt()
        .findAll();
    return items.map(_toItem).toList();
  }

  StaffAttendanceQueueItem _toItem(StaffAttendanceQueueItemIsar item) =>
      StaffAttendanceQueueItem(
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

  Future<StaffAttendanceQueueItemIsar?> _find(String idempotencyKey) {
    return isar.staffAttendanceQueueItemIsars
        .filter()
        .idempotencyKeyEqualTo(idempotencyKey)
        .findFirst();
  }

  @override
  Future<void> markSyncing(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = StaffAttendanceQueueStatus.syncing;
    await isar.writeTxn(() => isar.staffAttendanceQueueItemIsars.put(item));
  }

  @override
  Future<void> markDone(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = StaffAttendanceQueueStatus.done;
    await isar.writeTxn(() => isar.staffAttendanceQueueItemIsars.put(item));
  }

  @override
  Future<void> markFailed(String idempotencyKey, String error) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    item.status = StaffAttendanceQueueStatus.failed;
    item.retryCount += 1;
    item.lastError = error;
    await isar.writeTxn(() => isar.staffAttendanceQueueItemIsars.put(item));
  }

  @override
  Future<void> discard(String idempotencyKey) async {
    final item = await _find(idempotencyKey);
    if (item == null) return;
    await isar.writeTxn(
      () => isar.staffAttendanceQueueItemIsars.delete(item.id),
    );
  }
}
