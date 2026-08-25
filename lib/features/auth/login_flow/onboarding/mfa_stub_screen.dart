import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/onboarding_step_scaffold.dart';

/// Policy-gated skip step. Real MFA enrollment is explicitly out of scope
/// for Phase 1 - this only reads whether the institution's enabledFeatures
/// list requires it, and if not, tells the admin plainly that it isn't
/// required yet rather than presenting a broken enrollment flow.
class MfaStubScreen extends StatelessWidget {
  final bool mfaRequired;
  final VoidCallback onContinue;

  const MfaStubScreen({
    super.key,
    required this.mfaRequired,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OnboardingStepScaffold(
      title: 'Multi-Factor Authentication',
      subtitle: mfaRequired
          ? 'Your institution requires MFA. Enrollment will be available soon - '
                'for now, continue and set it up when prompted in a future update.'
          : 'Multi-factor authentication is not yet required for your institution.',
      primaryLabel: 'Continue',
      onPrimaryPressed: onContinue,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceDark : AppColors.borderLight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.shield_outlined,
              color: isDark ? Colors.white : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                mfaRequired
                    ? 'MFA policy: required by your institution'
                    : 'MFA policy: not required',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
