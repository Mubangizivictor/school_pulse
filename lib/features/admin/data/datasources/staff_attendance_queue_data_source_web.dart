import 'staff_attendance_queue_data_source.dart';

/// Web has no raw-socket connectivity probe and WebNetworkInfo always
/// reports connected there (see network_info.dart), so the offline queue is
/// never actually drained differently on web - actions submit directly and
/// Firestore/Functions' own retry handles transient blips. This
/// implementation exists only so shared call sites compile identically on
/// both platforms - mirrors ExamFactoryQueueDataSourceWeb.
StaffAttendanceQueueDataSource create({required dynamic isar}) =>
    const StaffAttendanceQueueDataSourceWeb();

class StaffAttendanceQueueDataSourceWeb
    implements StaffAttendanceQueueDataSource {
  const StaffAttendanceQueueDataSourceWeb();

  @override
  Future<void> enqueue({
    required String idempotencyKey,
    required String institutionId,
    required String actorId,
    required StaffAttendanceQueueActionType actionType,
    required String payloadJson,
  }) async {}

  @override
  Future<List<StaffAttendanceQueueItem>> pending({
    required String institutionId,
    required String actorId,
  }) async => const [];

  @override
  Future<void> markSyncing(String idempotencyKey) async {}

  @override
  Future<void> markDone(String idempotencyKey) async {}

  @override
  Future<void> markFailed(String idempotencyKey, String error) async {}

  @override
  Future<void> discard(String idempotencyKey) async {}
}
