import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/institution/domain/entities/access_mode.dart';

import '../../data/services/manual_payment_service.dart';
import '../../domain/entities/manual_subscription_payment.dart';
import '../../domain/entities/school.dart';
import 'billing_home_screen.dart';
import 'school_payments_screen.dart';

/// Screen B - Subscription & Billing. Real plan/renewal/status, a compact
/// recent-payments list scoped to this school (client-filtered from the
/// existing getManualPaymentsForOwner callable - there is no server-side
/// per-school payments query today, matching the current app's payments
/// data path), and a link into the full Billing history. "Manage
/// subscription" reuses the plan/renewal edit flow already wired on
/// SuperAdminBloc via UpdateSubscriptionEvent from the Subscriptions screen;
/// this screen surfaces state only, all lifecycle writes stay server-side.
class SchoolSubscriptionScreen extends StatefulWidget {
  const SchoolSubscriptionScreen({super.key, required this.school});
  final School school;

  @override
  State<SchoolSubscriptionScreen> createState() =>
      _SchoolSubscriptionScreenState();
}

class _SchoolSubscriptionScreenState extends State<SchoolSubscriptionScreen> {
  final ManualPaymentService _paymentsService = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateFormat = DateFormat('d MMM yyyy');

  bool _loading = true;
  String? _error;
  List<ManualSubscriptionPayment> _payments = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _paymentsService.getPayments();
      final mine = all.where((p) => p.schoolId == widget.school.id).toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      if (!mounted) return;
      setState(() {
        _payments = mine;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final school = widget.school;
    final daysRemaining = school.subscriptionExpiry
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(school.name, overflow: TextOverflow.ellipsis)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusRow(school: school),
              const SizedBox(height: AppSpacing.l),
              _PlanCard(
                school: school,
                dateFormat: _dateFormat,
                daysRemaining: daysRemaining,
              ),
              const SizedBox(height: AppSpacing.l),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent payments',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SchoolPaymentsScreen(school: widget.school),
                      ),
                    ),
                    child: const Text('View all payments'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              _buildPaymentsList(context),
              const SizedBox(height: AppSpacing.l),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        'Invoices are generated on the renewal date. Payment '
                        'methods and plan changes are managed from the '
                        'Billing and Subscriptions screens.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (_error != null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(child: Text(_error!)),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No payments recorded for this school yet.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      );
    }
    final recent = _payments.take(6).toList();
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final payment = recent[index];
          return ListTile(
            title: Text(
              _dateFormat.format(payment.submittedAt),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              'Ref ${payment.reference.isEmpty ? payment.id : payment.reference}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money.format(payment.submittedAmount),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                StatusBadge(
                  label: _statusLabel(payment.status),
                  color: _statusColor(context, payment.status),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(ManualPaymentStatus status) => switch (status) {
    ManualPaymentStatus.pendingVerification => 'Pending',
    ManualPaymentStatus.approved => 'Paid',
    ManualPaymentStatus.rejected => 'Failed',
  };

  Color _statusColor(BuildContext context, ManualPaymentStatus status) =>
      switch (status) {
        ManualPaymentStatus.pendingVerification => AppColors.warning(context),
        ManualPaymentStatus.approved => AppColors.success(context),
        ManualPaymentStatus.rejected => AppColors.danger(context),
      };
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.school});
  final School school;

  @override
  Widget build(BuildContext context) {
    final mode = AccessMode.fromRaw(school.accessMode);
    final (label, color) = switch (school.status) {
      SchoolStatus.active => ('Active', AppColors.success(context)),
      SchoolStatus.suspended => ('Suspended', AppColors.danger(context)),
      SchoolStatus.trial => ('Trial', AppColors.warning(context)),
      SchoolStatus.archived => ('Archived', AppColors.textSecondary(context)),
    };
    return Row(
      children: [
        StatusBadge(label: label, color: color),
        if (mode != AccessMode.full) ...[
          const SizedBox(width: AppSpacing.s),
          StatusBadge(
            label: mode == AccessMode.readOnly ? 'Read-only' : 'Blocked',
            color: AppColors.danger(context),
          ),
        ],
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.school,
    required this.dateFormat,
    required this.daysRemaining,
  });
  final School school;
  final DateFormat dateFormat;
  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primary(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Current subscription',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  school.subscriptionPlanId.isEmpty
                      ? 'No plan assigned'
                      : school.subscriptionPlanId.toUpperCase(),
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ),
              StatusBadge(
                label: daysRemaining >= 0
                    ? '$daysRemaining days'
                    : 'Expired ${-daysRemaining}d ago',
                color: daysRemaining < 0
                    ? AppColors.danger(context)
                    : AppColors.warning(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Renews ${dateFormat.format(school.subscriptionExpiry)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillingHomeScreen()),
              ),
              child: const Text('Manage subscription'),
            ),
          ),
        ],
      ),
    );
  }
}
