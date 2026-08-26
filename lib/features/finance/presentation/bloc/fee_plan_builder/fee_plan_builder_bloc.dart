import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/fee_billing_repository.dart';
import 'fee_plan_builder_event.dart';
import 'fee_plan_builder_state.dart';

/// Drives the Fee Plan Builder (Structure > Academics > Fee Plans). Listing
/// plans is a live Firestore stream (not money-authoritative); publishing
/// and archiving go through [FeeBillingRepository], which itself calls the
/// `publishFeePlan` callable for the money-bearing parts.
class FeePlanBuilderBloc extends Bloc<FeePlanBuilderEvent, FeePlanBuilderState> {
  final FeeBillingRepository repository;
  StreamSubscription? _plansSub;

  FeePlanBuilderBloc({required this.repository})
    : super(const FeePlanBuilderState()) {
    on<FeePlansSubscriptionRequested>(_onSubscriptionRequested);
    on<FeePlansUpdated>(_onPlansUpdated);
    on<FeePlanArchiveRequested>(_onArchiveRequested);
    on<FeePlanPublishRequested>(_onPublishRequested);
  }

  Future<void> _onSubscriptionRequested(
    FeePlansSubscriptionRequested event,
    Emitter<FeePlanBuilderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _plansSub?.cancel();
    _plansSub = repository
        .watchFeePlans(event.schoolId)
        .listen((plans) => add(FeePlansUpdated(plans)));
  }

  void _onPlansUpdated(
    FeePlansUpdated event,
    Emitter<FeePlanBuilderState> emit,
  ) {
    emit(state.copyWith(isLoading: false, plans: event.plans));
  }

  Future<void> _onArchiveRequested(
    FeePlanArchiveRequested event,
    Emitter<FeePlanBuilderState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await repository.archiveFeePlan(
      event.schoolId,
      event.planId,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: 'Fee plan archived.',
        ),
      ),
    );
  }

  Future<void> _onPublishRequested(
    FeePlanPublishRequested event,
    Emitter<FeePlanBuilderState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await repository.publishFeePlan(
      schoolId: event.schoolId,
      planId: event.planId,
      academicYearId: event.academicYearId,
      termId: event.termId,
      classId: event.classId,
      studentCategory: event.studentCategory,
      name: event.name,
      lines: event.lines,
      createNewVersion: event.createNewVersion,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: event.createNewVersion
              ? 'New fee plan version published.'
              : 'Fee plan published.',
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _plansSub?.cancel();
    return super.close();
  }
}
