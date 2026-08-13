import '../../domain/entities/notification_model.dart';
import '../../domain/entities/pending_notification_change.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_local_data_source.dart';
import 'notification_remote_data_source.dart';

NotificationLocalDataSource create({dynamic isar, dynamic remote}) =>
    NotificationLocalDataSourceWeb(remote as NotificationRemoteDataSource);

/// No local database on web - reads and writes go straight to Firestore
/// via the existing remote datasource. Nothing is ever pending, so
/// getPendingStateChanges is always empty and clearPendingFlags is a
/// no-op (there's nothing to clear).
class NotificationLocalDataSourceWeb implements NotificationLocalDataSource {
  final NotificationRemoteDataSource remote;

  NotificationLocalDataSourceWeb(this.remote);

  @override
  Future<List<NotificationItem>> query(NotificationQuery query) =>
      remote.fetch(query);

  @override
  Future<NotificationItem?> getById(String notificationId) =>
      remote.getById(notificationId);

  @override
  Future<void> upsertAll(
    List<NotificationItem> items, {
    required String schoolId,
    required String recipientUserId,
  }) async {}

  @override
  Future<NotificationCounts> counts({
    required String schoolId,
    required String recipientUserId,
  }) async {
    final items = await remote.fetch(
      NotificationQuery(
        schoolId: schoolId,
        recipientUserId: recipientUserId,
        includeArchived: false,
      ),
    );
    return _countsFrom(items);
  }

  @override
  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  }) {
    return remote
        .watch(
          NotificationQuery(
            schoolId: schoolId,
            recipientUserId: recipientUserId,
            includeArchived: false,
          ),
        )
        .map(_countsFrom);
  }

  NotificationCounts _countsFrom(List<NotificationItem> items) {
    var unread = 0;
    var pinned = 0;
    var needsAck = 0;
    final byCategory = <NotificationCategory, int>{};

    for (final item in items) {
      final isUnread = item.status == NotificationStatus.unread;
      if (isUnread) {
        unread++;
        byCategory.update(item.category, (v) => v + 1, ifAbsent: () => 1);
      }
      if (item.status == NotificationStatus.pinned) pinned++;
      if (item.requiresAcknowledgment && item.acknowledgedAt == null) {
        needsAck++;
      }
    }

    return NotificationCounts(
      total: items.length,
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
  }) {
    return remote.applyStateChange(
      notificationId: notificationId,
      field: field,
      value: value,
    );
  }

  @override
  Future<void> applyBulkLocalStateChange({
    required String schoolId,
    required String recipientUserId,
    required String field,
    Set<NotificationCategory> categories = const {},
  }) {
    return remote.applyBulkStateChange(
      schoolId: schoolId,
      recipientUserId: recipientUserId,
      field: field,
      categories: categories,
    );
  }

  @override
  Future<List<PendingNotificationChange>> getPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  }) async => [];

  @override
  Future<void> clearPendingFlags(List<String> notificationIds) async {}

  @override
  Future<void> deleteById(String notificationId) =>
      remote.delete(notificationId);

  @override
  Future<int> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  }) async {
    return remote.clearTransientForSource(
      schoolId: schoolId,
      recipientUserId: recipientUserId,
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
    );
  }

  @override
  Future<int> purgeOlderThan({
    required String schoolId,
    required String recipientUserId,
    required Map<NotificationCategory, DateTime> cutoffsByCategory,
  }) async => 0;

  @override
  Future<void> clearForUser({
    required String schoolId,
    required String recipientUserId,
  }) async {}
}
