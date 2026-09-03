import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/billing/data/datasources/subscription_cycle_remote_data_source.dart';
import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';
import 'package:school_pulse/features/billing/presentation/utils/subscription_cycle_status_ui.dart';
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
  final SubscriptionCycleRemoteDataSource _cycleDataSource =
      SubscriptionCycleRemoteDataSource();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateFormat = DateFormat('d MMM yyyy');

  bool _loading = true;
  String? _error;
  List<ManualSubscriptionPayment> _payments = const [];

  bool _loadingCycles = true;
  String? _cyclesError;
  List<SubscriptionCycle> _cycles = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadCycles();
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
        _error = friendlyErrorMessage(error);
      });
    }
  }

  Future<void> _loadCycles() async {
    setState(() {
      _loadingCycles = true;
      _cyclesError = null;
    });
    try {
      final cycles = await _cycleDataSource.getSubscriptionCyclesForSchool(
        widget.school.id,
      );
      if (!mounted) return;
      setState(() {
        // Newest term first for the history list.
        _cycles = cycles.reversed.toList();
        _loadingCycles = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingCycles = false;
        _cyclesError = friendlyErrorMessage(error);
      });
    }
  }

  /// The cycle representing "now": the earliest cycle whose term hasn't
  /// ended yet, falling back to the most recently ended one. Drives the
  /// compact info block near the top of the screen.
  SubscriptionCycle? get _currentCycle {
    if (_cycles.isEmpty) return null;
    final now = DateTime.now();
    final upcoming = _cycles.where((c) => !c.termEnd.isBefore(now)).toList()
      ..sort((a, b) => a.termStart.compareTo(b.termStart));
    if (upcoming.isNotEmpty) return upcoming.first;
    return _cycles.first; // newest-first list, so this is the latest term.
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
                currentCycle: _currentCycle,
                money: _money,
              ),
              if (_currentCycle != null) ...[
                const SizedBox(height: AppSpacing.m),
                _CurrentCycleInfoBlock(
                  cycle: _currentCycle!,
                  dateFormat: _dateFormat,
                  money: _money,
                ),
              ],
              const SizedBox(height: AppSpacing.m),
              const _AllFeaturesIncludedBanner(),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Term cycle history',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _buildCyclesList(context),
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

  Widget _buildCyclesList(BuildContext context) {
    if (_loadingCycles) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (_cyclesError != null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(child: Text(_cyclesError!)),
            TextButton(onPressed: _loadCycles, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_cycles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No term cycles yet - confirm an academic calendar to generate '
          'renewal cycles.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      );
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _cycles.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cycle = _cycles[index];
          return ListTile(
            title: Text(
              'Term ${cycle.termNumber}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              '${_dateFormat.format(cycle.termStart)} - '
              '${_dateFormat.format(cycle.termEnd)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (cycle.pricingSnapshot != null)
                  Text(
                    _money.format(cycle.pricingSnapshot!.amountUgx),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  )
                else
                  StatusBadge(
                    label: 'Pricing review needed',
                    color: cycle.pricingReviewRequired
                        ? AppColors.danger(context)
                        : AppColors.warning(context),
                  ),
                const SizedBox(height: 2),
                StatusBadge(
                  label: cycleStatusLabel(cycle.cycleStatus),
                  color: cycleStatusColor(context, cycle.cycleStatus),
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

/// Formats a pricing band range as "1–300 learners" / "1,201+ learners"
/// (unbounded max). Shared by [_CurrentCycleInfoBlock] and [_PlanCard].
String _pricingRangeLabel(int min, int? max) {
  final formatter = NumberFormat('#,##0', 'en_UG');
  if (max == null) return '${formatter.format(min)}+ learners';
  return '${formatter.format(min)}–${formatter.format(max)} learners';
}

/// "Term N · `band range`" title, or "Pricing review needed" when the cycle
/// has no [StudentPricingSnapshot] yet.
String _pricingBandLabel(StudentPricingSnapshot? snapshot) {
  if (snapshot == null) return 'Pricing review needed';
  return _pricingRangeLabel(snapshot.minStudents, snapshot.maxStudents);
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

/// Compact info block placed right under [_PlanCard], showing the school's
/// current term cycle: which term is active, its price, and the invoice/
/// due/grace/next-renewal dates. Deliberately kept to a single small card
/// (a row of labeled values, not another giant card) since the plan/expiry
/// summary already lives in [_PlanCard] just above - this block adds only
/// what that card doesn't already show.
class _CurrentCycleInfoBlock extends StatelessWidget {
  const _CurrentCycleInfoBlock({
    required this.cycle,
    required this.dateFormat,
    required this.money,
  });

  final SubscriptionCycle cycle;
  final DateFormat dateFormat;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Term ${cycle.termNumber} · ${_pricingBandLabel(cycle.pricingSnapshot)}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              StatusBadge(
                label: cycleStatusLabel(cycle.cycleStatus),
                color: cycleStatusColor(context, cycle.cycleStatus),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          _infoRow(
            context,
            'Term dates',
            '${dateFormat.format(cycle.termStart)} - '
                '${dateFormat.format(cycle.termEnd)}',
          ),
          if (cycle.pricingSnapshot != null) ...[
            _infoRow(
              context,
              'Verified learners',
              '${cycle.pricingSnapshot!.verifiedStudentCount}',
            ),
            _infoRow(
              context,
              'Term price',
              money.format(cycle.pricingSnapshot!.amountUgx),
            ),
            _infoRow(
              context,
              'Band',
              _pricingRangeLabel(
                cycle.pricingSnapshot!.minStudents,
                cycle.pricingSnapshot!.maxStudents,
              ),
            ),
            _infoRow(
              context,
              'Amount due',
              money.format(cycle.pricingSnapshot!.amountUgx),
            ),
          ] else
            _infoRow(context, 'Term price', 'Pricing review needed'),
          if (cycle.invoiceIssuedAt != null)
            _infoRow(
              context,
              'Invoice date',
              dateFormat.format(cycle.invoiceIssuedAt!),
            ),
          _infoRow(context, 'Payment due', dateFormat.format(cycle.paymentDueAt)),
          _infoRow(context, 'Grace ends', dateFormat.format(cycle.graceEndsAt)),
        ],
      ),
    );
  }


  Widget _infoRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.school,
    required this.dateFormat,
    required this.daysRemaining,
    this.currentCycle,
    required this.money,
  });
  final School school;
  final DateFormat dateFormat;
  final int daysRemaining;

  /// The school's current term cycle, if any - used to show the band range/
  /// verified count/amount in place of a plan name. Null shows "Pricing
  /// review needed" rather than fabricating a value.
  final SubscriptionCycle? currentCycle;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final pricing = currentCycle?.pricingSnapshot;
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
                  'Termly student pricing',
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
                  pricing == null
                      ? 'Pricing review needed'
                      : _pricingRangeLabel(
                          pricing.minStudents,
                          pricing.maxStudents,
                        ),
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
          if (pricing != null)
            Text(
              '${pricing.verifiedStudentCount} verified learners · '
              '${money.format(pricing.amountUgx)} / term',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
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

/// Compact banner stating the "every feature is available to every school"
/// business rule (Phase 3C: plans/feature-gating removed in favour of
/// student-count-only pricing). Deliberately a single row, not a card full
/// of feature chips - there is nothing to compare any more.
class _AllFeaturesIncludedBanner extends StatelessWidget {
  const _AllFeaturesIncludedBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 16,
          color: AppColors.success(context),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            'All School Pulse features are included for this school.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      ],
    ),
  );
}
