import 'exam_factory_queue_data_source.dart';

/// Web has no raw-socket connectivity probe and WebNetworkInfo always
/// reports connected there (see network_info.dart), so the offline queue is
/// never actually drained differently on web - actions submit directly and
/// Firestore/Functions' own retry handles transient blips. This
/// implementation exists only so shared call sites compile identically on
/// both platforms.
ExamFactoryQueueDataSource create({required dynamic isar}) =>
    const ExamFactoryQueueDataSourceWeb();

class ExamFactoryQueueDataSourceWeb implements ExamFactoryQueueDataSource {
  const ExamFactoryQueueDataSourceWeb();

  @override
  Future<void> enqueue({
    required String idempotencyKey,
    required String institutionId,
    required String actorId,
    required ExamFactoryQueueActionType actionType,
    required String payloadJson,
  }) async {}

  @override
  Future<List<ExamFactoryQueueItem>> pending({
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
