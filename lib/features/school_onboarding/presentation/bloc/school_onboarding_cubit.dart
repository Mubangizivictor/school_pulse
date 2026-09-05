import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/services/structure_integrity_validator.dart';
import '../../domain/entities/education_level_selection.dart';
import '../../domain/entities/school_setup_draft.dart';
import '../../domain/repositories/school_onboarding_repository.dart';
import '../../domain/services/education_level_mapper.dart';

/// Ordered ids of every step in the School setup wizard shell. Only
/// `educationLevels` has a real implementation today - the rest are inert
/// placeholder screens so Back/Save & continue can navigate a real 16-step
/// flow.
const List<String> schoolOnboardingStepIds = [
  'basic-information',
  'location',
  'school-type',
  'education-levels',
  'classes-and-streams',
  'contact-details',
  'branding',
  'academic-calendar',
  'fees-and-billing',
  'staff-roles',
  'communication-preferences',
  'feature-modules',
  'integrations',
  'terms-and-policies',
  'school-details',
  'review-and-finish',
];

const List<String> schoolOnboardingStepTitles = [
  'Basic information',
  'Location',
  'School type',
  'Education levels',
  'Classes and streams',
  'Contact details',
  'Branding',
  'Academic calendar',
  'Fees & billing setup',
  'Staff roles',
  'Communication preferences',
  'Feature modules',
  'Integrations',
  'Terms & policies',
  'School details',
  'Review and finish',
];

const int educationLevelsStepIndex = 3;
const int schoolTypeStepIndex = 2;

class SchoolOnboardingCubitState extends Equatable {
  final SchoolSetupDraft draft;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final int currentStepIndex;
  final bool hasUnsavedChanges;

  const SchoolOnboardingCubitState({
    this.draft = const SchoolSetupDraft(),
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.currentStepIndex = 0,
    this.hasUnsavedChanges = false,
  });

  bool get canContinueFromLevelsStep {
    final levels = draft.selectedLevels;
    if (levels.isEmpty) return false;
    final customNames = <String>{};
    final customCodes = <String>{};
    for (final level in levels) {
      if (!level.isCustom) continue;
      final name = level.name.trim().toLowerCase();
      final code = level.code.trim().toLowerCase();
      if (name.isEmpty) return false;
      if (!customNames.add(name)) return false;
      if (code.isNotEmpty && !customCodes.add(code)) return false;
    }
    return true;
  }

