import 'package:isar/isar.dart';

import 'package:school_pulse/features/exam_factory/data/datasources/exam_factory_queue_data_source.dart'
    show ExamFactoryQueueActionType, ExamFactoryQueueStatus;

part 'exam_factory_queue_item_isar.g.dart';

/// One durable, offline-queued Exam Factory action - mirrors
/// ParentQueueItemIsar's design. Only the safe-to-queue action types listed
/// in [ExamFactoryQueueActionType] may ever be written here.
///
/// [idempotencyKey] is generated once at enqueue time and passed unchanged
/// as `operationId` on every retry, matching the idempotency keys every
/// exam_factory Cloud Function already accepts - a flaky reconnect that
/// retries a partially-acked write can never duplicate a draft, mark or
/// attendance record server-side.
@collection
class ExamFactoryQueueItemIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String idempotencyKey;

  @Index()
  late String institutionId;

  @Index()
  late String actorId;

  late DateTime createdAt;

  @enumerated
  late ExamFactoryQueueActionType actionType;

  /// Minimised JSON payload for the target callable - the same shape
  /// ExamFactoryRepositoryImpl already sends, so replay is a direct
  /// re-dispatch with no separate mapping layer.
  late String payloadJson;

  int retryCount = 0;

  @enumerated
  ExamFactoryQueueStatus status = ExamFactoryQueueStatus.pending;

  String? lastError;
}
