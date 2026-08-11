import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../../domain/entities/school_application.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import 'super_admin_notifications_screen.dart';

/// Platform Overview / Dashboard tab of the SaaS owner console.
///
/// [onOpenBilling] switches the parent [IndexedStack] to the Payments &
/// Billing tab; [onOpenApplications] switches to the Schools tab (which
/// hosts the applications list) for the "Action Required" shortcuts.
class SuperAdminOverviewScreen extends StatefulWidget {
  const SuperAdminOverviewScreen({
    super.key,
    required this.onOpenBilling,
    required this.onOpenSchools,
  });

  final VoidCallback onOpenBilling;
  final VoidCallback onOpenSchools;

  @override
  State<SuperAdminOverviewScreen> createState() =>
      _SuperAdminOverviewScreenState();
}

class _SuperAdminOverviewScreenState extends State<SuperAdminOverviewScreen> {
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, h:mm a');

  bool _loadingPayments = true;
  String? _paymentsError;
  List<ManualSubscriptionPayment> _recentPayments = const [];
  int _pendingPaymentsCount = 0;
  int _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loadingPayments = true;
      _paymentsError = null;
    });
    try {
      final all = await _payments.getPayments();
      final sorted = List<ManualSubscriptionPayment>.from(all)
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      if (!mounted) return;
      setState(() {
        _recentPayments = sorted.take(5).toList();
        _pendingPaymentsCount = all
            .where((p) => p.status == ManualPaymentStatus.pendingVerification)
            .length;
        _totalRevenue = all
            .where((p) => p.status == ManualPaymentStatus.approved)
            .fold(0, (sum, p) => sum + p.submittedAmount);
        _loadingPayments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingPayments = false;
        _paymentsError = error.toString().replaceFirst(
          RegExp(r'^Exception:\s*'),
          '',
        );
      });
    }
  }

  Future<void> _refresh() async {
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    await _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuperAdminBloc, SuperAdminState>(
      builder: (context, state) {
        if (state.status == SuperAdminStatus.loading) {
          return const Center(child: SchoolPulseLoader());
        }

        final stats = state.stats;
        final recentApplications =
            List<SchoolApplication>.from(state.applications)..sort((a, b) {
              final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
              final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
              return bDate.compareTo(aDate);
            });
        final pendingApplications = recentApplications
            .where((a) => a.status == SchoolApplicationStatus.pendingReview)
            .length;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverviewHeader(
                    onNotifications: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuperAdminNotificationsScreen(),
                      ),
                    ),
                    onRefresh: _refresh,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _TotalRevenueCard(
                                    amount: _loadingPayments
                                        ? 0
                                        : _totalRevenue,
                                    onTap: widget.onOpenBilling,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _MiniStatCard(
                                        title: 'Total Schools',
                                        value:
                                            ((stats['totalSchools'] ?? 0)
                                                    as num)
                                                .toInt(),
                                        icon: Icons.school_rounded,
                                        iconBg: AppColors.information(
                                          context,
                                        ).withValues(alpha: 0.15),
                                        iconColor: AppColors.information(
                                          context,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.m),
                                      _MiniStatCard(
                                        title: 'Active Schools',
                                        value:
                                            ((stats['activeSchools'] ?? 0)
                                                    as num)
                                                .toInt(),
                                        icon: Icons.verified_rounded,
                                        iconBg: AppColors.success(
                                          context,
                                        ).withValues(alpha: 0.15),
                                        iconColor: AppColors.success(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.x2l,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pendingApplications > 0 ||
                            _pendingPaymentsCount > 0) ...[
                          SectionHeader(title: 'Action Required'),
                          const SizedBox(height: AppSpacing.s),
                          _ActionRequiredCard(
                            pendingApplications: pendingApplications,
                            pendingPayments: _pendingPaymentsCount,
                            onOpenApplications: widget.onOpenSchools,
                            onOpenPayments: widget.onOpenBilling,
                          ),
                          const SizedBox(height: AppSpacing.x2l),
                        ],
                        SectionHeader(
                          title: 'Recent School Applications',
                          actionLabel: 'View all',
                          onActionPressed: widget.onOpenSchools,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        _RecentApplicationsCard(
                          applications: recentApplications,
                        ),
                        const SizedBox(height: AppSpacing.x2l),
                        SectionHeader(
                          title: 'Recent Payments',
                          actionLabel: 'View all',
                          onActionPressed: widget.onOpenBilling,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        _RecentPaymentsCard(
                          loading: _loadingPayments,
                          error: _paymentsError,
                          payments: _recentPayments,
                          money: _money,
                          dateFormat: _dateTime,
                          onRetry: _loadPayments,
                          onTapPayment: (_) => widget.onOpenBilling(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionRequiredCard extends StatelessWidget {
  const _ActionRequiredCard({
    required this.pendingApplications,
    required this.pendingPayments,
    required this.onOpenApplications,
    required this.onOpenPayments,
  });

  final int pendingApplications;
  final int pendingPayments;
  final VoidCallback onOpenApplications;
  final VoidCallback onOpenPayments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pendingApplications > 0)
          _ActionRow(
            icon: Icons.assignment_late_rounded,
            color: AppColors.warning(context),
            title:
                '$pendingApplications school application${pendingApplications == 1 ? '' : 's'} awaiting review',
            subtitle: 'New schools waiting for approval or rejection.',
            onTap: onOpenApplications,
          ),
        if (pendingApplications > 0 && pendingPayments > 0)
          const SizedBox(height: AppSpacing.m),
        if (pendingPayments > 0)
          _ActionRow(
            icon: Icons.receipt_long_rounded,
            color: AppColors.danger(context),
            title:
                '$pendingPayments payment${pendingPayments == 1 ? '' : 's'} awaiting verification',
            subtitle: 'Confirm money received before activating or renewing.',
            onTap: onOpenPayments,
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _RecentApplicationsCard extends StatelessWidget {
  const _RecentApplicationsCard({required this.applications});

  final List<SchoolApplication> applications;

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No applications yet',
        message: 'No public school applications have been submitted yet.',
      );
    }

    final recent = applications.take(5).toList();
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 68),
        itemBuilder: (context, index) {
          final application = recent[index];
          final date = application.updatedAt ?? application.createdAt;
          return _ApplicationRow(
            name: application.schoolName.isEmpty
                ? 'School registration'
                : application.schoolName,
            dateLabel: date == null
                ? null
                : DateFormat('dd MMM, h:mm a').format(date.toLocal()),
            statusLabel: application.status.label,
            statusColor: _statusColor(context, application.status),
          );
        },
      ),
    );
  }

  Color _statusColor(BuildContext context, SchoolApplicationStatus status) =>
      switch (status) {
        SchoolApplicationStatus.pendingReview => AppColors.warning(context),
        SchoolApplicationStatus.approved => AppColors.success(context),
        SchoolApplicationStatus.rejected => AppColors.danger(context),
        _ => AppColors.information(context),
      };
}

class _RecentPaymentsCard extends StatelessWidget {
  const _RecentPaymentsCard({
    required this.loading,
    required this.error,
    required this.payments,
    required this.money,
    required this.dateFormat,
    required this.onRetry,
    required this.onTapPayment,
  });

  final bool loading;
  final String? error;
  final List<ManualSubscriptionPayment> payments;
  final NumberFormat money;
  final DateFormat dateFormat;
  final VoidCallback onRetry;
  final ValueChanged<ManualSubscriptionPayment> onTapPayment;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.x3l),
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (error != null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(child: Text(error!)),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (payments.isEmpty) {
      return const EmptyState(
        icon: Icons.payments_outlined,
        title: 'No payments yet',
        message: 'No manual subscription payments have been submitted yet.',
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 68),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _PaymentRow(
            icon: payment.method == ManualPaymentMethod.mtn
                ? Icons.phone_android_rounded
                : Icons.account_balance_rounded,
            name: payment.schoolName,
            amountDateLabel:
                '${money.format(payment.submittedAmount)} • ${dateFormat.format(payment.submittedAt)}',
            statusLabel: _statusLabel(payment.status),
            statusColor: _statusColor(context, payment.status),
            onTap: () => onTapPayment(payment),
          );
        },
      ),
    );
  }

  String _statusLabel(ManualPaymentStatus status) => switch (status) {
    ManualPaymentStatus.pendingVerification => 'Pending',
    ManualPaymentStatus.approved => 'Approved',
    ManualPaymentStatus.rejected => 'Rejected',
  };

  Color _statusColor(BuildContext context, ManualPaymentStatus status) =>
      switch (status) {
        ManualPaymentStatus.pendingVerification => AppColors.warning(context),
        ManualPaymentStatus.approved => AppColors.success(context),
        ManualPaymentStatus.rejected => AppColors.danger(context),
      };
}

/// Grouped-list row for a single school application: rounded icon avatar,
/// name + date, status pill and chevron.
class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({
    required this.name,
    required this.dateLabel,
    required this.statusLabel,
    required this.statusColor,
  });

  final String name;
  final String? dateLabel;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.information(context).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppColors.information(context),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (dateLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateLabel!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          StatusBadge(label: statusLabel, color: statusColor),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
    );
  }
}

