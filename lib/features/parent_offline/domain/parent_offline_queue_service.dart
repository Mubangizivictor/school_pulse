import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/parent_offline/data/datasources/parent_queue_data_source.dart';

/// A single queued action ready to be sent to the server. The caller
/// supplies [send] - this service only owns durability, ordering, and
/// idempotency-key bookkeeping, never the wire format of any one action
/// type.
typedef ParentQueueActionSender = Future<void> Function(ParentQueueItem item);

/// Drives the safe-actions-only offline queue: enqueue while offline,
/// replay in creation order on reconnect, and never double-submit thanks to
/// each item's stable [ParentQueueItemIsar.idempotencyKey].
class ParentOfflineQueueService {
  final ParentQueueDataSource _dataSource;
  static const _uuid = Uuid();

  ParentOfflineQueueService({required ParentQueueDataSource dataSource})
    : _dataSource = dataSource;

  Future<String> enqueue({
    required String tenantId,
    required String parentId,
    String? learnerId,
    required ParentQueueActionType actionType,
    required int payloadVersion,
    required String payloadJson,
  }) async {
    final idempotencyKey = _uuid.v4();
    await _dataSource.enqueue(
      idempotencyKey: idempotencyKey,
      tenantId: tenantId,
      parentId: parentId,
      learnerId: learnerId,
      actionType: actionType,
      payloadVersion: payloadVersion,
      payloadJson: payloadJson,
    );
    return idempotencyKey;
  }

  Future<List<ParentQueueItem>> pendingFor({
    required String tenantId,
    required String parentId,
  }) => _dataSource.pending(tenantId: tenantId, parentId: parentId);

  /// Sends every pending item for this parent, in creation order, stopping
  /// at the first failure so later items never jump ahead of an unresolved
  /// dependency. Safe to call repeatedly (e.g. on every reconnect) - items
  /// already marked done are excluded by the data source query.
  Future<void> syncPending({
    required String tenantId,
    required String parentId,
    required ParentQueueActionSender send,
  }) async {
    final items = await pendingFor(tenantId: tenantId, parentId: parentId);
    for (final item in items) {
      await _dataSource.markSyncing(item.idempotencyKey);
      try {
        await send(item);
        await _dataSource.markDone(item.idempotencyKey);
      } catch (e) {
        await _dataSource.markFailed(item.idempotencyKey, e.toString());
        break;
      }
    }
  }

  Future<void> retryNow(String idempotencyKey) =>
      _dataSource.markSyncing(idempotencyKey);

  Future<void> discard(String idempotencyKey) =>
      _dataSource.discard(idempotencyKey);

  Future<void> clearAllForParent({
    required String tenantId,
    required String parentId,
  }) => _dataSource.clearParent(tenantId: tenantId, parentId: parentId);
}
