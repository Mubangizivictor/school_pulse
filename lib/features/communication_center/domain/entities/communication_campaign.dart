import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';

/// The kind of notice a campaign is. Drives default channel/approval policy
/// and which delivery-summary breakdown a detail screen shows.
enum CommunicationType {
  announcement,
  generalNotice,
  urgentNotice,
  emergencyAlert,
  academicNotice,
  financeNotice,
  parentNotice,
  studentNotice,
  staffNotice,
  boardingNotice,
  transportNotice,
  healthNotice,
  eventNotice,
  reminder,
  policyUpdate,
  examNotice,
  timetableChange,
  custom,
}

extension CommunicationTypeX on CommunicationType {
  String get wireName => name;

  static CommunicationType fromWire(String? value) {
    return CommunicationType.values.firstWhere(
      (t) => t.wireName == value,
      orElse: () => CommunicationType.announcement,
    );
  }

  String get label {
    switch (this) {
      case CommunicationType.announcement:
        return 'Announcement';
      case CommunicationType.generalNotice:
        return 'General notice';
      case CommunicationType.urgentNotice:
        return 'Urgent notice';
      case CommunicationType.emergencyAlert:
        return 'Emergency alert';
      case CommunicationType.academicNotice:
        return 'Academic notice';
      case CommunicationType.financeNotice:
        return 'Finance notice';
      case CommunicationType.parentNotice:
        return 'Parent notice';
      case CommunicationType.studentNotice:
        return 'Student notice';
      case CommunicationType.staffNotice:
        return 'Staff notice';
      case CommunicationType.boardingNotice:
        return 'Boarding notice';
      case CommunicationType.transportNotice:
        return 'Transport notice';
      case CommunicationType.healthNotice:
        return 'Health notice';
      case CommunicationType.eventNotice:
        return 'Event notice';
      case CommunicationType.reminder:
        return 'Reminder';
      case CommunicationType.policyUpdate:
        return 'Policy update';
      case CommunicationType.examNotice:
        return 'Exam notice';
      case CommunicationType.timetableChange:
        return 'Timetable change';
      case CommunicationType.custom:
        return 'Custom';
    }
  }
}

enum CommunicationStatus {
  draft,
  pendingApproval,
  approved,
  scheduled,
  publishing,
  published,
  partiallyDelivered,
  delivered,
  failed,
  cancelled,
  expired,
  archived,
}

extension CommunicationStatusX on CommunicationStatus {
  String get wireName => name;

  static CommunicationStatus fromWire(String? value) {
    return CommunicationStatus.values.firstWhere(
      (s) => s.wireName == value,
      orElse: () => CommunicationStatus.draft,
    );
  }

  bool get isEditable =>
      this == CommunicationStatus.draft ||
      this == CommunicationStatus.pendingApproval ||
      this == CommunicationStatus.approved;

  bool get isCancellable => this == CommunicationStatus.scheduled;

  bool get isSent =>
      this == CommunicationStatus.published ||
      this == CommunicationStatus.partiallyDelivered ||
      this == CommunicationStatus.delivered;
}

enum CommunicationPriority { low, medium, high, critical }

extension CommunicationPriorityX on CommunicationPriority {
  String get wireName => name;

  static CommunicationPriority fromWire(String? value) {
    return CommunicationPriority.values.firstWhere(
      (p) => p.wireName == value,
      orElse: () => CommunicationPriority.medium,
    );
  }
}

/// Per-channel delivery counters, as recorded by the notification delivery
/// service - never fabricated client-side.
class CommunicationDeliverySummary extends Equatable {
  final int totalAudience;
  final int pushSent;
  final int pushFailed;

  const CommunicationDeliverySummary({
    this.totalAudience = 0,
    this.pushSent = 0,
    this.pushFailed = 0,
  });

