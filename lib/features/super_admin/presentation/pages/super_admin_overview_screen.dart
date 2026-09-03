import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/platform_health/data/platform_health_repository.dart';
import 'package:school_pulse/features/platform_health/domain/platform_health_models.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school_application.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';

/// Presentation-only, compact platform overview. It consumes the existing
/// SuperAdminBloc state and existing payment service without changing owner
/// routes, authorization, data models, or repositories.
class SuperAdminOverviewScreen extends StatefulWidget {
  const SuperAdminOverviewScreen({
    super.key,
    required this.onOpenBilling,
    required this.onOpenSchools,
    this.onSearchSchools,
  });
  final VoidCallback onOpenBilling;
  final VoidCallback onOpenSchools;
  final ValueChanged<String>? onSearchSchools;
  @override
  State<SuperAdminOverviewScreen> createState() =>
      _SuperAdminOverviewScreenState();
}

class _SuperAdminOverviewScreenState extends State<SuperAdminOverviewScreen> {
  Future<void> _refresh() async {
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    context.read<SuperAdminBloc>().add(const LoadAuditLogsEvent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
      builder: (context, state) => RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: _OverviewBody(
                state: state,
                onRefresh: _refresh,
                onOpenSchools: widget.onOpenSchools,
                onOpenBilling: widget.onOpenBilling,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.state,
    required this.onRefresh,
    required this.onOpenSchools,
    required this.onOpenBilling,
  });
  final SuperAdminState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSchools, onOpenBilling;

  @override
  Widget build(BuildContext context) {
    if (state.status == SuperAdminStatus.failure) {
      return _StateCard(
        icon: Icons.cloud_off_outlined,
        title: 'Platform overview is unavailable',
        message:
            state.errorMessage ?? 'Please check your connection and try again.',
        action: onRefresh,
      );
    }
    final schools = state.schools;
    final pendingApps = state.applications
        .where((a) => a.status == SchoolApplicationStatus.pendingReview)
        .length;
    final expired = schools
        .where((s) => s.subscriptionExpiry.isBefore(DateTime.now()))
        .length;
    // School verification is not a domain field. Only represent an explicit
    // existing metadata flag; missing data does not become a made-up metric.
    final unverified = schools
        .where((s) => s.metadata['verified'] == false)
        .length;
    final active = schools.where((s) => s.status == SchoolStatus.active).length;
    final needsAction = pendingApps + expired + unverified;
    final mrr = _estimatedMonthlyRevenue(schools, state.plans);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CompactTopBar(),
        const SizedBox(height: 18),
        const _PlatformHealthCard(),
        const SizedBox(height: 16),
        if (state.status == SuperAdminStatus.loading)
          const _MetricLoading()
        else
          _MetricGrid(
            total: schools.length,
            active: active,
            mrr: mrr,
            actionNeeded: needsAction,
            onActionNeeded: onOpenSchools,
          ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Quick actions',
          child: _QuickActions(
            onCreateSchool: onOpenSchools,
            onApplications: onOpenSchools,
            onPlans: () => context.go('/super-admin/plans'),
            onAudit: () => context.go('/super-admin/audit-logs'),
          ),
        ),
        const SizedBox(height: 20),
        AttentionList(
          pendingApplications: pendingApps,
          expiredSubscriptions: expired,
          unverifiedSchools: unverified,
          onOpenSchools: onOpenSchools,
        ),
        const SizedBox(height: 20),
        PlatformActivityTimeline(
          logs: state.auditLogs,
          schools: schools,
          onViewAll: () => context.go('/super-admin/audit-logs'),
        ),
      ],
    );
  }
}

/// Real Platform Health signal, streamed from platform_health/current (the
/// checkPlatformHealth Cloud Function's cached aggregate) via
/// PlatformHealthRepository — never derived from whether this screen's own
/// Firestore reads happened to succeed. A missing aggregate (no check has
/// run yet) shows a neutral "checking" state, never a false-positive
/// "All systems operational".
class _PlatformHealthCard extends StatefulWidget {
  const _PlatformHealthCard();
  @override
  State<_PlatformHealthCard> createState() => _PlatformHealthCardState();
}

class _PlatformHealthCardState extends State<_PlatformHealthCard> {
  final PlatformHealthRepository _repo = PlatformHealthRepository();

