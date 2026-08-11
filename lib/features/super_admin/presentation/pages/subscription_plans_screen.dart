import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import 'plan_edit_sheet.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        actions: [
          IconButton(
            tooltip: 'Refresh plans',
            onPressed: () =>
                context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading) {
            return const Center(child: SchoolPulseLoader());
          }

          final isWide = isSuperAdminWide(context);
          // Enterprise uses custom, off-platform pricing negotiated directly
          // with the school, so it isn't a self-service plan card here.
          final visiblePlans = state.plans
              .where((plan) => plan.id.toLowerCase() != 'enterprise')
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2l,
                  AppSpacing.xl,
                  AppSpacing.x2l,
                  AppSpacing.l,
                ),
                child: Text(
                  'Manage plan pricing and billing cycles for every school.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              Expanded(
                child: visiblePlans.isEmpty
                    ? const EmptyState(
                        icon: Icons.subscriptions_outlined,
                        title: 'No plans found',
                        message:
                            'Deploy the manual billing backend once to seed the School Pulse plans.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.x2l,
                          0,
                          AppSpacing.x2l,
                          AppSpacing.x2l,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 3 : 1,
                          crossAxisSpacing: AppSpacing.xl,
                          mainAxisSpacing: AppSpacing.xl,
                          childAspectRatio: isWide ? 0.78 : 1.15,
                        ),
                        itemCount: visiblePlans.length,
                        itemBuilder: (context, index) {
                          final plan = visiblePlans[index];
                          final customPrice =
                              plan.customPricing && plan.price <= 0;
                          final storageLabel = plan.storageLimitGb % 1 == 0
                              ? plan.storageLimitGb.toStringAsFixed(0)
                              : plan.storageLimitGb.toStringAsFixed(1);
                          final hasLimitsOrFeatures =
                              plan.maxStudents > 0 ||
                              plan.maxStaff > 0 ||
                              plan.storageLimitGb > 0 ||
                              plan.includedFeatures.isNotEmpty;
                          return AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _titleCase(plan.name),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary(
                                                context,
                                              ),
                                            ),
                                      ),
                                    ),
                                    if (plan.isDefault)
                                      StatusBadge(
                                        label: 'Default',
                                        color: AppColors.primary(context),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.m),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.m,
                                    vertical: AppSpacing.m,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary(
                                      context,
                                    ).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customPrice
                                            ? 'Custom price'
                                            : money.format(plan.price),
                                        style: AppTypography.titleLarge
                                            .copyWith(
                                              color: AppColors.primary(context),
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_cycleLabel(plan.billingCycle)} • ${plan.termLengthDays} days',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasLimitsOrFeatures) ...[
                                  const SizedBox(height: AppSpacing.l),
                                  if (plan.maxStudents > 0)
                                    _PlanFeature(
                                      label: '${plan.maxStudents} Students',
                                    ),
                                  if (plan.maxStaff > 0)
                                    _PlanFeature(
                                      label: '${plan.maxStaff} Staff',
                                    ),
                                  if (plan.storageLimitGb > 0)
                                    _PlanFeature(
                                      label: '$storageLabel GB Storage',
                                    ),
                                  ...plan.includedFeatures.map(
                                    (feature) => _PlanFeature(label: feature),
                                  ),
                                ],
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _editPlan(context, plan),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Edit Plan'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _titleCase(String value) => value
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');

  static String _cycleLabel(BillingCycle cycle) => switch (cycle) {
    BillingCycle.monthly => 'Monthly',
    BillingCycle.termly => 'Per term',
    BillingCycle.yearly => 'Yearly',
  };

  Future<void> _editPlan(BuildContext context, SubscriptionPlan plan) async {
    final updated = await showPlanEditSheet(context, plan);
    if (updated == true && context.mounted) {
      context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    }
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: semantic.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
