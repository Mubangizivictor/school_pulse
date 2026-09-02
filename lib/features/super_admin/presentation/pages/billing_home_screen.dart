import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import 'billing_page.dart';
import 'manual_payment_config_screen.dart';
import 'payment_review_screen.dart';
import 'subscription_plans_screen.dart';

enum _Period { today, thisWeek, thisMonth, thisYear, all }

extension on _Period {
  String get label => switch (this) {
    _Period.today => 'Today',
    _Period.thisWeek => 'This week',
    _Period.thisMonth => 'This month',
    _Period.thisYear => 'This year',
    _Period.all => 'All time',
  };

  bool includes(DateTime date) {
    final now = DateTime.now();
    switch (this) {
      case _Period.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case _Period.thisWeek:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        return !date.isBefore(startOfWeek);
      case _Period.thisMonth:
        return date.year == now.year && date.month == now.month;
      case _Period.thisYear:
        return date.year == now.year;
      case _Period.all:
        return true;
    }
  }
}

/// Compact "Billing" dashboard that replaced the old separate Payments and
/// Plans nav destinations. It reuses BillingPage's existing
/// ManualPaymentService for real payment data and the SuperAdminBloc's
/// existing schools/plans state for plan performance -- no new backend
/// logic. "Manage plans"/"Payment methods" and payment/plan rows push the
/// pre-existing screens unchanged.
class BillingHomeScreen extends StatefulWidget {
  const BillingHomeScreen({super.key, this.initialFilter, this.initialTab = 0});

  final ManualPaymentStatus? initialFilter;

  /// Kept for compatibility with the previous 3-tab shell's callers; a
  /// non-zero tab now just means "come here already filtered/pending".
  final int initialTab;

  @override
  State<BillingHomeScreen> createState() => _BillingHomeScreenState();
}

