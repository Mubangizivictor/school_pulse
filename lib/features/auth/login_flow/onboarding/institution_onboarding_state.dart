/// First-login foundation steps for a Primary Institution Administrator.
/// Deliberately shallow - this is Phase 1 of the universal institution
/// SaaS foundation, not detailed academic Structure setup.
enum OnboardingStep {
  identityConfirm,
  passwordChange,
  contactVerify,
  mfaStub,
  institutionConfirm,
  profileSummary,
  completed,
}

const List<OnboardingStep> onboardingStepOrder = [
  OnboardingStep.identityConfirm,
  OnboardingStep.passwordChange,
  OnboardingStep.contactVerify,
  OnboardingStep.mfaStub,
  OnboardingStep.institutionConfirm,
  OnboardingStep.profileSummary,
  OnboardingStep.completed,
];

OnboardingStep onboardingStepFromName(String? name) {
  return onboardingStepOrder.firstWhere(
    (s) => s.name == name,
    orElse: () => OnboardingStep.identityConfirm,
  );
}

class InstitutionOnboardingProgress {
  final OnboardingStep currentStep;
  final List<OnboardingStep> completedSteps;
  final bool mfaRequired;

  const InstitutionOnboardingProgress({
    required this.currentStep,
    required this.completedSteps,
    required this.mfaRequired,
  });

  bool get isCompleted => currentStep == OnboardingStep.completed;

  InstitutionOnboardingProgress copyWith({
    OnboardingStep? currentStep,
    List<OnboardingStep>? completedSteps,
    bool? mfaRequired,
  }) {
    return InstitutionOnboardingProgress(
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      mfaRequired: mfaRequired ?? this.mfaRequired,
    );
  }
}
