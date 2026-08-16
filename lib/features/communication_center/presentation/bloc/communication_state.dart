import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';
import 'package:school_pulse/features/communication_center/domain/repositories/communication_repository.dart';

abstract class CommunicationState extends Equatable {
  const CommunicationState();

  @override
  List<Object?> get props => [];
}

class CommunicationInitial extends CommunicationState {}

class CommunicationLoading extends CommunicationState {}

class CommunicationLoaded extends CommunicationState {
  final List<CommunicationCampaign> campaigns;
  final List<CommunicationTemplate> templates;
  final bool canManage;
  final bool canSendEmergency;
  final bool canViewDelivery;
  final bool canManageTemplates;
  final AudiencePreview? audiencePreview;

  const CommunicationLoaded({
    required this.campaigns,
    this.templates = const [],
    required this.canManage,
    this.canSendEmergency = false,
    this.canViewDelivery = false,
    this.canManageTemplates = false,
    this.audiencePreview,
  });

  CommunicationLoaded copyWith({
    List<CommunicationCampaign>? campaigns,
    List<CommunicationTemplate>? templates,
    bool? canManage,
    bool? canSendEmergency,
    bool? canViewDelivery,
    bool? canManageTemplates,
    AudiencePreview? audiencePreview,
    bool clearAudiencePreview = false,
  }) {
    return CommunicationLoaded(
      campaigns: campaigns ?? this.campaigns,
      templates: templates ?? this.templates,
      canManage: canManage ?? this.canManage,
      canSendEmergency: canSendEmergency ?? this.canSendEmergency,
      canViewDelivery: canViewDelivery ?? this.canViewDelivery,
      canManageTemplates: canManageTemplates ?? this.canManageTemplates,
      audiencePreview: clearAudiencePreview
          ? null
          : (audiencePreview ?? this.audiencePreview),
    );
  }

  @override
  List<Object?> get props => [
    campaigns,
    templates,
    canManage,
    canSendEmergency,
    canViewDelivery,
    canManageTemplates,
    audiencePreview?.estimatedRecipients,
  ];
}

class CommunicationError extends CommunicationState {
  final String message;
  const CommunicationError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommunicationActionDenied extends CommunicationState {
  final String message;
  const CommunicationActionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class CommunicationActionSuccess extends CommunicationState {
  final String message;
  final String? campaignId;
  const CommunicationActionSuccess(this.message, {this.campaignId});

  @override
  List<Object?> get props => [message, campaignId];
}
