import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/platform_health_repository.dart';
import 'package:school_pulse/features/super_admin/domain/platform_health_models.dart';
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _OverviewBody(
                state: state,
                onRefresh: _refresh,
                onOpenSchools: widget.onOpenSchools,
                onOpenBilling: widget.onOpenBilling,
                onSearchSchools: widget.onSearchSchools,
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
    required this.onSearchSchools,
  });
  final SuperAdminState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSchools, onOpenBilling;
  final ValueChanged<String>? onSearchSchools;

  @override
  Widget build(BuildContext context) {
    if (state.status == SuperAdminStatus.failure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactTopBar(onSearchSchools: onSearchSchools),
          _StateCard(
            icon: Icons.cloud_off_outlined,
            title: 'Platform overview is unavailable',
            message: state.errorMessage ??
                'Please check your connection and try again.',
            action: onRefresh,
          ),
        ],
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
    final loading = state.status == SuperAdminStatus.loading;

    final reviewQueue = _ReviewQueueCard(
      applications: state.applications,
      schools: schools,
      loading: loading,
      onReviewAll: onOpenSchools,
      onOpenApplication: onOpenSchools,
    );
    final health = _PlatformHealthCard(
      totalSchools: schools.length,
      activeSchools: active,
      mrr: mrr,
    );
    final activity = PlatformActivityTimeline(
      logs: state.auditLogs,
      schools: schools,
      onViewAll: () => context.go('/super-admin/audit-logs'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompactTopBar(onSearchSchools: onSearchSchools),
        const SizedBox(height: 20),
        if (needsAction > 0) ...[
          _ReviewBanner(
            count: needsAction,
            onReviewNow: onOpenSchools,
          ),
          const SizedBox(height: 20),
        ],
        if (loading)
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
            onApplications: onOpenBilling,
            onPlans: () => context.go('/super-admin/plans'),
            onAudit: () => context.go('/super-admin/audit-logs'),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumn = constraints.maxWidth >= 960;
            if (!twoColumn) {
              return Column(
                children: [
                  reviewQueue,
                  const SizedBox(height: 20),
                  health,
                  const SizedBox(height: 20),
                  activity,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: reviewQueue),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      health,
                      const SizedBox(height: 20),
                      activity,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Inline "items need review" banner. Urgent / action-needed => red, per the
/// platform palette. Routes through the same schools destination the metric
/// row and queue use.
class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.count, required this.onReviewNow});
  final int count;
  final VoidCallback onReviewNow;
  @override
  Widget build(BuildContext context) {
    final danger = AppColors.danger(context);
    return PulseCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: AppColors.dangerSurface(context),
      borderColor: danger.withValues(alpha: .35),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  '$count ${count == 1 ? 'item needs' : 'items need'} review',
                  style: AppTypography.labelLarge.copyWith(
                    color: danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Review pending schools, payments, and actions.',
                  style: _body(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onReviewNow,
            style: TextButton.styleFrom(
              foregroundColor: danger,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Review now'),
                Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
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
  const _PlatformHealthCard({
    required this.totalSchools,
    required this.activeSchools,
    required this.mrr,
  });
  final int totalSchools, activeSchools, mrr;
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
      // The semantic state is 'Platform healthy' / 'Attention needed'; the
      // status row renders the healthy case compactly as 'Operational' to
      // match the platform status vocabulary, and exposes the full phrase as
      // the row tooltip.
      final statusTooltip = summary == null
          ? 'Checking platform status…'
          : healthy
          ? 'Platform healthy'
          : 'Attention needed';
      return _SectionCard(
        title: 'Platform health',
        actionLabel: 'View system status',
        onAction: () => context.go('/super-admin/platform-health'),
        child: Column(
          children: [
            _HealthRow(
              leading: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
              label: 'System status',
              trailing: Tooltip(
                message: statusTooltip,
                child: Text(
                  summary == null
                      ? 'Checking platform status…'
                      : healthy
                      ? 'Operational'
                      : 'Attention needed',
                  style: AppTypography.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            _HealthRow(
              leading: Icon(
                Icons.school_outlined,
                size: 18,
                color: AppColors.textSecondary(context),
              ),
              label: 'Active schools',
              trailing: Text(
                '${widget.activeSchools}',
                style: _valueStyle(context),
              ),
            ),
            _HealthRow(
              leading: Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: AppColors.textSecondary(context),
              ),
              label: 'Subscription plans',
              trailing: Text(
                _formatUgx(widget.mrr),
                style: _valueStyle(context),
              ),
            ),
            _HealthRow(
              leading: Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: summary == null
                    ? AppColors.textMuted(context)
                    : summary.summary.isEmpty
                    ? AppColors.textMuted(context)
                    : color,
              ),
              label: 'Status detail',
              trailing: Flexible(
                child: Text(
                  summary == null
                      ? 'No health check has run yet'
                      : summary.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: _body(context),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  TextStyle _valueStyle(BuildContext c) => AppTypography.labelLarge.copyWith(
    color: AppColors.textPrimary(c),
    fontWeight: FontWeight.w800,
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

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.leading,
    required this.label,
    required this.trailing,
  });
  final Widget leading;
  final String label;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: _section(context))),
        const SizedBox(width: 12),
        trailing,
      ],
    ),
  );
}

class _CompactTopBar extends StatelessWidget {
  const _CompactTopBar({this.onSearchSchools});
  final ValueChanged<String>? onSearchSchools;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Super Admin Overview',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const _PlatformStatusPill(),
            ],
          );
          final trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NotificationsButton(),
              const SizedBox(width: 12),
              const _OwnerAvatar(),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    trailing,
                  ],
                ),
                const SizedBox(height: 12),
                _TopSearchField(onSubmitted: onSearchSchools),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              title,
              const SizedBox(width: 24),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: _TopSearchField(onSubmitted: onSearchSchools),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              trailing,
            ],
          );
        },
      ),
    );
  }
}

