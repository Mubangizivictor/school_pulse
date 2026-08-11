import '../../domain/entities/notification_model.dart';
import '../../domain/entities/pending_notification_change.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_local_data_source.dart';

NotificationLocalDataSource create({dynamic isar, dynamic remote}) =>
    _NotificationLocalDataSourceStub();

class _NotificationLocalDataSourceStub implements NotificationLocalDataSource {
  @override
  Future<List<NotificationItem>> query(NotificationQuery query) =>
      _unsupported();
  @override
  Future<NotificationItem?> getById(String notificationId) => _unsupported();
  @override
  Future<void> upsertAll(
    List<NotificationItem> items, {
    required String schoolId,
    required String recipientUserId,
  }) => _unsupported();
  @override
  Future<NotificationCounts> counts({
    required String schoolId,
    required String recipientUserId,
  }) => _unsupported();
  @override
  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  }) => Stream.error(
    UnimplementedError('No NotificationLocalDataSource for this platform'),
  );
  @override
  Future<void> applyLocalStateChange({
    required String notificationId,
    required String field,
    bool value = true,
  }) => _unsupported();
  @override
  Future<void> applyBulkLocalStateChange({
    required String schoolId,
    required String recipientUserId,
    required String field,
    Set<NotificationCategory> categories = const {},
  }) => _unsupported();
  @override
  Future<List<PendingNotificationChange>> getPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  }) => _unsupported();
  @override
  Future<void> clearPendingFlags(List<String> notificationIds) =>
      _unsupported();
  @override
  Future<void> deleteById(String notificationId) => _unsupported();
  @override
  Future<int> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  }) => _unsupported();
  @override
  Future<int> purgeOlderThan({
    required String schoolId,
    required String recipientUserId,
    required Map<NotificationCategory, DateTime> cutoffsByCategory,
  }) => _unsupported();
  @override
  Future<void> clearForUser({
    required String schoolId,
    required String recipientUserId,
  }) => _unsupported();

  Never _unsupported() => throw UnimplementedError(
    'No NotificationLocalDataSource for this platform',
  );
}
