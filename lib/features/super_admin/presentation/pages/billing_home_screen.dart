import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/billing/data/datasources/subscription_cycle_remote_data_source.dart';
import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';
import 'package:school_pulse/features/billing/presentation/utils/subscription_cycle_status_ui.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import 'billing_page.dart';
import 'manual_payment_config_screen.dart';
import 'payment_review_screen.dart';
import 'student_pricing_screen.dart';
import 'subscriptions_overview_screen.dart';

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

/// Compact "Billing" workspace that replaced the old separate Payments and
/// Plans nav destinations. It reuses BillingPage's existing
/// ManualPaymentService for real payment data and the SuperAdminBloc's
/// existing schools state -- no new backend logic. "Manage pricing bands"/
/// "Manage payment methods" and payment/renewal rows push the pre-existing
/// screens unchanged. Approve/reject on the confirmation queue call the same
/// ManualPaymentService.approve/reject callables that PaymentReviewScreen
/// uses, then reload.
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
  final SubscriptionCycleRemoteDataSource _cycles =
      SubscriptionCycleRemoteDataSource();
  final NumberFormat _ugx = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );

  List<ManualSubscriptionPayment>? _items;
  List<SubscriptionCycle>? _upcomingCycles;
  bool _loading = true;
  String? _error;
  String? _workingPaymentId;
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
      // Upcoming renewals is best-effort: a failure here shouldn't block
      // the rest of the billing workspace from loading.
      List<SubscriptionCycle> cycles = const [];
      try {
        cycles = await _cycles.getAllUpcomingSubscriptionCycles();
      } catch (_) {
        cycles = const [];
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _upcomingCycles = cycles;
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

  // ---------------------------------------------------------------------------
  // Approve / reject -- same callables PaymentReviewScreen uses, then reload.
  // ---------------------------------------------------------------------------

  Future<void> _approvePayment(ManualSubscriptionPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm payment?'),
        content: Text(
          'Confirm ${_ugx.format(payment.submittedAmount)} from '
          '${payment.schoolName}. This activates or renews their '
          'subscription and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _workingPaymentId = payment.id);
    try {
      await _payments.approve(payment.id);
      if (!mounted) return;
      _showSnack('Payment confirmed for ${payment.schoolName}.');
      await _load();
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not confirm the payment. Try again.');
    } finally {
      if (mounted) setState(() => _workingPaymentId = null);
    }
  }

  static const _rejectionReasonChips = [
    'Amount does not match',
    'Proof unclear or missing',
    'Reference not found',
    'Duplicate submission',
  ];

  Future<void> _rejectPayment(ManualSubscriptionPayment payment) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reject payment?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The school can submit corrected proof afterwards.',
                style: _rowBody(context),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final chip in _rejectionReasonChips)
                    ActionChip(
                      label: Text(chip),
                      onPressed: () {
                        controller.text = chip;
                        setDialogState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Reason shared with the school',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger(context),
              ),
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
    if (reason == null || reason.isEmpty) return;
    setState(() => _workingPaymentId = payment.id);
    try {
      await _payments.reject(payment.id, reason);
      if (!mounted) return;
      _showSnack('Payment rejected. The school can submit corrected proof.');
      await _load();
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not reject the payment. Try again.');
    } finally {
      if (mounted) setState(() => _workingPaymentId = null);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // Export -- copies a CSV of the scoped confirmation queue to the clipboard.
  // Derived entirely from already-loaded, permission-scoped payment data.
  // ---------------------------------------------------------------------------

  Future<void> _export() async {
    final rows = _scoped.toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    final buffer = StringBuffer(
      'School,Submitted,Method,Reference,Amount (UGX),Status\n',
    );
    for (final p in rows) {
      buffer.writeln(
        '${_csv(p.schoolName)},'
        '${_csv(DateFormat('yyyy-MM-dd HH:mm').format(p.submittedAt))},'
        '${_csv(_methodLabel(p.method))},'
        '${_csv(p.reference)},'
        '${p.submittedAmount},'
        '${_csv(_paymentStatusLabel(p.status))}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    _showSnack('Copied ${rows.length} payments to the clipboard as CSV.');
  }

  static String _csv(String value) => value.contains(',') || value.contains('"')
      ? '"${value.replaceAll('"', '""')}"'
      : value;

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
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
    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, wide),
          const SizedBox(height: 20),
          _ErrorCard(message: _error!, onRetry: _load),
        ],
      );
    }
    final pendingCount = _scoped
        .where((p) => p.status == ManualPaymentStatus.pendingVerification)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, wide),
        const SizedBox(height: 20),
        if (pendingCount > 0) ...[
          _PendingAlertBanner(
            count: pendingCount,
            onReview: () => _openBillingPage(
              context,
              filter: ManualPaymentStatus.pendingVerification,
            ),
          ),
          const SizedBox(height: 20),
        ],
        _metricGrid(context, state, wide),
        const SizedBox(height: 20),
        _twoColumn(
          wide: wide,
          left: _confirmationQueueSection(context),
          right: _renewalsSection(context, state),
        ),
        const SizedBox(height: 20),
        _twoColumn(
          wide: wide,
          left: _pricingBandsSection(context, state),
          right: _paymentMethodsSection(context),
        ),
      ],
    );
  }

  Widget _twoColumn({
    required bool wide,
    required Widget left,
    required Widget right,
  }) {
    if (!wide) {
      return Column(
        children: [left, const SizedBox(height: 20), right],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 20),
          Expanded(child: right),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _header(BuildContext context, bool wide) {
    final title = Text('Billing', style: _pageTitle(context));
    final controls = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _PeriodPicker(
          period: _period,
          onChanged: (value) => setState(() => _period = value),
        ),
        _HeaderButton(
          icon: Icons.file_download_outlined,
          label: 'Export',
          onTap: _export,
        ),
        _HeaderIconAction(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh billing data',
          onTap: _refresh,
        ),
      ],
    );
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          controls,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title,
        const Spacer(),
        controls,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Metric cards
  // ---------------------------------------------------------------------------

  Widget _metricGrid(BuildContext context, SuperAdminState state, bool wide) {
    if (_loading && _items == null) {
      return const SizedBox(
        height: 132,
        child: Center(child: SchoolPulseLoader()),
      );
    }
    final scoped = _scoped;
    final expected = scoped.fold<int>(0, (sum, p) => sum + p.expectedAmount);
    final confirmed = scoped
        .where((p) => p.status == ManualPaymentStatus.approved)
        .fold<int>(0, (sum, p) => sum + p.submittedAmount);
    final pendingList = scoped
        .where((p) => p.status == ManualPaymentStatus.pendingVerification)
        .toList();
    final pendingAmount = pendingList.fold<int>(
      0,
      (sum, p) => sum + p.submittedAmount,
    );
    final confirmedSchools = scoped
        .where((p) => p.status == ManualPaymentStatus.approved)
        .map((p) => p.schoolId)
        .toSet()
        .length;
    final overdueSchoolsList = state.schools.where(
      (s) =>
          s.status == SchoolStatus.active &&
          s.subscriptionExpiry.isBefore(DateTime.now()),
    );
    final overdueSchools = overdueSchoolsList.length;
    final confirmedPct = expected > 0
        ? (confirmed / expected * 100).round()
        : 0;
    final pendingPct = expected > 0
        ? (pendingAmount / expected * 100).round()
        : 0;

    final cards = [
      _MetricCard(
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.information(context),
        label: 'Expected term revenue (UGX)',
        value: _ugx.format(expected),
        detail: 'Across ${scoped.map((p) => p.schoolId).toSet().length} '
            '${scoped.map((p) => p.schoolId).toSet().length == 1 ? 'school' : 'schools'}',
        detailColor: AppColors.textSecondary(context),
      ),
      _MetricCard(
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success(context),
        label: 'Confirmed payments',
        value: _ugx.format(confirmed),
        detail:
            '$confirmedSchools ${confirmedSchools == 1 ? 'school' : 'schools'} · '
            '$confirmedPct% of expected',
        detailColor: AppColors.success(context),
        valueColor: AppColors.success(context),
      ),
      _MetricCard(
        icon: Icons.schedule_rounded,
        color: AppColors.warning(context),
        label: 'Pending confirmation',
        value: _ugx.format(pendingAmount),
        detail:
            '${pendingList.length} ${pendingList.length == 1 ? 'payment' : 'payments'} · '
            '$pendingPct% of expected',
        detailColor: AppColors.warning(context),
        valueColor: AppColors.warning(context),
      ),
      _MetricCard(
        icon: Icons.error_outline_rounded,
        color: AppColors.danger(context),
        label: 'Overdue schools',
        value: '$overdueSchools',
        detail: overdueSchools == 0
            ? 'None overdue'
            : '${overdueSchools == 1 ? '1 school' : '$overdueSchools schools'} past expiry',
        detailColor: AppColors.danger(context),
        valueColor: AppColors.danger(context),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = wide ? 4 : (constraints.maxWidth >= 520 ? 2 : 1);
        final width =
            (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Payment confirmation queue
  // ---------------------------------------------------------------------------

  Widget _confirmationQueueSection(BuildContext context) {
    final pending = _scoped
        .where((p) => p.status == ManualPaymentStatus.pendingVerification)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return _SectionCard(
      title: pending.isEmpty
          ? 'Payment confirmation queue'
          : 'Payment confirmation queue (${pending.length})',
      actionLabel: pending.isEmpty ? null : 'View all payments',
      onAction: pending.isEmpty
          ? null
          : () => _openBillingPage(
                context,
                filter: ManualPaymentStatus.pendingVerification,
              ),
      child: _loading && _items == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: SchoolPulseLoader()),
            )
          : pending.isEmpty
              ? const _CompactEmpty(
                  'No payments waiting for confirmation.',
                  title: 'All caught up',
                )
              : Column(
                  children: [
                    for (final (i, payment) in pending.take(6).indexed) ...[
                      if (i > 0)
                        Divider(height: 1, color: AppColors.border(context)),
                      _PaymentQueueRow(
                        payment: payment,
                        amountLabel: _ugx.format(payment.submittedAmount),
                        methodLabel: _methodLabel(payment.method),
                        submittedLabel: DateFormat(
                          'MMM d, yyyy · h:mm a',
                        ).format(payment.submittedAt),
                        working: _workingPaymentId == payment.id,
                        anyWorking: _workingPaymentId != null,
                        onTap: () => _openReview(context, payment),
                        onApprove: () => _approvePayment(payment),
                        onReject: () => _rejectPayment(payment),
                      ),
                    ],
                  ],
                ),
    );
  }

  // ---------------------------------------------------------------------------
  // Renewals due soon
  // ---------------------------------------------------------------------------

  Widget _renewalsSection(BuildContext context, SuperAdminState state) {
    final schoolNames = {for (final s in state.schools) s.id: s.name};
    final cycles = (_upcomingCycles ?? const [])
        .where((c) => schoolNames.containsKey(c.schoolId))
        .toList()
      ..sort((a, b) => a.paymentDueAt.compareTo(b.paymentDueAt));

    return _SectionCard(
      title: 'Renewals due soon',
      actionLabel: cycles.isEmpty ? null : 'View all renewals',
      onAction: cycles.isEmpty ? null : () => _openSubscriptions(context),
      child: _loading && _upcomingCycles == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: SchoolPulseLoader()),
            )
          : cycles.isEmpty
              ? const _CompactEmpty(
                  'No term cycles are due for renewal soon.',
                  title: 'Nothing upcoming',
                )
              : Column(
                  children: [
                    for (final (i, cycle) in cycles.take(6).indexed) ...[
                      if (i > 0)
                        Divider(height: 1, color: AppColors.border(context)),
                      _RenewalRow(
                        schoolName: schoolNames[cycle.schoolId] ?? '—',
                        cycle: cycle,
                        amountLabel: cycle.pricingSnapshot != null
                            ? _ugx.format(cycle.pricingSnapshot!.amountUgx)
                            : null,
                      ),
                    ],
                  ],
                ),
    );
  }

  // ---------------------------------------------------------------------------
  // Student pricing bands
  // ---------------------------------------------------------------------------

  /// Groups the upcoming-cycles preview (already loaded for the renewals
  /// section) by `pricingSnapshot.bandId` and shows how many schools
  /// currently fall in each band plus the termly revenue that band
  /// represents. This is a preview derived from the same bounded (50-cycle)
  /// cross-school feed as "Renewals due soon", not a full report -
  /// [StudentPricingScreen] is the source of truth for the band catalog.
  Widget _pricingBandsSection(BuildContext context, SuperAdminState state) {
    final cycles = (_upcomingCycles ?? const [])
        .where((c) => c.pricingSnapshot != null)
        .toList();
    final schoolsByBand = <String, Set<String>>{};
    final revenueByBand = <String, int>{};
    final rangeByBand = <String, (int, int?)>{};
    for (final cycle in cycles) {
      final pricing = cycle.pricingSnapshot!;
      schoolsByBand.putIfAbsent(pricing.bandId, () => {}).add(cycle.schoolId);
      revenueByBand.update(
        pricing.bandId,
        (value) => value + pricing.amountUgx,
        ifAbsent: () => pricing.amountUgx,
      );
      rangeByBand[pricing.bandId] = (pricing.minStudents, pricing.maxStudents);
    }
    final bandIds = schoolsByBand.keys.toList()
      ..sort(
        (a, b) =>
            (rangeByBand[a]?.$1 ?? 0).compareTo(rangeByBand[b]?.$1 ?? 0),
      );

    return _SectionCard(
      title: 'Student pricing bands',
      actionLabel: 'Manage pricing bands',
      onAction: () => _openPlans(context),
      child: bandIds.isEmpty
          ? const _CompactEmpty(
              'No priced upcoming cycles yet.',
              title: 'No pricing data',
            )
          : Column(
              children: [
                _PricingBandHeaderRow(),
                Divider(height: 1, color: AppColors.border(context)),
                for (final (i, bandId) in bandIds.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: AppColors.border(context)),
                  _PricingBandRow(
                    rangeLabel: _bandRangeLabel(rangeByBand[bandId]),
                    schoolCount: schoolsByBand[bandId]!.length,
                    termlyRevenue: _ugx.format(revenueByBand[bandId] ?? 0),
                    onTap: () => _openPlans(context),
                  ),
                ],
              ],
            ),
    );
  }

  static String _bandRangeLabel((int, int?)? range) {
    if (range == null) return 'Unknown band';
    final formatter = NumberFormat('#,##0', 'en_UG');
    final (min, max) = range;
    if (max == null) return '${formatter.format(min)}+ learners';
    return '${formatter.format(min)}–${formatter.format(max)} learners';
  }

  // ---------------------------------------------------------------------------
  // Payment methods panel -- derived from the loaded, permission-scoped
  // payment records (method + latest reference + latest transaction time).
  // "Manage payment methods" opens the unchanged config screen.
  // ---------------------------------------------------------------------------

  Widget _paymentMethodsSection(BuildContext context) {
    final byMethod = <ManualPaymentMethod, ManualSubscriptionPayment>{};
    for (final p in (_items ?? const [])) {
      final current = byMethod[p.method];
      if (current == null || p.submittedAt.isAfter(current.submittedAt)) {
        byMethod[p.method] = p;
      }
    }
    final methods = ManualPaymentMethod.values;
    return _SectionCard(
      title: 'Payment methods',
      actionLabel: 'Manage payment methods',
      onAction: () => _openPaymentMethods(context),
      child: _loading && _items == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: SchoolPulseLoader()),
            )
          : Column(
              children: [
                for (final (i, method) in methods.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: AppColors.border(context)),
                  _PaymentMethodRow(
                    icon: method == ManualPaymentMethod.bank
                        ? Icons.account_balance_outlined
                        : Icons.smartphone_outlined,
                    label: _methodLabel(method),
                    lastTransaction: byMethod[method] == null
                        ? 'No transactions yet'
                        : DateFormat(
                            'MMM d, yyyy · h:mm a',
                          ).format(byMethod[method]!.submittedAt),
                    reference: byMethod[method]?.reference,
                  ),
                ],
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation -- unchanged targets.
  // ---------------------------------------------------------------------------

  void _openBillingPage(BuildContext context, {ManualPaymentStatus? filter}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BillingPage(initialFilter: filter)),
    );
  }

  void _openReview(BuildContext context, ManualSubscriptionPayment payment) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PaymentReviewScreen(payment: payment),
          ),
        )
        .then((changed) {
      if (changed == true) _load();
    });
  }

  void _openPlans(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StudentPricingScreen()),
    );
  }

  void _openPaymentMethods(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualPaymentConfigScreen()),
    );
  }

  void _openSubscriptions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionsOverviewScreen()),
    );
  }
}