  factory CommunicationDeliverySummary.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CommunicationDeliverySummary();
    return CommunicationDeliverySummary(
      totalAudience: (map['totalAudience'] as num?)?.toInt() ?? 0,
      pushSent: (map['pushSent'] as num?)?.toInt() ?? 0,
      pushFailed: (map['pushFailed'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalAudience, pushSent, pushFailed];
}

/// Who this campaign was actually addressed to at publish time, frozen so
/// later membership changes cannot retroactively alter the historical record.
class CommunicationAudienceSnapshot extends Equatable {
  final int recipientCount;
  final bool truncated;
  final DateTime? resolvedAt;

  const CommunicationAudienceSnapshot({
    this.recipientCount = 0,
    this.truncated = false,
    this.resolvedAt,
  });

  factory CommunicationAudienceSnapshot.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CommunicationAudienceSnapshot();
    final resolvedAt = map['resolvedAt'];
    return CommunicationAudienceSnapshot(
      recipientCount: (map['recipientCount'] as num?)?.toInt() ?? 0,
      truncated: map['truncated'] == true,
      resolvedAt: resolvedAt is DateTime
          ? resolvedAt
          : (resolvedAt?.toDate?.call() as DateTime?),
    );
  }

  @override
  List<Object?> get props => [recipientCount, truncated, resolvedAt];
}

/// A School Admin communication - the single orchestration record that
/// carries a notice from draft through publication and delivery tracking.
/// It never sends anything itself; see NotificationSendService for fan-out.
class CommunicationCampaign extends Equatable {
  final String campaignId;
  final String schoolId;
  final String title;
  final String shortSummary;
  final String body;
  final CommunicationType communicationType;
  final CommunicationPriority priority;
  final String senderId;
  final String senderNameSnapshot;
  final String? senderRoleSnapshot;
  final NotificationAudience audienceDefinition;
  final List<String> deliveryChannels;
  final String? imageUrl;
  final List<String> attachmentRefs;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final CommunicationStatus status;
  final bool acknowledgementRequired;
  final CommunicationDeliverySummary deliverySummary;
  final CommunicationAudienceSnapshot? audienceSnapshot;
  final String? failureReason;
  final int version;
  final String? supersedesCampaignId;
  final String? supersededByCampaignId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunicationCampaign({
    required this.campaignId,
    required this.schoolId,
    required this.title,
    this.shortSummary = '',
    required this.body,
    this.communicationType = CommunicationType.announcement,
    this.priority = CommunicationPriority.medium,
    required this.senderId,
    required this.senderNameSnapshot,
    this.senderRoleSnapshot,
    required this.audienceDefinition,
    this.deliveryChannels = const ['inApp', 'push'],
    this.imageUrl,
    this.attachmentRefs = const [],
    this.scheduledAt,
    this.publishedAt,
    this.expiresAt,
    this.status = CommunicationStatus.draft,
    this.acknowledgementRequired = false,
    this.deliverySummary = const CommunicationDeliverySummary(),
    this.audienceSnapshot,
    this.failureReason,
    this.version = 1,
    this.supersedesCampaignId,
    this.supersededByCampaignId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmergency => communicationType == CommunicationType.emergencyAlert;

  CommunicationCampaign copyWith({
    String? imageUrl,
    List<String>? attachmentRefs,
  }) {
    return CommunicationCampaign(
      campaignId: campaignId,
      schoolId: schoolId,
      title: title,
      shortSummary: shortSummary,
      body: body,
      communicationType: communicationType,
      priority: priority,
      senderId: senderId,
      senderNameSnapshot: senderNameSnapshot,
      senderRoleSnapshot: senderRoleSnapshot,
      audienceDefinition: audienceDefinition,
      deliveryChannels: deliveryChannels,
      imageUrl: imageUrl ?? this.imageUrl,
      attachmentRefs: attachmentRefs ?? this.attachmentRefs,
      scheduledAt: scheduledAt,
      publishedAt: publishedAt,
      expiresAt: expiresAt,
      status: status,
      acknowledgementRequired: acknowledgementRequired,
      deliverySummary: deliverySummary,
      audienceSnapshot: audienceSnapshot,
      failureReason: failureReason,
      version: version,
      supersedesCampaignId: supersedesCampaignId,
      supersededByCampaignId: supersededByCampaignId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    campaignId,
    schoolId,
    title,
    shortSummary,
    body,
    communicationType,
    priority,
    senderId,
    senderNameSnapshot,
    senderRoleSnapshot,
    audienceDefinition.toMap(),
    deliveryChannels,
    imageUrl,
    attachmentRefs,
    scheduledAt,
    publishedAt,
    expiresAt,
    status,
    acknowledgementRequired,
    deliverySummary,
    audienceSnapshot,
    failureReason,
    version,
    supersedesCampaignId,
    supersededByCampaignId,
    createdAt,
    updatedAt,
  ];
}