class _BillingHomeScreenState extends State<BillingHomeScreen> {
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _ugx = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );

  List<ManualSubscriptionPayment>? _items;
  bool _loading = true;
  String? _error;
  _Period _period = _Period.thisMonth;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.initialFilter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openBillingPage(context, filter: widget.initialFilter);
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _payments.getPayments();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load billing data.';
      });
    }
  }

  Future<void> _refresh() async {
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    await _load();
  }

  List<ManualSubscriptionPayment> get _scoped =>
      (_items ?? const []).where((p) => _period.includes(p.submittedAt)).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    body: SafeArea(
      bottom: false,
      child: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: _body(context, state),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _body(BuildContext context, SuperAdminState state) {
    final wide = isSuperAdminWide(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Billing', style: _pageTitle(context)),
            const Spacer(),
            _HeaderIconAction(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh billing data',
              onTap: _refresh,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PeriodPicker(
          period: _period,
          onChanged: (value) => setState(() => _period = value),
        ),
        const SizedBox(height: 14),
        if (_error != null)
          _ErrorCard(message: _error!, onRetry: _load)
        else ...[
          _metricGrid(context, state, wide),
          const SizedBox(height: 14),
          RevenueTrendCard(payments: _scoped),
          const SizedBox(height: 14),
          _needsReviewSection(context),
          const SizedBox(height: 14),
          _planPerformanceSection(context, state),
          const SizedBox(height: 14),
          _actionsRow(context, wide),
        ],
      ],
    );
  }

  Widget _metricGrid(BuildContext context, SuperAdminState state, bool wide) {
    if (_loading && _items == null) {
      return const SizedBox(height: 184, child: Center(child: SchoolPulseLoader()));
    }
    final scoped = _scoped;
    final paid = scoped
        .where((p) => p.status == ManualPaymentStatus.approved)
        .fold<int>(0, (sum, p) => sum + p.submittedAmount);
    final pendingCount =
        scoped.where((p) => p.status == ManualPaymentStatus.pendingVerification).length;
    final overdueSchools = state.schools.where(
      (s) =>
          s.status == SchoolStatus.active &&
          s.subscriptionExpiry.isBefore(DateTime.now()),
    ).length;
    final mrr = _estimatedMonthlyRevenue(state.schools, state.plans);

    final cards = [
      PlatformMetricCard(
        icon: Icons.show_chart_rounded,
        color: AppColors.information(context),
        label: 'MRR (UGX)',
        value: _formatCompact(mrr),
        detail: 'Recurring monthly',
      ),
      PlatformMetricCard(
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success(context),
        label: 'Paid',
        value: _formatCompact(paid),
        detail: _period.label,
      ),
      PlatformMetricCard(
        icon: Icons.schedule_rounded,
        color: AppColors.warning(context),
        label: 'Pending review',
        value: '$pendingCount',
        detail: pendingCount == 1 ? '1 payment' : '$pendingCount payments',
      ),
      PlatformMetricCard(
        icon: Icons.error_outline_rounded,
        color: AppColors.danger(context),
        label: 'Overdue',
        value: '$overdueSchools',
        detail: overdueSchools == 1 ? '1 school' : '$overdueSchools schools',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = wide ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 9,
          children: [for (final card in cards) SizedBox(width: width, child: card)],
        );
      },
    );
  }

  Widget _needsReviewSection(BuildContext context) {
    final pending = _scoped
        .where((p) => p.status == ManualPaymentStatus.pendingVerification)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return _SectionCard(
      title: 'Needs review',
      actionLabel: pending.isEmpty ? null : 'View all',
      onAction: pending.isEmpty
          ? null
          : () => _openBillingPage(context, filter: ManualPaymentStatus.pendingVerification),
      child: _loading && _items == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: SchoolPulseLoader()),
            )
          : pending.isEmpty
              ? const _CompactEmpty(
                  'No payments waiting for review.',
                  title: 'All caught up',
                )
              : Column(
                  children: [
                    for (final (i, payment) in pending.take(5).indexed) ...[
                      if (i > 0) Divider(height: 1, color: AppColors.border(context)),
                      PaymentReviewRow(
                        payment: payment,
                        amountLabel: _ugx.format(payment.submittedAmount),
                        onTap: () => _openReview(context, payment),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _planPerformanceSection(BuildContext context, SuperAdminState state) {
    final plans = [...state.plans]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final schoolsByPlan = <String, List<School>>{};
    for (final school in state.schools) {
      schoolsByPlan.putIfAbsent(school.subscriptionPlanId, () => []).add(school);
    }
    return _SectionCard(
      title: 'Plan performance',
      actionLabel: plans.isEmpty ? null : 'View all',
      onAction: plans.isEmpty ? null : () => _openPlans(context),
      child: plans.isEmpty
          ? const _CompactEmpty(
              'No subscription plans configured yet.',
              title: 'No plans yet',
            )
          : Column(
              children: [
                for (final (i, plan) in plans.indexed) ...[
                  if (i > 0) Divider(height: 1, color: AppColors.border(context)),
                  PlanPerformanceRow(
                    plan: plan,
                    schoolCount: schoolsByPlan[plan.id]?.length ?? 0,
                    monthlyRevenue: _formatCompact(
                      _planMonthlyRevenue(plan, schoolsByPlan[plan.id] ?? const []),
                    ),
                    onTap: () => _openPlans(context),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _actionsRow(BuildContext context, bool wide) {
    final actions = [
      _ActionCard(
        icon: Icons.sell_outlined,
        title: 'Manage plans',
        subtitle: 'Create and manage plans',
        onTap: () => _openPlans(context),
      ),
      _ActionCard(
        icon: Icons.credit_card_outlined,
        title: 'Payment methods',
        subtitle: 'Manage bank & mobile',
        onTap: () => _openPaymentMethods(context),
      ),
    ];
    if (wide) {
      return Row(
        children: [
          for (final (i, action) in actions.indexed) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: action),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (final (i, action) in actions.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          action,
        ],
      ],
    );
  }

  void _openBillingPage(BuildContext context, {ManualPaymentStatus? filter}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BillingPage(initialFilter: filter)),
    );
  }

  void _openReview(BuildContext context, ManualSubscriptionPayment payment) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentReviewScreen(payment: payment)),
    );
  }

  void _openPlans(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
    );
  }

  void _openPaymentMethods(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualPaymentConfigScreen()),
    );
  }
}

class _HeaderIconAction extends StatelessWidget {
  const _HeaderIconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        ),
      ),
    ),
  );
}

