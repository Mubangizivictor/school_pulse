import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../responsive.dart';
import 'payment_review_screen.dart';

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

  /// Optional deep-link filter, e.g. from the Dashboard's
  /// "Payments to Verify" card which should land here pre-filtered to
  /// pending verification.
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
  final TextEditingController _searchController = TextEditingController();

  List<ManualSubscriptionPayment> _items = const [];
  bool _loading = true;
  String? _error;
  ManualPaymentStatus? _filter;
  String _search = '';
  String? _workingPaymentId;
  _DateRange _dateRange = _DateRange.thisMonth;
  ManualPaymentMethod? _methodFilter;
  _SortBy _sortBy = _SortBy.newest;
  DateTime? _lastSyncedAt;

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
        _lastSyncedAt = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          IconButton(
            tooltip: 'Refresh payments',
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.s,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _header(context)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.m,
              ),
              sliver: SliverToBoxAdapter(child: _dateRangeChip(context)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.m,
              ),
              sliver: SliverToBoxAdapter(child: _summaryCards(context, wide)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _filtersAndSearch(context)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _resultsRow(context)),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: SchoolPulseLoader()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(message: _error!, onRetry: _reload),
              )
            else if (_visibleItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  filter: _filter,
                  hasQuery: _search.trim().isNotEmpty,
                ),
              )
            else if (wide)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.s,
                  AppSpacing.xl,
                  AppSpacing.x3l,
                ),
                sliver: SliverToBoxAdapter(child: _table(context)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.x3l,
                ),
                sliver: SliverList.separated(
                  itemCount: _visibleItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final payment = _visibleItems[index];
                    return _PaymentCard(
                      payment: payment,
                      amount: _money.format(payment.submittedAmount),
                      submittedAt: _dateTime.format(payment.submittedAt),
                      isWorking: _workingPaymentId == payment.id,
                      onTap: () => _openReview(payment),
                      onCopyReference: () => _copyReference(payment.reference),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Text(
      'Track and manage subscription payments from schools.',
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary(context),
      ),
    );
  }

  Widget _dateRangeChip(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _pickDateRange(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  _dateRange.label,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
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
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final selected = await showModalBottomSheet<_DateRange>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.m),
              for (final range in _DateRange.values)
                ListTile(
                  title: Text(range.label),
                  trailing: range == _dateRange
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColors.primary(sheetContext),
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, range),
                ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  Widget _summaryCards(BuildContext context, bool wide) {
    final tiles = [
      _BillingStatTile(
        label: 'Pending',
        value: '${_count(ManualPaymentStatus.pendingVerification)}',
        subtitle: _count(ManualPaymentStatus.pendingVerification) == 0
            ? 'No payments awaiting review'
            : 'Awaiting review',
        icon: Icons.schedule_rounded,
        color: AppColors.warning(context),
        accent: AppColors.warning(context),
      ),
      _BillingStatTile(
        label: 'Approved',
        value: '${_count(ManualPaymentStatus.approved)}',
        subtitle:
            '+${_count(ManualPaymentStatus.approved)} ${_dateRange.label.toLowerCase()}',
        subtitleIcon: Icons.arrow_upward_rounded,
        icon: Icons.verified_rounded,
        color: AppColors.success(context),
        accent: AppColors.success(context),
      ),
      _BillingStatTile(
        label: 'Rejected',
        value: '${_count(ManualPaymentStatus.rejected)}',
        subtitle: _count(ManualPaymentStatus.rejected) == 0
            ? 'No rejected payments'
            : 'Needs attention',
        icon: Icons.cancel_rounded,
        color: AppColors.danger(context),
        accent: AppColors.danger(context),
      ),
      _BillingStatTile(
        label: 'Verified revenue',
        value: _money.format(_totalVerifiedRevenue),
        subtitle: 'Total collected ${_dateRange.label.toLowerCase()}',
        icon: Icons.payments_rounded,
        color: AppColors.primary(context),
        accent: AppColors.information(context),
      ),
    ];

    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.m,
      mainAxisSpacing: AppSpacing.m,
      childAspectRatio: 1.35,
      children: tiles,
    );
  }

  Widget _filtersAndSearch(BuildContext context) {
    final filters = <(String, ManualPaymentStatus?)>[
      ('All', null),
      ('Pending', ManualPaymentStatus.pendingVerification),
      ('Approved', ManualPaymentStatus.approved),
      ('Rejected', ManualPaymentStatus.rejected),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
            itemBuilder: (context, index) {
              final (label, status) = filters[index];
              final selected = _filter == status;
              return _FilterChip(
                label: label,
                selected: selected,
                onTap: () => setState(() => _filter = status),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: AppSearchField(
                controller: _searchController,
                hintText: 'Search by school name...',
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            _AdvancedFilterButton(
              active: _hasActiveFilters,
              onTap: () => _openAdvancedFilters(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openAdvancedFilters(BuildContext context) async {
    var method = _methodFilter;
    var sortBy = _sortBy;
    final result = await showModalBottomSheet<(ManualPaymentMethod?, _SortBy)>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters & sorting',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      'Payment method',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
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
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      'Sort by',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
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
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.pop(sheetContext, (method, sortBy)),
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

  Widget _resultsRow(BuildContext context) {
    final synced = _lastSyncedAt;
    final label = synced == null
        ? ''
        : DateTime.now().difference(synced).inSeconds < 30
        ? 'Last synced just now'
        : 'Last synced ${DateFormat('h:mm a').format(synced)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_visibleItems.length} result${_visibleItems.length == 1 ? '' : 's'}',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (label.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.success(context),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _table(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.m,
            ),
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
                const SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final payment in _visibleItems)
            _TableRow(
              payment: payment,
              amount: _money.format(payment.submittedAmount),
              submittedAt: _dateTime.format(payment.submittedAt),
              isWorking: _workingPaymentId == payment.id,
              onTap: () => _openReview(payment),
              onCopyReference: () => _copyReference(payment.reference),
            ),
        ],
      ),
    );
  }

  Widget _headCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }

  Future<void> _openReview(ManualSubscriptionPayment payment) async {
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

class _AdvancedFilterButton extends StatelessWidget {
  const _AdvancedFilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Material(
      color: active ? primary : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 20,
            color: active ? primary : AppColors.textSecondary(context),
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
    required this.isWorking,
    required this.onTap,
    required this.onCopyReference,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final bool isWorking;
  final VoidCallback onTap;
  final VoidCallback onCopyReference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: isWorking ? null : onTap,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.schoolName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${payment.planName} • ${payment.paymentType == ManualPaymentType.activation ? 'First activation' : 'Renewal'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              StatusBadge(
                label: _statusLabel(payment.status),
                color: _statusColor(context, payment.status),
                icon: switch (payment.status) {
                  ManualPaymentStatus.approved => Icons.check_circle_rounded,
                  ManualPaymentStatus.rejected => Icons.cancel_rounded,
                  ManualPaymentStatus.pendingVerification =>
                    Icons.schedule_rounded,
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Text(
                amount,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              _MethodPill(method: payment.method),
              const Spacer(),
              if (!isWorking)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary(context),
                )
              else
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Text(
                submittedAt,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              if (payment.reference.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  '|',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.sell_outlined,
                  size: 14,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    payment.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onCopyReference,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        method == ManualPaymentMethod.mtn ? 'MTN MoMo' : 'Centenary Bank',
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context),
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
    required this.isWorking,
    required this.onTap,
    required this.onCopyReference,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final bool isWorking;
  final VoidCallback onTap;
  final VoidCallback onCopyReference;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isWorking ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                payment.schoolName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                payment.planName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                payment.paymentType == ManualPaymentType.activation
                    ? 'Activation'
                    : 'Renewal',
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                amount,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                payment.method == ManualPaymentMethod.mtn
                    ? 'MTN MoMo'
                    : 'Centenary Bank',
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      payment.reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (payment.reference.isNotEmpty)
                    InkWell(
                      onTap: onCopyReference,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.copy_rounded, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                submittedAt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              flex: 2,
              child: StatusBadge(
                label: _statusLabel(payment.status),
                color: _statusColor(context, payment.status),
              ),
            ),
            SizedBox(
              width: 40,
              child: isWorking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
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

class _BillingStatTile extends StatelessWidget {
  const _BillingStatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accent,
    this.subtitleIcon,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accent;
  final IconData? subtitleIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l + 3,
              AppSpacing.l,
              AppSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (subtitleIcon != null) ...[
                      Icon(
                        subtitleIcon,
                        size: 12,
                        color: AppColors.success(context),
                      ),
                      const SizedBox(width: 2),
                    ],
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: subtitleIcon != null
                              ? AppColors.success(context)
                              : AppColors.textSecondary(context),
                          fontWeight: subtitleIcon != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: accent),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Material(
      color: selected ? primary : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary(context),
            ),
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
    if (hasQuery) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        message: 'Try a different search term or clear your filters.',
      );
    }
    final label = switch (filter) {
      ManualPaymentStatus.pendingVerification =>
        'No payments are waiting for verification.',
      ManualPaymentStatus.approved => 'No approved payments yet.',
      ManualPaymentStatus.rejected => 'No rejected payments.',
      null => 'No manual subscription payments have been submitted yet.',
    };
    return EmptyState(
      icon: Icons.payments_outlined,
      title: 'No payments found',
      message: label,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
