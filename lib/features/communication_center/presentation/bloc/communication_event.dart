import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';

abstract class CommunicationEvent extends Equatable {
  const CommunicationEvent();

  @override
  List<Object?> get props => [];
}

class WatchCommunicationCampaignsRequested extends CommunicationEvent {
  final String schoolId;
  final UserEntity operatorUser;

  const WatchCommunicationCampaignsRequested({
    required this.schoolId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, operatorUser];
}

class SaveCommunicationDraftRequested extends CommunicationEvent {
  final String schoolId;
  final CommunicationCampaign campaign;
  final String? campaignId;
  final UserEntity operatorUser;

  const SaveCommunicationDraftRequested({
    required this.schoolId,
    required this.campaign,
    this.campaignId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, campaign, campaignId, operatorUser];
}

class PublishCommunicationCampaignRequested extends CommunicationEvent {
  final String schoolId;
  final String campaignId;
  final CommunicationType communicationType;
  final UserEntity operatorUser;

  const PublishCommunicationCampaignRequested({
    required this.schoolId,
    required this.campaignId,
    required this.communicationType,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [
    schoolId,
    campaignId,
    communicationType,
    operatorUser,
  ];
}

class CancelCommunicationCampaignRequested extends CommunicationEvent {
  final String schoolId;
  final String campaignId;
  final UserEntity operatorUser;

  const CancelCommunicationCampaignRequested({
    required this.schoolId,
    required this.campaignId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, campaignId, operatorUser];
}

class SupersedeCommunicationCampaignRequested extends CommunicationEvent {
  final String schoolId;
  final String campaignId;
  final UserEntity operatorUser;

  const SupersedeCommunicationCampaignRequested({
    required this.schoolId,
    required this.campaignId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, campaignId, operatorUser];
}

class AcknowledgeCommunicationCampaignRequested extends CommunicationEvent {
  final String schoolId;
  final String campaignId;

  const AcknowledgeCommunicationCampaignRequested({
    required this.schoolId,
    required this.campaignId,
  });

  @override
  List<Object?> get props => [schoolId, campaignId];
}

class PreviewCommunicationAudienceRequested extends CommunicationEvent {
  final String schoolId;
  final CommunicationCampaign campaign;

  const PreviewCommunicationAudienceRequested({
    required this.schoolId,
    required this.campaign,
  });

  @override
  List<Object?> get props => [schoolId, campaign];
}

class WatchCommunicationTemplatesRequested extends CommunicationEvent {
  final String schoolId;

  const WatchCommunicationTemplatesRequested({required this.schoolId});

  @override
  List<Object?> get props => [schoolId];
}

class SaveCommunicationTemplateRequested extends CommunicationEvent {
  final String schoolId;
  final CommunicationTemplate template;
  final String? templateId;
  final UserEntity operatorUser;

  const SaveCommunicationTemplateRequested({
    required this.schoolId,
    required this.template,
    this.templateId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, template, templateId, operatorUser];
}

class DeleteCommunicationTemplateRequested extends CommunicationEvent {
  final String schoolId;
  final String templateId;
  final UserEntity operatorUser;

  const DeleteCommunicationTemplateRequested({
    required this.schoolId,
    required this.templateId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, templateId, operatorUser];
}
