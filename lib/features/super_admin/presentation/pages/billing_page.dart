import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../responsive.dart';
import 'payment_inspector.dart';
import 'payment_review_screen.dart';
import 'package:school_pulse/design_system/components/app_error_state.dart';

enum _DateRange { today, thisWeek, thisMonth, thisYear, all }

extension on _DateRange {
  String get label => switch (this) {
    _DateRange.today => 'Today',
    _DateRange.thisWeek => 'This week',
    _DateRange.thisMonth => 'This month',
    _DateRange.thisYear => 'This year',
    _DateRange.all => 'All time',
  };

  bool includes(DateTime date) {
    final now = DateTime.now();
    switch (this) {
      case _DateRange.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case _DateRange.thisWeek:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        return !date.isBefore(startOfWeek);
      case _DateRange.thisMonth:
        return date.year == now.year && date.month == now.month;
      case _DateRange.thisYear:
        return date.year == now.year;
      case _DateRange.all:
        return true;
    }
  }
}

enum _SortBy { newest, oldest, amountHigh, amountLow }

extension on _SortBy {
  String get label => switch (this) {
    _SortBy.newest => 'Newest first',
    _SortBy.oldest => 'Oldest first',
    _SortBy.amountHigh => 'Amount: high to low',
    _SortBy.amountLow => 'Amount: low to high',
  };
}

class BillingPage extends StatefulWidget {
  const BillingPage({super.key, this.initialFilter});

  /// Optional deep-link filter, e.g. from the Dashboard's "Payments to Verify"
  /// card which should land here pre-filtered to pending verification.
  final ManualPaymentStatus? initialFilter;

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');
  final DateFormat _shortDateTime = DateFormat('MMM d, yyyy\nh:mm a');
  final TextEditingController _searchController = TextEditingController();