  @override
  Widget build(BuildContext context) => StreamBuilder<PlatformHealthSummary?>(
    stream: _repo.watchCurrent(),
    builder: (context, snapshot) {
      final summary = snapshot.data;
      final color = _colorFor(context, summary?.status);
      final healthy = summary?.status == PlatformHealthStatus.operational;
      return PulseCard(
        onTap: () => context.go('/super-admin/platform-health'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary == null
                        ? 'Checking platform status…'
                        : healthy
                        ? 'Platform healthy'
                        : 'Attention needed',
                    style: _section(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary == null
                        ? 'No health check has run yet'
                        : summary.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(context),
                  ),
                ],
              ),
            ),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Live status'),
                Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ],
        ),
      );
    },
  );

  Color _colorFor(BuildContext context, PlatformHealthStatus? status) =>
      switch (status) {
        PlatformHealthStatus.operational => AppColors.success(context),
        PlatformHealthStatus.degraded => AppColors.warning(context),
        PlatformHealthStatus.outage => AppColors.danger(context),
        PlatformHealthStatus.unknown => AppColors.textMuted(context),
        PlatformHealthStatus.notConfigured => AppColors.textMuted(context),
        null => AppColors.textMuted(context),
      };
}

class _CompactTopBar extends StatelessWidget {
  const _CompactTopBar();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Text(
              'School Pulse Admin',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _NotificationsButton(),
          ],
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<OwnerNotification>>(
    stream: OwnerNotificationService().watchNotifications(),
    builder: (context, snapshot) {
      final unread = snapshot.data?.where((item) => item.isUnread).length ?? 0;
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context).withValues(alpha: .72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border(context).withValues(alpha: .65),
              ),
            ),
            child: IconButton(
              tooltip: 'Notifications',
              // Goes through the real owner route (not a bare push) so the
              // persistent bottom navigation stays visible - Overview stays
              // highlighted, matching every other entry point into Owner
              // Notifications.
              onPressed: () => context.go('/super-admin/notifications'),
              icon: Badge(
                isLabelVisible: unread > 0,
                smallSize: 8,
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary(context),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class PlatformMetricCard extends StatelessWidget {
  const PlatformMetricCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label, value, detail;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => PulseCard(
    onTap: onTap,
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _label(context),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSmall.copyWith(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _body(context),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.total,
    required this.active,
    required this.mrr,
    required this.actionNeeded,
    required this.onActionNeeded,
  });
  final int total, active, mrr, actionNeeded;
  final VoidCallback onActionNeeded;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900 ? 4 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      final cards = [
        PlatformMetricCard(
          icon: Icons.school_outlined,
          color: AppColors.information(context),
          label: 'Total schools',
          value: '$total',
          detail: 'Across all regions',
        ),
        PlatformMetricCard(
          icon: Icons.groups_2_outlined,
          color: AppColors.success(context),
          label: 'Active schools',
          value: '$active',
          detail: total == 0
              ? 'No schools yet'
              : '${((active / total) * 100).round()}% of total',
        ),
        PlatformMetricCard(
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.information(context),
          label: 'Est. MRR (UGX)',
          value: _formatUgx(mrr),
          detail: 'Based on active plans',
        ),
        PlatformMetricCard(
          icon: Icons.warning_amber_rounded,
          color: actionNeeded == 0
              ? AppColors.success(context)
              : AppColors.warning(context),
          label: 'Action needed',
          value: '$actionNeeded',
          detail: actionNeeded == 0 ? 'All caught up' : 'Requires attention',
          onTap: actionNeeded == 0 ? null : onActionNeeded,
        ),
      ];
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final card in cards) SizedBox(width: width, child: card),
        ],
      );
    },
  );
}

