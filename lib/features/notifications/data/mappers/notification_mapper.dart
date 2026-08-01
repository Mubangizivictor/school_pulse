import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_category_config.dart';
import '../../domain/entities/notification_model.dart';

/// Converts between Firestore documents and [NotificationItem].
///
/// Every field is read defensively: a notification document is written by
/// Cloud Functions, by admin tooling and by several feature modules, so the
/// mapper must not throw when an older document is missing a newer field.
/// A malformed row degrading to a readable notification is always better than
/// an exception thrown while painting the list.
class NotificationMapper {
  const NotificationMapper._();

  /// Firestore collection holding per-recipient notification documents.
  static const collection = 'notifications';

  static NotificationItem fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final type = _enumFromName(
      NotificationType.values,
      data['type'] as String?,
      NotificationType.custom,
    );

    // Category is stored explicitly, but derive it from the type when absent
    // so notifications written by a module that only sets `type` still land in
    // the right tab with the right icon.
    final category = data['category'] != null
        ? _enumFromName(
            NotificationCategory.values,
            data['category'] as String?,
            NotificationCategoryCatalog.categoryForType(type),
          )
        : NotificationCategoryCatalog.categoryForType(type);

    final config = NotificationCategoryCatalog.of(category);

    final senderKind = _enumFromName(
      NotificationSourceKind.values,
      data['senderKind'] as String?,
      // No senderId means nobody to attribute it to - treat as automated
      // rather than inventing a human sender.
      data['senderId'] == null
          ? NotificationSourceKind.automated
          : NotificationSourceKind.human,
    );

    final readAt = _dateFrom(data['readAt']);
    final isPinned = data['isPinned'] as bool? ?? false;
    final isArchived = data['isArchived'] as bool? ?? false;

    return NotificationItem(
      id: id,
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? data['title'] as String
          : 'School Pulse',
      description: data['shortBody'] as String? ?? data['body'] as String? ?? '',
      longMessage: data['fullBody'] as String?,
      senderName: data['senderNameSnapshot'] as String? ??
          (senderKind == NotificationSourceKind.human
              ? 'School Pulse'
              : 'Automated System'),
      senderRole: data['senderRoleSnapshot'] as String? ?? 'School Pulse',
      senderAvatar: data['senderPhotoUrl'] as String?,
      timestamp: _dateFrom(data['createdAt']) ??
          _dateFrom(data['sentAt']) ??
          DateTime.now(),
      category: category,
      priority: _enumFromName(
        NotificationPriority.values,
        data['priority'] as String?,
        config.defaultPriority,
      ),
      status: _statusFrom(
        isPinned: isPinned,
        isArchived: isArchived,
        isRead: data['isRead'] as bool? ?? readAt != null,
      ),
      attachments: _attachmentsFrom(data['attachments']),
      bannerImageUrl: data['imageUrl'] as String?,
      schoolId: data['schoolId'] as String?,
      campusId: data['campusId'] as String?,
      recipientUserId: data['recipientUserId'] as String?,
      recipientRole: data['recipientRole'] as String?,
      type: type,
      persistence: _enumFromName(
        NotificationPersistence.values,
        data['persistence'] as String?,
        config.defaultPersistence,
      ),
      sender: NotificationSender(
        senderId: data['senderId'] as String?,
        nameSnapshot: data['senderNameSnapshot'] as String? ??
            (senderKind == NotificationSourceKind.human
                ? 'School Pulse'
                : 'Automated System'),
        roleSnapshot: data['senderRoleSnapshot'] as String? ?? 'School Pulse',
        department: data['senderDepartment'] as String?,
        photoUrl: data['senderPhotoUrl'] as String?,
        kind: senderKind,
        sourceModule: data['sourceModule'] as String?,
        triggerReason: data['triggerReason'] as String?,
      ),
      sourceModule: data['sourceModule'] as String?,
      sourceEntityId: data['sourceEntityId'] as String?,
      relatedStudentId: data['relatedStudentId'] as String?,
      relatedStudentName: data['relatedStudentName'] as String?,
      relatedParentId: data['relatedParentId'] as String?,
      relatedStaffId: data['relatedStaffId'] as String?,
      relatedConversationId: data['relatedConversationId'] as String?,
      relatedClassName: data['relatedClassName'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      deepLinkRoute: data['deepLinkRoute'] as String?,
      deepLinkParameters: _stringMapFrom(data['deepLinkParameters']),
      actions: _actionsFrom(data['actionButtons']),
      scheduledAt: _dateFrom(data['scheduledAt']),
      sentAt: _dateFrom(data['sentAt']),
      deliveredAt: _dateFrom(data['deliveredAt']),
      openedAt: _dateFrom(data['openedAt']),
      readAt: readAt,
      acknowledgedAt: _dateFrom(data['acknowledgedAt']),
      expiresAt: _dateFrom(data['expiresAt']),
      requiresAcknowledgment: data['requiresAcknowledgment'] as bool? ??
          config.requiresAcknowledgment,
      isArchived: isArchived,
      pushDeliveryStatus: _enumFromName(
        NotificationDeliveryStatus.values,
        data['pushDeliveryStatus'] as String?,
        NotificationDeliveryStatus.notApplicable,
      ),
      localDeliveryStatus: _enumFromName(
        NotificationDeliveryStatus.values,
        data['localDeliveryStatus'] as String?,
        NotificationDeliveryStatus.notApplicable,
      ),
      failureReason: data['failureReason'] as String?,
      metadata: _stringMapFrom(data['metadata']),
    );
  }

