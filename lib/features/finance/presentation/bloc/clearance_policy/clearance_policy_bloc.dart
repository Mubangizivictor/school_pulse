import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/finance/data/datasources/clearance_policy_remote_data_source.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_catalogue_item.dart';
import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_catalogue_repository.dart';

abstract class ClearancePolicyEvent extends Equatable {
  const ClearancePolicyEvent();
  @override
  List<Object?> get props => [];
}

class ClearancePolicyLoaded extends ClearancePolicyEvent {
  final String schoolId;
  const ClearancePolicyLoaded(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class ClearancePolicyDraftChanged extends ClearancePolicyEvent {
  final FinancialClearancePolicy draft;
  const ClearancePolicyDraftChanged(this.draft);
  @override
  List<Object?> get props => [draft];
}

class ClearancePolicySaved extends ClearancePolicyEvent {
  const ClearancePolicySaved();
}

class ClearancePolicyFeedbackCleared extends ClearancePolicyEvent {
  const ClearancePolicyFeedbackCleared();
}

enum ClearancePolicyStatus { loading, ready, saving, error }

class ClearancePolicyState extends Equatable {
  final ClearancePolicyStatus status;
  final FinancialClearancePolicy saved;
  final FinancialClearancePolicy draft;
  final ClearancePolicyMeta meta;
  final List<FeeCatalogueItem> feeCatalogue;
  final String? errorMessage;
  final String? successMessage;

  const ClearancePolicyState({
    this.status = ClearancePolicyStatus.loading,
    this.saved = const FinancialClearancePolicy(),
    this.draft = const FinancialClearancePolicy(),
    this.meta = const ClearancePolicyMeta(),
    this.feeCatalogue = const [],
    this.errorMessage,
    this.successMessage,
  });

  bool get isDirty => draft != saved;

  ClearancePolicyState copyWith({
    ClearancePolicyStatus? status,
    FinancialClearancePolicy? saved,
    FinancialClearancePolicy? draft,
    ClearancePolicyMeta? meta,
    List<FeeCatalogueItem>? feeCatalogue,
    String? errorMessage,
    String? successMessage,
    bool clearFeedback = false,
  }) => ClearancePolicyState(
    status: status ?? this.status,
    saved: saved ?? this.saved,
    draft: draft ?? this.draft,
    meta: meta ?? this.meta,
    feeCatalogue: feeCatalogue ?? this.feeCatalogue,
    errorMessage: clearFeedback ? null : (errorMessage ?? this.errorMessage),
    successMessage: clearFeedback
        ? null
        : (successMessage ?? this.successMessage),
  );

  @override
  List<Object?> get props => [
    status,
    saved,
    draft,
    meta,
    feeCatalogue,
    errorMessage,
    successMessage,
  ];
}

class ClearancePolicyBloc
    extends Bloc<ClearancePolicyEvent, ClearancePolicyState> {
  final ClearancePolicyRemoteDataSource dataSource;
  final FeeCatalogueRepository feeCatalogueRepository;

  ClearancePolicyBloc({
    required this.dataSource,
    required this.feeCatalogueRepository,
  }) : super(const ClearancePolicyState()) {
    on<ClearancePolicyLoaded>(_onLoaded);
    on<ClearancePolicyDraftChanged>(
      (e, emit) => emit(state.copyWith(draft: e.draft, clearFeedback: true)),
    );
    on<ClearancePolicySaved>(_onSaved);
    on<ClearancePolicyFeedbackCleared>(
      (e, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoaded(
    ClearancePolicyLoaded event,
    Emitter<ClearancePolicyState> emit,
  ) async {
    emit(state.copyWith(status: ClearancePolicyStatus.loading));
    try {
      final result = await dataSource.getPolicy();
      List<FeeCatalogueItem> catalogue = const [];
      try {
        catalogue = await feeCatalogueRepository
            .watchCatalogue(event.schoolId)
            .first;
      } catch (_) {
        // A missing catalogue must not block the editor; the
        // selected-categories mode just shows an empty picker with guidance.
      }
      emit(
        state.copyWith(
          status: ClearancePolicyStatus.ready,
          saved: result.policy,
          draft: result.policy,
          meta: result.meta,
          feeCatalogue: catalogue,
          clearFeedback: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ClearancePolicyStatus.error,
          errorMessage: 'Could not load the clearance policy.',
        ),
      );
    }
  }

  Future<void> _onSaved(
    ClearancePolicySaved event,
    Emitter<ClearancePolicyState> emit,
  ) async {
    emit(
      state.copyWith(status: ClearancePolicyStatus.saving, clearFeedback: true),
    );
    try {
      final result = await dataSource.savePolicy(state.draft);
      // effectiveFrom / updatedBy just changed - reflect "just now" locally
      // so the "in effect since" line is immediately accurate.
      emit(
        state.copyWith(
          status: ClearancePolicyStatus.ready,
          saved: result.policy,
          draft: result.policy,
          meta: ClearancePolicyMeta(
            effectiveFrom: DateTime.now(),
            updatedAt: DateTime.now(),
            updatedByName: state.meta.updatedByName,
            configured: true,
          ),
          successMessage:
              'Policy saved. ${result.reMaterialisedPeriods} report period(s) '
              're-evaluated.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClearancePolicyStatus.ready,
          errorMessage: _friendly(e),
        ),
      );
    }
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('not authorised') || s.contains('permission-denied')) {
      return 'You are not authorised to change the clearance policy.';
    }
    if (s.contains('greater than 0')) {
      return 'Minimum percentage must be greater than 0.';
    }
    if (s.contains('at least one fee category')) {
      return 'Select at least one fee category.';
    }
    return 'Could not save the policy. Please try again.';
  }
}
