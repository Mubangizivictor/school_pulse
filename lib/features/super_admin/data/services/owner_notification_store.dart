import '../../domain/entities/owner_notification.dart';

/// Contract every owner-notification offline cache + safe-action queue
/// implementation satisfies.
///
/// There are two: [OwnerNotificationOfflineStore] (SharedPreferences —
/// web / test default) and [OwnerNotificationIsarStore] (a dedicated
/// per-owner Isar instance — mobile / desktop). Both are strictly
/// owner-scoped: a call for `owner-a` can never read `owner-b`'s rows or
/// queue. Neither shares storage, keys, schema or an Isar instance with any
/// school-role notification cache.
abstract class OwnerNotificationCacheStore {
  Future<void> writeCache(String ownerId, List<OwnerNotification> notifications);

  Future<List<OwnerNotification>> readCache(String ownerId);

  /// Drops cached rows (and queued actions targeting them) whose ids are no
  /// longer present server-side.
  Future<void> reconcile(String ownerId, Set<String> liveIds);

  Future<List<OwnerQueuedAction>> readQueue(String ownerId);

  Future<OwnerQueuedAction> enqueue({
    required String ownerId,
    required OwnerQueuedActionType type,
    String? notificationId,
    Map<String, dynamic>? payload,
  });

  Future<OwnerQueueSyncResult> sync({
    required String ownerId,
    required Future<void> Function(OwnerQueuedAction action) send,
    int maxAttempts = 6,
  });

  Future<int> pendingCount(String ownerId);

  /// Wipes cache + queue for one owner. Logout / account switch / role loss.
  Future<void> clearForOwner(String ownerId);

  /// Wipes cache + queue for every owner (full sign-out on a shared device).
  Future<void> clearEverything();
}

enum OwnerQueuedActionType {
  markRead,
  markAllRead,
  archive,
  delete,
  clearAll,
  updatePreferences,
}

/// A durable, replayable safe action. Carries exactly the envelope the
/// spec requires: owner id, action type, target document id (where
/// applicable), an idempotency key, a created timestamp and retry state.
class OwnerQueuedAction {
  const OwnerQueuedAction({
    required this.idempotencyKey,
    required this.ownerId,
    required this.type,
    required this.createdAt,
    required this.attempts,
    this.notificationId,
    this.payload,
    this.lastError,
  });

  final String idempotencyKey;
  final String ownerId;
  final OwnerQueuedActionType type;
  final String? notificationId;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  OwnerQueuedAction copyWith({int? attempts, String? lastError}) {
    return OwnerQueuedAction(
      idempotencyKey: idempotencyKey,
      ownerId: ownerId,
      type: type,
      notificationId: notificationId,
      payload: payload,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'ownerId': ownerId,
    'type': type.name,
    'notificationId': notificationId,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'attempts': attempts,
    'lastError': lastError,
  };

  factory OwnerQueuedAction.fromJson(Map<String, dynamic> json) {
    return OwnerQueuedAction(
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      type: OwnerQueuedActionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => OwnerQueuedActionType.markRead,
      ),
      notificationId: json['notificationId']?.toString(),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError']?.toString(),
    );
  }
}

/// Thrown by a queue [OwnerNotificationCacheStore.sync] `send` callback when
/// the failure is permanent (`not-found`, `permission-denied`,
/// `unauthenticated`, `invalid-argument`) so the action is dropped rather
/// than retried forever.
class OwnerPermanentSyncError implements Exception {
  const OwnerPermanentSyncError(this.message);
  final String message;
  @override
  String toString() => 'OwnerPermanentSyncError: $message';
}

class OwnerQueueSyncResult {
  const OwnerQueueSyncResult({
    required this.synced,
    required this.dropped,
    required this.remaining,
  });
  final int synced;
  final int dropped;
  final int remaining;
}

/// Collapsing / superseding logic shared by both store implementations, so
/// the queue never grows unbounded from repeated offline taps and a later
/// delete supersedes an earlier mark-read for the same id.
List<OwnerQueuedAction> applyQueueCollapse(
  List<OwnerQueuedAction> existing,
  OwnerQueuedActionType type,
  String? notificationId,
) {
  final queue = [...existing];
  final collapsible = type == OwnerQueuedActionType.markAllRead ||
      type == OwnerQueuedActionType.clearAll ||
      type == OwnerQueuedActionType.updatePreferences;
  if (collapsible) {
    queue.removeWhere((a) => a.type == type);
  } else if (notificationId != null) {
    queue.removeWhere(
      (a) => a.notificationId == notificationId && a.type == type,
    );
    // A delete supersedes any pending mark-read / archive for the same id.
    if (type == OwnerQueuedActionType.delete) {
      queue.removeWhere(
        (a) =>
            a.notificationId == notificationId &&
            (a.type == OwnerQueuedActionType.markRead ||
                a.type == OwnerQueuedActionType.archive),
      );
    }
  }
  return queue;
}

String newIdempotencyKey(
  String ownerId,
  OwnerQueuedActionType type,
  String? notificationId,
) =>
    '${ownerId}_${type.name}_${notificationId ?? '*'}_'
    '${DateTime.now().microsecondsSinceEpoch}';
