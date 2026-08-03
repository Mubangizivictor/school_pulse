import 'package:flutter/material.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/onboarding_step_scaffold.dart';

/// Contact verification step. Phase 1 does not build new OTP/verification
/// infrastructure - it surfaces the account's already-known contact and
/// defers to whatever verification the auth feature already performs at
/// login (e.g. parent phone OTP). This step exists so the onboarding
/// journey has an explicit checkpoint for it, not to duplicate that logic.
class ContactVerifyScreen extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onContinue;

  const ContactVerifyScreen({super.key, required this.user, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: 'Verify Your Contact',
      subtitle: 'This is the email and phone number School Pulse will use to reach you.',
      primaryLabel: 'Looks correct, continue',
      onPrimaryPressed: onContinue,
      child: Column(
        children: [
          OnboardingSummaryRow(label: 'Email', value: user.email),
          OnboardingSummaryRow(label: 'Phone', value: user.phoneNumber ?? 'Not provided'),
        ],
      ),
    );
  }
}