  SchoolOnboardingCubitState copyWith({
    SchoolSetupDraft? draft,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    int? currentStepIndex,
    bool? hasUnsavedChanges,
  }) {
    return SchoolOnboardingCubitState(
      draft: draft ?? this.draft,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [
    draft,
    isLoading,
    isSaving,
    errorMessage,
    currentStepIndex,
    hasUnsavedChanges,
  ];
}

class SchoolOnboardingCubit extends Cubit<SchoolOnboardingCubitState> {
  final SchoolOnboardingRepository repository;
  final StructureRepository structureRepository;
  final String schoolId;
  final StructureIntegrityValidator _validator;
  StreamSubscription<SchoolSetupDraft>? _subscription;

  SchoolOnboardingCubit({
    required this.repository,
    required this.structureRepository,
    required this.schoolId,
    StructureIntegrityValidator? validator,
  }) : _validator = validator ?? const StructureIntegrityValidator(),
       super(const SchoolOnboardingCubitState()) {
    _subscription = repository.watchDraft().listen(
      (draft) {
        final restoredIndex = draft.lastStepId.isEmpty
            ? state.currentStepIndex
            : schoolOnboardingStepIds
                  .indexOf(draft.lastStepId)
                  .clamp(0, schoolOnboardingStepIds.length - 1);
        emit(
          state.copyWith(
            draft: draft,
            isLoading: false,
            clearError: true,
            currentStepIndex: restoredIndex,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) =>
          emit(state.copyWith(isLoading: false, errorMessage: error.toString())),
    );
  }

  void applyTemplate(String templateId) {
    final template = kBuiltInTemplates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => kBuiltInTemplates.last,
    );
    final preset = kUgandaLevelOptions
        .where((level) => template.presetCategories.contains(level.category))
        .toList();
    _updateSelection(
      state.draft.copyWith(
        selectedLevels: preset,
        templateId: templateId,
        isCustomSelection: false,
      ),
    );
  }

  void setSelectedLevels(List<SelectableLevel> levels) {
    _updateSelection(
      state.draft.copyWith(
        selectedLevels: levels,
        isCustomSelection: _isCustomSelection(state.draft.templateId, levels),
      ),
    );
  }

  void addCustomLevel(SelectableLevel level) {
    final levels = [...state.draft.selectedLevels, level];
    setSelectedLevels(levels);
  }

  void removeLevel(String id) {
    final levels = state.draft.selectedLevels
        .where((level) => level.id != id)
        .toList();
    setSelectedLevels(levels);
  }

  void reorderLevels(int oldIndex, int newIndex) {
    final levels = [...state.draft.selectedLevels];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = levels.removeAt(oldIndex);
    levels.insert(newIndex, moved);
    for (var i = 0; i < levels.length; i++) {
      levels[i] = levels[i].copyWith(order: i);
    }
    setSelectedLevels(levels);
  }

  void setStepPlaceholderData(String stepId, Map<String, dynamic> data) {
    _updateSelection(
      state.draft.copyWith(stepData: {...state.draft.stepData, stepId: data}),
    );
  }

  void goToStep(int index) {
    emit(state.copyWith(currentStepIndex: index));
  }

  void nextStep() {
    if (state.currentStepIndex >= schoolOnboardingStepIds.length - 1) return;
    rememberStep(schoolOnboardingStepIds[state.currentStepIndex]);
    emit(state.copyWith(currentStepIndex: state.currentStepIndex + 1));
  }

  void previousStep() {
    if (state.currentStepIndex <= 0) return;
    emit(state.copyWith(currentStepIndex: state.currentStepIndex - 1));
  }

  Future<void> rememberStep(String stepId) =>
      _save(state.draft.copyWith(lastStepId: stepId));

  Future<void> saveDraft() => _save(state.draft);

  /// Builds real `EducationalLevel` documents from the current selection and
  /// writes them via Structure's own validated batch-save path, then records
  /// the resulting ids back into the draft so future edits can be checked
  /// against real usage via `LevelsInUseChecker`.
  Future<void> provisionLevels() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final existingIds = <String, String>{
        for (final level in state.draft.selectedLevels)
          if (state.draft.provisionedLevelIds.contains(level.id))
            level.id: level.id,
      };
      final structureLevels = toEducationalLevels(
        schoolId: schoolId,
        selected: state.draft.selectedLevels,
        existingIds: existingIds,
      );
      for (final level in structureLevels) {
        final error = _validator.validateLevel(level, structureLevels);
        if (error != null) {
          throw StateError(error);
        }
      }
      await structureRepository.saveLevelsBatch(structureLevels);
      final next = state.draft.copyWith(
        provisionedLevelIds: structureLevels.map((l) => l.id).toList(),
      );
      await repository.saveDraft(next);
      emit(state.copyWith(draft: next, isSaving: false, clearError: true));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      rethrow;
    }
  }

  bool _isCustomSelection(String templateId, List<SelectableLevel> levels) {
    if (templateId.isEmpty) return levels.isNotEmpty;
    final template = kBuiltInTemplates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => kBuiltInTemplates.last,
    );
    final presetCategories = kUgandaLevelOptions
        .where((level) => template.presetCategories.contains(level.category))
        .map((level) => level.id)
        .toSet();
    final currentIds = levels.map((level) => level.id).toSet();
    return presetCategories.length != currentIds.length ||
        !presetCategories.containsAll(currentIds);
  }

  void _updateSelection(SchoolSetupDraft draft) {
    emit(state.copyWith(draft: draft, hasUnsavedChanges: true));
    unawaited(_save(draft));
  }

  Future<void> _save(SchoolSetupDraft next) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await repository.saveDraft(next);
      emit(
        state.copyWith(
          draft: next,
          isSaving: false,
          clearError: true,
          hasUnsavedChanges: false,
        ),
      );
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
