import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../responsive.dart';
import 'payment_review_screen.dart';

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
    if (_search.trim().isNotEmpty) {
      final query = _search.trim().toLowerCase();
      items = items.where(
        (payment) => payment.schoolName.toLowerCase().contains(query),
      );
    }
    return items.toList();
  }

  int _count(ManualPaymentStatus status) =>
      _items.where((payment) => payment.status == status).length;

  int get _totalVerifiedRevenue => _items
      .where((payment) => payment.status == ManualPaymentStatus.approved)
      .fold(0, (sum, payment) => sum + payment.submittedAmount);

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Billing'),
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
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _header(context)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.m,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _summaryCards(context, wide)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.m,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _filtersAndSearch(context)),
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
                child: _EmptyState(filter: _filter),
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
                  AppSpacing.s,
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payments & Billing',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Review and manage subscription payments from schools.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _summaryCards(BuildContext context, bool wide) {
    final cards = [
      DashboardStatCard(
        title: 'Pending Verification',
        value: _count(ManualPaymentStatus.pendingVerification).toDouble(),
        icon: Icons.schedule_rounded,
        color: AppColors.warning(context),
      ),
      DashboardStatCard(
        title: 'Approved',
        value: _count(ManualPaymentStatus.approved).toDouble(),
        icon: Icons.verified_rounded,
        color: AppColors.success(context),
      ),
      DashboardStatCard(
        title: 'Rejected',
        value: _count(ManualPaymentStatus.rejected).toDouble(),
        icon: Icons.cancel_outlined,
        color: AppColors.danger(context),
      ),
      DashboardStatCard(
        title: 'Total Verified Revenue',
        value: _totalVerifiedRevenue.toDouble(),
        icon: Icons.payments_rounded,
        color: AppColors.primary(context),
        suffix: ' UGX',
      ),
    ];

    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.l,
      mainAxisSpacing: AppSpacing.l,
      childAspectRatio: 1.35,
      children: cards,
    );
  }

  Widget _filtersAndSearch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'pending', label: Text('Pending')),
              ButtonSegment(value: 'approved', label: Text('Approved')),
              ButtonSegment(value: 'rejected', label: Text('Rejected')),
            ],
            selected: {
              switch (_filter) {
                ManualPaymentStatus.pendingVerification => 'pending',
                ManualPaymentStatus.approved => 'approved',
                ManualPaymentStatus.rejected => 'rejected',
                null => 'all',
              },
            },
            onSelectionChanged: (selection) {
              final value = selection.first;
              setState(() {
                _filter = switch (value) {
                  'pending' => ManualPaymentStatus.pendingVerification,
                  'approved' => ManualPaymentStatus.approved,
                  'rejected' => ManualPaymentStatus.rejected,
                  _ => null,
                };
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        AppSearchField(
          controller: _searchController,
          hintText: 'Search by school name',
          onChanged: (value) => setState(() => _search = value),
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

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (text.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    return text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.amount,
    required this.submittedAt,
    required this.isWorking,
    required this.onTap,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final bool isWorking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: isWorking ? null : onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              payment.method == ManualPaymentMethod.mtn
                  ? Icons.phone_android_rounded
                  : Icons.account_balance_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        payment.schoolName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    StatusBadge(
                      label: _statusLabel(payment.status),
                      color: _statusColor(context, payment.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.planName} • ${payment.paymentType == ManualPaymentType.activation ? 'First activation' : 'Renewal'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      payment.method == ManualPaymentMethod.mtn
                          ? 'MTN MoMo'
                          : 'Centenary Bank',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      submittedAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isWorking
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right_rounded),
        ],
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
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final bool isWorking;
  final VoidCallback onTap;

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
              child: Text(
                payment.reference,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final ManualPaymentStatus? filter;

  @override
  Widget build(BuildContext context) {
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
