import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/billing/data/datasources/pricing_band_remote_data_source.dart';
import 'package:school_pulse/features/billing/data/datasources/subscription_cycle_remote_data_source.dart';
import 'package:school_pulse/features/billing/domain/entities/pricing_band.dart';
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

/// One configured manual payment method, folded from the owner-scoped
/// `getManualPaymentConfig` Cloud Function so the payment-methods panel can
/// show real account details instead of guessing from payment records. This
/// is display-only here; [ManualPaymentConfigScreen] remains the sole place
/// these are edited (and the callable is the sole writer).
class _ConfiguredMethod {
  const _ConfiguredMethod({
    required this.name,
    required this.icon,
    required this.detail,
    required this.configured,
  });
  final String name;
  final IconData icon;
  final String detail;
  final bool configured;
}

/// Compact "Billing" workspace that replaced the old separate Payments and
/// Plans nav destinations. Reuses BillingPage's ManualPaymentService for
/// real payment data, the SuperAdminBloc's schools state, and the existing
/// pricing-band / manual-payment-config Cloud Functions -- no new backend
/// logic. Row actions and the "Manage" links push the pre-existing screens
/// unchanged; inline Confirm/Reject call the same approve/reject callables
/// PaymentReviewScreen uses, then reload.
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
  final PricingBandRemoteDataSource _bands = PricingBandRemoteDataSource();
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );
  final NumberFormat _ugx = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );

  List<ManualSubscriptionPayment>? _items;
  List<SubscriptionCycle>? _upcomingCycles;
  List<PricingBand> _pricingBands = const [];
  List<_ConfiguredMethod> _methods = const [];
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
      // Everything below the core payment feed is best-effort: a failure in
      // any one of these must not block the billing workspace from loading.
      List<SubscriptionCycle> cycles = const [];
      try {
        cycles = await _cycles.getAllUpcomingSubscriptionCycles();
      } catch (_) {
        cycles = const [];
      }
      List<PricingBand> bands = const [];
      try {
        bands = await _bands.getPricingBands();
      } catch (_) {
        bands = const [];
      }
      List<_ConfiguredMethod> methods = const [];
      try {
        methods = await _loadMethods();
      } catch (_) {
        methods = const [];
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _upcomingCycles = cycles;
        _pricingBands = bands;
        _methods = methods;
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

  Future<List<_ConfiguredMethod>> _loadMethods() async {
    final result = await _functions
        .httpsCallable('getManualPaymentConfig')
        .call<Map<String, dynamic>>();
    final data = result.data;
    final momo = Map<String, dynamic>.from(
      (data['mobileMoney'] as Map?) ?? const {},
    );
    final airtel = Map<String, dynamic>.from(
      (data['airtelMoney'] as Map?) ?? const {},
    );
    final bank = Map<String, dynamic>.from((data['bank'] as Map?) ?? const {});

    String s(Map<String, dynamic> m, String k) => m[k]?.toString().trim() ?? '';

    final momoNumber = s(momo, 'number');
    final momoName = s(momo, 'accountName');
    final airtelNumber = s(airtel, 'number');
    final airtelName = s(airtel, 'accountName');
    final bankName = s(bank, 'bankName');
    final bankBranch = s(bank, 'branch');
    final bankAccountName = s(bank, 'accountName');
    final bankAccountNumber = s(bank, 'accountNumber');

    return [
      _ConfiguredMethod(
        name: 'MTN MoMo',
        icon: Icons.smartphone_outlined,
        configured: momoNumber.isNotEmpty,
        detail: momoNumber.isEmpty
            ? 'Not configured'
            : [
                momoNumber,
                if (momoName.isNotEmpty) '($momoName)',
              ].join(' '),
      ),
      _ConfiguredMethod(
        name: 'Airtel Money',
        icon: Icons.smartphone_outlined,
        configured: airtelNumber.isNotEmpty,
        detail: airtelNumber.isEmpty
            ? 'Not configured'
            : [
                airtelNumber,
                if (airtelName.isNotEmpty) '($airtelName)',
              ].join(' '),
      ),
      _ConfiguredMethod(
        name: bankName.isEmpty ? 'Bank transfer' : bankName,
        icon: Icons.account_balance_outlined,
        configured: bankAccountNumber.isNotEmpty,
        detail: bankAccountNumber.isEmpty
            ? 'Not configured'
            : [
                if (bankAccountName.isNotEmpty) bankAccountName,
                'Acc No: $bankAccountNumber',
                if (bankBranch.isNotEmpty) '· $bankBranch',
              ].join(' '),
      ),
    ];
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
          left: _confirmationQueueSection(context, wide),
          right: _renewalsSection(context, state, wide),
        ),
        const SizedBox(height: 20),
        _twoColumn(
          wide: wide,
          left: _pricingBandsSection(context, wide),
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
    final schoolCount = scoped.map((p) => p.schoolId).toSet().length;
    final confirmedSchools = scoped
        .where((p) => p.status == ManualPaymentStatus.approved)
        .map((p) => p.schoolId)
        .toSet()
        .length;
    final overdueSchools = state.schools
        .where(
          (s) =>
              s.status == SchoolStatus.active &&
              s.subscriptionExpiry.isBefore(DateTime.now()),
        )
        .length;
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
        detail: 'From $schoolCount ${schoolCount == 1 ? 'school' : 'schools'}',
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

  Widget _confirmationQueueSection(BuildContext context, bool wide) {
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
              : wide
                  ? _PaymentQueueTable(
                      rows: pending.take(6).toList(),
                      ugx: _ugx,
                      methodLabel: _methodLabel,
                      workingId: _workingPaymentId,
                      onOpen: (p) => _openReview(context, p),
                      onApprove: _approvePayment,
                      onReject: _rejectPayment,
                    )
                  : Column(
                      children: [
                        for (final (i, payment) in pending.take(6).indexed) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: AppColors.border(context),
                            ),
                          _PaymentQueueCard(
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
  // Renewals due soon (next 30 days)
  // ---------------------------------------------------------------------------

  Widget _renewalsSection(
    BuildContext context,
    SuperAdminState state,
    bool wide,
  ) {
    final schoolNames = {for (final s in state.schools) s.id: s.name};
    final horizon = DateTime.now().add(const Duration(days: 30));
    final cycles = (_upcomingCycles ?? const [])
        .where((c) => schoolNames.containsKey(c.schoolId))
        .where((c) => !c.paymentDueAt.isAfter(horizon))
        .toList()
      ..sort((a, b) => a.paymentDueAt.compareTo(b.paymentDueAt));

    return _SectionCard(
      title: 'Renewals due soon (next 30 days)',
      actionLabel: cycles.isEmpty ? null : 'View all renewals',
      onAction: cycles.isEmpty ? null : () => _openSubscriptions(context),
      child: _loading && _upcomingCycles == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: SchoolPulseLoader()),
            )
          : cycles.isEmpty
              ? const _CompactEmpty(
                  'No term cycles are due for renewal in the next 30 days.',
                  title: 'Nothing upcoming',
                )
              : wide
                  ? _RenewalTable(
                      rows: cycles.take(6).toList(),
                      schoolNames: schoolNames,
                    )
                  : Column(
                      children: [
                        for (final (i, cycle) in cycles.take(6).indexed) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: AppColors.border(context),
                            ),
                          _RenewalCard(
                            schoolName: schoolNames[cycle.schoolId] ?? '—',
                            cycle: cycle,
                          ),
                        ],
                      ],
                    ),
    );
  }

  // ---------------------------------------------------------------------------
  // Student pricing bands -- real band catalog, with active-school counts
  // and termly revenue derived from the upcoming-cycles preview.
  // ---------------------------------------------------------------------------

  Widget _pricingBandsSection(BuildContext context, bool wide) {
    final cycles = (_upcomingCycles ?? const [])
        .where((c) => c.pricingSnapshot != null)
        .toList();
    final schoolsByBand = <String, Set<String>>{};
    final revenueByBand = <String, int>{};
    for (final cycle in cycles) {
      final pricing = cycle.pricingSnapshot!;
      schoolsByBand.putIfAbsent(pricing.bandId, () => {}).add(cycle.schoolId);
      revenueByBand.update(
        pricing.bandId,
        (value) => value + pricing.amountUgx,
        ifAbsent: () => pricing.amountUgx,
      );
    }

    final bands = _pricingBands.toList()
      ..sort((a, b) => a.minStudents.compareTo(b.minStudents));

    return _SectionCard(
      title: 'Student pricing bands',
      actionLabel: 'Manage pricing bands',
      onAction: () => _openPlans(context),
      child: _loading && _items == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: SchoolPulseLoader()),
            )
          : bands.isEmpty
              ? const _CompactEmpty(
                  'No pricing bands are configured yet.',
                  title: 'No pricing bands',
                )
              : wide
                  ? _PricingBandTable(
                      bands: bands,
                      ugx: _ugx,
                      schoolsByBand: schoolsByBand,
                      revenueByBand: revenueByBand,
                      onManage: () => _openPlans(context),
                    )
                  : Column(
                      children: [
                        for (final (i, band) in bands.indexed) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: AppColors.border(context),
                            ),
                          _PricingBandCard(
                            bandLabel: _bandLetter(i),
                            rangeLabel: _bandRangeLabel(band),
                            termly: _ugx.format(band.amountUgx),
                            activeSchools:
                                schoolsByBand[band.id]?.length ?? 0,
                            isActive: band.isActive,
                            onTap: () => _openPlans(context),
                          ),
                        ],
                      ],
                    ),
    );
  }

  static String _bandLetter(int index) {
    if (index < 26) return 'Band ${String.fromCharCode(65 + index)}';
    return 'Band ${index + 1}';
  }

  static String _bandRangeLabel(PricingBand band) {
    final formatter = NumberFormat('#,##0', 'en_UG');
    if (band.maxStudents == null) {
      return '${formatter.format(band.minStudents)}+';
    }
    return '${formatter.format(band.minStudents)} – '
        '${formatter.format(band.maxStudents)}';
  }

  // ---------------------------------------------------------------------------
  // Payment methods panel -- real config from getManualPaymentConfig.
  // "Manage payment methods" opens the unchanged config screen.
  // ---------------------------------------------------------------------------

  Widget _paymentMethodsSection(BuildContext context) => _SectionCard(
    title: 'Payment methods',
    actionLabel: 'Manage payment methods',
    onAction: () => _openPaymentMethods(context),
    child: _loading && _items == null
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: SchoolPulseLoader()),
          )
        : _methods.isEmpty
            ? const _CompactEmpty(
                'Payment method details could not be loaded.',
                title: 'Unavailable',
              )
            : Column(
                children: [
                  for (final (i, method) in _methods.indexed) ...[
                    if (i > 0)
                      Divider(height: 1, color: AppColors.border(context)),
                    _PaymentMethodRow(method: method),
                  ],
                ],
              ),
  );

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
// Payment confirmation queue -- desktop table
// =============================================================================

