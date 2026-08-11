import '../entities/notification_model.dart';

/// A notification row with an unsynced local state change, plus just
/// enough of its current state to replay each pending field to the
/// server (see NotificationRepositoryImpl._valueForField). Never has a
/// web equivalent - web writes go straight to Firestore, so nothing is
/// ever pending there.
class PendingNotificationChange {
  final String notificationId;
  final List<String> pendingFields;
  final NotificationStatus status;
  final bool isArchived;

  const PendingNotificationChange({
    required this.notificationId,
    required this.pendingFields,
    required this.status,
    required this.isArchived,
  });
}
