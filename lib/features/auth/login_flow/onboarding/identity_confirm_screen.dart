import 'package:flutter/material.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/onboarding_step_scaffold.dart';

class IdentityConfirmScreen extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onConfirmed;

  const IdentityConfirmScreen({super.key, required this.user, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: 'Confirm Your Identity',
      subtitle: 'Please confirm these details are correct before continuing.',
      primaryLabel: 'This is me, continue',
      onPrimaryPressed: onConfirmed,
      child: Column(
        children: [
          OnboardingSummaryRow(label: 'Name', value: user.name),
          OnboardingSummaryRow(label: 'Email', value: user.email),
          OnboardingSummaryRow(label: 'Phone', value: user.phoneNumber ?? '—'),
          OnboardingSummaryRow(label: 'Role', value: UserRoleDisplay.name(user.role)),
        ],
      ),
    );
  }
}
