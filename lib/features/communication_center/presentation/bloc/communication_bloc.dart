import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/repositories/communication_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import 'communication_event.dart';
import 'communication_state.dart';

class CommunicationBloc extends Bloc<CommunicationEvent, CommunicationState> {
  final CommunicationRepository repository;
  final PermissionEvaluator permissionEvaluator;

  CommunicationBloc({
    required this.repository,
    required this.permissionEvaluator,
  }) : super(CommunicationInitial()) {
    on<WatchCommunicationCampaignsRequested>(_onWatchCampaigns);
    on<SaveCommunicationDraftRequested>(_onSaveDraft);
    on<PublishCommunicationCampaignRequested>(_onPublish);
    on<CancelCommunicationCampaignRequested>(_onCancel);
    on<SupersedeCommunicationCampaignRequested>(_onSupersede);
    on<AcknowledgeCommunicationCampaignRequested>(_onAcknowledge);
    on<PreviewCommunicationAudienceRequested>(_onPreviewAudience);
    on<WatchCommunicationTemplatesRequested>(_onWatchTemplates);
    on<SaveCommunicationTemplateRequested>(_onSaveTemplate);
    on<DeleteCommunicationTemplateRequested>(_onDeleteTemplate);
  }

  Future<bool> _has(String permission, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permission, operatorUser);
    return result.fold((failure) => false, (allowed) => allowed);
  }

  CommunicationLoaded? get _loaded =>
      state is CommunicationLoaded ? state as CommunicationLoaded : null;

  Future<void> _onWatchCampaigns(
    WatchCommunicationCampaignsRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    final canManage = await _has(
      Permission.communicationsCreate,
      event.operatorUser,
    );
    final canSendEmergency = await _has(
      Permission.communicationsSendEmergency,
      event.operatorUser,
    );
    final canViewDelivery = await _has(
      Permission.communicationsViewDelivery,
      event.operatorUser,
    );
    final canManageTemplates = await _has(
      Permission.communicationsManageTemplates,
      event.operatorUser,
    );
    await emit.forEach(
      repository.watchCampaigns(event.schoolId),
      onData: (campaigns) {
        final current = _loaded;
        return CommunicationLoaded(
          campaigns: campaigns,
          templates: current?.templates ?? const [],
          canManage: canManage,
          canSendEmergency: canSendEmergency,
          canViewDelivery: canViewDelivery,
          canManageTemplates: canManageTemplates,
        );
      },
      onError: (error, stackTrace) => CommunicationError('$error'),
    );
  }

  Future<void> _onWatchTemplates(
    WatchCommunicationTemplatesRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    await emit.forEach(
      repository.watchTemplates(event.schoolId),
      onData: (templates) {
        final current = _loaded;
        if (current == null) return state;
        return current.copyWith(templates: templates);
      },
    );
  }

  Future<void> _onSaveDraft(
    SaveCommunicationDraftRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    final permission = event.campaignId == null
        ? Permission.communicationsCreate
        : Permission.communicationsEditDraft;
    if (!await _has(permission, event.operatorUser)) {
      emit(
        const CommunicationActionDenied(
          'You cannot create or edit this communication.',
        ),
      );
      return;
    }
    final result = await repository.saveDraft(
      event.schoolId,
      event.campaign,
      campaignId: event.campaignId,
    );
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (id) => emit(CommunicationActionSuccess('Draft saved', campaignId: id)),
    );
  }

  Future<void> _onPublish(
    PublishCommunicationCampaignRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    final requiredPermission =
        event.communicationType == CommunicationType.emergencyAlert
        ? Permission.communicationsSendEmergency
        : Permission.communicationsPublish;
    if (!await _has(requiredPermission, event.operatorUser)) {
      emit(
        const CommunicationActionDenied(
          'You cannot publish this communication.',
        ),
      );
      return;
    }
    final result = await repository.publish(event.schoolId, event.campaignId);
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (_) => emit(
        CommunicationActionSuccess(
          'Communication published',
          campaignId: event.campaignId,
        ),
      ),
    );
  }

  Future<void> _onCancel(
    CancelCommunicationCampaignRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    if (!await _has(Permission.communicationsCancel, event.operatorUser)) {
      emit(
        const CommunicationActionDenied(
          'You cannot cancel this communication.',
        ),
      );
      return;
    }
    final result = await repository.cancel(event.schoolId, event.campaignId);
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (_) => emit(
        const CommunicationActionSuccess('Scheduled communication cancelled'),
      ),
    );
  }

  Future<void> _onSupersede(
    SupersedeCommunicationCampaignRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    if (!await _has(Permission.communicationsEditDraft, event.operatorUser)) {
      emit(
        const CommunicationActionDenied(
          'You cannot correct this communication.',
        ),
      );
      return;
    }
    final result = await repository.supersede(event.schoolId, event.campaignId);
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (id) => emit(
        CommunicationActionSuccess(
          'New corrected draft created',
          campaignId: id,
        ),
      ),
    );
  }

  Future<void> _onAcknowledge(
    AcknowledgeCommunicationCampaignRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    final result = await repository.acknowledge(
      event.schoolId,
      event.campaignId,
    );
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (_) => emit(const CommunicationActionSuccess('Acknowledged')),
    );
  }

  Future<void> _onPreviewAudience(
    PreviewCommunicationAudienceRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    final result = await repository.previewAudience(
      event.schoolId,
      event.campaign,
    );
    result.fold((failure) => emit(CommunicationError(failure.message)), (
      preview,
    ) {
      final current = _loaded;
      if (current != null) {
        emit(current.copyWith(audiencePreview: preview));
      }
    });
  }

  Future<void> _onSaveTemplate(
    SaveCommunicationTemplateRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    if (!await _has(
      Permission.communicationsManageTemplates,
      event.operatorUser,
    )) {
      emit(
        const CommunicationActionDenied(
          'You cannot manage communication templates.',
        ),
      );
      return;
    }
    final result = await repository.saveTemplate(
      event.schoolId,
      event.template,
      templateId: event.templateId,
    );
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (id) =>
          emit(CommunicationActionSuccess('Template saved', campaignId: id)),
    );
  }

  Future<void> _onDeleteTemplate(
    DeleteCommunicationTemplateRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    if (!await _has(
      Permission.communicationsManageTemplates,
      event.operatorUser,
    )) {
      emit(
        const CommunicationActionDenied(
          'You cannot manage communication templates.',
        ),
      );
      return;
    }
    final result = await repository.deleteTemplate(
      event.schoolId,
      event.templateId,
    );
    result.fold(
      (failure) => emit(CommunicationError(failure.message)),
      (_) => emit(const CommunicationActionSuccess('Template deleted')),
    );
  }
}
