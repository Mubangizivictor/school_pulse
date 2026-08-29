import 'package:flutter/material.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';

/// Pure validation for the payment form - amountText must parse as a
/// positive whole number of UGX (int.tryParse, never double.tryParse) and
/// must not exceed the bill's current balance.
String? validatePaymentDraft({
  required String amountText,
  required int balanceUgx,
}) {
  final trimmed = amountText.trim();
  if (trimmed.isEmpty) return 'Enter an amount.';
  if (double.tryParse(trimmed) != null && int.tryParse(trimmed) == null) {
    return 'Amount must be a whole number of UGX (no decimals).';
  }
  final amount = int.tryParse(trimmed);
  if (amount == null || amount <= 0) {
    return 'Amount must be a positive whole number.';
  }
  if (amount > balanceUgx) {
    return 'Amount exceeds the remaining balance.';
  }
  return null;
}

class RecordPaymentDialog extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final StudentBill bill;

  const RecordPaymentDialog({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.bill,
  });

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  String _method = 'cash';
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _payerNameController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.bill.balanceUgx.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _payerNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = validatePaymentDraft(
      amountText: _amountController.text,
      balanceUgx: widget.bill.balanceUgx,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _submitting = true);
    final amount = int.parse(_amountController.text.trim());
    final result = await sl<StudentBillingRepository>().recordStudentPayment(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
      billId: widget.bill.id,
      method: _method,
      amountUgx: amount,
      referenceNumber: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      payerName: _payerNameController.text.trim().isEmpty
          ? null
          : _payerNameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment recorded. Receipt ${success.receiptNumber}.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Payment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _method,
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(
                  value: 'mobile_money',
                  child: Text('Mobile Money'),
                ),
                DropdownMenuItem(
                  value: 'bank_transfer',
                  child: Text('Bank Transfer'),
                ),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'cash'),
              decoration: const InputDecoration(labelText: 'Method'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (UGX)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference number (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _payerNameController,
              decoration: const InputDecoration(
                labelText: 'Payer name (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: const Text('Record'),
        ),
      ],
    );
  }
}
