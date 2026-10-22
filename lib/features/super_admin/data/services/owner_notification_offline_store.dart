import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/owner_notification.dart';
import 'owner_notification_store.dart';

export 'owner_notification_store.dart'
    show
        OwnerNotificationCacheStore,
        OwnerQueuedActionType,
        OwnerQueuedAction,
        OwnerPermanentSyncError,
        OwnerQueueSyncResult;

/// Owner-only offline cache + safe-action queue for the SaaS Owner
/// notification feed — SharedPreferences backing.
///
/// Used on **web** (Isar has no owner instance there) and as the default in
/// tests. On mobile / desktop the app uses [OwnerNotificationIsarStore]
/// instead, which opens a dedicated per-owner Isar instance.
///
/// Scope, deliberately narrow:
///  * Only the currently authenticated owner's authorized feed documents
///    are cached, under a key namespaced by that owner's uid.
///  * Only *safe* mutations queue: mark read, mark all read, archive, delete
///    one, clear all, and preference updates. Sensitive owner actions are
///    never queued or cached — those callers never touch this store.
///  * Nothing sensitive is persisted: only ids, titles, a short body,
///    category / severity tokens and timestamps.
class OwnerNotificationOfflineStore implements OwnerNotificationCacheStore {
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

  @override
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
            'category': n.category.wire,
            'severity': n.severity.name,
            'reference': n.reference,
            'platformHealthDegraded': n.platformHealthDegraded,
            'createdAt': n.createdAt.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_cacheKey(ownerId), jsonEncode(payload));
  }

  @override
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
      await prefs.remove(_cacheKey(ownerId));
      return const [];
    }
  }

  @override
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

  @override
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

  @override
  Future<OwnerQueuedAction> enqueue({
    required String ownerId,
    required OwnerQueuedActionType type,
    String? notificationId,
    Map<String, dynamic>? payload,
  }) async {
    final queue = applyQueueCollapse(
      await readQueue(ownerId),
      type,
      notificationId,
    );
    final action = OwnerQueuedAction(
      idempotencyKey: newIdempotencyKey(ownerId, type, notificationId),
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

  @override
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

  @override
  Future<int> pendingCount(String ownerId) async =>
      (await readQueue(ownerId)).length;

  // ---- Teardown --------------------------------------------------

  @override
  Future<void> clearForOwner(String ownerId) async {
    final prefs = await _prefs;
    await prefs.remove(_cacheKey(ownerId));
    await prefs.remove(_queueKey(ownerId));
  }

  @override
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
