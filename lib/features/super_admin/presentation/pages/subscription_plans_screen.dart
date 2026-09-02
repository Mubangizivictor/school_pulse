import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import 'plan_editor_page.dart';

enum _PlanStatusFilter { all, active, archived }

/// Owner-facing plan catalog management: searchable/filterable list of
/// plans backed by the same plans/schools loaded for the dashboard.
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool _isRefreshing = false;
  String _query = '';
  _PlanStatusFilter _filter = _PlanStatusFilter.all;

  void _refresh() {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PlanEditorPage(plan: null)),
    );
    if (created == true && mounted) {
      context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    }
  }

  Future<void> _openEdit(SubscriptionPlan plan) async {
    final updated = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => PlanEditorPage(plan: plan)));
    if (updated == true && mounted) {
      context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    }
  }

  List<SubscriptionPlan> _filtered(List<SubscriptionPlan> plans) {
    final query = _query.trim().toLowerCase();
    return plans.where((plan) {
      final matchesQuery =
          query.isEmpty ||
          plan.name.toLowerCase().contains(query) ||
          plan.id.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _PlanStatusFilter.all => true,
        _PlanStatusFilter.active => !plan.isArchived,
        _PlanStatusFilter.archived => plan.isArchived,
      };
      return matchesQuery && matchesFilter;
    }).toList()..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = isSuperAdminWide(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: isWide ? null : 44,
        title: isWide ? const Text('Manage plans') : null,
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

          final allPlans = List<SubscriptionPlan>.of(state.plans)
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          final visible = _filtered(allPlans);

          return _PlansContent(
            allPlans: allPlans,
            visiblePlans: visible,
            schools: state.schools,
            query: _query,
            filter: _filter,
            isRefreshing: _isRefreshing,
            onRefresh: _refresh,
            onQueryChanged: (value) => setState(() => _query = value),
            onFilterChanged: (value) => setState(() => _filter = value),
            onCreate: _openCreate,
            onEditPlan: _openEdit,
          );
        },
      ),
    );
  }
}

class _PlansContent extends StatelessWidget {
  const _PlansContent({
    required this.allPlans,
    required this.visiblePlans,
    required this.schools,
    required this.query,
    required this.filter,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onCreate,
    required this.onEditPlan,
  });

  final List<SubscriptionPlan> allPlans;
  final List<SubscriptionPlan> visiblePlans;
  final List<School> schools;
  final String query;
  final _PlanStatusFilter filter;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_PlanStatusFilter> onFilterChanged;
  final VoidCallback onCreate;
  final ValueChanged<SubscriptionPlan> onEditPlan;

  int _schoolCountFor(String planId) =>
      schools.where((school) => school.subscriptionPlanId == planId).length;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 400
            ? AppSpacing.l
            : AppSpacing.x2l;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.l,
                    horizontalPadding,
                    AppSpacing.m,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Plans',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: onCreate,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('New plan'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppSearchField(
                          hintText: 'Search plans...',
                          onChanged: onQueryChanged,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      _FilterMenu(value: filter, onChanged: onFilterChanged),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: visiblePlans.isEmpty
                      ? _PlansEmptyView(
                          hasAnyPlans: allPlans.isNotEmpty,
                          onCreate: onCreate,
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            AppSpacing.m,
                          ),
                          itemCount: visiblePlans.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.m),
                          itemBuilder: (context, index) {
                            final plan = visiblePlans[index];
                            return _PlanCard(
                              plan: plan,
                              schoolCount: _schoolCountFor(plan.id),
                              onEdit: () => onEditPlan(plan),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    AppSpacing.m,
                  ),
                  child: const AlertBanner(
                    title: 'Heads up',
                    message:
                        'Changes apply to new subscriptions. Existing schools keep their assigned plan until updated.',
                    color: Colors.amber,
                    icon: Icons.info_outline_rounded,
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

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.value, required this.onChanged});

  final _PlanStatusFilter value;
  final ValueChanged<_PlanStatusFilter> onChanged;

  static String _label(_PlanStatusFilter filter) => switch (filter) {
    _PlanStatusFilter.all => 'All',
    _PlanStatusFilter.active => 'Active',
    _PlanStatusFilter.archived => 'Archived',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PlanStatusFilter>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => _PlanStatusFilter.values
          .map(
            (filter) =>
                PopupMenuItem(value: filter, child: Text(_label(filter))),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Filter',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.schoolCount,
    required this.onEdit,
  });

  final SubscriptionPlan plan;
  final int schoolCount;
  final VoidCallback onEdit;

  IconData get _icon => switch (plan.id) {
    'starter' => Icons.rocket_launch_outlined,
    'growth' => Icons.trending_up_rounded,
    'pro' => Icons.bar_chart_rounded,
    'enterprise' => Icons.workspace_premium_outlined,
    _ => Icons.subscriptions_outlined,
  };

  static String _cycleLabel(BillingCycle cycle) => switch (cycle) {
    BillingCycle.monthly => 'month',
    BillingCycle.termly => 'term',
    BillingCycle.yearly => 'year',
  };

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    final primary = AppColors.primary(context);
    final features = <String>[
      if (plan.maxStudents > 0) 'Up to ${plan.maxStudents} students',
      ...plan.includedFeatures,
    ].take(3).toList();

    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(_icon, color: primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.customPricing && plan.price <= 0
                          ? 'Custom price'
                          : '${money.format(plan.price)} / ${_cycleLabel(plan.billingCycle)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      '$schoolCount ${schoolCount == 1 ? 'school' : 'schools'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: plan.isArchived ? 'Archived' : 'Active',
                color: plan.isArchived
                    ? AppColors.textSecondary(context)
                    : AppColors.success(context),
              ),
            ],
          ),
          if (features.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.xs,
              children: features
                  .map(
                    (feature) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.success(context),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          feature,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlansLoadingView extends StatelessWidget {
  const _PlansLoadingView();
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          children: const [
            Skeleton(width: 230, height: 28),
            SizedBox(height: AppSpacing.m),
            Skeleton(height: 44, borderRadius: 12),
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
  const _PlansEmptyView({required this.hasAnyPlans, required this.onCreate});

  final bool hasAnyPlans;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.subscriptions_outlined,
    title: hasAnyPlans ? 'No plans match your filters' : 'No plans yet',
    message: hasAnyPlans
        ? 'Try a different search term or filter.'
        : 'Create your first plan to start offering subscriptions.',
    ctaLabel: hasAnyPlans ? null : 'Create first plan',
    onCtaPressed: hasAnyPlans ? null : onCreate,
  );
}
