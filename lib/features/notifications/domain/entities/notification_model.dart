import 'package:flutter/material.dart';

/// Broad grouping used by the notification UI for icon/colour treatment and
/// the category tabs. Deliberately coarse - the fine-grained event kind lives
/// in [NotificationType], which maps down onto one of these for display.
///
/// Existing values keep their ordinal positions because persisted Isar rows
/// store `@enumerated` category indices; append new values at the end only.
enum NotificationCategory {
  announcements,
  attendance,
  finance,
  transport,
  messages,
  homework,
  library,
  others,
  gate,
  results,
  examinations,
  timetable,
  medical,
  appointments,
  visitors,
  security,
  discipline,
  counselling,
  clubs,
  sports,
  catering,
  hostel,
  events,
  emergency,
  billing,
  system,
  support,
  platform,
}

enum NotificationPriority { low, medium, high, urgent }

/// Display/lifecycle state shown in the list. `unread`/`read`/`pinned` are the
/// original three the UI switches on; `archived` is additive.
///
/// This is the *presentation* state only. Delivery lifecycle (sent, delivered,
/// opened, read, acknowledged) is tracked separately on the entity, because the
/// spec requires delivered and read to never collapse into one another.
enum NotificationStatus { unread, read, pinned, archived }

/// Fine-grained event kind. Drives deep-link resolution and template choice.
enum NotificationType {
  // Messaging
  newMessage,
  groupMessage,
  messageRequest,
  // Attendance
  gateEntry,
  gateExit,
  lateArrival,
  studentAbsent,
  subjectAttendance,
  boardingRollCall,
  // Transport
  busBoarded,
  busDropOff,
  busDelayed,
  transportIncident,
  // Fees
  paymentReceived,
  paymentFailed,
  feeReminder,
  receiptGenerated,
  // Academics
  reportCardPublished,
  resultsPublished,
  homeworkAssigned,
  assignmentDue,
  examScheduled,
  timetableUpdated,
  // Exam Factory: question submission/moderation is teacher/moderator-
  // facing; paper workflow (approval/print/schedule/marking) is DOS/marker-
  // facing. Kept as two types, not one, so each gets its own deep-link
  // destination and permission rule below.
  examQuestionModeration,
  examPaperWorkflow,
  // Library
  bookOverdue,
  bookDueSoon,
  // Health
  nurseAlert,
  medicalAlert,
  // Appointments / visitors
  appointmentApproved,
  appointmentChanged,
  appointmentReminder,
  visitorArrived,
  // Welfare / conduct
  disciplineCase,
  counsellingNote,
  // School life
  announcement,
  eventNotice,
  clubNotice,
  sportsNotice,
  mealEligibility,
  hostelNotice,
  // Critical
  emergencyAlert,
  securityAlert,
  // Platform
  subscriptionNotice,
  systemMaintenance,
  supportTicketUpdate,
  platformAnnouncement,
  // Fallback
  custom,
}

/// Where a notification came from. Used for audit display and to decide whether
/// a human sender may legitimately be attributed.
enum NotificationSourceKind { human, automated, platform }

/// Push/local delivery outcome for a single channel.
enum NotificationDeliveryStatus {
  pending,
  sent,
  delivered,
  failed,
  expired,
  suppressed,
  notApplicable,
}

/// How long a notification survives once the user has engaged with it.
///
/// `transient` alerts (new-message pings, sync notices) are cleared once the
/// user opens the underlying source, so the notification centre does not
/// accumulate a duplicate record for every chat message. `permanent` records
/// (receipts, report publications, emergency notices) stay in history subject
/// to the school's retention policy.
enum NotificationPersistence { transient, permanent }

/// A single tappable action rendered on the details screen and, where the
/// platform supports it, on the push notification itself.
@immutable
class NotificationAction {
  /// Stable machine identifier, e.g. `view_attendance`. Matched against the
  /// push action id when the user taps a button on the system notification.
  final String id;
  final String label;

  /// Route this action opens. Resolved through the deep-link router, never
  /// pushed directly, so tenancy and permission checks always run first.
  final String? deepLinkRoute;
  final Map<String, String> deepLinkParameters;

  /// Permission required to see and invoke this action. `null` means the
  /// action is available to any recipient of the notification.
  final String? requiredPermission;

