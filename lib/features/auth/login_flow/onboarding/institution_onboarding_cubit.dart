import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/institution_onboarding_state.dart';

/// Drives the first-login state machine for a Primary Institution
/// Administrator. Progress is persisted to onboarding_state/{uid}_{institutionId}
/// so a killed app resumes mid-flow instead of restarting from step one.
class InstitutionOnboardingCubit extends Cubit<InstitutionOnboardingProgress> {
  final FirebaseFirestore firestore;
  final String userId;
  final String institutionId;

  InstitutionOnboardingCubit({
    required this.firestore,
    required this.userId,
    required this.institutionId,
  }) : super(const InstitutionOnboardingProgress(
          currentStep: OnboardingStep.identityConfirm,
          completedSteps: [],
          mfaRequired: false,
        ));

  DocumentReference<Map<String, dynamic>> get _docRef =>
      firestore.collection('onboarding_state').doc('${userId}_$institutionId');

  Future<void> load() async {
    final doc = await _docRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    emit(InstitutionOnboardingProgress(
      currentStep: onboardingStepFromName(data['currentStep'] as String?),
      completedSteps: (data['completedSteps'] as List<dynamic>? ?? [])
          .map((s) => onboardingStepFromName(s as String))
          .toList(),
      mfaRequired: data['mfaRequired'] as bool? ?? false,
    ));
  }

  Future<void> advance() async {
    final currentIndex = onboardingStepOrder.indexOf(state.currentStep);
    if (currentIndex >= onboardingStepOrder.length - 1) return;

    final nextStep = onboardingStepOrder[currentIndex + 1];
    final completedSteps = [...state.completedSteps, state.currentStep];

    emit(state.copyWith(currentStep: nextStep, completedSteps: completedSteps));

    await _docRef.set({
      'userId': userId,
      'institutionId': institutionId,
      'currentStep': nextStep.name,
      'completedSteps': completedSteps.map((s) => s.name).toList(),
      'mfaRequired': state.mfaRequired,
      if (nextStep == OnboardingStep.completed)
        'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
