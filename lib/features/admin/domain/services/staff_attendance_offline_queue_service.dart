import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/admin/data/datasources/staff_attendance_queue_data_source.dart';

/// A single queued action ready to be sent to the server. The caller
/// supplies [send] - this service only owns durability, ordering, and
/// idempotency-key bookkeeping, never the wire format of any one action
/// type. Mirrors ExamFactoryOfflineQueueService's design.
typedef StaffAttendanceQueueActionSender =
    Future<void> Function(StaffAttendanceQueueItem item);

/// Drives the safe-actions-only offline queue for staff attendance:
/// enqueue while offline, replay in creation order on reconnect, and never
/// double-submit thanks to each item's stable
/// [StaffAttendanceQueueItemIsar.idempotencyKey], which is sent unchanged as
/// `operationId` to `clockInStaff`/`correctStaffAttendance`.
///
/// Deliberately closed to a same-day clock-in and an authorised correction -
/// no other staff attendance action is ever queued.
class StaffAttendanceOfflineQueueService {
  final StaffAttendanceQueueDataSource _dataSource;
  static const _uuid = Uuid();

  StaffAttendanceOfflineQueueService({
    required StaffAttendanceQueueDataSource dataSource,
  }) : _dataSource = dataSource;

  Future<String> enqueue({
    required String institutionId,
    required String actorId,
    required StaffAttendanceQueueActionType actionType,
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

  Future<List<StaffAttendanceQueueItem>> pendingFor({
    required String institutionId,
    required String actorId,
  }) => _dataSource.pending(institutionId: institutionId, actorId: actorId);

  /// Sends every pending item for this user, in creation order, stopping at
  /// the first failure so later items never jump ahead of an unresolved
  /// dependency. Safe to call repeatedly (e.g. on every reconnect) - items
  /// already marked done are excluded by the data source query.
  ///
  /// A conflict (the server rejects the queued item because the record it
  /// targeted changed in the meantime, e.g. `already-exists`/`aborted`) is
  /// treated the same as any other failure: marked `failed` with the reason,
  /// surfaced for manual re-review - this service never silently overwrites
  /// a newer server-side state.
  Future<void> syncPending({
    required String institutionId,
    required String actorId,
    required StaffAttendanceQueueActionSender send,
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
