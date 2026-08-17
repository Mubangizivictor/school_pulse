import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/repositories/structure_setup_repository.dart';

class StructureSetupCubitState extends Equatable {
  final StructureSetupPreferences preferences;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const StructureSetupCubitState({
    this.preferences = const StructureSetupPreferences(),
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
  });

  StructureSetupCubitState copyWith({
    StructureSetupPreferences? preferences,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StructureSetupCubitState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [preferences, isLoading, isSaving, errorMessage];
}

class StructureSetupCubit extends Cubit<StructureSetupCubitState> {
  final StructureSetupRepository repository;
  StreamSubscription<StructureSetupPreferences>? _subscription;

  StructureSetupCubit({required this.repository})
      : super(const StructureSetupCubitState()) {
    _subscription = repository.watchPreferences().listen(
      (preferences) => emit(
        state.copyWith(
          preferences: preferences,
          isLoading: false,
          clearError: true,
        ),
      ),
      onError: (Object error, StackTrace stackTrace) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      ),
    );
  }

  Future<void> setDepartments(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(departments: choice));

  Future<void> setStreams(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(streams: choice));

  Future<void> setRooms(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(rooms: choice));

  Future<void> setHouses(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(houses: choice));

  Future<void> setClubs(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(clubs: choice));

  Future<void> setBoarding(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(boarding: choice));

  Future<void> setTransport(StructureUseChoice choice) =>
      _save(state.preferences.copyWith(transport: choice));

  Future<void> rememberStep(String stepId) =>
      _save(state.preferences.copyWith(lastStepId: stepId));

  Future<void> markOnboardingCompleted() => _save(
        state.preferences.copyWith(
          onboardingCompleted: true,
          setupVersion: StructureSetupPreferences.currentSetupVersion,
        ),
      );

  Future<void> reopenOnboarding() =>
      _save(state.preferences.copyWith(onboardingCompleted: false));

  Future<void> _save(StructureSetupPreferences next) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await repository.savePreferences(next);
      // The live listener remains authoritative. This optimistic emission
      // keeps the survey responsive while Firestore confirms the write.
      emit(state.copyWith(preferences: next, isSaving: false, clearError: true));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
