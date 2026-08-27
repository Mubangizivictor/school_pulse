import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';
import 'record_payment_dialog.dart';
import 'apply_adjustment_dialog.dart';

/// Renders a student's real, issued bills - the immutable snapshot backend
/// (functions/student_fee_billing.js), not the legacy FeeItem/FinanceBloc
/// mock stream. Used both embedded in the parent Fees screen (read-only)
/// and as a standalone staff screen (with adjustment/payment/reversal
/// actions gated to finance roles).
///
/// Every amount shown for a bill is exactly what was stored at issuance -
/// this screen never recomputes a total against the current fee-plan
/// version, only ever displays adjustmentTotalUgx/paidTotalUgx/balanceUgx
/// as they stand after adjustments/payments have been layered on top.
class StudentBillsScreen extends StatelessWidget {
  final String schoolId;
  final String studentId;
  final bool embedded;

  const StudentBillsScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    this.embedded = false,
  });

  static const _financeRoles = {
    UserRole.schoolAdmin,
    UserRole.director,
    UserRole.headTeacher,
    UserRole.bursar,
  };

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final canManage = authState is AuthAuthenticated &&
        authState.user.roles.any(_financeRoles.contains);

    final body = StreamBuilder<List<StudentBill>>(
      stream: sl<StudentBillingRepository>().watchBills(schoolId, studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SchoolPulseLoader());
        }
        final bills = snapshot.data!;
        if (bills.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No bills yet',
            message:
                'No bill has been issued for this student yet. Billing '
                'starts once a fee plan is published and the student is '
                'activated.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bills.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BillCard(
              schoolId: schoolId,
              studentId: studentId,
              bill: bills[index],
              canManage: canManage,
            ),
          ),
        );
      },
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: body,
    );
  }
}

class _BillCard extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final StudentBill bill;
  final bool canManage;

  const _BillCard({
    required this.schoolId,
    required this.studentId,
    required this.bill,
    required this.canManage,
  });

  @override
  State<_BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<_BillCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bill.issuedAt != null
                      ? 'Bill issued ${DateFormatter.format(bill.issuedAt!)}'
                      : 'Bill',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                _StatusChip(status: bill.status),
              ],
            ),
            const SizedBox(height: 12),
            for (final line in bill.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(line.name)),
                    Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
                  ],
                ),
              ),
            const Divider(height: 20),
            _totalRow(context, 'Issued total', bill.issuedTotalUgx),
            if (bill.adjustmentTotalUgx > 0)
              _totalRow(
                context,
                'Adjustments',
                -bill.adjustmentTotalUgx,
                color: AppColors.success(context),
              ),
            if (bill.paidTotalUgx > 0)
              _totalRow(
                context,
                'Paid',
                -bill.paidTotalUgx,
                color: AppColors.success(context),
              ),
            const Divider(height: 20),
            _totalRow(
              context,
              'Balance',
              bill.balanceUgx,
              bold: true,
              color: bill.balanceUgx > 0
                  ? AppColors.warning(context)
                  : AppColors.success(context),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(_expanded ? 'Hide history' : 'Show history'),
                ),
                const Spacer(),
                if (widget.canManage) ...[
                  TextButton(
                    onPressed: bill.balanceUgx <= 0
                        ? null
                        : () => showDialog(
                              context: context,
                              builder: (_) => ApplyAdjustmentDialog(
                                schoolId: widget.schoolId,
                                studentId: widget.studentId,
                                bill: bill,
                              ),
                            ),
                    child: const Text('Adjust'),
                  ),
                  PrimaryButton(
                    label: 'Record payment',
                    onPressed: bill.balanceUgx <= 0
                        ? null
                        : () => showDialog(
                              context: context,
                              builder: (_) => RecordPaymentDialog(
                                schoolId: widget.schoolId,
                                studentId: widget.studentId,
                                bill: bill,
                              ),
                            ),
                  ),
                ],
              ],
            ),
            if (_expanded)
              _BillHistory(
                schoolId: widget.schoolId,
                studentId: widget.studentId,
                bill: bill,
                canManage: widget.canManage,
              ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(
    BuildContext context,
    String label,
    int amountUgx, {
    bool bold = false,
    Color? color,
  }) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '${amountUgx < 0 ? '- ' : ''}${CurrencyFormatter.ugx(amountUgx.abs().toDouble())}',
            style: style,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'paid'
        ? AppColors.success(context)
        : AppColors.warning(context);
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _BillHistory extends StatelessWidget {
  final String schoolId;
  final String studentId;
  final StudentBill bill;
  final bool canManage;

  const _BillHistory({
    required this.schoolId,
    required this.studentId,
    required this.bill,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Text('Payments', style: TextStyle(fontWeight: FontWeight.w600)),
          StreamBuilder<List<StudentPayment>>(
            stream: sl<StudentBillingRepository>().watchPayments(
              schoolId,
              studentId,
              bill.id,
            ),
            builder: (context, snapshot) {
              final payments = snapshot.data ?? const <StudentPayment>[];
              if (payments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('No payments recorded yet.'),
                );
              }
              return Column(
                children: payments
                    .map(
                      (p) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          p.isReversal
                              ? Icons.undo_outlined
                              : Icons.payments_outlined,
                          color: p.isReversal
                              ? AppColors.danger(context)
                              : AppColors.success(context),
                        ),
                        title: Text(
                          '${CurrencyFormatter.ugx(p.amountUgx.abs().toDouble())} '
                          '${p.isReversal ? '(reversal)' : ''}',
                        ),
                        subtitle: Text(
                          'Receipt ${p.receiptNumber} • ${p.method}'
                          '${p.isReversed ? ' • reversed' : ''}',
                        ),
                        trailing: canManage && !p.isReversal && !p.isReversed
                            ? TextButton(
                                onPressed: () => _confirmReverse(context, p),
                                child: const Text('Reverse'),
                              )
                            : null,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Adjustments',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          StreamBuilder<List<BillAdjustment>>(
            stream: sl<StudentBillingRepository>().watchAdjustments(
              schoolId,
              studentId,
              bill.id,
            ),
            builder: (context, snapshot) {
              final adjustments = snapshot.data ?? const <BillAdjustment>[];
              if (adjustments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('No adjustments applied yet.'),
                );
              }
              return Column(
                children: adjustments
                    .map(
                      (a) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.discount_outlined),
                        title: Text(
                          '${a.type} - ${CurrencyFormatter.ugx(a.amountUgx.toDouble())}',
                        ),
                        subtitle: Text(a.reason),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReverse(BuildContext context, StudentPayment payment) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reverse payment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This records a compensating reversal for receipt '
              '${payment.receiptNumber}. The original payment record is '
              'never deleted or changed.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reverse'),
          ),
        ],
      ),
    );
    if (confirmed != true || reasonController.text.trim().isEmpty) return;
    final result = await sl<StudentBillingRepository>().reverseStudentPayment(
      schoolId: schoolId,
      studentId: studentId,
      billId: bill.id,
      paymentId: payment.id,
      reason: reasonController.text.trim(),
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment reversed.'))),
    );
  }
}
