import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/communication_center/data/datasources/communication_remote_data_source.dart';
import 'package:school_pulse/features/communication_center/data/models/communication_campaign_model.dart';
import 'package:school_pulse/features/communication_center/data/models/communication_template_model.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';
import 'package:school_pulse/features/communication_center/domain/repositories/communication_repository.dart';

class CommunicationRepositoryImpl implements CommunicationRepository {
  final CommunicationRemoteDataSource remoteDataSource;

  CommunicationRepositoryImpl({required this.remoteDataSource});

  Failure _mapError(Object error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'permission-denied':
          return PermissionDeniedFailure(
            error.message ?? 'You do not have permission to do this.',
          );
        case 'invalid-argument':
        case 'failed-precondition':
          return ValidationFailure(error.message ?? 'That is not valid.');
        case 'unauthenticated':
          return const AuthFailure();
        default:
          return ServerFailure(error.message ?? 'Something went wrong.');
      }
    }
    debugPrint('CommunicationRepositoryImpl error: $error');
    return ServerFailure('$error');
  }

  CommunicationCampaignModel _asModel(CommunicationCampaign campaign) {
    if (campaign is CommunicationCampaignModel) return campaign;
    return CommunicationCampaignModel(
      campaignId: campaign.campaignId,
      schoolId: campaign.schoolId,
      title: campaign.title,
      shortSummary: campaign.shortSummary,
      body: campaign.body,
      communicationType: campaign.communicationType,
      priority: campaign.priority,
      senderId: campaign.senderId,
      senderNameSnapshot: campaign.senderNameSnapshot,
      senderRoleSnapshot: campaign.senderRoleSnapshot,
      audienceDefinition: campaign.audienceDefinition,
      deliveryChannels: campaign.deliveryChannels,
      imageUrl: campaign.imageUrl,
      attachmentRefs: campaign.attachmentRefs,
      scheduledAt: campaign.scheduledAt,
      publishedAt: campaign.publishedAt,
      expiresAt: campaign.expiresAt,
      status: campaign.status,
      acknowledgementRequired: campaign.acknowledgementRequired,
      deliverySummary: campaign.deliverySummary,
      audienceSnapshot: campaign.audienceSnapshot,
      failureReason: campaign.failureReason,
      version: campaign.version,
      supersedesCampaignId: campaign.supersedesCampaignId,
      supersededByCampaignId: campaign.supersededByCampaignId,
      createdAt: campaign.createdAt,
      updatedAt: campaign.updatedAt,
    );
  }

  CommunicationTemplateModel _asTemplateModel(CommunicationTemplate template) {
    if (template is CommunicationTemplateModel) return template;
    return CommunicationTemplateModel(
      templateId: template.templateId,
      schoolId: template.schoolId,
      name: template.name,
      communicationType: template.communicationType,
      shortSummary: template.shortSummary,
      body: template.body,
      placeholders: template.placeholders,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }

  @override
  Stream<List<CommunicationCampaign>> watchCampaigns(
    String schoolId, {
    int limit = 50,
  }) {
    return remoteDataSource.watchCampaigns(schoolId, limit: limit);
  }

  @override
  Stream<CommunicationCampaign?> watchCampaign(
    String schoolId,
    String campaignId,
  ) {
    return remoteDataSource.watchCampaign(schoolId, campaignId);
  }

  @override
  Future<Either<Failure, String>> saveDraft(
    String schoolId,
    CommunicationCampaign campaign, {
    String? campaignId,
  }) async {
    try {
      final id = await remoteDataSource.saveDraft(
        schoolId,
        _asModel(campaign),
        campaignId: campaignId,
      );
      return Right(id);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> publish(
    String schoolId,
    String campaignId,
  ) async {
    try {
      await remoteDataSource.publish(schoolId, campaignId);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancel(
    String schoolId,
    String campaignId,
  ) async {
    try {
      await remoteDataSource.cancel(schoolId, campaignId);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, String>> supersede(
    String schoolId,
    String campaignId,
  ) async {
    try {
      final id = await remoteDataSource.supersede(schoolId, campaignId);
      return Right(id);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> acknowledge(
    String schoolId,
    String campaignId,
  ) async {
    try {
      await remoteDataSource.acknowledge(schoolId, campaignId);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AudiencePreview>> previewAudience(
    String schoolId,
    CommunicationCampaign campaign,
  ) async {
    try {
      final count = await remoteDataSource.previewAudience(
        schoolId,
        campaign.audienceDefinition,
      );
      return Right(AudiencePreview(estimatedRecipients: count));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Stream<List<CommunicationTemplate>> watchTemplates(String schoolId) {
    return remoteDataSource.watchTemplates(schoolId);
  }

  @override
  Future<Either<Failure, String>> saveTemplate(
    String schoolId,
    CommunicationTemplate template, {
    String? templateId,
  }) async {
    try {
      final id = await remoteDataSource.saveTemplate(
        schoolId,
        _asTemplateModel(template),
        templateId: templateId,
      );
      return Right(id);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(
    String schoolId,
    String templateId,
  ) async {
    try {
      await remoteDataSource.deleteTemplate(schoolId, templateId);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }
}
