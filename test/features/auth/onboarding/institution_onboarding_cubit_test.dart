import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/institution_onboarding_cubit.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/institution_onboarding_state.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  const userId = 'user-1';
  const institutionId = 'school-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  InstitutionOnboardingCubit buildCubit() {
    return InstitutionOnboardingCubit(
      firestore: firestore,
      userId: userId,
      institutionId: institutionId,
    );
  }

  test('starts at identityConfirm with no completed steps', () {
    final cubit = buildCubit();
    expect(cubit.state.currentStep, OnboardingStep.identityConfirm);
    expect(cubit.state.completedSteps, isEmpty);
  });

  test(
    'advance moves through every step in order and persists progress',
    () async {
      final cubit = buildCubit();

      for (final expectedNext in onboardingStepOrder.skip(1)) {
        await cubit.advance();
        expect(cubit.state.currentStep, expectedNext);
      }

      final doc = await firestore
          .collection('onboarding_state')
          .doc('${userId}_$institutionId')
          .get();
      expect(doc.data()!['currentStep'], OnboardingStep.completed.name);
      expect(
        doc.data()!['completedSteps'],
        onboardingStepOrder
            .take(onboardingStepOrder.length - 1)
            .map((s) => s.name)
            .toList(),
      );
    },
  );

  test('advance does not go past completed', () async {
    final cubit = buildCubit();
    for (var i = 0; i < onboardingStepOrder.length + 2; i++) {
      await cubit.advance();
    }
    expect(cubit.state.currentStep, OnboardingStep.completed);
  });

  test('load resumes from previously persisted progress', () async {
    await firestore
        .collection('onboarding_state')
        .doc('${userId}_$institutionId')
        .set({
          'userId': userId,
          'institutionId': institutionId,
          'currentStep': OnboardingStep.mfaStub.name,
          'completedSteps': [
            OnboardingStep.identityConfirm.name,
            OnboardingStep.passwordChange.name,
            OnboardingStep.contactVerify.name,
          ],
          'mfaRequired': true,
        });

    final cubit = buildCubit();
    await cubit.load();

    expect(cubit.state.currentStep, OnboardingStep.mfaStub);
    expect(cubit.state.mfaRequired, isTrue);
    expect(cubit.state.completedSteps, hasLength(3));
  });

  test('load is a no-op when no progress doc exists yet', () async {
    final cubit = buildCubit();
    await cubit.load();
    expect(cubit.state.currentStep, OnboardingStep.identityConfirm);
  });

  test('reaching completed sets completedAt', () async {
    final cubit = buildCubit();
    for (var i = 0; i < onboardingStepOrder.length - 1; i++) {
      await cubit.advance();
    }
    final doc = await firestore
        .collection('onboarding_state')
        .doc('${userId}_$institutionId')
        .get();
    expect(doc.data()!['completedAt'], isNotNull);
  });
}
