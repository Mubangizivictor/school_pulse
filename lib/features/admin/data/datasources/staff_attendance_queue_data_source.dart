/// Mirrors ExamFactoryQueueDataSource's design (see its doc for the web/Isar
/// split rationale): a web-reachable Isar `.g.dart` import breaks the web
/// build, so this interface and every platform's implementation stay free
/// of Isar's generated code.
///
/// Deliberately closed to the two explicitly-safe staff attendance actions:
/// a same-day "Mark staff attendance" clock-in and an authorised correction.
/// Both callables (`clockInStaff`, `correctStaffAttendance`) already accept
/// an `operationId` for idempotent replay - see staff_attendance_offline_queue_service.dart.
enum StaffAttendanceQueueActionType { clockIn, correction }

enum StaffAttendanceQueueStatus { pending, syncing, failed, done }

class StaffAttendanceQueueItem {
  final String idempotencyKey;
  final String institutionId;
  final String actorId;
  final DateTime createdAt;
  final StaffAttendanceQueueActionType actionType;
  final String payloadJson;
  final int retryCount;
  final StaffAttendanceQueueStatus status;
  final String? lastError;

  const StaffAttendanceQueueItem({
    required this.idempotencyKey,
    required this.institutionId,
    required this.actorId,
    required this.createdAt,
    required this.actionType,
    required this.payloadJson,
    this.retryCount = 0,
    this.status = StaffAttendanceQueueStatus.pending,
    this.lastError,
  });
}

abstract class StaffAttendanceQueueDataSource {
  Future<void> enqueue({
    required String idempotencyKey,
    required String institutionId,
    required String actorId,
    required StaffAttendanceQueueActionType actionType,
    required String payloadJson,
  });

  Future<List<StaffAttendanceQueueItem>> pending({
    required String institutionId,
    required String actorId,
  });

  Future<void> markSyncing(String idempotencyKey);
  Future<void> markDone(String idempotencyKey);
  Future<void> markFailed(String idempotencyKey, String error);
  Future<void> discard(String idempotencyKey);
}
