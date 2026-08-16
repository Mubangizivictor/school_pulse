import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:school_pulse/features/communication_center/data/models/communication_campaign_model.dart';
import 'package:school_pulse/features/communication_center/data/models/communication_template_model.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';

/// Talks to the communication_campaigns Cloud Functions and reads the
/// resulting Firestore documents directly. All mutation goes through
/// callables - the client never writes a campaign/template document itself,
/// matching the Firestore rules (allow write: if false) for both
/// collections. See functions/communication_campaigns.js.
class CommunicationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  CommunicationRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  CollectionReference<Map<String, dynamic>> _campaigns(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('communication_campaigns');

  CollectionReference<Map<String, dynamic>> _templates(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('communication_templates');

  Stream<List<CommunicationCampaignModel>> watchCampaigns(
    String schoolId, {
    int limit = 50,
  }) {
    return _campaigns(schoolId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs.map(CommunicationCampaignModel.fromFirestore).toList(),
        );
  }

  Stream<CommunicationCampaignModel?> watchCampaign(
    String schoolId,
    String campaignId,
  ) {
    return _campaigns(schoolId)
        .doc(campaignId)
        .snapshots()
        .map(
          (doc) =>
              doc.exists ? CommunicationCampaignModel.fromFirestore(doc) : null,
        );
  }

  Future<String> saveDraft(
    String schoolId,
    CommunicationCampaignModel campaign, {
    String? campaignId,
  }) async {
    final result = await functions
        .httpsCallable('saveCommunicationDraft')
        .call({
          'schoolId': schoolId,
          'campaignId': ?campaignId,
          'campaign': campaign.toDraftPayload(),
        });
    return (result.data as Map)['campaignId'] as String;
  }

  Future<void> publish(String schoolId, String campaignId) async {
    await functions.httpsCallable('publishCommunicationCampaign').call({
      'schoolId': schoolId,
      'campaignId': campaignId,
    });
  }

  Future<void> cancel(String schoolId, String campaignId) async {
    await functions.httpsCallable('cancelCommunicationCampaign').call({
      'schoolId': schoolId,
      'campaignId': campaignId,
    });
  }

  Future<String> supersede(String schoolId, String campaignId) async {
    final result = await functions
        .httpsCallable('supersedeCommunicationCampaign')
        .call({'schoolId': schoolId, 'campaignId': campaignId});
    return (result.data as Map)['campaignId'] as String;
  }

  Future<void> acknowledge(
    String schoolId,
    String campaignId, {
    String? deviceId,
  }) async {
    await functions.httpsCallable('acknowledgeCommunicationCampaign').call({
      'schoolId': schoolId,
      'campaignId': campaignId,
      'deviceId': ?deviceId,
    });
  }

  Future<int> previewAudience(
    String schoolId,
    NotificationAudience audience,
  ) async {
    final result = await functions
        .httpsCallable('previewCommunicationAudience')
        .call({'schoolId': schoolId, 'audienceDefinition': audience.toMap()});
    return ((result.data as Map)['estimatedRecipients'] as num).toInt();
  }

  Stream<List<CommunicationTemplateModel>> watchTemplates(String schoolId) {
    return _templates(schoolId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(CommunicationTemplateModel.fromFirestore).toList(),
        );
  }

  Future<String> saveTemplate(
    String schoolId,
    CommunicationTemplateModel template, {
    String? templateId,
  }) async {
    final result = await functions
        .httpsCallable('saveCommunicationTemplate')
        .call({
          'schoolId': schoolId,
          'templateId': ?templateId,
          'template': template.toDraftPayload(),
        });
    return (result.data as Map)['templateId'] as String;
  }

  Future<void> deleteTemplate(String schoolId, String templateId) async {
    await functions.httpsCallable('deleteCommunicationTemplate').call({
      'schoolId': schoolId,
      'templateId': templateId,
    });
  }
}