  /// Serialises for a client-originated write (composing a notification in the
  /// app). Recipient state fields are deliberately excluded - those are only
  /// ever written through the targeted state-update helpers below, so a full
  /// document write cannot clobber another device's read receipt.
  static Map<String, dynamic> toFirestore(NotificationItem item) {
    final sender = item.senderIdentity;
    return {
      'schoolId': item.schoolId,
      if (item.campusId != null) 'campusId': item.campusId,
      'recipientUserId': item.recipientUserId,
      if (item.recipientRole != null) 'recipientRole': item.recipientRole,
      'category': item.category.name,
      'type': item.type.name,
      'title': item.title,
      'shortBody': item.description,
      if (item.longMessage != null) 'fullBody': item.longMessage,
      if (sender.senderId != null) 'senderId': sender.senderId,
      'senderNameSnapshot': sender.nameSnapshot,
      'senderRoleSnapshot': sender.roleSnapshot,
      'senderKind': sender.kind.name,
      if (sender.department != null) 'senderDepartment': sender.department,
      if (sender.photoUrl != null) 'senderPhotoUrl': sender.photoUrl,
      if (item.sourceModule != null) 'sourceModule': item.sourceModule,
      if (sender.triggerReason != null) 'triggerReason': sender.triggerReason,
      if (item.sourceEntityId != null) 'sourceEntityId': item.sourceEntityId,
      if (item.relatedStudentId != null) 'relatedStudentId': item.relatedStudentId,
      if (item.relatedStudentName != null)
        'relatedStudentName': item.relatedStudentName,
      if (item.relatedParentId != null) 'relatedParentId': item.relatedParentId,
      if (item.relatedStaffId != null) 'relatedStaffId': item.relatedStaffId,
      if (item.relatedConversationId != null)
        'relatedConversationId': item.relatedConversationId,
      if (item.relatedClassName != null) 'relatedClassName': item.relatedClassName,
      if (item.bannerImageUrl != null) 'imageUrl': item.bannerImageUrl,
      if (item.thumbnailUrl != null) 'thumbnailUrl': item.thumbnailUrl,
      if (item.deepLinkRoute != null) 'deepLinkRoute': item.deepLinkRoute,
      if (item.deepLinkParameters.isNotEmpty)
        'deepLinkParameters': item.deepLinkParameters,
      if (item.actions.isNotEmpty)
        'actionButtons': item.actions.map(_actionToMap).toList(),
      if (item.attachments.isNotEmpty)
        'attachments': item.attachments.map(_attachmentToMap).toList(),
      'priority': item.priority.name,
      'persistence': item.persistence.name,
      'requiresAcknowledgment': item.requiresAcknowledgment,
      'isRead': false,
      'isPinned': false,
      'isArchived': false,
      'createdAt': item.sentAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(item.sentAt!),
      if (item.scheduledAt != null)
        'scheduledAt': Timestamp.fromDate(item.scheduledAt!),
      if (item.expiresAt != null) 'expiresAt': Timestamp.fromDate(item.expiresAt!),
      if (item.metadata.isNotEmpty) 'metadata': item.metadata,
    };
  }

