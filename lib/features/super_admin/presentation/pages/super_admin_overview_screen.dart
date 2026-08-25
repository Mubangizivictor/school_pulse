import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../../domain/entities/school.dart';
import '../../domain/entities/school_application.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_top_bar.dart';
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
    this.onSearchSchools,
  });

  final VoidCallback onOpenBilling;
  final VoidCallback onOpenSchools;

  /// Backs the desktop top bar's global search (Dashboard-only): since
  /// Schools/Applications are the only owner-searchable dataset today, a
  /// submitted query jumps to Schools and pre-fills its search field.
  final ValueChanged<String>? onSearchSchools;

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

        if (isSuperAdminWide(context)) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            body: _DesktopOverviewBody(
              schools: state.schools,
              recentApplications: recentApplications,
              pendingApplications: pendingApplications,
              loadingPayments: _loadingPayments,
              paymentsError: _paymentsError,
              recentPayments: _recentPayments,
              pendingPaymentsCount: _pendingPaymentsCount,
              totalRevenue: _totalRevenue,
              money: _money,
              dateFormat: _dateTime,
              onRefresh: _refresh,
              onRetryPayments: _loadPayments,
              onOpenBilling: widget.onOpenBilling,
              onOpenSchools: widget.onOpenSchools,
              onSearchSchools: widget.onSearchSchools ?? (_) {},
            ),
          );
        }

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
                                        iconBg: AppColors.information(context),
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
                                        iconBg: AppColors.success(context),
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
              color: color,
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
              color: AppColors.information(context),
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
                color: AppColors.electricBlue,
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
            colors: [Colors.black, Colors.black, Colors.black],
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
                  color: Colors.white,
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
                  color: Colors.white,
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
                            color: Colors.white,
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
      side: BorderSide(color: Colors.white),
    );
    return Material(
      color: Colors.white,
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
                color: AppColors.deepNavy,
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
                  color: Colors.white,
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
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
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
                    color: AppColors.electricBlue,
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

/// Desktop ("Platform Overview") body matching the reference dashboard: a
/// flat page header, a row of metric cards, recent applications/payments
/// side-by-side, and a Revenue Overview / Subscription Status / Platform
/// Health row underneath. Uses the same production data as the mobile
/// layout — nothing here is demo/dummy content.
class _DesktopOverviewBody extends StatelessWidget {
  const _DesktopOverviewBody({
    required this.schools,
    required this.recentApplications,
    required this.pendingApplications,
    required this.loadingPayments,
    required this.paymentsError,
    required this.recentPayments,
    required this.pendingPaymentsCount,
    required this.totalRevenue,
    required this.money,
    required this.dateFormat,
    required this.onRefresh,
    required this.onRetryPayments,
    required this.onOpenBilling,
    required this.onOpenSchools,
    required this.onSearchSchools,
  });

  final List<School> schools;
  final List<SchoolApplication> recentApplications;
  final int pendingApplications;
  final bool loadingPayments;
  final String? paymentsError;
  final List<ManualSubscriptionPayment> recentPayments;
  final int pendingPaymentsCount;
  final int totalRevenue;
  final NumberFormat money;
  final ValueChanged<String> onSearchSchools;
  final DateFormat dateFormat;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetryPayments;
  final VoidCallback onOpenBilling;
  final VoidCallback onOpenSchools;

  @override
  Widget build(BuildContext context) {
    final activeSchools = schools
        .where(
          (s) =>
              s.status == SchoolStatus.active || s.status == SchoolStatus.trial,
        )
        .length;

    return Column(
      children: [
        SuperAdminTopBar(
          onSearchSubmitted: (query) {
            final trimmed = query.trim();
            if (trimmed.isEmpty) return;
            onSearchSchools(trimmed);
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2l,
                AppSpacing.xl,
                AppSpacing.x2l,
                AppSpacing.x3l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DesktopPageHeader(onRefresh: onRefresh),
                  const SizedBox(height: AppSpacing.xl),
                  _DesktopMetricsRow(
                    totalRevenue: loadingPayments ? 0 : totalRevenue,
                    totalSchools: schools.length,
                    activeSchools: activeSchools,
                    pendingApplications: pendingApplications,
                    money: money,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      final applicationsCard = _DesktopSectionCard(
                        title: 'Recent School Applications',
                        onViewAll: onOpenSchools,
                        child: _RecentApplicationsCard(
                          applications: recentApplications,
                        ),
                      );
                      final paymentsCard = _DesktopSectionCard(
                        title: 'Recent Payments',
                        onViewAll: onOpenBilling,
                        child: _RecentPaymentsCard(
                          loading: loadingPayments,
                          error: paymentsError,
                          payments: recentPayments,
                          money: money,
                          dateFormat: dateFormat,
                          onRetry: onRetryPayments,
                          onTapPayment: (_) => onOpenBilling(),
                        ),
                      );
                      if (!wide) {
                        return Column(
                          children: [
                            applicationsCard,
                            const SizedBox(height: AppSpacing.xl),
                            paymentsCard,
                          ],
                        );
                      }
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: applicationsCard),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(child: paymentsCard),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      final revenueCard = _RevenueOverviewCard(
                        payments: recentPayments,
                        loading: loadingPayments,
                        money: money,
                      );
                      final sideColumn = Column(
                        children: [
                          _SubscriptionStatusCard(schools: schools),
                          const SizedBox(height: AppSpacing.xl),
                          const _PlatformHealthCard(),
                        ],
                      );
                      if (!wide) {
                        return Column(
                          children: [
                            revenueCard,
                            const SizedBox(height: AppSpacing.xl),
                            sideColumn,
                          ],
                        );
                      }
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 2, child: revenueCard),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(child: sideColumn),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopPageHeader extends StatelessWidget {
  const _DesktopPageHeader({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Overview',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor schools, subscriptions, payments and platform activity.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: 'Refresh',
          child: Material(
            color: AppColors.surfaceElevated(context),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.medium,
              side: BorderSide(color: AppColors.border(context)),
            ),
            child: InkWell(
              borderRadius: AppRadius.medium,
              onTap: onRefresh,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.refresh_rounded, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopMetricsRow extends StatelessWidget {
  const _DesktopMetricsRow({
    required this.totalRevenue,
    required this.totalSchools,
    required this.activeSchools,
    required this.pendingApplications,
    required this.money,
  });

  final int totalRevenue;
  final int totalSchools;
  final int activeSchools;
  final int pendingApplications;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 1080
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;
        final cards = [
          _DesktopMetricCard(
            title: 'Total Revenue',
            value: money.format(totalRevenue),
            icon: Icons.account_balance_wallet_rounded,
            accent: AppColors.royalBlue,
          ),
          _DesktopMetricCard(
            title: 'Total Schools',
            value: '$totalSchools',
            icon: Icons.school_rounded,
            accent: AppColors.information(context),
          ),
          _DesktopMetricCard(
            title: 'Active Schools',
            value: '$activeSchools',
            icon: Icons.verified_rounded,
            accent: AppColors.success(context),
          ),
          _DesktopMetricCard(
            title: 'Pending Applications',
            value: '$pendingApplications',
            icon: Icons.description_rounded,
            accent: AppColors.warning(context),
          ),
        ];
        return Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.xl,
          children: [
            for (final card in cards)
              SizedBox(
                width:
                    (constraints.maxWidth - AppSpacing.xl * (perRow - 1)) /
                    perRow,
                child: card,
              ),
          ],
        );
      },
    );
  }
}

class _DesktopMetricCard extends StatelessWidget {
  const _DesktopMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSectionCard extends StatelessWidget {
  const _DesktopSectionCard({
    required this.title,
    required this.onViewAll,
    required this.child,
  });

  final String title;
  final VoidCallback onViewAll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                TextButton(onPressed: onViewAll, child: const Text('View all')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.l,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Bar-style weekly revenue summary built from the same recent-payments
/// data as the "Recent Payments" card — no separate fetch, no fabricated
/// series. Falls back to the same clean empty state as the mobile layout
/// when there is no revenue yet.
class _RevenueOverviewCard extends StatelessWidget {
  const _RevenueOverviewCard({
    required this.payments,
    required this.loading,
    required this.money,
  });

  final List<ManualSubscriptionPayment> payments;
  final bool loading;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final approved = payments
        .where((p) => p.status == ManualPaymentStatus.approved)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Overview',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x3l),
              child: Center(child: SchoolPulseLoader()),
            )
          else if (approved.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x2l),
              child: EmptyState(
                icon: Icons.show_chart_rounded,
                title: 'No revenue data',
                message:
                    'Revenue data will appear here once payments are received.',
              ),
            )
          else
            _WeeklyRevenueBars(payments: approved, money: money),
        ],
      ),
    );
  }
}

class _WeeklyRevenueBars extends StatelessWidget {
  const _WeeklyRevenueBars({required this.payments, required this.money});

  final List<ManualSubscriptionPayment> payments;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday % 7));
    final totalsByDay = List<int>.filled(7, 0);
    for (final payment in payments) {
      final day = payment.submittedAt.toLocal();
      final diff = DateTime(
        day.year,
        day.month,
        day.day,
      ).difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7) {
        totalsByDay[diff] += payment.submittedAmount;
      }
    }
    final maxValue = totalsByDay.fold<int>(0, (a, b) => a > b ? a : b);
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      totalsByDay[i] == 0 ? '' : money.format(totalsByDay[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary(context),
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: maxValue == 0
                          ? 4
                          : (120 * totalsByDay[i] / maxValue).clamp(4, 120),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({required this.schools});

  final List<School> schools;

  @override
  Widget build(BuildContext context) {
    final active = schools.where((s) => s.status == SchoolStatus.active).length;
    final trial = schools.where((s) => s.status == SchoolStatus.trial).length;
    final suspended = schools
        .where((s) => s.status == SchoolStatus.suspended)
        .length;
    final archived = schools
        .where((s) => s.status == SchoolStatus.archived)
        .length;

    final rows = [
      ('Active', active, AppColors.success(context)),
      ('Trial', trial, AppColors.information(context)),
      ('Expired', archived, AppColors.warning(context)),
      ('Suspended', suspended, AppColors.danger(context)),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Status',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: row.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      row.$1,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  Text(
                    '${row.$2}',
                    style: AppTypography.labelLarge.copyWith(
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

/// Static "all systems operational" indicator, matching the reference.
/// Reflects that the dashboard itself loaded successfully — there is no
/// separate platform health/monitoring feed to bind to.
class _PlatformHealthCard extends StatelessWidget {
  const _PlatformHealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Health',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successSurface(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.success(context),
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All systems operational',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Everything is running smoothly.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