class _MetricLoading extends StatelessWidget {
  const _MetricLoading();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 184,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCreateSchool,
    required this.onApplications,
    required this.onPlans,
    required this.onAudit,
  });
  final VoidCallback onCreateSchool, onApplications, onPlans, onAudit;
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_business_outlined, 'Create', onCreateSchool),
      (Icons.assignment_outlined, 'Review', onApplications),
      (Icons.sell_outlined, 'Student pricing', onPlans),
      (Icons.shield_outlined, 'Audit', onAudit),
    ];
    return LayoutBuilder(
      builder: (context, _) => Row(
        children: [
          for (final (i, action) in actions.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: PlatformQuickAction(
                icon: action.$1,
                label: action.$2,
                onTap: action.$3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PlatformQuickAction extends StatelessWidget {
  const PlatformQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PulseCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.informationSurface(context),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.information(context), size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class AttentionList extends StatelessWidget {
  const AttentionList({
    super.key,
    required this.pendingApplications,
    required this.expiredSubscriptions,
    required this.unverifiedSchools,
    required this.onOpenSchools,
  });
  final int pendingApplications, expiredSubscriptions, unverifiedSchools;
  final VoidCallback onOpenSchools;
  @override
  Widget build(BuildContext context) {
    final items = <_AttentionItem>[
      if (pendingApplications > 0)
        _AttentionItem(
          Icons.assignment_late_outlined,
          AppColors.warning(context),
          'Pending school applications',
          'Applications awaiting review',
          pendingApplications,
          onOpenSchools,
        ),
      if (expiredSubscriptions > 0)
        _AttentionItem(
          Icons.credit_card_off_outlined,
          AppColors.warning(context),
          'Expired subscriptions',
          'Schools with expired subscriptions',
          expiredSubscriptions,
          onOpenSchools,
        ),
      if (unverifiedSchools > 0)
        _AttentionItem(
          Icons.verified_user_outlined,
          AppColors.danger(context),
          'Unverified schools',
          'Schools pending verification',
          unverifiedSchools,
          onOpenSchools,
        ),
    ];
    return _SectionCard(
      title: 'Needs attention',
      actionLabel: items.isEmpty ? null : 'View all',
      onAction: items.isEmpty ? null : onOpenSchools,
      child: items.isEmpty
          ? const _CompactEmpty('Nothing needs your attention right now.')
          : Column(
              children: [
                for (final (i, item) in items.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: AppColors.border(context)),
                  _AttentionRow(item),
                ],
              ],
            ),
    );
  }
}

class _AttentionItem {
  const _AttentionItem(
    this.icon,
    this.color,
    this.title,
    this.detail,
    this.count,
    this.onTap,
  );
  final IconData icon;
  final Color color;
  final String title, detail;
  final int count;
  final VoidCallback onTap;
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow(this.item);
  final _AttentionItem item;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: item.onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _section(context),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _body(context),
                ),
              ],
            ),
          ),
          Text(
            '${item.count}',
            style: AppTypography.titleMedium.copyWith(
              color: item.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted(context),
          ),
        ],
      ),
    ),
  );
}

class PlatformActivityTimeline extends StatelessWidget {
  const PlatformActivityTimeline({
    super.key,
    required this.logs,
    required this.schools,
    required this.onViewAll,
  });
  final List<AuditLog> logs;
  final List<School> schools;
  final VoidCallback onViewAll;
  @override
  Widget build(BuildContext context) {
    final recent = List<AuditLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _SectionCard(
      title: 'Recent platform activity',
      actionLabel: 'View all',
      onAction: onViewAll,
      child: recent.isEmpty
          ? const _CompactEmpty(
              'Recent activity will appear here when audit data is available.',
            )
          : Column(
              children: [
                for (final log in recent.take(5))
                  _ActivityRow(log, _schoolName(log.schoolId)),
              ],
            ),
    );
  }

  String _schoolName(String? id) {
    for (final school in schools) {
      if (school.id == id) return school.name;
    }
    return 'Platform';
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(this.log, this.school);
  final AuditLog log;
  final String school;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppColors.information(context),
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1, height: 26, color: AppColors.border(context)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$school ${log.action}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(_relative(log.timestamp), style: _body(context)),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => PulseCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: _sectionTitle(context))),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 20,
          color: AppColors.textMuted(context),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: _body(context))),
      ],
    ),
  );
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });
  final IconData icon;
  final String title, message;
  final Future<void> Function() action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Center(
      child: PulseCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted(context)),
            const SizedBox(height: 12),
            Text(title, style: _sectionTitle(context)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: _body(context)),
            const SizedBox(height: 12),
            TextButton(onPressed: action, child: const Text('Retry')),
          ],
        ),
      ),
    ),
  );
}

String _relative(DateTime value) {
  final d = DateTime.now().difference(value);
  if (d.inMinutes < 1) return 'now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

/// Converts the existing plan prices into a monthly estimate. Custom-priced
/// plans are intentionally skipped because their authoritative price is not
/// represented in the current plan model.
int _estimatedMonthlyRevenue(
  List<School> schools,
  List<SubscriptionPlan> plans,
) {
  final plansById = {for (final plan in plans) plan.id: plan};
  return schools
      .where((school) => school.status == SchoolStatus.active)
      .fold<double>(0, (total, school) {
        final plan = plansById[school.subscriptionPlanId];
        if (plan == null || plan.customPricing) return total;
        final monthlyPrice = switch (plan.billingCycle) {
          BillingCycle.monthly => plan.price,
          BillingCycle.termly => plan.price * 30 / plan.termLengthDays,
          BillingCycle.yearly => plan.price / 12,
        };
        return total + monthlyPrice;
      })
      .round();
}

String _formatUgx(int value) => NumberFormat.compactCurrency(
  symbol: 'UGX ',
  decimalDigits: 0,
).format(value);

TextStyle _sectionTitle(BuildContext c) => AppTypography.titleLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 16,
  fontWeight: FontWeight.w800,
);
TextStyle _section(BuildContext c) => AppTypography.labelLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontWeight: FontWeight.w700,
);
TextStyle _label(BuildContext c) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(c),
  fontSize: 13,
);
TextStyle _body(BuildContext c) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(c),
  fontSize: 13,
);
