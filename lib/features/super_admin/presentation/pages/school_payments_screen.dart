import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../data/services/manual_payment_service.dart';
import '../../domain/entities/manual_subscription_payment.dart';
import '../../domain/entities/school.dart';
import 'payment_review_screen.dart';

enum _PaymentFilter { all, pendingReview, paid, failed }

/// A real, school-scoped payment history screen - "View all payments" from
/// Screen B pushes this (with the same [School] object, preserving
/// selection across the push/pop) instead of the previously unfiltered
/// BillingHomeScreen. The school-scoping is enforced server-side by
/// ManualPaymentService.getPayments(schoolId: ...), which is itself a real
/// where('schoolId', ...) clause on the callable - route/query params alone
/// are never the authorization boundary here.
class SchoolPaymentsScreen extends StatefulWidget {
  const SchoolPaymentsScreen({super.key, required this.school});
  final School school;

  @override
  State<SchoolPaymentsScreen> createState() => _SchoolPaymentsScreenState();
}

class _SchoolPaymentsScreenState extends State<SchoolPaymentsScreen> {
  final ManualPaymentService _service = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('d MMM yyyy');

  bool _loading = true;
  String? _error;
  List<ManualSubscriptionPayment> _payments = const [];
  _PaymentFilter _filter = _PaymentFilter.all;
  DateTimeRange? _dateRange;

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
      final payments = await _service.getPayments(
        schoolId: widget.school.id,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      );
      if (!mounted) return;
      setState(() {
        _payments = payments;
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

  List<ManualSubscriptionPayment> get _filtered {
    final matches = switch (_filter) {
      _PaymentFilter.all => _payments,
      _PaymentFilter.pendingReview => _payments
          .where((p) => p.status == ManualPaymentStatus.pendingVerification)
          .toList(),
      _PaymentFilter.paid => _payments
          .where((p) => p.status == ManualPaymentStatus.approved)
          .toList(),
      _PaymentFilter.failed => _payments
          .where((p) => p.status == ManualPaymentStatus.rejected)
          .toList(),
    };
    return matches;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
    );
    if (picked == null) return;
    setState(() => _dateRange = picked);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          '${widget.school.name} · Payments',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Filter by date range',
            icon: const Icon(Icons.date_range_outlined),
            onPressed: _pickDateRange,
          ),
          if (_dateRange != null)
            IconButton(
              tooltip: 'Clear date range',
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() => _dateRange = null);
                _load();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in _PaymentFilter.values) ...[
                      ChoiceChip(
                        label: Text(_filterLabel(filter)),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                      const SizedBox(width: AppSpacing.s),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: SchoolPulseLoader());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
              const SizedBox(height: AppSpacing.s),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Text(
                _payments.isEmpty
                    ? 'No payments recorded for this school yet.'
                    : 'No payments match this filter.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        0,
        AppSpacing.l,
        AppSpacing.l,
      ),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
      itemBuilder: (context, index) {
        final payment = filtered[index];
        return AppCard(
          onTap: payment.status == ManualPaymentStatus.pendingVerification
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentReviewScreen(payment: payment),
                  ),
                )
              : null,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateFormat.format(payment.submittedAt),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref ${payment.reference.isEmpty ? payment.id : payment.reference}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
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
            ],
          ),
        );
      },
    );
  }

  String _filterLabel(_PaymentFilter filter) => switch (filter) {
    _PaymentFilter.all => 'All',
    _PaymentFilter.pendingReview => 'Pending review',
    _PaymentFilter.paid => 'Paid',
    _PaymentFilter.failed => 'Failed',
  };

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
