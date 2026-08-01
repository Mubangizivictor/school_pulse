import '../../domain/entities/notification_category_config.dart';
import '../../domain/entities/notification_model.dart';

/// A parsed FCM data payload.
///
/// FCM data values are always strings, so every field here is parsed
/// defensively from `Map<String, dynamic>`. This type exists so the rest of
/// the push pipeline never touches the raw map, and so a malformed or hostile
/// payload is rejected at one boundary rather than causing a crash somewhere
/// deep in the UI.
///
/// The payload is treated as untrusted: it names a notification and carries
/// enough to render a banner, but the authoritative record is always the
/// Firestore document fetched by [notificationId]. In particular
/// [deepLinkRoute] is never navigated to directly - see
/// NotificationDeepLinkRouter, which resolves destinations from the typed
/// [type] instead.
class NotificationPushPayload {
  final String notificationId;
  final String? schoolId;
  final String? recipientUserId;

  final String title;
  final String body;

  final NotificationCategory category;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationPersistence persistence;

  final String? senderName;
  final String? senderRole;
  final String? senderPhotoUrl;
  final bool isAutomated;

  final String? imageUrl;
  final String? thumbnailUrl;

  final String? sourceModule;
  final String? sourceEntityId;
  final String? relatedStudentId;
  final String? relatedStudentName;
  final String? relatedConversationId;

  /// Advisory only - the router derives the real destination from [type].
  final String? deepLinkRoute;

  final bool requiresAcknowledgment;

  /// Server-supplied key used to suppress duplicates when the same event is
  /// delivered twice (retry, or the same user on two devices in one session).
  final String? collapseKey;

  const NotificationPushPayload({
    required this.notificationId,
    this.schoolId,
    this.recipientUserId,
    required this.title,
    required this.body,
    required this.category,
    required this.type,
    required this.priority,
    required this.persistence,
    this.senderName,
    this.senderRole,
    this.senderPhotoUrl,
    this.isAutomated = false,
    this.imageUrl,
    this.thumbnailUrl,
    this.sourceModule,
    this.sourceEntityId,
    this.relatedStudentId,
    this.relatedStudentName,
    this.relatedConversationId,
    this.deepLinkRoute,
    this.requiresAcknowledgment = false,
    this.collapseKey,
  });

  /// Parses an FCM `message.data` map.
  ///
  /// Returns null when the payload carries no notification id - without one
  /// there is nothing to fetch, mark read, or route to, so it is not a
  /// notification this pipeline can handle.
  static NotificationPushPayload? tryParse(Map<String, dynamic> data) {
    final id = _string(data['notificationId']) ?? _string(data['id']);
    if (id == null || id.isEmpty) return null;

    final type = _enumFromName(
      NotificationType.values,
      _string(data['type']),
      NotificationType.custom,
    );
    final category = _enumFromName(
      NotificationCategory.values,
      _string(data['category']),
      NotificationCategoryCatalog.categoryForType(type),
    );
    final config = NotificationCategoryCatalog.of(category);

    return NotificationPushPayload(
      notificationId: id,
      schoolId: _string(data['schoolId']),
      recipientUserId: _string(data['recipientUserId']),
      title: _string(data['title']) ?? 'School Pulse',
      body: _string(data['body']) ?? _string(data['shortBody']) ?? '',
      category: category,
      type: type,
      priority: _enumFromName(
        NotificationPriority.values,
        _string(data['priority']),
        config.defaultPriority,
      ),
      persistence: _enumFromName(
        NotificationPersistence.values,
        _string(data['persistence']),
        config.defaultPersistence,
      ),
      senderName: _string(data['senderName']),
      senderRole: _string(data['senderRole']),
      senderPhotoUrl: _string(data['senderPhotoUrl']),
      isAutomated: _bool(data['isAutomated']),
      imageUrl: _string(data['imageUrl']),
      thumbnailUrl: _string(data['thumbnailUrl']),
      sourceModule: _string(data['sourceModule']),
      sourceEntityId: _string(data['sourceEntityId']),
      relatedStudentId: _string(data['relatedStudentId']),
      relatedStudentName: _string(data['relatedStudentName']),
      relatedConversationId: _string(data['relatedConversationId']),
      deepLinkRoute: _string(data['deepLinkRoute']),
      requiresAcknowledgment: _bool(data['requiresAcknowledgment']) ||
          config.requiresAcknowledgment,
      collapseKey: _string(data['collapseKey']),
    );
  }

  /// Builds a provisional [NotificationItem] for immediate display.
  ///
  /// Used to paint a banner the instant a push arrives, before the Firestore
  /// document has been read. Marked with `provisional` metadata so it is never
  /// mistaken for the authoritative record.
  NotificationItem toProvisionalItem() {
    return NotificationItem(
      id: notificationId,
      title: title,
      description: body,
      senderName: senderName ?? (isAutomated ? 'Automated System' : 'School Pulse'),
      senderRole: senderRole ?? 'School Pulse',
      senderAvatar: senderPhotoUrl,
      timestamp: DateTime.now(),
      category: category,
      priority: priority,
      schoolId: schoolId,
      recipientUserId: recipientUserId,
      type: type,
      persistence: persistence,
      sender: isAutomated
          ? NotificationSender.automated(module: sourceModule ?? 'system')
          : NotificationSender(
              nameSnapshot: senderName ?? 'School Pulse',
              roleSnapshot: senderRole ?? 'School Pulse',
              photoUrl: senderPhotoUrl,
            ),
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
      relatedStudentId: relatedStudentId,
      relatedStudentName: relatedStudentName,
      relatedConversationId: relatedConversationId,
      bannerImageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      deepLinkRoute: deepLinkRoute,
      requiresAcknowledgment: requiresAcknowledgment,
      deliveredAt: DateTime.now(),
      pushDeliveryStatus: NotificationDeliveryStatus.delivered,
      metadata: const {'provisional': 'true'},
    );
  }

  /// Stable per-notification id for the OS notification slot.
  ///
  /// Derived from [collapseKey] when the server supplied one, so a re-sent
  /// event replaces its earlier banner instead of stacking a duplicate.
  /// Masked to 31 bits because Android notification ids are signed 32-bit.
  int get systemNotificationId =>
      (collapseKey ?? notificationId).hashCode & 0x7fffffff;

  static String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    final text = _string(value)?.toLowerCase();
    return text == 'true' || text == '1';
  }

  static T _enumFromName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
