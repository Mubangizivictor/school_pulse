import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';
import 'package:school_pulse/features/finance/domain/services/receipt_pdf_generator.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Receipt detail.
///
/// Shows one [StudentPayment] (or its reversal) exactly as the server
/// recorded it - `receiptNumber`, `amountInWords`, method, reference, and
/// the verify QR are all server-generated and never recomputed here. Offers
/// Print / Download / Share (via the existing [ReceiptPdfGenerator]) and,
/// for authorised roles only, Reverse - which calls `reverseStudentPayment`
/// (a compensating record, never a delete). Reversal state and who recorded
/// it form the on-screen audit trail.
class ReceiptDetailScreen extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;
  final String billId;
  final StudentPayment payment;
  final bool justRecorded;

  const ReceiptDetailScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.billId,
    required this.payment,
    this.justRecorded = false,
  });

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  /// Only these roles may reverse a recorded payment - mirrors the finance
  /// approver set. Bursars record; reversal is a supervised correction.
  static const _reversalRoles = {
    UserRole.schoolAdmin,
    UserRole.director,
    UserRole.headTeacher,
    UserRole.bursar,
  };

  late StudentPayment _payment = widget.payment;
  bool _busy = false;

  bool get _canReverse {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated &&
        auth.user.roles.any(_reversalRoles.contains);
  }

  String get _schoolName {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated
        ? (auth.user.schoolName ?? 'School Pulse')
        : 'School Pulse';
  }

  Future<void> _sharePdf() async {
    setState(() => _busy = true);
    try {
      await ReceiptPdfGenerator.download(
        payment: _payment,
        studentName: widget.studentName,
        schoolName: _schoolName,
      );
    } catch (e) {
      if (mounted) _snack('Could not generate the receipt PDF.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _printPdf() async {
    setState(() => _busy = true);
    try {
      await Printing.layoutPdf(
        onLayout: (_) => ReceiptPdfGenerator.generate(
          payment: _payment,
          studentName: widget.studentName,
          schoolName: _schoolName,
        ),
      );
    } catch (e) {
      if (mounted) _snack('Could not open the print dialog.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reverse() async {
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
              '${_payment.receiptNumber}. The original record is never '
              'deleted or changed.',
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger(context),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reverse'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      _snack('A reason is required to reverse a payment.');
      return;
    }
    setState(() => _busy = true);
    final result = await sl<StudentBillingRepository>().reverseStudentPayment(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
      billId: widget.billId,
      paymentId: _payment.id,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold((failure) => _snack(failure.message), (_) {
      _snack('Payment reversed. A reversal receipt has been recorded.');
      setState(() {
        _payment = StudentPayment(
          id: _payment.id,
          billId: _payment.billId,
          status: _payment.status,
          method: _payment.method,
          amountUgx: _payment.amountUgx,
          referenceNumber: _payment.referenceNumber,
          payerName: _payment.payerName,
          payerGuardianId: _payment.payerGuardianId,
          receiptNumber: _payment.receiptNumber,
          recordedBy: _payment.recordedBy,
          recordedAt: _payment.recordedAt,
          reversalOfPaymentId: _payment.reversalOfPaymentId,
          reversedByPaymentId: 'pending',
          reversedAt: DateTime.now(),
          amountInWords: _payment.amountInWords,
          qrVerificationUrl: _payment.qrVerificationUrl,
          sourcePendingPaymentId: _payment.sourcePendingPaymentId,
        );
      });
    });
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final p = _payment;
    final reversed = p.isReversed;

    return FinanceScaffold(
      title: p.isReversal ? 'Reversal Receipt' : 'Receipt',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.x3l,
        ),
        children: [
          if (widget.justRecorded)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.l),
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.successSurface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success(context),
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Payment recorded. Receipt ${p.receiptNumber}.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Center(
            child: Column(
              children: [
                Text(
                  reversed || p.isReversal ? 'REVERSED' : 'PAYMENT RECEIVED',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                    color: reversed || p.isReversal
                        ? AppColors.danger(context)
                        : AppColors.success(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  CurrencyFormatter.ugx(p.amountUgx.abs().toDouble()),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (p.amountInWords != null)
                  Text(
                    p.amountInWords!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),

          SectionCard(
            child: Column(
              children: [
                KeyValueRow('Receipt number', p.receiptNumber),
                KeyValueRow('Learner', widget.studentName),
                if (p.recordedAt != null)
                  KeyValueRow('Date', DateFormatter.format(p.recordedAt!)),
                KeyValueRow('Method', _methodLabel(p.method)),
                if (p.referenceNumber != null)
                  KeyValueRow('Reference', p.referenceNumber!),
                if (p.payerName != null) KeyValueRow('Payer', p.payerName!),
                KeyValueRow('Recorded by', p.recordedBy),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          // Audit / reversal trail
          SectionCard(
            title: 'AUDIT',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _auditLine(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  tone: FinanceStatusTone.positive,
                  text: p.isReversal ? 'Reversal recorded' : 'Payment recorded',
                  when: p.recordedAt,
                ),
                if (reversed)
                  _auditLine(
                    context,
                    icon: Icons.undo_rounded,
                    tone: FinanceStatusTone.negative,
                    text: 'Reversed by a compensating receipt',
                    when: p.reversedAt,
                  ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Money records are immutable. Corrections are made by '
                  'reversal, never by editing or deleting a receipt.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _printPdf,
                  icon: const Icon(Icons.print_outlined, size: 16),
                  label: const Text('Print'),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _sharePdf,
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
          if (_canReverse && !p.isReversal && !reversed) ...[
            const SizedBox(height: AppSpacing.m),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger(context),
                side: BorderSide(color: AppColors.danger(context)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _busy ? null : _reverse,
              icon: const Icon(Icons.undo_rounded, size: 16),
              label: const Text('Reverse payment'),
            ),
          ],
        ],
      ),
    );
  }

  String _methodLabel(String m) => switch (m) {
    'cash' => 'Cash',
    'mobile_money' => 'Mobile Money',
    'bank_transfer' => 'Bank Transfer',
    _ => m,
  };

  Widget _auditLine(
    BuildContext context, {
    required IconData icon,
    required FinanceStatusTone tone,
    required String text,
    DateTime? when,
  }) {
    final color = tone == FinanceStatusTone.negative
        ? AppColors.danger(context)
        : AppColors.success(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          if (when != null)
            Text(
              DateFormatter.format(when),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
        ],
      ),
    );
  }
}