  /// Marks the acknowledgement action, which records `acknowledgedAt` rather
  /// than navigating anywhere.
  final bool isAcknowledgement;

  const NotificationAction({
    required this.id,
    required this.label,
    this.deepLinkRoute,
    this.deepLinkParameters = const {},
    this.requiredPermission,
    this.isAcknowledgement = false,
  });
}

class NotificationAttachment {
  final String name;
  final String type;
  final String size;
  final String url;

  /// Populated once the attachment has been cached for offline viewing.
  final String? localPath;

  NotificationAttachment({
    required this.name,
    required this.type,
    required this.size,
    required this.url,
    this.localPath,
  });
}

/// Identity of whoever caused the notification, snapshotted at send time.
///
/// Snapshotted rather than joined so a notification still renders correctly
/// after the sender leaves the school or changes role, and so the list does not
/// need an N+1 read per row. [kind] exists to keep the spec's rule enforceable:
/// an automated event must never be attributed to a human.
@immutable
class NotificationSender {
  final String? senderId;
  final String nameSnapshot;
  final String roleSnapshot;
  final String? department;
  final String? photoUrl;
  final String? localPhotoPath;
  final NotificationSourceKind kind;

  /// For automated notifications: which module raised it, and why.
  final String? sourceModule;
  final String? triggerReason;

  const NotificationSender({
    this.senderId,
    required this.nameSnapshot,
    required this.roleSnapshot,
    this.department,
    this.photoUrl,
    this.localPhotoPath,
    this.kind = NotificationSourceKind.human,
    this.sourceModule,
    this.triggerReason,
  });

  /// System-generated sender. Never carries a human name, per the spec's
  /// prohibition on falsely attributing automated events to a person.
  const NotificationSender.automated({required String module, String? reason})
    : senderId = null,
      nameSnapshot = 'Automated System',
      roleSnapshot = 'School Pulse',
      department = null,
      photoUrl = null,
      localPhotoPath = null,
      kind = NotificationSourceKind.automated,
      sourceModule = module,
      triggerReason = reason;

  bool get isAutomated => kind != NotificationSourceKind.human;
}