  /// Field-level update for a state change.
  ///
  /// Uses `serverTimestamp` so ordering stays consistent across devices with
  /// skewed clocks, and only ever touches the specific fields being changed.
  static Map<String, dynamic> stateUpdate(String field, {bool value = true}) {
    switch (field) {
      case 'read':
        return {'isRead': true, 'readAt': FieldValue.serverTimestamp()};
      case 'unread':
        return {'isRead': false, 'readAt': FieldValue.delete()};
      case 'opened':
        return {'openedAt': FieldValue.serverTimestamp()};
      case 'acknowledged':
        return {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
          'acknowledgedAt': FieldValue.serverTimestamp(),
        };
      case 'pinned':
        return {'isPinned': value};
      case 'archived':
        return {'isArchived': value};
      default:
        return const {};
    }
  }

  // --- helpers -------------------------------------------------------------

  /// Collapses the persisted read/pinned/archived booleans onto the single
  /// [NotificationStatus] the list UI switches on. Pinned wins over read so a
  /// pinned notification keeps its pin after being read.
  static NotificationStatus _statusFrom({
    required bool isPinned,
    required bool isArchived,
    required bool isRead,
  }) {
    if (isArchived) return NotificationStatus.archived;
    if (isPinned) return NotificationStatus.pinned;
    return isRead ? NotificationStatus.read : NotificationStatus.unread;
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

  /// Accepts a Firestore [Timestamp], an ISO-8601 string or epoch millis -
  /// all three appear in practice depending on which writer produced the row.
  static DateTime? _dateFrom(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Map<String, String> _stringMapFrom(dynamic value) {
    if (value is! Map) return const {};
    final result = <String, String>{};
    value.forEach((k, v) {
      if (v != null) result[k.toString()] = v.toString();
    });
    return result;
  }

  static List<NotificationAttachment> _attachmentsFrom(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((raw) {
      return NotificationAttachment(
        name: raw['name']?.toString() ?? 'Attachment',
        type: raw['type']?.toString() ?? '',
        size: raw['size']?.toString() ?? '',
        url: raw['url']?.toString() ?? '',
      );
    }).toList();
  }

  static Map<String, dynamic> _attachmentToMap(NotificationAttachment a) => {
        'name': a.name,
        'type': a.type,
        'size': a.size,
        'url': a.url,
      };

  static List<NotificationAction> _actionsFrom(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((raw) {
      return NotificationAction(
        id: raw['id']?.toString() ?? '',
        label: raw['label']?.toString() ?? '',
        deepLinkRoute: raw['deepLinkRoute']?.toString(),
        deepLinkParameters: _stringMapFrom(raw['deepLinkParameters']),
        requiredPermission: raw['requiredPermission']?.toString(),
        isAcknowledgement: raw['isAcknowledgement'] == true,
      );
    }).toList();
  }

  static Map<String, dynamic> _actionToMap(NotificationAction a) => {
        'id': a.id,
        'label': a.label,
        if (a.deepLinkRoute != null) 'deepLinkRoute': a.deepLinkRoute,
        if (a.deepLinkParameters.isNotEmpty)
          'deepLinkParameters': a.deepLinkParameters,
        if (a.requiredPermission != null)
          'requiredPermission': a.requiredPermission,
        if (a.isAcknowledgement) 'isAcknowledgement': true,
      };
}
