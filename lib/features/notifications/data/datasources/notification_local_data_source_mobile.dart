import 'package:isar/isar.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/pending_notification_change.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_isar.dart';
import 'notification_local_data_source.dart';

NotificationLocalDataSource create({dynamic isar, dynamic remote}) =>
    NotificationLocalDataSourceImpl(isar: isar as Isar);

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Isar isar;

  NotificationLocalDataSourceImpl({required this.isar});

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
  _scoped(String schoolId, String recipientUserId) {
    return isar.notificationIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .recipientUserIdEqualTo(recipientUserId);
  }

  @override
  Future<List<NotificationItem>> query(NotificationQuery q) async {
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

    final rows = await builder.sortByTimestampDesc().limit(q.limit).findAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<NotificationItem?> getById(String notificationId) async {
    final row = await isar.notificationIsars
        .filter()
        .notificationIdEqualTo(notificationId)
        .findFirst();
    return row?.toEntity();
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

        if (existing != null) {
          row.id = existing.id;
          if (existing.hasPendingStateChange) {
            row.hasPendingStateChange = true;
            row.pendingFields = existing.pendingFields;
            for (final field in existing.pendingFields) {
              _applyFieldToRow(row, field, true);
            }
          }
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
    final rows = await _scoped(
      schoolId,
      recipientUserId,
    ).isArchivedEqualTo(false).findAll();
    return _countsFrom(rows);
  }

  @override
  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  }) async* {
    yield await counts(schoolId: schoolId, recipientUserId: recipientUserId);
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
        row.readAt ??= now;
        if (row.status == NotificationStatus.unread) {
          row.status = NotificationStatus.read;
        }
        break;
      case PendingField.pinned:
        row.status = value
            ? NotificationStatus.pinned
            : NotificationStatus.read;
        break;
      case PendingField.archived:
        row.isArchived = value;
        break;
    }
  }

  @override
  Future<List<PendingNotificationChange>> getPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  }) async {
    final rows = await _scoped(
      schoolId,
      recipientUserId,
    ).and().hasPendingStateChangeEqualTo(true).findAll();
    return rows
        .map(
          (r) => PendingNotificationChange(
            notificationId: r.notificationId,
            pendingFields: r.pendingFields,
            status: r.status,
            isArchived: r.isArchived,
          ),
        )
        .toList();
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
            .and()
            .not()
            .group(
              (b) => b
                  .requiresAcknowledgmentEqualTo(true)
                  .and()
                  .acknowledgedAtIsNull(),
            )
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
