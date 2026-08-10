import 'package:firebase_auth/firebase_auth.dart';
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
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';

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
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final ownerLabel = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email?.trim().isNotEmpty ?? false)
        ? user!.email!.trim()
        : 'SaaS Owner';
    final initials = _initialsOf(ownerLabel);

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
          appBar: AppBar(
            title: const Text('Platform Overview'),
            actions: [
              IconButton(
                onPressed: _refresh,
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
              ),
              PopupMenuButton<String>(
                tooltip: ownerLabel,
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary(context),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      ownerLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
                onSelected: (value) {
                  if (value == 'logout') handleSuperAdminLogout(context);
                },
              ),
              const SizedBox(width: AppSpacing.s),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.x3l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Overview',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Monitor schools, subscriptions, payments and platform activity.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  GridView.count(
                    crossAxisCount: isSuperAdminWide(context) ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.xl,
                    mainAxisSpacing: AppSpacing.xl,
                    childAspectRatio: 1.35,
                    children: [
                      DashboardStatCard(
                        title: 'Total Schools',
                        value: ((stats['totalSchools'] ?? 0) as num).toDouble(),
                        icon: Icons.school_rounded,
                        color: Colors.blue,
                      ),
                      DashboardStatCard(
                        title: 'Active Schools',
                        value: ((stats['activeSchools'] ?? 0) as num)
                            .toDouble(),
                        icon: Icons.verified_rounded,
                        color: AppColors.success(context),
                      ),
                      DashboardStatCard(
                        title: 'Pending Applications',
                        value: ((stats['pendingApplications'] ?? 0) as num)
                            .toDouble(),
                        icon: Icons.rate_review_rounded,
                        color: AppColors.warning(context),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: widget.onOpenBilling,
                        child: DashboardStatCard(
                          title: 'Payments to Verify',
                          value: _loadingPayments
                              ? 0
                              : _pendingPaymentsCount.toDouble(),
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.danger(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  SectionHeader(title: 'Action Required'),
                  const SizedBox(height: AppSpacing.m),
                  _ActionRequiredCard(
                    pendingApplications: pendingApplications,
                    pendingPayments: _pendingPaymentsCount,
                    onOpenApplications: widget.onOpenSchools,
                    onOpenPayments: widget.onOpenBilling,
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  SectionHeader(
                    title: 'Recent School Applications',
                    actionLabel: 'View all',
                    onActionPressed: widget.onOpenSchools,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _RecentApplicationsCard(applications: recentApplications),
                  const SizedBox(height: AppSpacing.x3l),
                  SectionHeader(
                    title: 'Recent Payments',
                    actionLabel: 'View all',
                    onActionPressed: widget.onOpenBilling,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _RecentPaymentsCard(
                    loading: _loadingPayments,
                    error: _paymentsError,
                    payments: _recentPayments,
                    money: _money,
                    dateFormat: _dateTime,
                    onRetry: _loadPayments,
                    onTapPayment: (_) => widget.onOpenBilling(),
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _initialsOf(String label) {
    final parts = label
        .split(RegExp(r'[\s@.]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SO';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
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
    if (pendingApplications == 0 && pendingPayments == 0) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.task_alt_rounded, color: AppColors.success(context)),
            const SizedBox(width: AppSpacing.l),
            const Expanded(
              child: Text('Nothing needs your attention right now.'),
            ),
          ],
        ),
      );
    }

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
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final application = recent[index];
          final date = application.updatedAt ?? application.createdAt;
          return ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(
              application.schoolName.isEmpty
                  ? 'School registration'
                  : application.schoolName,
            ),
            subtitle: date == null
                ? null
                : Text(DateFormat('dd MMM, h:mm a').format(date.toLocal())),
            trailing: StatusBadge(
              label: application.status.label,
              color: _statusColor(context, application.status),
            ),
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
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return ListTile(
            onTap: () => onTapPayment(payment),
            leading: Icon(
              payment.method == ManualPaymentMethod.mtn
                  ? Icons.phone_android_rounded
                  : Icons.account_balance_rounded,
            ),
            title: Text(payment.schoolName),
            subtitle: Text(
              '${money.format(payment.submittedAmount)} • ${dateFormat.format(payment.submittedAt)}',
            ),
            trailing: StatusBadge(
              label: _statusLabel(payment.status),
              color: _statusColor(context, payment.status),
            ),
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
