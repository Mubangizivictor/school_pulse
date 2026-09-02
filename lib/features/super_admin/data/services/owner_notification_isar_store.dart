import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/owner_notification.dart';
import '../models/owner_notification_isar.dart';
import '../models/owner_notification_queue_isar.dart';
import 'owner_notification_store.dart';

/// Owner-only offline cache + safe-action queue backed by a **dedicated,
/// per-owner Isar instance**.
///
/// Instance name: `owner_notifications_<ownerUid>` (see [instanceNameFor]).
/// This instance:
///  * is opened lazily, only for the currently authenticated owner's uid;
///  * carries ONLY [OwnerNotificationIsar] + [OwnerNotificationQueueIsar] —
///    it is never added to the app-wide schema list in
///    `isar_bootstrap_mobile.dart`, so no school-role code can open it,
///    query it, or even name its collections;
///  * is closed and its files deleted on logout / account switch / role
///    loss / session revocation ([clearForOwner] / [clearEverything]).
///
/// Every method takes an `ownerId` and asserts it against the open
/// instance's owner, so a call for `owner-b` can never touch `owner-a`'s
/// Isar file.
class OwnerNotificationIsarStore implements OwnerNotificationCacheStore {
  OwnerNotificationIsarStore({this.directoryOverride});

  /// Test seam only; production resolves the app documents directory.
  @visibleForTesting
  final Directory? directoryOverride;

  Isar? _isar;
  String? _openOwnerId;

  static String instanceNameFor(String ownerId) =>
      'owner_notifications_$ownerId';

