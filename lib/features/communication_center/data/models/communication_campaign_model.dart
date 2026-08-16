import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';

/// Reads campaign documents written by the Cloud Functions in
/// functions/communication_campaigns.js, and builds the `campaign` payload
/// those callables expect. The client never writes a campaign document
/// directly - see saveCommunicationDraft/publishCommunicationCampaign.
class CommunicationCampaignModel extends CommunicationCampaign {
  const CommunicationCampaignModel({
    required super.campaignId,
    required super.schoolId,
    required super.title,
    super.shortSummary,
    required super.body,
    super.communicationType,
    super.priority,
    required super.senderId,
    required super.senderNameSnapshot,
    super.senderRoleSnapshot,
    required super.audienceDefinition,
    super.deliveryChannels,
    super.imageUrl,
    super.attachmentRefs,
    super.scheduledAt,
    super.publishedAt,
    super.expiresAt,
    super.status,
    super.acknowledgementRequired,
    super.deliverySummary,
    super.audienceSnapshot,
    super.failureReason,
    super.version,
    super.supersedesCampaignId,
    super.supersededByCampaignId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommunicationCampaignModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    DateTime? asDate(dynamic value) => (value as Timestamp?)?.toDate();
    return CommunicationCampaignModel(
      campaignId: doc.id,
      schoolId: data['schoolId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      shortSummary: data['shortSummary'] as String? ?? '',
      body: data['body'] as String? ?? '',
      communicationType: CommunicationTypeX.fromWire(
        data['communicationType'] as String?,
      ),
      priority: CommunicationPriorityX.fromWire(data['priority'] as String?),
      senderId: data['senderId'] as String? ?? '',
      senderNameSnapshot: data['senderNameSnapshot'] as String? ?? '',
      senderRoleSnapshot: data['senderRoleSnapshot'] as String?,
      audienceDefinition: NotificationAudience.fromMap(
        (data['audienceDefinition'] as Map?)?.cast<String, dynamic>(),
      ),
      deliveryChannels: List<String>.from(
        data['deliveryChannels'] ?? const ['inApp', 'push'],
      ),
      imageUrl: data['imageUrl'] as String?,
      attachmentRefs: List<String>.from(data['attachmentRefs'] ?? const []),
      scheduledAt: asDate(data['scheduledAt']),
      publishedAt: asDate(data['publishedAt']),
      expiresAt: asDate(data['expiresAt']),
      status: CommunicationStatusX.fromWire(data['status'] as String?),
      acknowledgementRequired: data['acknowledgementRequired'] == true,
      deliverySummary: CommunicationDeliverySummary.fromMap(
        (data['deliverySummary'] as Map?)?.cast<String, dynamic>(),
      ),
      audienceSnapshot: data['audienceSnapshot'] != null
          ? CommunicationAudienceSnapshot.fromMap(
              (data['audienceSnapshot'] as Map).cast<String, dynamic>(),
            )
          : null,
      failureReason: (data['failureSummary'] as Map?)?['reason'] as String?,
      version: (data['version'] as num?)?.toInt() ?? 1,
      supersedesCampaignId: data['supersedesCampaignId'] as String?,
      supersededByCampaignId: data['supersededByCampaignId'] as String?,
      createdAt: asDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: asDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  /// The `campaign` payload saveCommunicationDraft expects. Server fields
  /// (status/version/senderId/timestamps) are derived there, not sent here.
  Map<String, dynamic> toDraftPayload() {
    return {
      'title': title,
      'shortSummary': shortSummary,
      'body': body,
      'communicationType': communicationType.wireName,
      'priority': priority.wireName,
      'sensitivity': isEmergency ? 'sensitive' : 'normal',
      'audienceDefinition': audienceDefinition.toMap(),
      'deliveryChannels': deliveryChannels,
      'imageUrl': imageUrl,
      'attachmentRefs': attachmentRefs,
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      'acknowledgementRequired': acknowledgementRequired,
    };
  }
}