// =============================================================================
// Header widgets
// =============================================================================

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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon, size: 19, color: AppColors.textPrimary(context)),
        ),
      ),
    ),
  );
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AppColors.textPrimary(context)),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
      for (final option in options)
        PopupMenuItem(value: option, child: Text(option)),
    ],
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 15,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 8),
          Text(
            selected,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary(context),
          ),
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
  Widget build(BuildContext context) => CompactPeriodPicker(
    label: 'Select period',
    options: _Period.values.map((p) => p.label).toList(),
    selected: period.label,
    onSelected: (label) {
      final match = _Period.values.firstWhere((p) => p.label == label);
      onChanged(match);
    },
  );
}

// =============================================================================
// Alert banner
// =============================================================================

class _PendingAlertBanner extends StatelessWidget {
  const _PendingAlertBanner({required this.count, required this.onReview});
  final int count;
  final VoidCallback onReview;
  @override
  Widget build(BuildContext context) {
    final amber = AppColors.warning(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warningSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: amber.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '1 payment pending confirmation'
                  : '$count payments pending confirmation',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.information(context),
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: onReview,
              borderRadius: BorderRadius.circular(9),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Review payments',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Metric card
// =============================================================================

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
    required this.detailColor,
    this.valueColor,
  });
  final IconData icon;
  final Color color;
  final String label, value, detail;
  final Color detailColor;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) => PulseCard(
    padding: const EdgeInsets.all(16),
    borderRadius: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headlineSmall.copyWith(
            color: valueColor ?? AppColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: detailColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
// Payment confirmation queue row
// =============================================================================

class _PaymentQueueRow extends StatelessWidget {
  const _PaymentQueueRow({
    required this.payment,
    required this.amountLabel,
    required this.methodLabel,
    required this.submittedLabel,
    required this.working,
    required this.anyWorking,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });
  final ManualSubscriptionPayment payment;
  final String amountLabel;
  final String methodLabel;
  final String submittedLabel;
  final bool working;
  final bool anyWorking;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: anyWorking ? null : onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 3),
                    Text(
                      '$methodLabel · $submittedLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _rowBody(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref ${payment.reference.isEmpty ? '—' : payment.reference}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _rowBody(context).copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountLabel,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusPill(
                    label: 'Pending review',
                    color: AppColors.warning(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (working)
                const SizedBox(
                  height: 32,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else ...[
                _QueueActionButton(
                  icon: Icons.check_rounded,
                  label: 'Confirm',
                  color: AppColors.success(context),
                  onTap: anyWorking ? null : onApprove,
                ),
                const SizedBox(width: 8),
                _QueueActionButton(
                  icon: Icons.close_rounded,
                  label: 'Reject',
                  color: AppColors.danger(context),
                  onTap: anyWorking ? null : onReject,
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted(context),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

class _QueueActionButton extends StatelessWidget {
  const _QueueActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? .12 : .05),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: color.withValues(alpha: enabled ? .30 : .12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: color.withValues(alpha: enabled ? 1 : .4),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: enabled ? 1 : .4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Renewal row
// =============================================================================

class _RenewalRow extends StatelessWidget {
  const _RenewalRow({
    required this.schoolName,
    required this.cycle,
    required this.amountLabel,
  });
  final String schoolName;
  final SubscriptionCycle cycle;
  final String? amountLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schoolName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _rowTitle(context),
              ),
              const SizedBox(height: 3),
              Text(
                'Term ${cycle.termNumber} · Due '
                '${DateFormat('MMM d, yyyy').format(cycle.paymentDueAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _rowBody(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (amountLabel != null)
              Text(
                amountLabel!,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            if (amountLabel != null) const SizedBox(height: 4),
            StatusBadge(
              label: cycleStatusLabel(cycle.cycleStatus),
              color: cycleStatusColor(context, cycle.cycleStatus),
            ),
          ],
        ),
      ],
    ),
  );
}

// =============================================================================
// Pricing band rows
// =============================================================================

class _PricingBandHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = AppTypography.labelSmall.copyWith(
      color: AppColors.textMuted(context),
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: .3,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Row(
        children: [
          Expanded(child: Text('STUDENT RANGE', style: style)),
          const SizedBox(width: 8),
          SizedBox(
            width: 74,
            child: Text(
              'SCHOOLS',
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 116,
            child: Text(
              'TERMLY (UGX)',
              style: style,
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

/// One pricing band's school count and termly revenue, derived from
/// `subscription_cycles.pricingSnapshot`.
class _PricingBandRow extends StatelessWidget {
  const _PricingBandRow({
    required this.rangeLabel,
    required this.schoolCount,
    required this.termlyRevenue,
    required this.onTap,
  });
  final String rangeLabel;
  final int schoolCount;
  final String termlyRevenue;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rangeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _rowTitle(context),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 74,
            child: Text(
              '$schoolCount',
              textAlign: TextAlign.center,
              style: _rowBody(context).copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 116,
            child: Text(
              termlyRevenue,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
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

// =============================================================================
// Payment method row
// =============================================================================

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.icon,
    required this.label,
    required this.lastTransaction,
    required this.reference,
  });
  final IconData icon;
  final String label;
  final String lastTransaction;
  final String? reference;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _rowTitle(context)),
              const SizedBox(height: 2),
              Text(
                (reference == null || reference!.isEmpty)
                    ? lastTransaction
                    : 'Last ref $reference · $lastTransaction',
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

// =============================================================================
// Shared building blocks
// =============================================================================

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
    padding: const EdgeInsets.all(16),
    borderRadius: 12,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.information(context),
                ),
                child: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: AppColors.border(context)),
        const SizedBox(height: 4),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: .30)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty(this.message, {this.title = 'Nothing here yet'});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 76),
    padding: const EdgeInsets.symmetric(vertical: 12),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 22,
          color: AppColors.textMuted(context),
        ),
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
                maxLines: 2,
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

// =============================================================================
// Formatting helpers
// =============================================================================

String _methodLabel(ManualPaymentMethod method) => switch (method) {
  ManualPaymentMethod.mtn => 'MTN MoMo',
  ManualPaymentMethod.bank => 'Bank transfer',
};

String _paymentStatusLabel(ManualPaymentStatus status) => switch (status) {
  ManualPaymentStatus.pendingVerification => 'Pending review',
  ManualPaymentStatus.approved => 'Confirmed',
  ManualPaymentStatus.rejected => 'Rejected',
};

TextStyle _pageTitle(BuildContext c) => AppTypography.headlineMedium.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 26,
  fontWeight: FontWeight.w800,
);
TextStyle _sectionTitle(BuildContext c) => AppTypography.titleLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 16,
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