  List<ManualSubscriptionPayment> _items = const [];
  bool _loading = true;
  String? _error;
  ManualPaymentStatus? _filter;
  String _search = '';
  _DateRange _dateRange = _DateRange.thisMonth;
  ManualPaymentMethod? _methodFilter;
  _SortBy _sortBy = _SortBy.newest;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await _payments.getPayments();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        // Drop a stale selection that is no longer in the list.
        if (_selectedId != null && !items.any((p) => p.id == _selectedId)) {
          _selectedId = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  // --- Derived data (preserved) ---------------------------------------------

  List<ManualSubscriptionPayment> get _visibleItems {
    Iterable<ManualSubscriptionPayment> items = _items;
    if (_filter != null) {
      items = items.where((payment) => payment.status == _filter);
    }
    if (_methodFilter != null) {
      items = items.where((payment) => payment.method == _methodFilter);
    }
    items = items.where((payment) => _dateRange.includes(payment.submittedAt));
    if (_search.trim().isNotEmpty) {
      final query = _search.trim().toLowerCase();
      items = items.where(
        (payment) =>
            payment.schoolName.toLowerCase().contains(query) ||
            payment.planName.toLowerCase().contains(query) ||
            payment.reference.toLowerCase().contains(query),
      );
    }
    final sorted = items.toList();
    switch (_sortBy) {
      case _SortBy.newest:
        sorted.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      case _SortBy.oldest:
        sorted.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
      case _SortBy.amountHigh:
        sorted.sort((a, b) => b.submittedAmount.compareTo(a.submittedAmount));
      case _SortBy.amountLow:
        sorted.sort((a, b) => a.submittedAmount.compareTo(b.submittedAmount));
    }
    return sorted;
  }

  List<ManualSubscriptionPayment> get _dateScopedItems => _items
      .where((payment) => _dateRange.includes(payment.submittedAt))
      .toList();

  int _count(ManualPaymentStatus status) =>
      _dateScopedItems.where((payment) => payment.status == status).length;

  int get _totalVerifiedRevenue => _dateScopedItems
      .where((payment) => payment.status == ManualPaymentStatus.approved)
      .fold(0, (sum, payment) => sum + payment.submittedAmount);

  bool get _hasActiveFilters =>
      _methodFilter != null || _sortBy != _SortBy.newest;

  ManualSubscriptionPayment? get _selected {
    final id = _selectedId;
    if (id == null) return null;
    for (final p in _items) {
      if (p.id == id) return p;
    }
    return null;
  }

  ManualSubscriptionPayment? get _firstPending {
    for (final p in _visibleItems) {
      if (p.status == ManualPaymentStatus.pendingVerification) return p;
    }
    return null;
  }

  // --- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);
    final bg = AppColors.background(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, wide),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: SchoolPulseLoader())
                  : _error != null
                  ? AppErrorState(message: _error!, onRetry: _reload)
                  : wide
                  ? _wideBody(context)
                  : _narrowBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, bool wide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription payments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review and manage subscription payments from schools.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _termFilterButton(context),
          const SizedBox(width: 8),
          _iconAction(
            context,
            icon: Icons.file_download_outlined,
            label: wide ? 'Export' : null,
            tooltip: 'Export CSV',
            onTap: _visibleItems.isEmpty ? null : _exportCsv,
          ),
          const SizedBox(width: 8),
          _iconAction(
            context,
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onTap: _loading ? null : _reload,
          ),
        ],
      ),
    );
  }

  Widget _termFilterButton(BuildContext context) {
    return _OutlinedPill(
      onTap: () => _pickDateRange(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _dateRange.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
    );
  }

  Widget _iconAction(
    BuildContext context, {
    required IconData icon,
    String? label,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: _OutlinedPill(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: onTap == null
                  ? AppColors.disabled(context)
                  : AppColors.textPrimary(context),
            ),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onTap == null
                      ? AppColors.disabled(context)
                      : AppColors.textPrimary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Wide (desktop) two-pane -------------------------------------------

  Widget _wideBody(BuildContext context) {
    final selected = _selected;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (_firstPending != null) ...[
                _pendingAlert(context),
                const SizedBox(height: 16),
              ],
              _metricRow(context),
              const SizedBox(height: 20),
              _statusTabs(context),
              const SizedBox(height: 12),
              _searchAndFilters(context),
              const SizedBox(height: 16),
              _resultsCount(context),
              const SizedBox(height: 8),
              if (_visibleItems.isEmpty)
                _EmptyState(
                  filter: _filter,
                  hasQuery: _search.trim().isNotEmpty,
                )
              else
                _table(context),
            ],
          ),
        ),
        Container(width: 1, color: AppColors.border(context)),
        SizedBox(
          width: 380,
          child: selected == null
              ? _inspectorEmpty(context)
              : PaymentInspector(
                  key: ValueKey(selected.id),
                  payment: selected,
                  onClose: () => setState(() => _selectedId = null),
                  onMutated: _reload,
                ),
        ),
      ],
    );
  }

  Widget _inspectorEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 32,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a payment to review',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'School details, proof and Approve / Reject '
              'actions appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Narrow (mobile) -------------------------------------------------

  Widget _narrowBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (_firstPending != null) ...[
          _pendingAlert(context),
          const SizedBox(height: 16),
        ],
        _metricRow(context),
        const SizedBox(height: 20),
        _statusTabs(context),
        const SizedBox(height: 12),
        _searchAndFilters(context),
        const SizedBox(height: 16),
        _resultsCount(context),
        const SizedBox(height: 8),
        if (_visibleItems.isEmpty)
          _EmptyState(filter: _filter, hasQuery: _search.trim().isNotEmpty)
        else
          for (final payment in _visibleItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentCard(
                payment: payment,
                amount: _money.format(payment.submittedAmount),
                submittedAt: _dateTime.format(payment.submittedAt),
                onTap: () => _openMobileInspector(payment),
                onCopyReference: () => _copyReference(payment.reference),
              ),
            ),
      ],
    );
  }

  // --- Shared blocks -------------------------------------------------------

  Widget _pendingAlert(BuildContext context) {
    final pending = _count(ManualPaymentStatus.pendingVerification);
    final amber = AppColors.warning(context);
    final target = _firstPending;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pending == 1
                      ? '1 payment awaiting confirmation'
                      : '$pending payments awaiting confirmation',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review the next payment to keep revenue on track.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (target != null)
            FilledButton(
              onPressed: () {
                if (isSuperAdminWide(context)) {
                  setState(() => _selectedId = target.id);
                } else {
                  _openMobileInspector(target);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: paymentAccent(context),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Review next'),
            ),
        ],
      ),
    );
  }

  Widget _metricRow(BuildContext context) {
    final tiles = [
      _Metric(
        label: 'Pending',
        value: '${_count(ManualPaymentStatus.pendingVerification)}',
        dotColor: AppColors.warning(context),
      ),
      _Metric(
        label: 'Confirmed',
        value: '${_count(ManualPaymentStatus.approved)}',
        dotColor: AppColors.success(context),
      ),
      _Metric(
        label: 'Rejected',
        value: '${_count(ManualPaymentStatus.rejected)}',
        dotColor: AppColors.danger(context),
      ),
      _Metric(
        label: 'Verified revenue',
        value: _money.format(_totalVerifiedRevenue),
        dotColor: null,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoUp = constraints.maxWidth < 560;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final t in tiles)
              SizedBox(
                width: twoUp
                    ? (constraints.maxWidth - 12) / 2
                    : (constraints.maxWidth - 36) / 4,
                child: t,
              ),
          ],
        );
      },
    );
  }

  Widget _statusTabs(BuildContext context) {
    final tabs = <(String, ManualPaymentStatus?)>[
      ('All', null),
      ('Pending', ManualPaymentStatus.pendingVerification),
      ('Approved', ManualPaymentStatus.approved),
      ('Rejected', ManualPaymentStatus.rejected),
    ];
    final accent = paymentAccent(context);
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final (label, status) = tabs[index];
          final selected = _filter == status;
          return GestureDetector(
            onTap: () => setState(() => _filter = status),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? accent : AppColors.textSecondary(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _searchAndFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search by school name, plan, reference…',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true,
                fillColor: AppColors.surfaceContainer(context),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _OutlinedPill(
          onTap: () => _openAdvancedFilters(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: _hasActiveFilters
                    ? paymentAccent(context)
                    : AppColors.textPrimary(context),
              ),
              const SizedBox(width: 6),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _hasActiveFilters
                      ? paymentAccent(context)
                      : AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultsCount(BuildContext context) {
    final n = _visibleItems.length;
    return Text(
      'Showing $n result${n == 1 ? '' : 's'}',
      style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
    );
  }

  Widget _table(BuildContext context) {
    final border = AppColors.border(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceContainer(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _headCell('School', flex: 3),
                _headCell('Plan', flex: 2),
                _headCell('Type', flex: 2),
                _headCell('Amount', flex: 2),
                _headCell('Method', flex: 2),
                _headCell('Reference', flex: 2),
                _headCell('Submitted', flex: 2),
                _headCell('Status', flex: 2),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          for (var i = 0; i < _visibleItems.length; i++) ...[
            if (i > 0) Divider(height: 1, color: border),
            _TableRow(
              payment: _visibleItems[i],
              amount: _money.format(_visibleItems[i].submittedAmount),
              submittedAt: _shortDateTime.format(_visibleItems[i].submittedAt),
              selected: _selectedId == _visibleItems[i].id,
              onTap: () => setState(() => _selectedId = _visibleItems[i].id),
              onCopyReference: () => _copyReference(_visibleItems[i].reference),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }

  // --- Actions ----------------------------------------------------------

  Future<void> _openMobileInspector(ManualSubscriptionPayment payment) async {
    final mutated = await PaymentReviewScreen.open(context, payment);
    if (mutated == true) await _reload();
  }

  Future<void> _copyReference(String reference) async {
    if (reference.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: reference));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$reference"')));
  }

  Future<void> _exportCsv() async {
    String escape(String value) => '"${value.replaceAll('"', '""')}"';
    final buffer = StringBuffer(
      'School,Plan,Type,ExpectedAmount,SubmittedAmount,Currency,Method,'
      'Payer,Reference,PaidAt,SubmittedAt,Status,ReviewedAt\n',
    );
    for (final p in _visibleItems) {
      buffer.writeln(
        [
          escape(p.schoolName),
          escape(p.planName),
          escape(
            p.paymentType == ManualPaymentType.activation
                ? 'Activation'
                : 'Renewal',
          ),
          p.expectedAmount,
          p.submittedAmount,
          escape(p.currency),
          escape(paymentMethodLabel(p.method)),
          escape(p.payerName),
          escape(p.reference),
          escape(p.paidAt.toIso8601String()),
          escape(p.submittedAt.toIso8601String()),
          escape(paymentStatusLabel(p.status)),
          escape(p.reviewedAt?.toIso8601String() ?? ''),
        ].join(','),
      );
    }
    final bytes = utf8.encode(buffer.toString());
    final name =
        'subscription_payments_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    await Share.shareXFiles([
      XFile.fromData(bytes, name: name, mimeType: 'text/csv'),
    ], subject: 'School Pulse subscription payments export');
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final selected = await showModalBottomSheet<_DateRange>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              for (final range in _DateRange.values)
                ListTile(
                  title: Text(range.label),
                  trailing: range == _dateRange
                      ? Icon(
                          Icons.check_rounded,
                          color: paymentAccent(sheetContext),
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, range),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  Future<void> _openAdvancedFilters(BuildContext context) async {
    var method = _methodFilter;
    var sortBy = _sortBy;
    final result = await showModalBottomSheet<(ManualPaymentMethod?, _SortBy)>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters & sorting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment method',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: method == null,
                          onSelected: (_) => setSheetState(() => method = null),
                        ),
                        ChoiceChip(
                          label: const Text('MTN MoMo'),
                          selected: method == ManualPaymentMethod.mtn,
                          onSelected: (_) => setSheetState(
                            () => method = ManualPaymentMethod.mtn,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Centenary Bank'),
                          selected: method == ManualPaymentMethod.bank,
                          onSelected: (_) => setSheetState(
                            () => method = ManualPaymentMethod.bank,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in _SortBy.values)
                          ChoiceChip(
                            label: Text(option.label),
                            selected: sortBy == option,
                            onSelected: (_) =>
                                setSheetState(() => sortBy = option),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.pop(sheetContext, (method, sortBy)),
                            style: FilledButton.styleFrom(
                              backgroundColor: paymentAccent(sheetContext),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null && mounted) {
      setState(() {
        _methodFilter = result.$1;
        _sortBy = result.$2;
      });
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (text.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    return friendlyErrorMessage(error);
  }
}

// --- Small building blocks -------------------------------------------------

class _OutlinedPill extends StatelessWidget {
  const _OutlinedPill({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  final String label;
  final String value;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodPill extends StatelessWidget {
  const _MethodPill({required this.method});
  final ManualPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          method == ManualPaymentMethod.mtn
              ? Icons.smartphone_rounded
              : Icons.account_balance_rounded,
          size: 14,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 5),
        Text(
          paymentMethodLabel(method),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ManualPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = paymentStatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        paymentStatusLabel(status).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.payment,
    required this.amount,
    required this.submittedAt,
    required this.selected,
    required this.onTap,
    required this.onCopyReference,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onCopyReference;

  @override
  Widget build(BuildContext context) {
    final accent = paymentAccent(context);
    return Material(
      color: selected ? accent.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: paymentStatusColor(context, payment.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        payment.schoolName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  payment.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  payment.paymentType == ManualPaymentType.activation
                      ? 'Activation'
                      : 'Renewal',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(flex: 2, child: _MethodPill(method: payment.method)),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        payment.reference.isEmpty ? '—' : payment.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (payment.reference.isNotEmpty)
                      InkWell(
                        onTap: onCopyReference,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  submittedAt,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusPill(status: payment.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.amount,
    required this.submittedAt,
    required this.onTap,
    required this.onCopyReference,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final VoidCallback onTap;
  final VoidCallback onCopyReference;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${payment.planName} • '
                          '${payment.paymentType == ManualPaymentType.activation ? 'Activation' : 'Renewal'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(status: payment.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _MethodPill(method: payment.method),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: border),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    submittedAt,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (payment.reference.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.tag_rounded,
                      size: 13,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        payment.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onCopyReference,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, this.hasQuery = false});
  final ManualPaymentStatus? filter;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final (title, message) = hasQuery
        ? (
            'No results found',
            'Try a different search term or clear your filters.',
          )
        : switch (filter) {
            ManualPaymentStatus.pendingVerification => (
              'Nothing to review',
              'No payments are waiting for verification.',
            ),
            ManualPaymentStatus.approved => (
              'No approved payments',
              'No approved payments in this period.',
            ),
            ManualPaymentStatus.rejected => (
              'No rejected payments',
              'No rejected payments in this period.',
            ),
            null => (
              'No payments yet',
              'No manual subscription payments have been submitted yet.',
            ),
          };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.payments_outlined,
            size: 30,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
