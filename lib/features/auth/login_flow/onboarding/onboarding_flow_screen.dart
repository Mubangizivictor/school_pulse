import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/login_flow/force_set_password_screen.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/contact_verify_screen.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/identity_confirm_screen.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/institution_confirm_screen.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/institution_onboarding_cubit.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/institution_onboarding_state.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/mfa_stub_screen.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/profile_summary_screen.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Host/controller for the first-login onboarding flow. Wraps
/// ForceSetPasswordScreen (unmodified) as the passwordChange step and adds
/// the new institution-context-aware steps around it.
class OnboardingFlowScreen extends StatelessWidget {
  final UserEntity user;

  const OnboardingFlowScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final institutionState = context.watch<InstitutionContextCubit>().state;
    final institutionId =
        context.read<InstitutionContextCubit>().currentInstitutionId ??
        user.schoolId;

    return BlocProvider(
      create: (_) => InstitutionOnboardingCubit(
        firestore: di.sl<FirebaseFirestore>(),
        userId: user.id,
        institutionId: institutionId,
      )..load(),
      child:
          BlocBuilder<
            InstitutionOnboardingCubit,
            InstitutionOnboardingProgress
          >(
            builder: (context, progress) {
              final onboardingCubit = context
                  .read<InstitutionOnboardingCubit>();

              switch (progress.currentStep) {
                case OnboardingStep.identityConfirm:
                  return IdentityConfirmScreen(
                    user: user,
                    onConfirmed: onboardingCubit.advance,
                  );
                case OnboardingStep.passwordChange:
                  return ForceSetPasswordScreen(user: user);
                case OnboardingStep.contactVerify:
                  return ContactVerifyScreen(
                    user: user,
                    onContinue: onboardingCubit.advance,
                  );
                case OnboardingStep.mfaStub:
                  return MfaStubScreen(
                    mfaRequired: progress.mfaRequired,
                    onContinue: onboardingCubit.advance,
                  );
                case OnboardingStep.institutionConfirm:
                  if (institutionState is! InstitutionContextLoaded) {
                    return const Scaffold(
                      body: Center(child: SchoolPulseLoader()),
                    );
                  }
                  return InstitutionConfirmScreen(
                    context: institutionState.context,
                    onConfirmed: onboardingCubit.advance,
                  );
                case OnboardingStep.profileSummary:
                  if (institutionState is! InstitutionContextLoaded) {
                    return const Scaffold(
                      body: Center(child: SchoolPulseLoader()),
                    );
                  }
                  return ProfileSummaryScreen(
                    user: user,
                    context: institutionState.context,
                    onGetStarted: onboardingCubit.advance,
                  );
                case OnboardingStep.completed:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/school-splash', extra: user);
                  });
                  return const Scaffold(
                    body: Center(child: SchoolPulseLoader()),
                  );
              }
            },
          ),
    );
  }
}