class _PlatformStatusPill extends StatelessWidget {
  const _PlatformStatusPill();
  @override
  Widget build(BuildContext context) => StreamBuilder<PlatformHealthSummary?>(
    stream: PlatformHealthRepository().watchCurrent(),
    builder: (context, snapshot) {
      final summary = snapshot.data;
      final healthy = summary?.status == PlatformHealthStatus.operational;
      final color = summary == null
          ? AppColors.textMuted(context)
          : healthy
          ? AppColors.success(context)
          : AppColors.danger(context);
      final label = summary == null
          ? 'Checking status'
          : healthy
          ? 'All systems operational'
          : 'Attention needed';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _TopSearchField extends StatelessWidget {
  const _TopSearchField({this.onSubmitted});
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: TextField(
      onSubmitted: (value) {
        final q = value.trim();
        if (q.isNotEmpty) onSubmitted?.call(q);
      },
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search schools, regions, or plans…',
        hintStyle: _body(context),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.textMuted(context),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 0),
        filled: true,
        fillColor: AppColors.surfaceElevated(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.focus(context)),
        ),
      ),
    ),
  );
}

class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar();
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(999),
    onTap: () => context.go('/super-admin/settings'),
    child: CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.information(context),
      child: Text(
        'SA',
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _NotificationsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<OwnerNotification>>(
    stream: OwnerNotificationService().watchNotifications(),
    builder: (context, snapshot) {
      final unread = snapshot.data?.where((item) => item.isUnread).length ?? 0;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context).withValues(alpha: .72),
              borderRadius: BorderRadius.circular(12),
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
                label: Text('$unread'),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary(context),
                  size: 20,
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
        const SizedBox(height: 10),
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
            color: AppColors.textPrimary(context),
            fontSize: 20,
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
      // Mobile shows the metric row as 2x2, matching the reference; it only
      // collapses to a single column on very narrow (small-phone) widths,
      // and expands to a single 4-up row on desktop.
      final columns = constraints.maxWidth >= 900
          ? 4
          : constraints.maxWidth >= 340
          ? 2
          : 1;
      final width =
          (constraints.maxWidth - (columns - 1) * 12) / columns;
      final cards = [
        PlatformMetricCard(
          icon: Icons.account_balance_outlined,
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
          label: 'Termly revenue (UGX)',
          value: _formatUgx(mrr),
          detail: 'Based on active plans',
        ),
        PlatformMetricCard(
          icon: Icons.error_outline_rounded,
          color: actionNeeded == 0
              ? AppColors.success(context)
              : AppColors.danger(context),
          label: 'Pending reviews',
          value: '$actionNeeded',
          detail: actionNeeded == 0 ? 'All caught up' : 'Needs your attention',
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
    height: 160,
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
    final actions = <(IconData, String, String, VoidCallback)>[
      (
        Icons.add_business_outlined,
        'Register school',
        'Add a new school to the platform',
        onCreateSchool,
      ),
      (
        Icons.credit_card_outlined,
        'Confirm payment',
        'Review and confirm payments',
        onApplications,
      ),
      (
        Icons.sell_outlined,
        'Student pricing',
        'Manage pricing and plans',
        onPlans,
      ),
      (
        Icons.shield_outlined,
        'Audit log',
        'View platform audit trail',
        onAudit,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2x2 on mobile (matching the metric row), 4 across on desktop,
        // single column only on very small phones.
        final columns = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 340
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final action in actions)
              SizedBox(
                width: width,
                child: PlatformQuickAction(
                  icon: action.$1,
                  label: action.$2,
                  detail: action.$3,
                  onTap: action.$4,
                ),
              ),
          ],
        );
      },
    );
  }
}

