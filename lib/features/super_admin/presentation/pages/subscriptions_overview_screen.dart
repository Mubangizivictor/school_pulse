import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/institution/domain/services/subscription_date_math.dart'
    as date_math;
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import 'billing_page.dart';
import 'school_detail_screen.dart';

/// Threshold used to bucket a school's subscription as "expiring soon".
/// Chosen to give the owner about two weeks' notice before a manual renewal
/// payment is due.
const int kExpiringSoonWindowDays = 14;

/// Read-only rollup of every school's subscription standing, derived
/// entirely from [School.status] and [School.subscriptionExpiry] - the only
/// two fields that reliably describe subscription state today. Deliberately
/// does not attempt "awaiting first payment" or "renewal under review"
/// school buckets since there is no reliable field for either; that signal
/// is surfaced instead via the pending-verification payments banner at top.
class SubscriptionsOverviewScreen extends StatefulWidget {
  const SubscriptionsOverviewScreen({super.key});

  @override
  State<SubscriptionsOverviewScreen> createState() =>
      _SubscriptionsOverviewScreenState();
}

class _SubscriptionsOverviewScreenState
    extends State<SubscriptionsOverviewScreen> {
  final ManualPaymentService _payments = ManualPaymentService();
  final DateFormat _date = DateFormat('MMM dd, yyyy');
  final TextEditingController _searchController = TextEditingController();

  bool _loadingPending = true;
  int _pendingPaymentsCount = 0;
  String _search = '';
  String _planFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(School school, List<SubscriptionPlan> plans) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    if (school.name.toLowerCase().contains(q)) return true;
    final plan = _planName(plans, school.subscriptionPlanId).toLowerCase();
    return plan.contains(q);
  }

  bool _matchesPlan(School school) =>
      _planFilter == 'all' || school.subscriptionPlanId == _planFilter;

  @override
  void initState() {
    super.initState();
    if (context.read<SuperAdminBloc>().state.schools.isEmpty) {
      context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    }
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments() async {
    setState(() => _loadingPending = true);
    try {
      final pending = await _payments.getPayments(
        status: ManualPaymentStatus.pendingVerification,
      );
      if (!mounted) return;
      setState(() {
        _pendingPaymentsCount = pending.length;
        _loadingPending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPending = false);
    }
  }

  Future<void> _refresh() async {
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    await _loadPendingPayments();
  }

  String _planName(List<SubscriptionPlan> plans, String planId) {
    if (planId.isEmpty) return '—';
    for (final plan in plans) {
      if (plan.id == planId) return plan.name;
    }
    return planId;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions Overview'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading &&
              state.schools.isEmpty) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state.status == SuperAdminStatus.failure &&
              state.schools.isEmpty) {
            return _ErrorState(
              message: state.errorMessage ?? 'Unable to load schools.',
              onRetry: _refresh,
            );
          }

          final active = <School>[];
          final expiringSoon = <School>[];
          final expired = <School>[];
          final trial = <School>[];
          final suspended = <School>[];
          final cancelled = <School>[];

          final visibleSchools = state.schools
              .where((s) => _matchesSearch(s, state.plans) && _matchesPlan(s))
              .toList();

          for (final school in visibleSchools) {
            if (school.status == SchoolStatus.suspended) {
              suspended.add(school);
              continue;
            }
            if (school.status == SchoolStatus.archived) {
              cancelled.add(school);
              continue;
            }
            if (date_math.isExpired(school.subscriptionExpiry, now: now)) {
              expired.add(school);
              continue;
            }
            if (school.status == SchoolStatus.trial) {
              trial.add(school);
              continue;
            }
            if (school.status == SchoolStatus.active) {
              final daysUntilExpiry =
                  date_math.daysRemaining(
                    school.subscriptionExpiry,
                    now: now,
                  ) ??
                  0;
              if (daysUntilExpiry <= kExpiringSoonWindowDays) {
                expiringSoon.add(school);
              } else {
                active.add(school);
              }
            }
          }

          for (final bucket in [
            active,
            expiringSoon,
            expired,
            trial,
            suspended,
            cancelled,
          ]) {
            bucket.sort(
              (a, b) => a.subscriptionExpiry.compareTo(b.subscriptionExpiry),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.l,
                AppSpacing.xl,
                AppSpacing.x3l,
              ),
              children: [
                Text(
                  'Subscription standing for every school, derived from '
                  'live status and expiry dates.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _search = value.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search by school or plan',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          ),
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _PlanFilterChips(
                  plans: state.plans,
                  selected: _planFilter,
                  onSelected: (value) => setState(() => _planFilter = value),
                ),
                const SizedBox(height: AppSpacing.l),
                _pendingPaymentsBanner(context),
                const SizedBox(height: AppSpacing.xl),
                _section(
                  context,
                  title: 'Suspended',
                  subtitle: 'Access suspended by the platform owner',
                  schools: suspended,
                  plans: state.plans,
                  now: now,
                  emptyLabel: 'No suspended schools.',
                  accentColor: AppColors.warning(context),
                  icon: Icons.pause_circle_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                _section(
                  context,
                  title: 'Cancelled',
                  subtitle: 'Archived / cancelled schools',
                  schools: cancelled,
                  plans: state.plans,
                  now: now,
                  emptyLabel: 'No cancelled schools.',
                  accentColor: AppColors.textSecondary(context),
                  icon: Icons.archive_outlined,
                ),
                const SizedBox(height: AppSpacing.xl),
                _section(
                  context,
                  title: 'Expiring Soon',
                  subtitle:
                      'Active, expiring within $kExpiringSoonWindowDays days',
                  schools: expiringSoon,
                  plans: state.plans,
                  now: now,
                  emptyLabel: 'No subscriptions expiring soon.',
                  accentColor: AppColors.warning(context),
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                _section(
                  context,
                  title: 'Expired',
                  subtitle: 'Past their subscription expiry date',
                  schools: expired,
                  plans: state.plans,
                  now: now,
                  emptyLabel: 'No expired subscriptions.',
                  accentColor: AppColors.danger(context),
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(height: AppSpacing.xl),
                _section(
                  context,
                  title: 'Trial',
                  subtitle: 'Schools currently on a trial',
                  schools: trial,
                  plans: state.plans,
                  now: now,
                  emptyLabel: 'No schools on trial.',
                  accentColor: AppColors.information(context),
                  icon: Icons.hourglass_top_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                _section(
                  context,
                  title: 'Active',
                  subtitle: 'Active with a healthy runway',
                  schools: active,
                  plans: state.plans,
                  now: now,
                  emptyLabel: 'No active subscriptions with a healthy runway.',
                  accentColor: AppColors.success(context),
                  icon: Icons.verified_rounded,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pendingPaymentsBanner(BuildContext context) {
    if (_loadingPending) {
      return const SizedBox.shrink();
    }
    if (_pendingPaymentsCount == 0) {
      return AlertBanner(
        title: 'All caught up',
        message: 'No payments are currently awaiting verification.',
        color: AppColors.success(context),
        icon: Icons.task_alt_rounded,
      );
    }
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BillingPage(
            initialFilter: ManualPaymentStatus.pendingVerification,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.danger(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.danger(context),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              '$_pendingPaymentsCount payment${_pendingPaymentsCount == 1 ? '' : 's'} '
              'awaiting verification',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<School> schools,
    required List<SubscriptionPlan> plans,
    required DateTime now,
    required String emptyLabel,
    required Color accentColor,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                '$title (${schools.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.s,
            bottom: AppSpacing.m,
            left: AppSpacing.x4l,
          ),
          child: Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        if (schools.isEmpty)
          AppCard(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: accentColor),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: Text(emptyLabel)),
              ],
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final school in schools)
                  _SubscriptionRow(
                    school: school,
                    planName: _planName(plans, school.subscriptionPlanId),
                    dateFormat: _date,
                    now: now,
                    accentColor: accentColor,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlanFilterChips extends StatelessWidget {
  const _PlanFilterChips({
    required this.plans,
    required this.selected,
    required this.onSelected,
  });

  final List<SubscriptionPlan> plans;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All plans'),
            selected: selected == 'all',
            onSelected: (_) => onSelected('all'),
          ),
          for (final plan in plans) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(plan.name),
              selected: selected == plan.id,
              onSelected: (_) => onSelected(plan.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({
    required this.school,
    required this.planName,
    required this.dateFormat,
    required this.now,
    required this.accentColor,
  });

  final School school;
  final String planName;
  final DateFormat dateFormat;
  final DateTime now;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = school.subscriptionExpiry.difference(now).inDays;
    final expiryLabel = daysUntilExpiry < 0
        ? 'Expired ${-daysUntilExpiry}d ago'
        : daysUntilExpiry == 0
        ? 'Expires today'
        : '$daysUntilExpiry d remaining';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolDetailScreen(school: school),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    planName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(school.subscriptionExpiry),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View Payments',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillingPage()),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 54,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
