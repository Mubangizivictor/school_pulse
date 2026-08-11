import '../../domain/entities/notification_model.dart';
import '../../domain/entities/pending_notification_change.dart';
import '../../domain/repositories/notification_repository.dart';

/// Names of the locally-mutable state fields, used to track which fields
/// an offline edit touched.
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

/// No Isar/isar-model import here on purpose - see
/// notification_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// notification_local_data_source_factory.dart's conditional import.
///
/// Serves the notification centre when offline and paints it instantly
/// when online on mobile (the repository emits cache first, then server).
/// Also owns the queue of state changes made while offline. Web has no
/// local database - query/getById/counts/watchCounts read straight from
/// Firestore, applyLocalStateChange/applyBulkLocalStateChange write
/// straight to Firestore, and getPendingStateChanges always returns empty
/// since nothing is ever queued there.
abstract class NotificationLocalDataSource {
  Future<List<NotificationItem>> query(NotificationQuery query);
  Future<NotificationItem?> getById(String notificationId);

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

  Future<List<PendingNotificationChange>> getPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  });

  Future<void> clearPendingFlags(List<String> notificationIds);

  Future<void> deleteById(String notificationId);

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
