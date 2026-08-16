import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';

/// Estimated reach shown before a campaign is sent - never a promise, since
/// membership can still change before publish. See AudienceResolver server
/// side (functions/notifications.js resolveRecipients) for the source of
/// truth used at actual publish time.
class AudiencePreview {
  final int estimatedRecipients;
  const AudiencePreview({required this.estimatedRecipients});
}

abstract class CommunicationRepository {
  /// Live campaign history for the institution, newest first.
  Stream<List<CommunicationCampaign>> watchCampaigns(
    String schoolId, {
    int limit = 50,
  });

  Stream<CommunicationCampaign?> watchCampaign(
    String schoolId,
    String campaignId,
  );

  Future<Either<Failure, String>> saveDraft(
    String schoolId,
    CommunicationCampaign campaign, {
    String? campaignId,
  });

  Future<Either<Failure, void>> publish(String schoolId, String campaignId);

  Future<Either<Failure, void>> cancel(String schoolId, String campaignId);

  Future<Either<Failure, String>> supersede(String schoolId, String campaignId);

  Future<Either<Failure, void>> acknowledge(String schoolId, String campaignId);

  /// Best-effort recipient count for the audience preview step. Uses the
  /// same resolver the server uses at publish time, so admins never send
  /// blind - see AudiencePreview above.
  Future<Either<Failure, AudiencePreview>> previewAudience(
    String schoolId,
    CommunicationCampaign campaign,
  );

  Stream<List<CommunicationTemplate>> watchTemplates(String schoolId);

  Future<Either<Failure, String>> saveTemplate(
    String schoolId,
    CommunicationTemplate template, {
    String? templateId,
  });

  Future<Either<Failure, void>> deleteTemplate(
    String schoolId,
    String templateId,
  );
}
