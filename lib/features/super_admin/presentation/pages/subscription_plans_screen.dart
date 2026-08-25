import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import 'plan_edit_sheet.dart';

/// Owner-facing plan management, backed by the same plans loaded for the
/// dashboard. Selecting a plan is deliberately local; no additional
/// Firestore reads occur while moving between plans.
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final PageController _pageController = PageController();
  String? _selectedPlanId;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
  }

  void _selectPlan(List<SubscriptionPlan> plans, int index) {
    if (index < 0 || index >= plans.length) return;
    setState(() => _selectedPlanId = plans[index].id);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = isSuperAdminWide(context);
    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: const PulseLogo(
                variant: PulseLogoVariant.header,
                width: 132,
                height: 32,
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh plans',
                  onPressed: _isRefreshing ? null : _refresh,
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
      body: BlocConsumer<SuperAdminBloc, SuperAdminState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status != SuperAdminStatus.loading && _isRefreshing) {
            setState(() => _isRefreshing = false);
          }
        },
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading && state.plans.isEmpty) {
            return const _PlansLoadingView();
          }
          if (state.status == SuperAdminStatus.failure && state.plans.isEmpty) {
            return _PlansErrorView(onRetry: _refresh);
          }

          final plans = state.plans.where(_isVisiblePlan).toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          if (plans.isEmpty) return const _PlansEmptyView();

          final selectedIndex = _selectedIndexFor(plans);
          _selectedPlanId ??= plans[selectedIndex].id;
          return _PlansContent(
            plans: plans,
            selectedIndex: selectedIndex,
            isWide: isWide,
            isRefreshing: _isRefreshing,
            pageController: _pageController,
            onRefresh: _refresh,
            onPlanSelected: (index) => _selectPlan(plans, index),
            onPageChanged: (index) {
              if (_selectedPlanId != plans[index].id) {
                setState(() => _selectedPlanId = plans[index].id);
              }
            },
          );
        },
      ),
    );
  }

  int _selectedIndexFor(List<SubscriptionPlan> plans) {
    final selectedIndex = plans.indexWhere(
      (plan) => plan.id == _selectedPlanId,
    );
    return selectedIndex < 0 ? 0 : selectedIndex;
  }

  static bool _isVisiblePlan(SubscriptionPlan plan) {
    final id = plan.id.toLowerCase();
    final name = plan.name.toLowerCase();
    return !plan.customPricing &&
        !id.contains('enterprise') &&
        !name.contains('enterprise');
  }
}

class _PlansContent extends StatelessWidget {
  const _PlansContent({
    required this.plans,
    required this.selectedIndex,
    required this.isWide,
    required this.isRefreshing,
    required this.pageController,
    required this.onRefresh,
    required this.onPlanSelected,
    required this.onPageChanged,
  });

  final List<SubscriptionPlan> plans;
  final int selectedIndex;
  final bool isWide;
  final bool isRefreshing;
  final PageController pageController;
  final VoidCallback onRefresh;
  final ValueChanged<int> onPlanSelected;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 400
            ? AppSpacing.xl
            : AppSpacing.x2l;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isWide ? AppSpacing.x3l : AppSpacing.xl,
                    horizontalPadding,
                    AppSpacing.l,
                  ),
                  child: _PlansHeader(
                    isWide: isWide,
                    isRefreshing: isRefreshing,
                    onRefresh: onRefresh,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _PlanSelector(
                    plans: plans,
                    selectedIndex: selectedIndex,
                    onSelected: onPlanSelected,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: plans.length,
                    itemBuilder: (context, index) => _PlanCardPage(
                      key: ValueKey(plans[index].id),
                      plan: plans[index],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlansHeader extends StatelessWidget {
  const _PlansHeader({
    required this.isWide,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final bool isWide;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'Subscription Plans',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Powerful tools for every school.',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
    if (!isWide) return title;
    return Row(
      children: [
        Expanded(child: title),
        OutlinedButton.icon(
          onPressed: isRefreshing ? null : onRefresh,
          icon: isRefreshing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh'),
        ),
      ],
    );
  }
}

class _PlanSelector extends StatelessWidget {
  const _PlanSelector({
    required this.plans,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SubscriptionPlan> plans;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Subscription plan selector',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            for (var index = 0; index < plans.length; index++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: index == selectedIndex,
                  label: '${plans[index].name} plan',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      onTap: () => onSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index == selectedIndex
                              ? scheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.s),
                          boxShadow: index == selectedIndex
                              ? [
                                  BoxShadow(
                                    color: scheme.primary,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          plans[index].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge.copyWith(
                            color: index == selectedIndex
                                ? scheme.onPrimary
                                : AppColors.textSecondary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanCardPage extends StatelessWidget {
  const _PlanCardPage({super.key, required this.plan});
  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    final wholeNumber = NumberFormat.decimalPattern();
    final storage = plan.storageLimitGb % 1 == 0
        ? plan.storageLimitGb.toStringAsFixed(0)
        : plan.storageLimitGb.toStringAsFixed(1);
    final features = <String>[
      if (plan.maxStudents > 0)
        'Up to ${wholeNumber.format(plan.maxStudents)} Students',
      if (plan.maxStaff > 0) 'Up to ${wholeNumber.format(plan.maxStaff)} Staff',
      if (plan.storageLimitGb > 0) '$storage GB Storage',
      ...plan.includedFeatures,
    ];
    final primary = AppColors.primary(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2l,
        0,
        AppSpacing.x2l,
        AppSpacing.x2l,
      ),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3l,
          AppSpacing.x3l,
          AppSpacing.x3l,
          AppSpacing.x2l,
        ),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: AppRadius.large,
              ),
              child: Icon(Icons.auto_awesome_rounded, color: primary, size: 31),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '${_titleCase(plan.name)} Plan',
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            if (plan.description.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                plan.description,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl,
                horizontal: AppSpacing.l,
              ),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: AppRadius.medium,
                border: Border.all(color: primary),
              ),
              child: Column(
                children: [
                  Text(
                    plan.customPricing && plan.price <= 0
                        ? 'Custom price'
                        : money.format(plan.price),
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_cycleLabel(plan.billingCycle)} • ${plan.termLengthDays} days',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (features.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              for (final feature in features) _PlanFeature(label: feature),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () async {
                  final updated = await showPlanEditSheet(context, plan);
                  if (updated == true && context.mounted) {
                    context.read<SuperAdminBloc>().add(
                      LoadSuperAdminDashboard(),
                    );
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 19),
                label: const Text('Edit Plan'),
              ),
            ),
          ],
        ),
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
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.success(context),
        ),
        const SizedBox(width: AppSpacing.l),
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

class _PlansLoadingView extends StatelessWidget {
  const _PlansLoadingView();
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          children: const [
            Skeleton(width: 230, height: 28),
            SizedBox(height: AppSpacing.m),
            Skeleton(width: 190, height: 16),
            SizedBox(height: AppSpacing.x3l),
            Skeleton(height: 50, borderRadius: 12),
            SizedBox(height: AppSpacing.xl),
            Expanded(child: Skeleton(borderRadius: 16)),
          ],
        ),
      ),
    ),
  );
}

class _PlansErrorView extends StatelessWidget {
  const _PlansErrorView({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x3l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Unable to load subscription plans.',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

class _PlansEmptyView extends StatelessWidget {
  const _PlansEmptyView();
  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.subscriptions_outlined,
    title: 'No subscription plans yet.',
    message: 'Plans will appear here once they have been configured.',
  );
}
