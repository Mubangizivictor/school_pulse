import 'package:isar/isar.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_isar.dart';

/// Names of the locally-mutable state fields, used as [NotificationIsar.pendingFields]
/// entries so the sync worker knows which columns an offline edit touched.
class PendingField {
  const PendingField._();
  static const read = 'read';
  static const unread = 'unread';
  static const opened = 'opened';
  static const acknowledged = 'acknowledged';
  static const pinned = 'pinned';
  static const archived = 'archived';
  static const deleted = 'deleted';
}

/// On-device notification cache.
///
/// Serves the notification centre when offline and paints it instantly when
/// online (the repository emits cache first, then server). Also owns the queue
/// of state changes made while offline.
abstract class NotificationLocalDataSource {
  Future<List<NotificationIsar>> query(NotificationQuery query);
  Future<NotificationIsar?> getById(String notificationId);

  /// Upserts server rows, preserving any unsynced local edits on the same row.
  Future<void> upsertAll(
    List<NotificationItem> items, {
    required String schoolId,
    required String recipientUserId,
  });

  Future<NotificationCounts> counts({
    required String schoolId,
    required String recipientUserId,
  });

  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  });

  /// Applies a state change locally and flags it for sync.
  Future<void> applyLocalStateChange({
    required String notificationId,
    required String field,
    bool value = true,
  });

  Future<void> applyBulkLocalStateChange({
    required String schoolId,
    required String recipientUserId,
    required String field,
    Set<NotificationCategory> categories = const {},
  });

  Future<List<NotificationIsar>> getPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  });

  /// Clears the pending flags once the server has accepted the change.
  Future<void> clearPendingFlags(List<String> notificationIds);

  Future<void> deleteById(String notificationId);

  /// Removes transient rows whose source has been opened elsewhere.
  Future<int> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  });

  Future<int> purgeOlderThan({
    required String schoolId,
    required String recipientUserId,
    required Map<NotificationCategory, DateTime> cutoffsByCategory,
  });

  Future<void> clearForUser({
    required String schoolId,
    required String recipientUserId,
  });
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Isar isar;

  NotificationLocalDataSourceImpl({required this.isar});

  /// Base query scoped to one tenant and recipient. Every read goes through
  /// this, so no code path can accidentally return another school's rows.
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition> _scoped(
    String schoolId,
    String recipientUserId,
  ) {
    return isar.notificationIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .recipientUserIdEqualTo(recipientUserId);
  }

  @override
  Future<List<NotificationIsar>> query(NotificationQuery q) async {
    var builder = _scoped(q.schoolId, q.recipientUserId);

    if (!q.includeArchived) {
      builder = builder.and().isArchivedEqualTo(false);
    }
    if (q.pinnedOnly) {
      builder = builder.and().statusEqualTo(NotificationStatus.pinned);
    }
    if (q.isRead == false) {
      builder = builder.and().statusEqualTo(NotificationStatus.unread);
    } else if (q.isRead == true) {
      builder = builder.and().not().statusEqualTo(NotificationStatus.unread);
    }
    if (q.relatedStudentId != null) {
      builder = builder.and().relatedStudentIdEqualTo(q.relatedStudentId);
    }
    if (q.from != null) {
      builder = builder.and().timestampGreaterThan(q.from!, include: true);
    }
    if (q.to != null) {
      builder = builder.and().timestampLessThan(q.to!, include: true);
    }
    if (q.startAfter != null) {
      builder = builder.and().timestampLessThan(q.startAfter!);
    }

    if (q.categories.isNotEmpty) {
      builder = builder.and().anyOf(
            q.categories,
            (b, NotificationCategory c) => b.categoryEqualTo(c),
          );
    }
    if (q.priorities.isNotEmpty) {
      builder = builder.and().anyOf(
            q.priorities,
            (b, NotificationPriority p) => b.priorityEqualTo(p),
          );
    }

    final term = q.searchTerm?.trim();
    if (term != null && term.isNotEmpty) {
      builder = builder.and().group(
            (b) => b
                .titleContains(term, caseSensitive: false)
                .or()
                .descriptionContains(term, caseSensitive: false)
                .or()
                .senderNameContains(term, caseSensitive: false),
          );
    }

    return builder.sortByTimestampDesc().limit(q.limit).findAll();
  }

  @override
  Future<NotificationIsar?> getById(String notificationId) {
    return isar.notificationIsars
        .filter()
        .notificationIdEqualTo(notificationId)
        .findFirst();
  }

  @override
  Future<void> upsertAll(
    List<NotificationItem> items, {
    required String schoolId,
    required String recipientUserId,
  }) async {
    if (items.isEmpty) return;

    await isar.writeTxn(() async {
      for (final item in items) {
        final existing = await isar.notificationIsars
            .filter()
            .notificationIdEqualTo(item.id)
            .findFirst();

        final row = NotificationIsar.fromEntity(
          item,
          schoolId: schoolId,
          recipientUserId: recipientUserId,
          syncedAt: DateTime.now(),
        );

        // An offline edit that has not reached the server yet must survive the
        // server row overwriting it - otherwise a background refresh silently
        // reverts a notification the user just marked read.
        if (existing != null) {
          row.id = existing.id;
          if (existing.hasPendingStateChange) {
            row.hasPendingStateChange = true;
            row.pendingFields = existing.pendingFields;
            for (final field in existing.pendingFields) {
              _applyFieldToRow(row, field, true);
            }
          }
          // Keep already-downloaded local media rather than re-fetching.
          row.localImagePath ??= existing.localImagePath;
          row.senderLocalPhotoPath ??= existing.senderLocalPhotoPath;
        }

        await isar.notificationIsars.put(row);
      }
    });
  }

  @override
  Future<NotificationCounts> counts({
    required String schoolId,
    required String recipientUserId,
  }) async {
    final rows = await _scoped(schoolId, recipientUserId)
        .isArchivedEqualTo(false)
        .findAll();
    return _countsFrom(rows);
  }

  @override
  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  }) async* {
    yield await counts(schoolId: schoolId, recipientUserId: recipientUserId);
    // fireImmediately is off because the initial value is already yielded
    // above; this only reacts to subsequent writes.
    await for (final _ in isar.notificationIsars.watchLazy()) {
      yield await counts(schoolId: schoolId, recipientUserId: recipientUserId);
    }
  }

  NotificationCounts _countsFrom(List<NotificationIsar> rows) {
    var unread = 0;
    var pinned = 0;
    var needsAck = 0;
    final byCategory = <NotificationCategory, int>{};

    for (final row in rows) {
      final isUnread = row.status == NotificationStatus.unread;
      if (isUnread) {
        unread++;
        byCategory.update(row.category, (v) => v + 1, ifAbsent: () => 1);
      }
      if (row.status == NotificationStatus.pinned) pinned++;
      if (row.requiresAcknowledgment && row.acknowledgedAt == null) needsAck++;
    }

    return NotificationCounts(
      total: rows.length,
      unread: unread,
      pinned: pinned,
      requiringAcknowledgement: needsAck,
      unreadByCategory: byCategory,
    );
  }

  @override
  Future<void> applyLocalStateChange({
    required String notificationId,
    required String field,
    bool value = true,
  }) async {
    await isar.writeTxn(() async {
      final row = await isar.notificationIsars
          .filter()
          .notificationIdEqualTo(notificationId)
          .findFirst();
      if (row == null) return;

      _applyFieldToRow(row, field, value);
      row.hasPendingStateChange = true;
      row.pendingFields = {...row.pendingFields, field}.toList();
      await isar.notificationIsars.put(row);
    });
  }

  @override
  Future<void> applyBulkLocalStateChange({
    required String schoolId,
    required String recipientUserId,
    required String field,
    Set<NotificationCategory> categories = const {},
  }) async {
    await isar.writeTxn(() async {
      var builder = _scoped(schoolId, recipientUserId);
      if (categories.isNotEmpty) {
        builder = builder.and().anyOf(
              categories,
              (b, NotificationCategory c) => b.categoryEqualTo(c),
            );
      }
      final rows = await builder.findAll();

      for (final row in rows) {
        _applyFieldToRow(row, field, true);
        row.hasPendingStateChange = true;
        row.pendingFields = {...row.pendingFields, field}.toList();
      }
      await isar.notificationIsars.putAll(rows);
    });
  }

  /// Mutates [row] for a single logical state change.
  ///
  /// Read deliberately does not clear a pinned status: pinning is a separate
  /// axis from read/unread, and a pinned notification that gets read should
  /// stay pinned.
  static void _applyFieldToRow(NotificationIsar row, String field, bool value) {
    final now = DateTime.now();
    switch (field) {
      case PendingField.read:
        if (row.status == NotificationStatus.unread) {
          row.status = NotificationStatus.read;
        }
        row.readAt ??= now;
        break;
      case PendingField.unread:
        row.status = NotificationStatus.unread;
        row.readAt = null;
        break;
      case PendingField.opened:
        row.openedAt ??= now;
        break;
      case PendingField.acknowledged:
        row.acknowledgedAt ??= now;
        // Acknowledging implies having read it.
        row.readAt ??= now;
        if (row.status == NotificationStatus.unread) {
          row.status = NotificationStatus.read;
        }
        break;
      case PendingField.pinned:
        row.status = value ? NotificationStatus.pinned : NotificationStatus.read;
        break;
      case PendingField.archived:
        row.isArchived = value;
        break;
    }
  }

  @override
  Future<List<NotificationIsar>> getPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  }) {
    return _scoped(schoolId, recipientUserId)
        .and()
        .hasPendingStateChangeEqualTo(true)
        .findAll();
  }

  @override
  Future<void> clearPendingFlags(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    await isar.writeTxn(() async {
      for (final id in notificationIds) {
        final row = await isar.notificationIsars
            .filter()
            .notificationIdEqualTo(id)
            .findFirst();
        if (row == null) continue;
        row.hasPendingStateChange = false;
        row.pendingFields = const [];
        row.syncedAt = DateTime.now();
        await isar.notificationIsars.put(row);
      }
    });
  }

  @override
  Future<void> deleteById(String notificationId) async {
    await isar.writeTxn(() async {
      await isar.notificationIsars
          .filter()
          .notificationIdEqualTo(notificationId)
          .deleteAll();
    });
  }

  @override
  Future<int> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  }) async {
    var deleted = 0;
    await isar.writeTxn(() async {
      deleted = await _scoped(schoolId, recipientUserId)
          .and()
          .persistenceEqualTo(NotificationPersistence.transient)
          .and()
          .sourceModuleEqualTo(sourceModule)
          .and()
          .sourceEntityIdEqualTo(sourceEntityId)
          .deleteAll();
    });
    return deleted;
  }

  @override
  Future<int> purgeOlderThan({
    required String schoolId,
    required String recipientUserId,
    required Map<NotificationCategory, DateTime> cutoffsByCategory,
  }) async {
    if (cutoffsByCategory.isEmpty) return 0;
    var deleted = 0;
    await isar.writeTxn(() async {
      for (final entry in cutoffsByCategory.entries) {
        deleted += await _scoped(schoolId, recipientUserId)
            .and()
            .categoryEqualTo(entry.key)
            .and()
            .timestampLessThan(entry.value)
            // Never discard something the user still has to acknowledge, even
            // if it is past its retention window.
            .and()
            .not()
            .group((b) => b
                .requiresAcknowledgmentEqualTo(true)
                .and()
                .acknowledgedAtIsNull())
            .deleteAll();
      }
    });
    return deleted;
  }

  @override
  Future<void> clearForUser({
    required String schoolId,
    required String recipientUserId,
  }) async {
    await isar.writeTxn(() async {
      await _scoped(schoolId, recipientUserId).deleteAll();
    });
  }
}
