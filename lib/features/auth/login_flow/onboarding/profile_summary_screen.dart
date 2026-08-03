import 'package:flutter/material.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/onboarding_step_scaffold.dart';

class ProfileSummaryScreen extends StatelessWidget {
  final UserEntity user;
  final InstitutionContext context;
  final VoidCallback onGetStarted;

  const ProfileSummaryScreen({
    super.key,
    required this.user,
    required this.context,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext buildContext) {
    return OnboardingStepScaffold(
      title: 'You\'re All Set',
      subtitle: 'Here\'s a quick recap before you get started.',
      primaryLabel: 'Get Started',
      onPrimaryPressed: onGetStarted,
      child: Column(
        children: [
          OnboardingSummaryRow(label: 'Name', value: user.name),
          OnboardingSummaryRow(label: 'Role', value: UserRoleDisplay.name(user.role)),
          OnboardingSummaryRow(label: 'Institution', value: context.displayLabel),
          if (context.divisions.isNotEmpty)
            OnboardingSummaryRow(
              label: 'Divisions',
              value: context.divisions.map((d) => d.name).join(', '),
            ),
        ],
      ),
    );
  }
}
