import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plan.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.titleLarge
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
                                const SizedBox(height: 8),
                                Text(
                                  customPrice
                                      ? 'Custom price'
                                      : money.format(plan.price),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: AppColors.primary(context),
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                Text(
                                  '${_cycleLabel(plan.billingCycle)} • ${plan.termLengthDays} days',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                                if (hasLimitsOrFeatures) ...[
                                  const SizedBox(height: AppSpacing.l),
                                  const Divider(),
                                  const SizedBox(height: AppSpacing.m),
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
                                    label: const Text('Edit Price & Billing'),
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

  static String _cycleLabel(BillingCycle cycle) => switch (cycle) {
    BillingCycle.monthly => 'Monthly',
    BillingCycle.termly => 'Per term',
    BillingCycle.yearly => 'Yearly',
  };

  Future<void> _editPlan(BuildContext context, SubscriptionPlan plan) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditPlanPricingDialog(plan: plan),
    );
    if (updated == true && context.mounted) {
      context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    }
  }
}

class _EditPlanPricingDialog extends StatefulWidget {
  const _EditPlanPricingDialog({required this.plan});
  final SubscriptionPlan plan;

  @override
  State<_EditPlanPricingDialog> createState() => _EditPlanPricingDialogState();
}

class _EditPlanPricingDialogState extends State<_EditPlanPricingDialog> {
  final ManualPaymentService _service = ManualPaymentService();
  late final TextEditingController _priceController;
  late final TextEditingController _daysController;
  late BillingCycle _cycle;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.plan.price.round().toString(),
    );
    _daysController = TextEditingController(
      text: widget.plan.termLengthDays.toString(),
    );
    _cycle = widget.plan.billingCycle;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.plan.name}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'These values are stored in Firestore. Future payment screens read them automatically, so changing a price does not require a code deployment.',
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _priceController,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (UGX)',
                helperText: widget.plan.id.toLowerCase() == 'enterprise'
                    ? 'Use 0 to keep Enterprise as custom pricing.'
                    : 'Full payment is required; partial payments are disabled.',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<BillingCycle>(
              initialValue: _cycle,
              decoration: const InputDecoration(labelText: 'Billing cycle'),
              items: BillingCycle.values
                  .map(
                    (cycle) => DropdownMenuItem(
                      value: cycle,
                      child: Text(SubscriptionPlansScreen._cycleLabel(cycle)),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) setState(() => _cycle = value);
                    },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _daysController,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Paid period length (days)',
                helperText: 'Currently 120 days by default for a school term.',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Pricing'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final price = int.tryParse(
      _priceController.text.replaceAll(',', '').trim(),
    );
    final days = int.tryParse(_daysController.text.trim());
    final enterprise = widget.plan.id.toLowerCase() == 'enterprise';
    if (price == null || price < 0 || (!enterprise && price == 0)) {
      setState(() => _error = 'Enter a valid plan price in Uganda shillings.');
      return;
    }
    if (days == null || days < 1 || days > 730) {
      setState(
        () => _error = 'Paid period length must be between 1 and 730 days.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.updatePlanPricing(
        plan: widget.plan,
        priceUgx: price,
        billingCycle: _cycle,
        termLengthDays: days,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
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
