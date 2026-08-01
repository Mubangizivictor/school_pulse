import 'package:isar/isar.dart';

import '../../domain/entities/notification_model.dart';

part 'notification_isar.g.dart';

/// Offline cache row for a notification.
///
/// Mirrors [NotificationItem] flattened for Isar: nested objects become
/// embedded types, and maps become parallel key/value lists since Isar has no
/// map support. Enum fields are `@enumerated`, so their ordinal positions are
/// persisted - append new enum values, never reorder existing ones.
@collection
class NotificationIsar {
  Id id = Isar.autoIncrement;

  /// Firestore document id. Unique with `replace` so re-syncing the same
  /// notification updates the row rather than duplicating it.
  @Index(unique: true, replace: true)
  late String notificationId;

  /// Every read path filters on school + recipient, so this composite index is
  /// what keeps the notification centre fast as history accumulates.
  @Index(composite: [CompositeIndex('recipientUserId')])
  late String schoolId;

  late String recipientUserId;
  String? campusId;
  String? recipientRole;

  late String title;
  late String description;
  String? longMessage;

  late String senderName;
  late String senderRole;
  String? senderAvatar;
  String? senderId;
  String? senderDepartment;
  String? senderLocalPhotoPath;

  @enumerated
  late NotificationSourceKind senderKind;

  String? sourceModule;
  String? triggerReason;

  @Index()
  late DateTime timestamp;

  @enumerated
  late NotificationCategory category;

  @enumerated
  late NotificationPriority priority;

  @enumerated
  late NotificationStatus status;

  @enumerated
  late NotificationType type;

  @enumerated
  late NotificationPersistence persistence;

  @enumerated
  late NotificationDeliveryStatus pushDeliveryStatus;

  @enumerated
  late NotificationDeliveryStatus localDeliveryStatus;

  String? sourceEntityId;
  String? relatedStudentId;
  String? relatedStudentName;
  String? relatedParentId;
  String? relatedStaffId;
  String? relatedConversationId;
  String? relatedClassName;

  String? bannerImageUrl;
  String? thumbnailUrl;
  String? localImagePath;

  String? deepLinkRoute;

  /// Deep-link parameters, stored as parallel lists (Isar has no map type).
  /// Always written together and read back by zipping - see [_zip].
  List<String> deepLinkParamKeys = const [];
  List<String> deepLinkParamValues = const [];

  List<String> metadataKeys = const [];
  List<String> metadataValues = const [];

  List<NotificationActionIsar> actions = const [];
  List<NotificationAttachmentIsar> attachments = const [];

  DateTime? scheduledAt;
  DateTime? sentAt;
  DateTime? deliveredAt;
  DateTime? openedAt;
  DateTime? readAt;
  DateTime? acknowledgedAt;
  DateTime? expiresAt;

  late bool requiresAcknowledgment;

  @Index()
  late bool isArchived;

  String? failureReason;

  /// Set when a state change (read/acknowledge/archive) was made offline and
  /// still needs pushing. The sync worker drains rows where this is true.
  @Index()
  late bool hasPendingStateChange;

  /// Which local edits are unsynced, e.g. `['read', 'acknowledged']`. Kept as
  /// a field list rather than a single flag so two offline edits to different
  /// fields do not overwrite one another on merge.
  List<String> pendingFields = const [];

  /// When this row was last written from the server. Used to resolve conflicts
  /// in favour of whichever side is newer.
  DateTime? syncedAt;

  NotificationIsar();

  factory NotificationIsar.fromEntity(
    NotificationItem entity, {
    required String schoolId,
    required String recipientUserId,
    bool hasPendingStateChange = false,
    List<String> pendingFields = const [],
    DateTime? syncedAt,
  }) {
    final sender = entity.senderIdentity;
    return NotificationIsar()
      ..notificationId = entity.id
      ..schoolId = entity.schoolId ?? schoolId
      ..recipientUserId = entity.recipientUserId ?? recipientUserId
      ..campusId = entity.campusId
      ..recipientRole = entity.recipientRole
      ..title = entity.title
      ..description = entity.description
      ..longMessage = entity.longMessage
      ..senderName = entity.senderName
      ..senderRole = entity.senderRole
      ..senderAvatar = entity.senderAvatar
      ..senderId = sender.senderId
      ..senderDepartment = sender.department
      ..senderLocalPhotoPath = sender.localPhotoPath
      ..senderKind = sender.kind
      ..sourceModule = entity.sourceModule ?? sender.sourceModule
      ..triggerReason = sender.triggerReason
      ..timestamp = entity.timestamp
      ..category = entity.category
      ..priority = entity.priority
      ..status = entity.status
      ..type = entity.type
      ..persistence = entity.persistence
      ..pushDeliveryStatus = entity.pushDeliveryStatus
      ..localDeliveryStatus = entity.localDeliveryStatus
      ..sourceEntityId = entity.sourceEntityId
      ..relatedStudentId = entity.relatedStudentId
      ..relatedStudentName = entity.relatedStudentName
      ..relatedParentId = entity.relatedParentId
      ..relatedStaffId = entity.relatedStaffId
      ..relatedConversationId = entity.relatedConversationId
      ..relatedClassName = entity.relatedClassName
      ..bannerImageUrl = entity.bannerImageUrl
      ..thumbnailUrl = entity.thumbnailUrl
      ..localImagePath = entity.localImagePath
      ..deepLinkRoute = entity.deepLinkRoute
      ..deepLinkParamKeys = entity.deepLinkParameters.keys.toList()
      ..deepLinkParamValues = entity.deepLinkParameters.values.toList()
      ..metadataKeys = entity.metadata.keys.toList()
      ..metadataValues = entity.metadata.values.toList()
      ..actions =
          entity.actions.map(NotificationActionIsar.fromEntity).toList()
      ..attachments =
          entity.attachments.map(NotificationAttachmentIsar.fromEntity).toList()
      ..scheduledAt = entity.scheduledAt
      ..sentAt = entity.sentAt
      ..deliveredAt = entity.deliveredAt
      ..openedAt = entity.openedAt
      ..readAt = entity.readAt
      ..acknowledgedAt = entity.acknowledgedAt
      ..expiresAt = entity.expiresAt
      ..requiresAcknowledgment = entity.requiresAcknowledgment
      ..isArchived = entity.isArchived
      ..failureReason = entity.failureReason
      ..hasPendingStateChange = hasPendingStateChange
      ..pendingFields = pendingFields
      ..syncedAt = syncedAt;
  }