/// The notification entity consumed directly by the presentation layer.
///
/// The first block of fields is the original shape the existing screens were
/// written against and is unchanged. Everything below it is additive and
/// optional, so previously-written call sites keep compiling while the new
/// delivery, tenancy, routing and lifecycle behaviour has somewhere to live.
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String senderName;
  final String senderRole;
  final String? senderAvatar;
  final DateTime timestamp;
  final NotificationCategory category;
  final NotificationPriority priority;
  final NotificationStatus status;
  final List<NotificationAttachment> attachments;
  final String? bannerImageUrl;
  final String? longMessage;

  // --- Tenancy -------------------------------------------------------------
  /// Owning school. Every read path filters on this; a notification without a
  /// school is only ever a locally-constructed placeholder.
  final String? schoolId;
  final String? campusId;

  // --- Addressing ----------------------------------------------------------
  final String? recipientUserId;
  final String? recipientRole;

  // --- Classification ------------------------------------------------------
  final NotificationType type;
  final NotificationPersistence persistence;

  // --- Rich sender identity ------------------------------------------------
  /// Full sender record. [senderName]/[senderRole] remain the fields the list
  /// tiles read; this carries photo, department and automated-source detail for
  /// the details screen.
  final NotificationSender? sender;

  // --- Source linkage ------------------------------------------------------
  final String? sourceModule;
  final String? sourceEntityId;
  final String? relatedStudentId;
  final String? relatedStudentName;
  final String? relatedParentId;
  final String? relatedStaffId;
  final String? relatedConversationId;
  final String? relatedClassName;

  // --- Media ---------------------------------------------------------------
  final String? thumbnailUrl;
  final String? localImagePath;

  // --- Routing -------------------------------------------------------------
  /// Target route as authored by the sender or server. Always passed through
  /// the deep-link router for validation - never navigated to verbatim.
  final String? deepLinkRoute;
  final Map<String, String> deepLinkParameters;
  final List<NotificationAction> actions;

  // --- Delivery lifecycle --------------------------------------------------
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? openedAt;
  final DateTime? readAt;
  final DateTime? acknowledgedAt;
  final DateTime? expiresAt;

  final bool requiresAcknowledgment;
  final bool isArchived;
  final NotificationDeliveryStatus pushDeliveryStatus;
  final NotificationDeliveryStatus localDeliveryStatus;
  final String? failureReason;

  final Map<String, String> metadata;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.senderName,
    required this.senderRole,
    this.senderAvatar,
    required this.timestamp,
    required this.category,
    required this.priority,
    this.status = NotificationStatus.unread,
    this.attachments = const [],
    this.bannerImageUrl,
    this.longMessage,
    this.schoolId,
    this.campusId,
    this.recipientUserId,
    this.recipientRole,
    this.type = NotificationType.custom,
    this.persistence = NotificationPersistence.permanent,
    this.sender,
    this.sourceModule,
    this.sourceEntityId,
    this.relatedStudentId,
    this.relatedStudentName,
    this.relatedParentId,
    this.relatedStaffId,
    this.relatedConversationId,
    this.relatedClassName,
    this.thumbnailUrl,
    this.localImagePath,
    this.deepLinkRoute,
    this.deepLinkParameters = const {},
    this.actions = const [],
    this.scheduledAt,
    this.sentAt,
    this.deliveredAt,
    this.openedAt,
    this.readAt,
    this.acknowledgedAt,
    this.expiresAt,
    this.requiresAcknowledgment = false,
    this.isArchived = false,
    this.pushDeliveryStatus = NotificationDeliveryStatus.notApplicable,
    this.localDeliveryStatus = NotificationDeliveryStatus.notApplicable,
    this.failureReason,
    this.metadata = const {},
  });

  bool get isRead => status != NotificationStatus.unread || readAt != null;
  bool get isOpened => openedAt != null;
  bool get isAcknowledged => acknowledgedAt != null;
  bool get isPinned => status == NotificationStatus.pinned;
  bool get isTransient => persistence == NotificationPersistence.transient;

  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  /// True when acknowledgement is required but has not happened yet - the
  /// details screen uses this to keep the acknowledge action prominent.
  bool get needsAcknowledgement =>
      requiresAcknowledgment && acknowledgedAt == null;

  /// Effective sender identity, falling back to the flat name/role fields for
  /// records created before the richer [sender] existed.
  NotificationSender get senderIdentity =>
      sender ??
      NotificationSender(
        nameSnapshot: senderName,
        roleSnapshot: senderRole,
        photoUrl: senderAvatar,
        kind: NotificationSourceKind.human,
      );

  NotificationItem copyWith({
    String? title,
    String? description,
    NotificationStatus? status,
    List<NotificationAttachment>? attachments,
    String? bannerImageUrl,
    String? thumbnailUrl,
    String? localImagePath,
    String? longMessage,
    DateTime? openedAt,
    DateTime? readAt,
    DateTime? acknowledgedAt,
    DateTime? deliveredAt,
    bool? isArchived,
    NotificationDeliveryStatus? pushDeliveryStatus,
    NotificationDeliveryStatus? localDeliveryStatus,
    String? failureReason,
  }) {
    return NotificationItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      senderName: senderName,
      senderRole: senderRole,
      senderAvatar: senderAvatar,
      timestamp: timestamp,
      category: category,
      priority: priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      longMessage: longMessage ?? this.longMessage,
      schoolId: schoolId,
      campusId: campusId,
      recipientUserId: recipientUserId,
      recipientRole: recipientRole,
      type: type,
      persistence: persistence,
      sender: sender,
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
      relatedStudentId: relatedStudentId,
      relatedStudentName: relatedStudentName,
      relatedParentId: relatedParentId,
      relatedStaffId: relatedStaffId,
      relatedConversationId: relatedConversationId,
      relatedClassName: relatedClassName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      deepLinkRoute: deepLinkRoute,
      deepLinkParameters: deepLinkParameters,
      actions: actions,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      openedAt: openedAt ?? this.openedAt,
      readAt: readAt ?? this.readAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      expiresAt: expiresAt,
      requiresAcknowledgment: requiresAcknowledgment,
      isArchived: isArchived ?? this.isArchived,
      pushDeliveryStatus: pushDeliveryStatus ?? this.pushDeliveryStatus,
      localDeliveryStatus: localDeliveryStatus ?? this.localDeliveryStatus,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata,
    );
  }
}