class _PaymentQueueTable extends StatelessWidget {
  const _PaymentQueueTable({
    required this.rows,
    required this.ugx,
    required this.methodLabel,
    required this.workingId,
    required this.onOpen,
    required this.onApprove,
    required this.onReject,
  });
  final List<ManualSubscriptionPayment> rows;
  final NumberFormat ugx;
  final String Function(ManualPaymentMethod) methodLabel;
  final String? workingId;
  final void Function(ManualSubscriptionPayment) onOpen;
  final void Function(ManualSubscriptionPayment) onApprove;
  final void Function(ManualSubscriptionPayment) onReject;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width < 700 ? 640 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableHeaderRow(
              cells: const [
                _Col('School', flex: 3),
                _Col('Submitted', flex: 3),
                _Col('Method', flex: 2),
                _Col('Reference', flex: 2),
                _Col('Amount (UGX)', flex: 2, alignEnd: true),
                _Col('Status', flex: 2),
                _Col('Actions', width: 92),
              ],
            ),
            for (final (i, p) in rows.indexed) ...[
              if (i > 0)
                Divider(height: 1, color: AppColors.border(context)),
              _PaymentQueueTableRow(
                payment: p,
                amountLabel: ugx.format(p.submittedAmount),
                methodLabel: methodLabel(p.method),
                submittedLabel:
                    DateFormat('MMM d, yyyy\nh:mm a').format(p.submittedAt),
                working: workingId == p.id,
                anyWorking: workingId != null,
                onOpen: () => onOpen(p),
                onApprove: () => onApprove(p),
                onReject: () => onReject(p),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentQueueTableRow extends StatelessWidget {
  const _PaymentQueueTableRow({
    required this.payment,
    required this.amountLabel,
    required this.methodLabel,
    required this.submittedLabel,
    required this.working,
    required this.anyWorking,
    required this.onOpen,
    required this.onApprove,
    required this.onReject,
  });
  final ManualSubscriptionPayment payment;
  final String amountLabel, methodLabel, submittedLabel;
  final bool working, anyWorking;
  final VoidCallback onOpen, onApprove, onReject;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: anyWorking ? null : onOpen,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(
            flex: 3,
            child: Text(
              payment.schoolName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _rowTitle(context),
            ),
          ),
          _cell(
            flex: 3,
            child: Text(
              submittedLabel,
              style: _rowBody(context),
            ),
          ),
          _cell(
            flex: 2,
            child: Text(
              methodLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _rowBody(context).copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          _cell(
            flex: 2,
            child: Text(
              payment.reference.isEmpty ? '—' : payment.reference,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _rowBody(context),
            ),
          ),
          _cell(
            flex: 2,
            alignEnd: true,
            child: Text(
              amountLabel,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          _cell(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: 'Pending review',
                color: AppColors.warning(context),
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: working
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _IconAction(
                        icon: Icons.check_rounded,
                        color: AppColors.success(context),
                        tooltip: 'Confirm payment',
                        onTap: anyWorking ? null : onApprove,
                      ),
                      const SizedBox(width: 6),
                      _IconAction(
                        icon: Icons.close_rounded,
                        color: AppColors.danger(context),
                        tooltip: 'Reject payment',
                        onTap: anyWorking ? null : onReject,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _cell({
    required int flex,
    required Widget child,
    bool alignEnd = false,
  }) =>
      Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Align(
            alignment:
                alignEnd ? Alignment.centerRight : Alignment.centerLeft,
            child: child,
          ),
        ),
      );
}

// Payment confirmation queue -- mobile stacked card
class _PaymentQueueCard extends StatelessWidget {
  const _PaymentQueueCard({
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
  final String amountLabel, methodLabel, submittedLabel;
  final bool working, anyWorking;
  final VoidCallback onTap, onApprove, onReject;

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

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: enabled ? .12 : .05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: enabled ? .30 : .12),
              ),
            ),
            child: Icon(
              icon,
              size: 17,
              color: color.withValues(alpha: enabled ? 1 : .4),
            ),
          ),
        ),
      ),
    );
  }
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
// Renewals -- desktop table
// =============================================================================

class _RenewalTable extends StatelessWidget {
  const _RenewalTable({required this.rows, required this.schoolNames});
  final List<SubscriptionCycle> rows;
  final Map<String, String> schoolNames;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width < 700 ? 520 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableHeaderRow(
              cells: const [
                _Col('School', flex: 3),
                _Col('Term end date', flex: 2),
                _Col('Amount (UGX)', flex: 2, alignEnd: true),
                _Col('Status', flex: 2),
              ],
            ),
            for (final (i, cycle) in rows.indexed) ...[
              if (i > 0)
                Divider(height: 1, color: AppColors.border(context)),
              _RenewalTableRow(
                schoolName: schoolNames[cycle.schoolId] ?? '—',
                cycle: cycle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RenewalTableRow extends StatelessWidget {
  const _RenewalTableRow({required this.schoolName, required this.cycle});
  final String schoolName;
  final SubscriptionCycle cycle;

  @override
  Widget build(BuildContext context) {
    final amount = cycle.pricingSnapshot != null
        ? NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0)
            .format(cycle.pricingSnapshot!.amountUgx)
        : '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                schoolName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _rowTitle(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                DateFormat('MMM d, yyyy').format(cycle.termEnd),
                style: _rowBody(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  amount,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: cycleStatusLabel(cycle.cycleStatus),
                color: cycleStatusColor(context, cycle.cycleStatus),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Renewals -- mobile stacked card
class _RenewalCard extends StatelessWidget {
  const _RenewalCard({required this.schoolName, required this.cycle});
  final String schoolName;
  final SubscriptionCycle cycle;

  @override
  Widget build(BuildContext context) {
    final amount = cycle.pricingSnapshot != null
        ? NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0)
            .format(cycle.pricingSnapshot!.amountUgx)
        : null;
    return Padding(
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
                  'Term ${cycle.termNumber} · Ends '
                  '${DateFormat('MMM d, yyyy').format(cycle.termEnd)}',
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
              if (amount != null)
                Text(
                  amount,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              if (amount != null) const SizedBox(height: 4),
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
}

// =============================================================================
// Pricing bands -- desktop table
// =============================================================================

class _PricingBandTable extends StatelessWidget {
  const _PricingBandTable({
    required this.bands,
    required this.ugx,
    required this.schoolsByBand,
    required this.revenueByBand,
    required this.onManage,
  });
  final List<PricingBand> bands;
  final NumberFormat ugx;
  final Map<String, Set<String>> schoolsByBand;
  final Map<String, int> revenueByBand;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width < 700 ? 560 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableHeaderRow(
              cells: const [
                _Col('Band', flex: 2),
                _Col('Student range', flex: 3),
                _Col('Termly (UGX)', flex: 3, alignEnd: true),
                _Col('Active schools', flex: 2, alignEnd: true),
                _Col('', width: 68),
              ],
            ),
            for (final (i, band) in bands.indexed) ...[
              if (i > 0)
                Divider(height: 1, color: AppColors.border(context)),
              _PricingBandTableRow(
                bandLabel: _bandLetter(i),
                rangeLabel: _range(band),
                termly: ugx.format(band.amountUgx),
                activeSchools: schoolsByBand[band.id]?.length ?? 0,
                isActive: band.isActive,
                onManage: onManage,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _bandLetter(int index) {
    if (index < 26) return 'Band ${String.fromCharCode(65 + index)}';
    return 'Band ${index + 1}';
  }

  static String _range(PricingBand band) {
    final f = NumberFormat('#,##0', 'en_UG');
    if (band.maxStudents == null) return '${f.format(band.minStudents)}+';
    return '${f.format(band.minStudents)} – ${f.format(band.maxStudents)}';
  }
}

class _PricingBandTableRow extends StatelessWidget {
  const _PricingBandTableRow({
    required this.bandLabel,
    required this.rangeLabel,
    required this.termly,
    required this.activeSchools,
    required this.isActive,
    required this.onManage,
  });
  final String bandLabel, rangeLabel, termly;
  final int activeSchools;
  final bool isActive;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    bandLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _rowTitle(context),
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 6),
                  _StatusPill(
                    label: 'Inactive',
                    color: AppColors.textMuted(context),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '$rangeLabel learners',
              style: _rowBody(context),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                termly,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$activeSchools',
                style: _rowBody(context).copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 68,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onManage,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.information(context),
              ),
              child: const Text('Manage'),
            ),
          ),
        ),
      ],
    ),
  );
}

// Pricing bands -- mobile stacked card
class _PricingBandCard extends StatelessWidget {
  const _PricingBandCard({
    required this.bandLabel,
    required this.rangeLabel,
    required this.termly,
    required this.activeSchools,
    required this.isActive,
    required this.onTap,
  });
  final String bandLabel, rangeLabel, termly;
  final int activeSchools;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(bandLabel, style: _rowTitle(context)),
                    if (!isActive) ...[
                      const SizedBox(width: 6),
                      _StatusPill(
                        label: 'Inactive',
                        color: AppColors.textMuted(context),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$rangeLabel learners · $activeSchools '
                  '${activeSchools == 1 ? 'school' : 'schools'}',
                  style: _rowBody(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            termly,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 13,
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
  const _PaymentMethodRow({required this.method});
  final _ConfiguredMethod method;
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
            method.icon,
            size: 17,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method.name, style: _rowTitle(context)),
              const SizedBox(height: 2),
              Text(
                method.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _rowBody(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusPill(
          label: method.configured ? 'Active' : 'Not set',
          color: method.configured
              ? AppColors.success(context)
              : AppColors.textMuted(context),
        ),
      ],
    ),
  );
}

// =============================================================================
// Table primitives
// =============================================================================

class _Col {
  const _Col(this.label, {this.flex = 1, this.width, this.alignEnd = false});
  final String label;
  final int flex;
  final double? width;
  final bool alignEnd;
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.cells});
  final List<_Col> cells;
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
          for (final col in cells)
            if (col.width != null)
              SizedBox(
                width: col.width,
                child: Text(
                  col.label.toUpperCase(),
                  style: style,
                  textAlign:
                      col.alignEnd ? TextAlign.end : TextAlign.start,
                ),
              )
            else
              Expanded(
                flex: col.flex,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    col.label.toUpperCase(),
                    style: style,
                    textAlign:
                        col.alignEnd ? TextAlign.end : TextAlign.start,
                  ),
                ),
              ),
        ],
      ),
    );
  }
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