  NotificationItem toEntity() {
    return NotificationItem(
      id: notificationId,
      title: title,
      description: description,
      senderName: senderName,
      senderRole: senderRole,
      senderAvatar: senderAvatar,
      timestamp: timestamp,
      category: category,
      priority: priority,
      status: status,
      attachments: attachments.map((a) => a.toEntity()).toList(),
      bannerImageUrl: bannerImageUrl,
      longMessage: longMessage,
      schoolId: schoolId,
      campusId: campusId,
      recipientUserId: recipientUserId,
      recipientRole: recipientRole,
      type: type,
      persistence: persistence,
      sender: NotificationSender(
        senderId: senderId,
        nameSnapshot: senderName,
        roleSnapshot: senderRole,
        department: senderDepartment,
        photoUrl: senderAvatar,
        localPhotoPath: senderLocalPhotoPath,
        kind: senderKind,
        sourceModule: sourceModule,
        triggerReason: triggerReason,
      ),
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
      relatedStudentId: relatedStudentId,
      relatedStudentName: relatedStudentName,
      relatedParentId: relatedParentId,
      relatedStaffId: relatedStaffId,
      relatedConversationId: relatedConversationId,
      relatedClassName: relatedClassName,
      thumbnailUrl: thumbnailUrl,
      localImagePath: localImagePath,
      deepLinkRoute: deepLinkRoute,
      deepLinkParameters: _zip(deepLinkParamKeys, deepLinkParamValues),
      actions: actions.map((a) => a.toEntity()).toList(),
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      deliveredAt: deliveredAt,
      openedAt: openedAt,
      readAt: readAt,
      acknowledgedAt: acknowledgedAt,
      expiresAt: expiresAt,
      requiresAcknowledgment: requiresAcknowledgment,
      isArchived: isArchived,
      pushDeliveryStatus: pushDeliveryStatus,
      localDeliveryStatus: localDeliveryStatus,
      failureReason: failureReason,
      metadata: _zip(metadataKeys, metadataValues),
    );
  }

  /// Rebuilds a map from parallel key/value lists, tolerating a length
  /// mismatch (possible if a row was written by an older schema) rather than
  /// throwing while painting the list.
  static Map<String, String> _zip(List<String> keys, List<String> values) {
    if (keys.isEmpty) return const {};
    final result = <String, String>{};
    final count = keys.length < values.length ? keys.length : values.length;
    for (var i = 0; i < count; i++) {
      result[keys[i]] = values[i];
    }
    return result;
  }
}

@embedded
class NotificationActionIsar {
  String? actionId;
  String? label;
  String? deepLinkRoute;
  List<String> paramKeys = const [];
  List<String> paramValues = const [];
  String? requiredPermission;
  bool isAcknowledgement = false;

  NotificationActionIsar();

  factory NotificationActionIsar.fromEntity(NotificationAction action) {
    return NotificationActionIsar()
      ..actionId = action.id
      ..label = action.label
      ..deepLinkRoute = action.deepLinkRoute
      ..paramKeys = action.deepLinkParameters.keys.toList()
      ..paramValues = action.deepLinkParameters.values.toList()
      ..requiredPermission = action.requiredPermission
      ..isAcknowledgement = action.isAcknowledgement;
  }

  NotificationAction toEntity() {
    return NotificationAction(
      id: actionId ?? '',
      label: label ?? '',
      deepLinkRoute: deepLinkRoute,
      deepLinkParameters: NotificationIsar._zip(paramKeys, paramValues),
      requiredPermission: requiredPermission,
      isAcknowledgement: isAcknowledgement,
    );
  }
}

@embedded
class NotificationAttachmentIsar {
  String? name;
  String? type;
  String? size;
  String? url;
  String? localPath;

  NotificationAttachmentIsar();

  factory NotificationAttachmentIsar.fromEntity(
    NotificationAttachment attachment,
  ) {
    return NotificationAttachmentIsar()
      ..name = attachment.name
      ..type = attachment.type
      ..size = attachment.size
      ..url = attachment.url
      ..localPath = attachment.localPath;
  }

  NotificationAttachment toEntity() {
    return NotificationAttachment(
      name: name ?? '',
      type: type ?? '',
      size: size ?? '',
      url: url ?? '',
      localPath: localPath,
    );
  }
}
