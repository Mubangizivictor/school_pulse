import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/salary_structure_repository.dart';
import 'salary_structure_builder_event.dart';
import 'salary_structure_builder_state.dart';

/// Drives the Salary Structure Builder (Structure > People > Salary
/// Structures). Listing structures is a live Firestore stream (not
/// money-authoritative); publishing and archiving go through
/// [SalaryStructureRepository], which itself calls the
/// `publishSalaryStructure` callable for the money-bearing parts.
class SalaryStructureBuilderBloc
    extends Bloc<SalaryStructureBuilderEvent, SalaryStructureBuilderState> {
  final SalaryStructureRepository repository;
  StreamSubscription? _structuresSub;

  SalaryStructureBuilderBloc({required this.repository})
    : super(const SalaryStructureBuilderState()) {
    on<SalaryStructuresSubscriptionRequested>(_onSubscriptionRequested);
    on<SalaryStructuresUpdated>(_onStructuresUpdated);
    on<SalaryStructureArchiveRequested>(_onArchiveRequested);
    on<SalaryStructurePublishRequested>(_onPublishRequested);
  }

  Future<void> _onSubscriptionRequested(
    SalaryStructuresSubscriptionRequested event,
    Emitter<SalaryStructureBuilderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _structuresSub?.cancel();
    _structuresSub = repository
        .watchSalaryStructures(event.schoolId)
        .listen((structures) => add(SalaryStructuresUpdated(structures)));
  }

  void _onStructuresUpdated(
    SalaryStructuresUpdated event,
    Emitter<SalaryStructureBuilderState> emit,
  ) {
    emit(state.copyWith(isLoading: false, structures: event.structures));
  }

  Future<void> _onArchiveRequested(
    SalaryStructureArchiveRequested event,
    Emitter<SalaryStructureBuilderState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await repository.archiveSalaryStructure(
      event.schoolId,
      event.structureId,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: 'Salary structure archived.',
        ),
      ),
    );
  }

  Future<void> _onPublishRequested(
    SalaryStructurePublishRequested event,
    Emitter<SalaryStructureBuilderState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await repository.publishSalaryStructure(
      schoolId: event.schoolId,
      structureId: event.structureId,
      designationId: event.designationId,
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
              ? 'New salary structure version published.'
              : 'Salary structure published.',
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _structuresSub?.cancel();
    return super.close();
  }
}
