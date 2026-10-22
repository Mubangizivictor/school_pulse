/// Mirrors the Isar-only `ParentQueueActionType`/`ParentQueueStatus` enums
/// without depending on the Isar model, so this interface (and every
/// platform's data source, including web) stays free of Isar's generated
/// code - dart2js can't compile the `.g.dart` file's 64-bit collection-id
/// literals, so any web-reachable import of it breaks the entire web build.
enum ParentQueueActionType {
  markMessageRead,
  markAnnouncementRead,
  acknowledgement,
  saveMessageDraft,
  absenceRequest,
  appointmentRequest,
  appointmentCancellation,
  contactPreferenceUpdate,
  notificationPreferenceUpdate,
  externalPaymentReference,
}

enum ParentQueueStatus { pending, syncing, failed, done }

class ParentQueueItem {
  final String idempotencyKey;
  final String tenantId;
  final String parentId;
  final String? learnerId;
  final DateTime createdAt;
  final ParentQueueActionType actionType;
  final int payloadVersion;
  final String payloadJson;
  final int retryCount;
  final ParentQueueStatus status;
  final String? lastError;

  const ParentQueueItem({
    required this.idempotencyKey,
    required this.tenantId,
    required this.parentId,
    this.learnerId,
    required this.createdAt,
    required this.actionType,
    required this.payloadVersion,
    required this.payloadJson,
    this.retryCount = 0,
    this.status = ParentQueueStatus.pending,
    this.lastError,
  });
}

abstract class ParentQueueDataSource {
  Future<void> enqueue({
    required String idempotencyKey,
    required String tenantId,
    required String parentId,
    String? learnerId,
    required ParentQueueActionType actionType,
    required int payloadVersion,
    required String payloadJson,
  });

  Future<List<ParentQueueItem>> pending({
    required String tenantId,
    required String parentId,
  });

  Future<void> markSyncing(String idempotencyKey);

  Future<void> markDone(String idempotencyKey);

  Future<void> markFailed(String idempotencyKey, String error);

  Future<void> discard(String idempotencyKey);

  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  });
}
