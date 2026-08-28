import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';
import 'package:school_pulse/features/finance/presentation/screens/receipt_detail_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/student_billing/record_payment_dialog.dart'
    show validatePaymentDraft;
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Receive Payment.
///
/// Matches the reference "Receive Payment" screenshot: the learner header,
/// a large editable amount, a Cash / Mobile Money / Bank segmented method
/// selector, an "Allocate to" list of the bill's fee lines with the total
/// allocated + remaining balance, an optional note, and a pinned
/// "Record payment" action.
///
/// Every write goes through the callable `recordStudentPayment` (integer
/// UGX, server-generated receipt, append-only `finance_audit_events`). The
/// screen never writes Firestore directly. A double-submit guard plus the
/// shared [validatePaymentDraft] rules (whole UGX, not over balance, sums to
/// the amount) enforce accounting consistency before the call.
class ReceivePaymentScreen extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;
  final StudentBill bill;

  const ReceivePaymentScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.bill,
  });

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  static const _methods = [
    (value: 'cash', label: 'Cash'),
    (value: 'mobile_money', label: 'Mobile Money'),
    (value: 'bank_transfer', label: 'Bank'),
  ];

  String _method = 'cash';
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _payerNameController = TextEditingController();
  final _noteController = TextEditingController();

  /// chargeId -> allocated whole UGX. Seeded from the bill lines, capped at
  /// each line's amount, initially covering the full balance top-down.
  late final Map<String, int> _allocations = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController
      ..text = widget.bill.balanceUgx.toString()
      ..addListener(_reallocate);
    _reallocate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _payerNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_amountController.text.trim()) ?? 0;

  int get _allocated => _allocations.values.fold(0, (s, v) => s + v);

  /// Spreads the entered amount across the bill's charge lines top-down so
  /// the "Allocate to" list always sums to the amount (the screenshot's
  /// "Total allocated" / "Balance" rows).
  void _reallocate() {
    var remaining = _amount.clamp(0, widget.bill.balanceUgx);
    final next = <String, int>{};
    for (final line in widget.bill.lines) {
      if (remaining <= 0) break;
      final take = remaining < line.amountUgx ? remaining : line.amountUgx;
      next[line.chargeId] = take;
      remaining -= take;
    }
    setState(() {
      _allocations
        ..clear()
        ..addAll(next);
    });
  }

  Future<void> _submit() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || _submitting) return;

    final error = validatePaymentDraft(
      amountText: _amountController.text,
      balanceUgx: widget.bill.balanceUgx,
    );
    if (error != null) {
      _snack(error);
      return;
    }
    if (_allocated != _amount) {
      _snack('Allocations must add up to the payment amount.');
      return;
    }

    setState(() => _submitting = true);
    final result = await sl<StudentBillingRepository>().recordStudentPayment(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
      billId: widget.bill.id,
      method: _method,
      amountUgx: _amount,
      referenceNumber: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      payerName: _payerNameController.text.trim().isEmpty
          ? null
          : _payerNameController.text.trim(),
      allocations: [
        for (final e in _allocations.entries)
          if (e.value > 0) (chargeId: e.key, amountUgx: e.value),
      ],
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold((failure) => _snack(failure.message), (success) async {
      // Re-fetch the payment record so the receipt shows the
      // server-generated receiptNumber / amountInWords / QR.
      final billStream = sl<StudentBillingRepository>().watchPayments(
        widget.schoolId,
        widget.studentId,
        widget.bill.id,
      );
      final payments = await billStream.first;
      final payment = payments.firstWhere(
        (p) => p.id == success.paymentId,
        orElse: () => StudentPayment(
          id: success.paymentId,
          billId: widget.bill.id,
          status: 'recorded',
          method: _method,
          amountUgx: _amount,
          receiptNumber: success.receiptNumber,
          recordedBy: auth.user.id,
          recordedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReceiptDetailScreen(
            schoolId: widget.schoolId,
            studentId: widget.studentId,
            studentName: widget.studentName,
            billId: widget.bill.id,
            payment: payment,
            justRecorded: true,
          ),
        ),
      );
    });
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final unallocated = _amount - _allocated;

    return FinanceScaffold(
      title: 'Receive Payment',
      bottomBar: PrimaryActionBar(
        label: 'Record payment',
        loading: _submitting,
        onPressed: _submit,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.x3l,
        ),
        children: [
          FinanceCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainer(context),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.studentName.isEmpty
                            ? 'Learner'
                            : widget.studentName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Class ${widget.bill.classId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),

          Text(
            'Amount',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              prefixText: 'UGX ',
              prefixStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              border: InputBorder.none,
            ),
          ),
          Divider(color: AppColors.border(context), height: 1),
          const SizedBox(height: AppSpacing.x2l),

          MethodSegments(
            options: _methods,
            selected: _method,
            onChanged: (m) => setState(() => _method = m),
          ),
          if (_method != 'cash') ...[
            const SizedBox(height: AppSpacing.l),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: _method == 'mobile_money'
                    ? 'Mobile money transaction ID'
                    : 'Bank reference',
                border: OutlineInputBorder(borderRadius: AppRadius.medium),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          TextField(
            controller: _payerNameController,
            decoration: InputDecoration(
              labelText: 'Payer name (optional)',
              border: OutlineInputBorder(borderRadius: AppRadius.medium),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),

          Text(
            'Allocate to',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          for (final line in widget.bill.lines)
            KeyValueRow(
              line.name,
              CurrencyFormatter.ugx(
                (_allocations[line.chargeId] ?? 0).toDouble(),
              ),
            ),
          const Divider(height: AppSpacing.x2l),
          KeyValueRow(
            'Total allocated',
            CurrencyFormatter.ugx(_allocated.toDouble()),
            bold: true,
          ),
          KeyValueRow(
            'Balance',
            CurrencyFormatter.ugx(unallocated.toDouble()),
            bold: true,
            valueColor: unallocated == 0
                ? AppColors.textPrimary(context)
                : AppColors.danger(context),
          ),
          const SizedBox(height: AppSpacing.l),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Add payment note (optional)',
              border: OutlineInputBorder(borderRadius: AppRadius.medium),
            ),
          ),
        ],
      ),
    );
  }
}
