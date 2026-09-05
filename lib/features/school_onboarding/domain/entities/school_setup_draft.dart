import 'package:equatable/equatable.dart';

import 'education_level_selection.dart';

/// A school's in-progress "School setup" onboarding wizard state, persisted
/// as one tenant-owned Firestore document (mirrors the shape/versioning
/// convention of `StructureSetupPreferences`).
class SchoolSetupDraft extends Equatable {
  static const currentSetupVersion = 1;

  final List<SelectableLevel> selectedLevels;

  /// Id of the [LevelTemplate] currently applied, or '' if none/custom.
  final String templateId;

  /// True once the admin has edited the selection away from the exact
  /// preset categories of [templateId] - drives the "Custom selection"
  /// relabel. Always false when [templateId] is empty.
  final bool isCustomSelection;

  /// Step 3's (placeholder) school-type answer - forward-compatible so that
  /// step can write into this same draft once built.
  final String schoolTypeHint;

  /// Ids of the real `EducationalLevel` Structure documents already
  /// provisioned from [selectedLevels] (set after the first successful
  /// Save & continue on the Education levels step). Used to know whether a
  /// later edit is touching real, already-in-use data.
  final List<String> provisionedLevelIds;

  /// Loosely-typed answers for the remaining placeholder steps, keyed by
  /// step id. Kept untyped deliberately - each stub step only reads/writes
  /// its own key, and typing these out now would model content that does
  /// not exist yet. Expand into typed fields as each step is actually built.
  final Map<String, dynamic> stepData;

  final String lastStepId;
  final bool onboardingCompleted;
  final int setupVersion;

  const SchoolSetupDraft({
    this.selectedLevels = const [],
    this.templateId = '',
    this.isCustomSelection = false,
    this.schoolTypeHint = '',
    this.provisionedLevelIds = const [],
    this.stepData = const {},
    this.lastStepId = '',
    this.onboardingCompleted = false,
    this.setupVersion = currentSetupVersion,
  });

  SchoolSetupDraft copyWith({
    List<SelectableLevel>? selectedLevels,
    String? templateId,
    bool? isCustomSelection,
    String? schoolTypeHint,
    List<String>? provisionedLevelIds,
    Map<String, dynamic>? stepData,
    String? lastStepId,
    bool? onboardingCompleted,
    int? setupVersion,
  }) {
    return SchoolSetupDraft(
      selectedLevels: selectedLevels ?? this.selectedLevels,
      templateId: templateId ?? this.templateId,
      isCustomSelection: isCustomSelection ?? this.isCustomSelection,
      schoolTypeHint: schoolTypeHint ?? this.schoolTypeHint,
      provisionedLevelIds: provisionedLevelIds ?? this.provisionedLevelIds,
      stepData: stepData ?? this.stepData,
      lastStepId: lastStepId ?? this.lastStepId,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      setupVersion: setupVersion ?? this.setupVersion,
    );
  }

  @override
  List<Object?> get props => [
    selectedLevels,
    templateId,
    isCustomSelection,
    schoolTypeHint,
    provisionedLevelIds,
    stepData,
    lastStepId,
    onboardingCompleted,
    setupVersion,
  ];
}