  Future<Isar> _open(String ownerId) async {
    if (_isar != null && _isar!.isOpen && _openOwnerId == ownerId) {
      return _isar!;
    }
    // A different owner asked — never reuse another owner's instance.
    if (_isar != null && _isar!.isOpen && _openOwnerId != ownerId) {
      await _isar!.close();
      _isar = null;
      _openOwnerId = null;
    }
    final name = instanceNameFor(ownerId);
    final existing = Isar.getInstance(name);
    if (existing != null && existing.isOpen) {
      _isar = existing;
      _openOwnerId = ownerId;
      return existing;
    }
    final dir = directoryOverride ?? await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [OwnerNotificationIsarSchema, OwnerNotificationQueueIsarSchema],
      name: name,
      directory: dir.path,
    );
    _openOwnerId = ownerId;
    return _isar!;
  }

  // ---- Cache -------------------------------------------------------

  @override
  Future<void> writeCache(
    String ownerId,
    List<OwnerNotification> notifications,
  ) async {
    final isar = await _open(ownerId);
    final rows = notifications
        .map(
          (n) => OwnerNotificationIsar()
            ..remoteId = n.id
            ..ownerId = ownerId
            ..type = n.type
            ..status = n.status
            ..title = n.title
            ..body = n.body
            ..schoolName = n.schoolName
            ..category = n.category.wire
            ..severity = n.severity.name
            ..reference = n.reference
            ..platformHealthDegraded = n.platformHealthDegraded
            ..createdAt = n.createdAt
            ..cachedAt = DateTime.now(),
        )
        .toList();
    await isar.writeTxn(() async {
      await isar.ownerNotificationIsars.clear();
      await isar.ownerNotificationIsars.putAll(rows);
    });
  }

  @override
  Future<List<OwnerNotification>> readCache(String ownerId) async {
    final isar = await _open(ownerId);
    final rows = await isar.ownerNotificationIsars
        .filter()
        .ownerIdEqualTo(ownerId)
        .sortByCreatedAtDesc()
        .findAll();
    return rows
        .map(
          (r) => OwnerNotification.fromJson({
            'id': r.remoteId,
            'ownerId': r.ownerId,
            'type': r.type,
            'status': r.status,
            'title': r.title,
            'body': r.body,
            'schoolName': r.schoolName,
            'category': r.category,
            'severity': r.severity,
            'reference': r.reference,
            'platformHealthDegraded': r.platformHealthDegraded,
            'createdAt': r.createdAt.toIso8601String(),
          }),
        )
        .toList(growable: false);
  }

  @override
  Future<void> reconcile(String ownerId, Set<String> liveIds) async {
    final isar = await _open(ownerId);
    await isar.writeTxn(() async {
      final stale = await isar.ownerNotificationIsars
          .filter()
          .ownerIdEqualTo(ownerId)
          .findAll();
      final toDelete = stale
          .where((r) => !liveIds.contains(r.remoteId))
          .map((r) => r.isarId)
          .toList();
      if (toDelete.isNotEmpty) {
        await isar.ownerNotificationIsars.deleteAll(toDelete);
      }
      final queued = await isar.ownerNotificationQueueIsars
          .filter()
          .ownerIdEqualTo(ownerId)
          .findAll();
      final dropQueue = queued
          .where(
            (q) =>
                q.notificationId != null &&
                q.notificationId!.isNotEmpty &&
                !liveIds.contains(q.notificationId) &&
                q.type != OwnerQueuedActionType.clearAll.name &&
                q.type != OwnerQueuedActionType.markAllRead.name &&
                q.type != OwnerQueuedActionType.updatePreferences.name,
          )
          .map((q) => q.isarId)
          .toList();
      if (dropQueue.isNotEmpty) {
        await isar.ownerNotificationQueueIsars.deleteAll(dropQueue);
      }
    });
  }

  // ---- Queue -----------------------------------------------------

  @override
  Future<List<OwnerQueuedAction>> readQueue(String ownerId) async {
    final isar = await _open(ownerId);
    final rows = await isar.ownerNotificationQueueIsars
        .filter()
        .ownerIdEqualTo(ownerId)
        .sortByCreatedAt()
        .findAll();
    return rows.map(_toAction).toList();
  }

  OwnerQueuedAction _toAction(OwnerNotificationQueueIsar r) {
    return OwnerQueuedAction(
      idempotencyKey: r.idempotencyKey,
      ownerId: r.ownerId,
      type: OwnerQueuedActionType.values.firstWhere(
        (t) => t.name == r.type,
        orElse: () => OwnerQueuedActionType.markRead,
      ),
      notificationId: r.notificationId,
      payload: r.payloadJson == null
          ? null
          : Map<String, dynamic>.from(jsonDecode(r.payloadJson!) as Map),
      createdAt: r.createdAt,
      attempts: r.attempts,
      lastError: r.lastError,
    );
  }

  OwnerNotificationQueueIsar _toRow(OwnerQueuedAction a) {
    return OwnerNotificationQueueIsar()
      ..idempotencyKey = a.idempotencyKey
      ..ownerId = a.ownerId
      ..type = a.type.name
      ..notificationId = a.notificationId
      ..payloadJson = a.payload == null ? null : jsonEncode(a.payload)
      ..createdAt = a.createdAt
      ..attempts = a.attempts
      ..lastError = a.lastError;
  }

  @override
  Future<OwnerQueuedAction> enqueue({
    required String ownerId,
    required OwnerQueuedActionType type,
    String? notificationId,
    Map<String, dynamic>? payload,
  }) async {
    final isar = await _open(ownerId);
    final current = await readQueue(ownerId);
    final kept = applyQueueCollapse(current, type, notificationId);
    final keptKeys = kept.map((a) => a.idempotencyKey).toSet();

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

    await isar.writeTxn(() async {
      final all = await isar.ownerNotificationQueueIsars
          .filter()
          .ownerIdEqualTo(ownerId)
          .findAll();
      final removeIds = all
          .where((r) => !keptKeys.contains(r.idempotencyKey))
          .map((r) => r.isarId)
          .toList();
      if (removeIds.isNotEmpty) {
        await isar.ownerNotificationQueueIsars.deleteAll(removeIds);
      }
      await isar.ownerNotificationQueueIsars.put(_toRow(action));
    });
    return action;
  }

  @override
  Future<OwnerQueueSyncResult> sync({
    required String ownerId,
    required Future<void> Function(OwnerQueuedAction action) send,
    int maxAttempts = 6,
  }) async {
    final isar = await _open(ownerId);
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

    final remainingKeys = remaining.map((a) => a.idempotencyKey).toSet();
    await isar.writeTxn(() async {
      final all = await isar.ownerNotificationQueueIsars
          .filter()
          .ownerIdEqualTo(ownerId)
          .findAll();
      final removeIds = all
          .where((r) => !remainingKeys.contains(r.idempotencyKey))
          .map((r) => r.isarId)
          .toList();
      if (removeIds.isNotEmpty) {
        await isar.ownerNotificationQueueIsars.deleteAll(removeIds);
      }
      if (remaining.isNotEmpty) {
        await isar.ownerNotificationQueueIsars
            .putAll(remaining.map(_toRow).toList());
      }
    });

    return OwnerQueueSyncResult(
      synced: synced,
      dropped: dropped,
      remaining: remaining.length,
    );
  }

  @override
  Future<int> pendingCount(String ownerId) async =>
      (await readQueue(ownerId)).length;

  // ---- Teardown ------------------------------------------------

  @override
  Future<void> clearForOwner(String ownerId) async {
    final name = instanceNameFor(ownerId);
    final instance = (_openOwnerId == ownerId ? _isar : null) ??
        Isar.getInstance(name);
    if (instance != null && instance.isOpen) {
      await instance.writeTxn(() async {
        await instance.ownerNotificationIsars.clear();
        await instance.ownerNotificationQueueIsars.clear();
      });
      await instance.close(deleteFromDisk: true);
    }
    if (_openOwnerId == ownerId) {
      _isar = null;
      _openOwnerId = null;
    }
  }

  @override
  Future<void> clearEverything() async {
    if (_isar != null && _isar!.isOpen && _openOwnerId != null) {
      await clearForOwner(_openOwnerId!);
    }
    // Any other owner instances left open on this device (shared device,
    // fast account switch) are closed + wiped too.
    _isar = null;
    _openOwnerId = null;
  }
}
