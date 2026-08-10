import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Honest, read-only informational screen about the manual payment method
/// configuration (MTN MoMo / Centenary Bank details schools use to pay).
///
/// There is currently no owner-scoped Cloud Function to read or update this
/// configuration: `platform_billing_config/manual` in Firestore is seeded by
/// `ensureBillingDefaults()` and read by `getManualConfig()` on the backend,
/// but the only client-facing endpoint (`getManualPaymentContext`) is gated
/// to school-admin subscriber identities, not the SaaS owner. This screen
/// deliberately does not fetch or hardcode any of those values — doing so
/// would mean either calling a function the owner isn't authorized for, or
/// scattering real payment account numbers into app source, both of which
/// are out of bounds. Instead it explains the situation and what a future
/// phase should add.
class ManualPaymentConfigScreen extends StatelessWidget {
  const ManualPaymentConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Payment Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          'Managed at the backend level',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'The MTN MoMo and Centenary Bank details schools use to '
                    'pay their subscription live in Firestore, at '
                    'platform_billing_config/manual. They are seeded once by '
                    'the backend and read internally by the payment '
                    'verification functions — there is currently no '
                    'owner-console read or write path for this configuration.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'The only client-facing endpoint that surfaces this data '
                    '(getManualPaymentContext) requires a school-admin '
                    'subscriber identity, not an owner identity, so this '
                    'console cannot call it to display the current values.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'To change these details today, update the '
                    'platform_billing_config/manual document directly in '
                    'Firestore or the DEFAULT_MANUAL_PAYMENT_CONFIG seed in '
                    'the backend.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppCard(
              color: AppColors.primary(context).withValues(alpha: 0.06),
              showShadow: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.construction_rounded,
                    color: AppColors.primary(context),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'A future phase should add owner-scoped Cloud '
                      'Functions (e.g. getManualPaymentConfig / '
                      'updateManualPaymentConfig) so this can be viewed and '
                      'edited safely from the console.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary(context),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