/// Grouped-list row for a single payment: rounded icon tile, name + amount
/// & date, status pill and chevron.
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.icon,
    required this.name,
    required this.amountDateLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  final IconData icon;
  final String name;
  final String amountDateLabel;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.electricBlue, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amountDateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.electricBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            StatusBadge(label: statusLabel, color: statusColor),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Purple/blue gradient hero header with title, subtitle and the
/// notifications/refresh icon buttons.
class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.onNotifications,
    required this.onRefresh,
  });

  final VoidCallback onNotifications;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.l,
          AppSpacing.xl,
          AppSpacing.x4l + 56,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4839E0), Color(0xFF6A3AE0), Color(0xFF8B3FE0)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Platform Overview',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Monitor schools, subscriptions, payments and platform activity.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  _HeaderIconButton(
                    icon: Icons.notifications_outlined,
                    onTap: onNotifications,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  _HeaderIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: onRefresh,
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
    );
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Dark gradient "Total Revenue" hero stat card.
class _TotalRevenueCard extends StatelessWidget {
  const _TotalRevenueCard({required this.amount, required this.onTap});

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern().format(amount);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.midnightNavy, AppColors.deepNavy],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Total Revenue',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'UGX $money',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact white/dark surface stat card used for Total Schools / Active
/// Schools in the top hero row.
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
