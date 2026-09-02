import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/owner_notification.dart';

/// Owner-only offline cache + safe-action queue for the SaaS Owner
/// notification feed.
///
/// Scope, deliberately narrow:
///  * Only the currently authenticated owner's authorized feed documents
///    are cached, under a key namespaced by that owner's uid.
///  * Only *safe* mutations queue: mark read, mark all read, delete one,
///    clear all, and preference updates. Sensitive owner actions
///    (subscription/plan edits, school lifecycle, permissions,
///    impersonation, custom-domain approval) are never queued or cached
///    offline - those callers never touch this store.
///  * Nothing sensitive is persisted: only notification ids, titles, a
///    short body and timestamps. No payment details, no plan data, no
///    credentials. Safe for the web's SharedPreferences/localStorage
///    backing per the "no unsafe browser storage of sensitive owner data"
///    rule.
///
/// On logout / account switch / role loss / session revocation the caller
/// invokes [clearForOwner] (or [clearEverything]) which wipes both the
/// cache and the queue for that owner.
class OwnerNotificationOfflineStore {
  OwnerNotificationOfflineStore({SharedPreferences? prefs}) : _injected = prefs;

  final SharedPreferences? _injected;
  SharedPreferences? _cached;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? (_cached ??= await SharedPreferences.getInstance());

  static const _cachePrefix = 'owner_notif_cache_v1_';
  static const _queuePrefix = 'owner_notif_queue_v1_';

  String _cacheKey(String ownerId) => '$_cachePrefix$ownerId';
  String _queueKey(String ownerId) => '$_queuePrefix$ownerId';

  // ---- Cache ---------------------------------------------------------