class CompactPeriodPicker extends StatelessWidget {
  const CompactPeriodPicker({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: label,
    onSelected: onSelected,
    itemBuilder: (_) => [
      for (final option in options) PopupMenuItem(value: option, child: Text(option)),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary(context)),
          const SizedBox(width: 7),
          Text(
            selected,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary(context)),
        ],
      ),
    ),
  );
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.period, required this.onChanged});
  final _Period period;
  final ValueChanged<_Period> onChanged;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: CompactPeriodPicker(
      label: 'Select period',
      options: _Period.values.map((p) => p.label).toList(),
      selected: period.label,
      onSelected: (label) {
        final match = _Period.values.firstWhere((p) => p.label == label);
        onChanged(match);
      },
    ),
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
    padding: const EdgeInsets.all(12),
    borderRadius: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class RevenueTrendCard extends StatelessWidget {
  const RevenueTrendCard({super.key, required this.payments});
  final List<ManualSubscriptionPayment> payments;
  @override
  Widget build(BuildContext context) {
    final approved = payments.where((p) => p.status == ManualPaymentStatus.approved).toList();
    return PulseCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue trend', style: _sectionTitle(context)),
          const SizedBox(height: 10),
          if (approved.isEmpty)
            const _CompactEmpty(
              'No approved payments in this period yet.',
              title: 'No revenue data',
            )
          else
            SizedBox(height: 96, child: _Sparkline(payments: approved)),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.payments});
  final List<ManualSubscriptionPayment> payments;
  @override
  Widget build(BuildContext context) {
    final byDay = <DateTime, int>{};
    for (final payment in payments) {
      final day = DateTime(
        payment.submittedAt.year,
        payment.submittedAt.month,
        payment.submittedAt.day,
      );
      byDay[day] = (byDay[day] ?? 0) + payment.submittedAmount;
    }
    final days = byDay.keys.toList()..sort();
    if (days.length < 2) {
      return const _CompactEmpty('Not enough data points to chart yet.');
    }
    final maxValue = byDay.values.fold<int>(0, (a, b) => a > b ? a : b);
    final color = AppColors.information(context);
    return CustomPaint(
      painter: _SparklinePainter(
        values: [for (final day in days) byDay[day]!.toDouble()],
        maxValue: maxValue.toDouble(),
        color: color,
      ),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.maxValue, required this.color});
  final List<double> values;
  final double maxValue;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || maxValue <= 0) return;
    final path = Path();
    final stepX = size.width / (values.length - 1);
    for (var i = 0; i < values.length; i++) {
      final x = stepX * i;
      final y = size.height - (values[i] / maxValue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()..color = color.withValues(alpha: .08);
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.maxValue != maxValue;
}

class PaymentReviewRow extends StatelessWidget {
  const PaymentReviewRow({
    super.key,
    required this.payment,
    required this.amountLabel,
    required this.onTap,
  });
  final ManualSubscriptionPayment payment;
  final String amountLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.schoolName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _rowTitle(context),
                ),
                const SizedBox(height: 2),
                Text(
                  'Submitted ${_relative(payment.submittedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _rowBody(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountLabel,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(label: 'Pending review', color: AppColors.warning(context)),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
        ],
      ),
    ),
  );
}

class PlanPerformanceRow extends StatelessWidget {
  const PlanPerformanceRow({
    super.key,
    required this.plan,
    required this.schoolCount,
    required this.monthlyRevenue,
    required this.onTap,
  });
  final SubscriptionPlan plan;
  final int schoolCount;
  final String monthlyRevenue;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.informationSurface(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              plan.isPopular ? Icons.workspace_premium_outlined : Icons.sell_outlined,
              size: 17,
              color: AppColors.information(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _rowTitle(context)),
                const SizedBox(height: 2),
                Text(
                  '$schoolCount ${schoolCount == 1 ? 'school' : 'schools'}',
                  style: _rowBody(context),
                ),
              ],
            ),
          ),
          Text(
            monthlyRevenue,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
        ],
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PulseCard(
    onTap: onTap,
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.informationSurface(context),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.information(context), size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _rowTitle(context)),
              const SizedBox(height: 2),
              Text(subtitle, style: _rowBody(context)),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty(this.message, {this.title = 'Nothing here yet'});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 76, maxHeight: 96),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        Icon(Icons.inbox_outlined, size: 22, color: AppColors.textMuted(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _rowBody(context),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => PulseCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off_outlined, color: AppColors.danger(context)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: _rowBody(context)),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

int _estimatedMonthlyRevenue(List<School> schools, List<SubscriptionPlan> plans) {
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

double _planMonthlyRevenue(SubscriptionPlan plan, List<School> schools) {
  if (plan.customPricing) return 0;
  final active = schools.where((s) => s.status == SchoolStatus.active).length;
  final monthlyPrice = switch (plan.billingCycle) {
    BillingCycle.monthly => plan.price,
    BillingCycle.termly => plan.price * 30 / plan.termLengthDays,
    BillingCycle.yearly => plan.price / 12,
  };
  return monthlyPrice * active;
}

String _formatCompact(num value) =>
    NumberFormat.compactCurrency(symbol: 'UGX ', decimalDigits: 0).format(value);

String _relative(DateTime value) {
  final d = DateTime.now().difference(value);
  if (d.inMinutes < 1) return 'now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

TextStyle _pageTitle(BuildContext c) => AppTypography.headlineMedium.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 24,
  fontWeight: FontWeight.w800,
);
TextStyle _sectionTitle(BuildContext c) => AppTypography.titleLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 17,
  fontWeight: FontWeight.w800,
);
TextStyle _rowTitle(BuildContext c) => AppTypography.labelLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontWeight: FontWeight.w700,
  fontSize: 14,
);
TextStyle _rowBody(BuildContext c) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(c),
  fontSize: 12.5,
);
