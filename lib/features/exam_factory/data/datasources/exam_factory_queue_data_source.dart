/// Mirrors ParentQueueActionType/Status without depending on Isar's
/// generated code, so this interface (and every platform's data source,
/// including web) stays free of it - see parent_queue_data_source.dart for
/// why a web-reachable Isar `.g.dart` import breaks the web build.
///
/// Deliberately closed to the spec's offline-safe actions only: teacher
/// question drafts, moderation comments, mark entry, attendance and
/// incident reports. Paper approval, locking, controlled PDF download and
/// secure printing must never be queued - they require an online session by
/// design (see ExamFactoryOfflineQueueService doc).
enum ExamFactoryQueueActionType {
  saveQuestionDraft,
  submitQuestion,
  moderateQuestion,
  recordAttendance,
  reportIncident,
  saveMarkEntry,
}

enum ExamFactoryQueueStatus { pending, syncing, failed, done }

class ExamFactoryQueueItem {
  final String idempotencyKey;
  final String institutionId;
  final String actorId;
  final DateTime createdAt;
  final ExamFactoryQueueActionType actionType;
  final String payloadJson;
  final int retryCount;
  final ExamFactoryQueueStatus status;
  final String? lastError;

  const ExamFactoryQueueItem({
    required this.idempotencyKey,
    required this.institutionId,
    required this.actorId,
    required this.createdAt,
    required this.actionType,
    required this.payloadJson,
    this.retryCount = 0,
    this.status = ExamFactoryQueueStatus.pending,
    this.lastError,
  });
}

abstract class ExamFactoryQueueDataSource {
  Future<void> enqueue({
    required String idempotencyKey,
    required String institutionId,
    required String actorId,
    required ExamFactoryQueueActionType actionType,
    required String payloadJson,
  });

  Future<List<ExamFactoryQueueItem>> pending({
    required String institutionId,
    required String actorId,
  });

  Future<void> markSyncing(String idempotencyKey);
  Future<void> markDone(String idempotencyKey);
  Future<void> markFailed(String idempotencyKey, String error);
  Future<void> discard(String idempotencyKey);
}