class PlatformQuickAction extends StatelessWidget {
  const PlatformQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
  });
  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PulseCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final iconChip = Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.informationSurface(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.information(context), size: 18),
        );
        final labelText = Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        );
        final detailText = detail == null
            ? null
            : Text(
                detail!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _body(context),
              );

        // Narrow (2-up on a phone): stack icon over label, drop the chevron
        // so the text isn't crushed. Wide: the horizontal row + chevron.
        if (constraints.maxWidth < 220) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconChip,
              const SizedBox(height: 10),
              labelText,
              if (detailText != null) ...[
                const SizedBox(height: 2),
                detailText,
              ],
            ],
          );
        }
        return Row(
          children: [
            iconChip,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelText,
                  if (detailText != null) ...[
                    const SizedBox(height: 2),
                    detailText,
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted(context),
            ),
          ],
        );
      },
    ),
  );
}

/// School onboarding & payment review queue. Presentation-only: it renders
/// the real `SchoolApplication` list from bloc state and routes every row and
/// the header action to the existing Schools destination.
class _ReviewQueueCard extends StatelessWidget {
  const _ReviewQueueCard({
    required this.applications,
    required this.schools,
    required this.loading,
    required this.onReviewAll,
    required this.onOpenApplication,
  });
  final List<SchoolApplication> applications;
  final List<School> schools;
  final bool loading;
  final VoidCallback onReviewAll;
  final VoidCallback onOpenApplication;

  @override
  Widget build(BuildContext context) {
    final queue = List<SchoolApplication>.from(applications)
      ..sort((a, b) {
        final ao = _pendingFirst(a.status);
        final bo = _pendingFirst(b.status);
        if (ao != bo) return ao.compareTo(bo);
        final at = a.updatedAt ?? a.createdAt;
        final bt = b.updatedAt ?? b.createdAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    final rows = queue.take(5).toList();
    return _SectionCard(
      title: 'School onboarding & payment queue',
      actionLabel: rows.isEmpty ? null : 'Review all items',
      onAction: rows.isEmpty ? null : onReviewAll,
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          : rows.isEmpty
          ? const _CompactEmpty(
              'New school applications and payments will appear here for review.',
            )
          : Column(
              children: [
                _QueueHeaderRow(),
                Divider(height: 1, color: AppColors.border(context)),
                for (final (i, app) in rows.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: AppColors.border(context)),
                  _QueueRow(app: app, onTap: onOpenApplication),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onReviewAll,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Review all items'),
                        Icon(Icons.chevron_right_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  int _pendingFirst(SchoolApplicationStatus status) =>
      status == SchoolApplicationStatus.pendingReview ? 0 : 1;
}

class _QueueHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text('School / Request', style: _label(context)),
        ),
        Expanded(
          flex: 3,
          child: Text('Type', style: _label(context)),
        ),
        Expanded(
          flex: 2,
          child: Text('Submitted', style: _label(context)),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Status', style: _label(context)),
          ),
        ),
      ],
    ),
  );
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.app, required this.onTap});
  final SchoolApplication app;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final submitted = app.updatedAt ?? app.createdAt;
    final region = app.region.trim().isNotEmpty
        ? app.region.trim()
        : app.district.trim();
    final pending = app.status == SchoolApplicationStatus.pendingReview;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.informationSurface(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                      color: AppColors.information(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.schoolName.trim().isEmpty
                              ? 'Untitled school'
                              : app.schoolName.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _section(context),
                        ),
                        if (region.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            region,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _body(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'School application',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _body(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                submitted == null ? '—' : _relative(submitted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _body(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: _StatusChip(
                  label: app.status.label,
                  color: pending
                      ? AppColors.danger(context)
                      : app.status == SchoolApplicationStatus.approved
                      ? AppColors.success(context)
                      : AppColors.textMuted(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Retained for source/behaviour compatibility. The standalone "Needs
/// attention" panel was removed from the Overview layout in favour of the
/// inline review banner and the onboarding/payment queue, but the derivation
/// (real pending applications + expired subscriptions + explicitly
/// unverified schools) still lives here so callers and tests keep working.
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
          AppColors.danger(context),
          'Pending school applications',
          'Applications awaiting review',
          pendingApplications,
          onOpenSchools,
        ),
      if (expiredSubscriptions > 0)
        _AttentionItem(
          Icons.credit_card_off_outlined,
          AppColors.danger(context),
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
      title: 'Recent activity',
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
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: AppColors.information(context),
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1, height: 24, color: AppColors.border(context)),
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
    padding: const EdgeInsets.all(18),
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
        const SizedBox(height: 12),
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
