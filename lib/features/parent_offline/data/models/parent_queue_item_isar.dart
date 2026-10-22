import 'package:isar/isar.dart';

import 'package:school_pulse/features/parent_offline/data/datasources/parent_queue_data_source.dart'
    show ParentQueueActionType, ParentQueueStatus;

part 'parent_queue_item_isar.g.dart';

/// One durable, offline-queued parent action. Only the actions explicitly
/// permitted to be queued (see [ParentQueueActionType]) may ever be written
/// here - anything else (in-app payment, direct record mutation) must go
/// through its normal online-only path.
///
/// [idempotencyKey] is generated once at enqueue time and sent unchanged on
/// every retry, so a flaky reconnect that retries a partially-acked write
/// can never duplicate a message/ack/request server-side.
@collection
class ParentQueueItemIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String idempotencyKey;

  @Index()
  late String tenantId;

  @Index()
  late String parentId;

  String? learnerId;

  late DateTime createdAt;

  @enumerated
  late ParentQueueActionType actionType;

  late int payloadVersion;

  /// Minimised, encrypted-at-rest-by-device-storage payload for this
  /// action. Isar's own database file is app-sandboxed, not additionally
  /// field-level encrypted here - see ParentOfflineCacheService doc for why
  /// that's the accepted boundary for this slice.
  late String payloadJson;

  int retryCount = 0;

  @enumerated
  ParentQueueStatus status = ParentQueueStatus.pending;

  String? lastError;
}
