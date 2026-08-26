import 'package:flutter/material.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';

/// Pure validation for the adjustment form, extracted so it's unit-testable
/// without pumping a widget tree. Exactly one of amountText/percentageText
/// must be a valid, non-empty number; amountText must be a whole number of
/// UGX (int.tryParse, never double.tryParse).
String? validateAdjustmentDraft({
  required String type,
  required String amountText,
  required String percentageText,
  required String reason,
}) {
  if (reason.trim().isEmpty) return 'Enter a reason.';
  final hasAmount = amountText.trim().isNotEmpty;
  final hasPercentage = percentageText.trim().isNotEmpty;
  if (hasAmount == hasPercentage) {
    return 'Enter either an amount or a percentage, not both.';
  }
  if (hasAmount) {
    final trimmed = amountText.trim();
    if (double.tryParse(trimmed) != null && int.tryParse(trimmed) == null) {
      return 'Amount must be a whole number of UGX (no decimals).';
    }
    final amount = int.tryParse(trimmed);
    if (amount == null || amount <= 0) {
      return 'Amount must be a positive whole number.';
    }
  } else {
    final percentage = double.tryParse(percentageText.trim());
    if (percentage == null || percentage <= 0 || percentage > 100) {
      return 'Percentage must be a number between 0 (exclusive) and 100.';
    }
  }
  return null;
}

class ApplyAdjustmentDialog extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final StudentBill bill;

  const ApplyAdjustmentDialog({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.bill,
  });

  @override
  State<ApplyAdjustmentDialog> createState() => _ApplyAdjustmentDialogState();
}

class _ApplyAdjustmentDialogState extends State<ApplyAdjustmentDialog> {
  String _type = 'discount';
  final _amountController = TextEditingController();
  final _percentageController = TextEditingController();
  final _reasonController = TextEditingController();
  final _evidenceController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _percentageController.dispose();
    _reasonController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = validateAdjustmentDraft(
      type: _type,
      amountText: _amountController.text,
      percentageText: _percentageController.text,
      reason: _reasonController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _submitting = true);
    final amountText = _amountController.text.trim();
    final result = await sl<StudentBillingRepository>().applyBillAdjustment(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
      billId: widget.bill.id,
      type: _type,
      amountUgx: amountText.isEmpty ? null : int.parse(amountText),
      percentage: amountText.isEmpty
          ? double.parse(_percentageController.text.trim())
          : null,
      reason: _reasonController.text.trim(),
      evidenceReference: _evidenceController.text.trim().isEmpty
          ? null
          : _evidenceController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Adjustment applied.')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apply Adjustment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'discount', child: Text('Discount')),
                DropdownMenuItem(
                  value: 'scholarship',
                  child: Text('Scholarship'),
                ),
                DropdownMenuItem(value: 'waiver', child: Text('Waiver')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'discount'),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (UGX)'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('or'),
            ),
            TextField(
              controller: _percentageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Percentage (%)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _evidenceController,
              decoration: const InputDecoration(
                labelText: 'Evidence reference (optional)',
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
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
