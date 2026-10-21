import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/exam_factory/data/datasources/exam_factory_queue_data_source.dart';

/// A single queued action ready to be sent to the server. The caller
/// supplies [send] - this service only owns durability, ordering, and
/// idempotency-key bookkeeping, never the wire format of any one action
/// type. Mirrors ParentOfflineQueueService's design.
typedef ExamFactoryQueueActionSender =
    Future<void> Function(ExamFactoryQueueItem item);

/// Drives the safe-actions-only offline queue: enqueue while offline,
/// replay in creation order on reconnect, and never double-submit thanks to
/// each item's stable [ExamFactoryQueueItemIsar.idempotencyKey], which is
/// sent unchanged as `operationId` to the target callable.
///
/// Deliberately excludes paper approval, locking, controlled PDF download
/// and secure printing - those callables require an authorized online
/// session and must never be queued (see ExamFactoryQueueActionType doc).
class ExamFactoryOfflineQueueService {
  final ExamFactoryQueueDataSource _dataSource;
  static const _uuid = Uuid();

  ExamFactoryOfflineQueueService({required this._dataSource});

  Future<String> enqueue({
    required String institutionId,
    required String actorId,
    required ExamFactoryQueueActionType actionType,
    required String payloadJson,
  }) async {
    final idempotencyKey = _uuid.v4();
    await _dataSource.enqueue(
      idempotencyKey: idempotencyKey,
      institutionId: institutionId,
      actorId: actorId,
      actionType: actionType,
      payloadJson: payloadJson,
    );
    return idempotencyKey;
  }

  Future<List<ExamFactoryQueueItem>> pendingFor({
    required String institutionId,
    required String actorId,
  }) => _dataSource.pending(institutionId: institutionId, actorId: actorId);

  /// Sends every pending item for this user, in creation order, stopping at
  /// the first failure so later items never jump ahead of an unresolved
  /// dependency. Safe to call repeatedly (e.g. on every reconnect) - items
  /// already marked done are excluded by the data source query.
  Future<void> syncPending({
    required String institutionId,
    required String actorId,
    required ExamFactoryQueueActionSender send,
  }) async {
    final items = await pendingFor(
      institutionId: institutionId,
      actorId: actorId,
    );
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
}
