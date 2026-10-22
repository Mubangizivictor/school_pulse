import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';

import '../../domain/entities/parent_access_record.dart';
import '../../domain/repositories/parent_access_repository.dart';

class ParentDetailState extends Equatable {
  final bool loading;
  final String? error;
  final bool isOffline;
  final bool isPermissionDenied;
  final ParentAccessRecord? record;
  final List<ParentLinkAuditEntry> audit;
  final bool auditLoading;

  final bool actionInFlight;
  final String? actionError;
  final String? actionSuccess;

  const ParentDetailState({
    this.loading = true,
    this.error,
    this.isOffline = false,
    this.isPermissionDenied = false,
    this.record,
    this.audit = const [],
    this.auditLoading = false,
    this.actionInFlight = false,
    this.actionError,
    this.actionSuccess,
  });

  ParentDetailState copyWith({
    bool? loading,
    String? Function()? error,
    bool? isOffline,
    bool? isPermissionDenied,
    ParentAccessRecord? record,
    List<ParentLinkAuditEntry>? audit,
    bool? auditLoading,
    bool? actionInFlight,
    String? Function()? actionError,
    String? Function()? actionSuccess,
  }) {
    return ParentDetailState(
      loading: loading ?? this.loading,
      error: error != null ? error() : this.error,
      isOffline: isOffline ?? this.isOffline,
      isPermissionDenied: isPermissionDenied ?? this.isPermissionDenied,
      record: record ?? this.record,
      audit: audit ?? this.audit,
      auditLoading: auditLoading ?? this.auditLoading,
      actionInFlight: actionInFlight ?? this.actionInFlight,
      actionError: actionError != null ? actionError() : this.actionError,
      actionSuccess: actionSuccess != null
          ? actionSuccess()
          : this.actionSuccess,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    isOffline,
    isPermissionDenied,
    record,
    audit,
    auditLoading,
    actionInFlight,
    actionError,
    actionSuccess,
  ];
}

class ParentDetailCubit extends Cubit<ParentDetailState> {
  final ParentAccessRepository repository;
  final String inviteId;

  ParentDetailCubit({required this.repository, required this.inviteId})
    : super(const ParentDetailState());

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        error: () => null,
        isOffline: false,
        isPermissionDenied: false,
      ),
    );
    final result = await repository.getParentAccessRecord(inviteId: inviteId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          error: () => failure.message,
          isOffline: failure is NetworkFailure,
          isPermissionDenied: failure is PermissionDeniedFailure,
        ),
      ),
      (record) {
        emit(state.copyWith(loading: false, record: record));
        _loadAudit();
      },
    );
  }

  Future<void> retry() => load();

  Future<void> _loadAudit() async {
    emit(state.copyWith(auditLoading: true));
    final result = await repository.listParentLinkAudit(inviteId: inviteId);
    result.fold(
      (_) => emit(state.copyWith(auditLoading: false)),
      (entries) => emit(state.copyWith(auditLoading: false, audit: entries)),
    );
  }

  Future<bool> _run(
    Future<Either<Failure, dynamic>> Function() action,
    String successMessage,
  ) async {
    emit(
      state.copyWith(
        actionInFlight: true,
        actionError: () => null,
        actionSuccess: () => null,
      ),
    );
    final result = await action();
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionInFlight: false,
            actionError: () => failure.message,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            actionInFlight: false,
            actionSuccess: () => successMessage,
          ),
        );
        load();
        return true;
      },
    );
  }

  Future<bool> resendInvitation() => _run(
    () => repository.resendParentInvitation(inviteId: inviteId),
    'Invitation sent.',
  );

  Future<bool> revoke() => _run(
    () => repository.revokeParentAccessCode(inviteId: inviteId),
    'Parent access revoked.',
  );

  Future<bool> updateDetails({
    String? parentName,
    String? phoneNumber,
    String? email,
  }) => _run(
    () => repository.updateParentDetails(
      inviteId: inviteId,
      parentName: parentName,
      phoneNumber: phoneNumber,
      email: email,
    ),
    'Parent details updated.',
  );

  /// Unlinks one learner (reallocateParentLink removal mode). The caller is
  /// responsible for the "last remaining guardian" confirmation - this just
  /// performs it.
  Future<bool> unlinkLearner({
    required String linkId,
    required String reason,
  }) => _run(
    () => repository.reallocateParentLink(linkId: linkId, reason: reason),
    'Learner unlinked.',
  );

  void clearActionFeedback() {
    emit(state.copyWith(actionError: () => null, actionSuccess: () => null));
  }
}