  Future<void> writeCache(
    String ownerId,
    List<OwnerNotification> notifications,
  ) async {
    final prefs = await _prefs;
    final payload = notifications
        .map(
          (n) => {
            'id': n.id,
            'ownerId': ownerId,
            'type': n.type,
            'status': n.status,
            'title': n.title,
            'body': n.body,
            'schoolName': n.schoolName,
            'createdAt': n.createdAt.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_cacheKey(ownerId), jsonEncode(payload));
  }

  Future<List<OwnerNotification>> readCache(String ownerId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey(ownerId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list
          // Defence in depth: never surface a cached row that is not this
          // owner's, even if the file were tampered with.
          .where((m) => (m['ownerId'] ?? ownerId) == ownerId)
          .map(OwnerNotification.fromJson)
          .toList(growable: false);
    } catch (_) {
      // Corrupt cache is evicted rather than surfaced.
      await prefs.remove(_cacheKey(ownerId));
      return const [];
    }
  }

  /// Drops cached rows (and any queued actions targeting them) whose ids are
  /// no longer present server-side - the "evict stale / revoked / deleted"
  /// rule.
  Future<void> reconcile(String ownerId, Set<String> liveIds) async {
    final cached = await readCache(ownerId);
    final kept = cached.where((n) => liveIds.contains(n.id)).toList();
    if (kept.length != cached.length) {
      await writeCache(ownerId, kept);
    }
    final queue = await readQueue(ownerId);
    final prunedQueue = queue
        .where(
          (a) =>
              a.notificationId == null ||
              a.notificationId!.isEmpty ||
              liveIds.contains(a.notificationId) ||
              a.type == OwnerQueuedActionType.clearAll ||
              a.type == OwnerQueuedActionType.markAllRead ||
              a.type == OwnerQueuedActionType.updatePreferences,
        )
        .toList();
    if (prunedQueue.length != queue.length) {
      await _writeQueue(ownerId, prunedQueue);
    }
  }

  // ---- Queue -------------------------------------------------------

  Future<List<OwnerQueuedAction>> readQueue(String ownerId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_queueKey(ownerId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(OwnerQueuedAction.fromJson).toList();
    } catch (_) {
      await prefs.remove(_queueKey(ownerId));
      return const [];
    }
  }

  Future<void> _writeQueue(
    String ownerId,
    List<OwnerQueuedAction> actions,
  ) async {
    final prefs = await _prefs;
    if (actions.isEmpty) {
      await prefs.remove(_queueKey(ownerId));
      return;
    }
    await prefs.setString(
      _queueKey(ownerId),
      jsonEncode(actions.map((a) => a.toJson()).toList()),
    );
  }

  /// Enqueues a safe action. A [markAllRead] / [clearAll] / [updatePreferences]
  /// collapses any earlier same-type entry so the queue never grows
  /// unbounded from repeated taps while offline.
  Future<OwnerQueuedAction> enqueue({
    required String ownerId,
    required OwnerQueuedActionType type,
    String? notificationId,
    Map<String, dynamic>? payload,
  }) async {
    final queue = [...await readQueue(ownerId)];
    final collapsible = type == OwnerQueuedActionType.markAllRead ||
        type == OwnerQueuedActionType.clearAll ||
        type == OwnerQueuedActionType.updatePreferences;
    if (collapsible) {
      queue.removeWhere((a) => a.type == type);
    } else if (notificationId != null) {
      // A later delete supersedes a queued mark-read for the same id.
      queue.removeWhere(
        (a) => a.notificationId == notificationId && a.type == type,
      );
    }
    final action = OwnerQueuedAction(
      idempotencyKey:
          '${ownerId}_${type.name}_${notificationId ?? '*'}_${DateTime.now().microsecondsSinceEpoch}',
      ownerId: ownerId,
      type: type,
      notificationId: notificationId,
      payload: payload,
      createdAt: DateTime.now(),
      attempts: 0,
      lastError: null,
    );
    queue.add(action);
    await _writeQueue(ownerId, queue);
    return action;
  }

  /// Replays every pending action in creation order. [send] performs the
  /// real callable for one action; it must throw on failure. A thrown
  /// [OwnerPermanentSyncError] drops the action (permanent failure); any
  /// other error bumps the attempt count and is retried on the next sync,
  /// up to [maxAttempts] after which it is also dropped.
  Future<OwnerQueueSyncResult> sync({
    required String ownerId,
    required Future<void> Function(OwnerQueuedAction action) send,
    int maxAttempts = 6,
  }) async {
    final queue = await readQueue(ownerId);
    if (queue.isEmpty) {
      return const OwnerQueueSyncResult(synced: 0, dropped: 0, remaining: 0);
    }

    var synced = 0;
    var dropped = 0;
    final remaining = <OwnerQueuedAction>[];

    for (final action in queue) {
      try {
        await send(action);
        synced++;
      } on OwnerPermanentSyncError {
        dropped++;
      } catch (_) {
        final bumped = action.copyWith(
          attempts: action.attempts + 1,
          lastError: 'retry',
        );
        if (bumped.attempts >= maxAttempts) {
          dropped++;
        } else {
          remaining.add(bumped);
        }
      }
    }

    await _writeQueue(ownerId, remaining);
    return OwnerQueueSyncResult(
      synced: synced,
      dropped: dropped,
      remaining: remaining.length,
    );
  }

  Future<int> pendingCount(String ownerId) async =>
      (await readQueue(ownerId)).length;

  // ---- Teardown --------------------------------------------------

  Future<void> clearForOwner(String ownerId) async {
    final prefs = await _prefs;
    await prefs.remove(_cacheKey(ownerId));
    await prefs.remove(_queueKey(ownerId));
  }

  /// Nukes every owner's cache + queue - used when the current uid cannot
  /// be resolved (full sign-out) so nothing is left behind for the next
  /// account on a shared device.
  Future<void> clearEverything() async {
    final prefs = await _prefs;
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_cachePrefix) || k.startsWith(_queuePrefix))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

enum OwnerQueuedActionType {
  markRead,
  markAllRead,
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

/// Thrown by a queue [send] callback when the failure is permanent
/// (e.g. `not-found`, `permission-denied`) so the action is dropped rather
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
