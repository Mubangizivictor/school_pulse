import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:school_pulse/features/finance/presentation/screens/receive_payment_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/receipt_detail_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'apply_adjustment_dialog.dart';

/// Student Statement (a.k.a. issued bills).
///
/// Matches the reference "Student Statement" screenshot: a learner header,
/// a term selector, an overall status badge, a fee breakdown table with
/// scholarship/discount lines, an amount-due total, and payment history.
/// Renders the immutable snapshot backend (`student_accounts/*/bills/**`) -
/// every figure is displayed exactly as stored at issuance, never recomputed.
/// Staff see Record payment / Adjust; parents see a read-only view.
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
    final auth = context.watch<AuthBloc>().state;
    final canManage =
        auth is AuthAuthenticated &&
        auth.user.roles.any(_financeRoles.contains);
    final studentName = auth is AuthAuthenticated ? auth.user.name : '';

    final body = StreamBuilder<List<StudentBill>>(
      stream: sl<StudentBillingRepository>().watchBills(schoolId, studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FinanceStates.error(context, 'Could not load statement.');
        }
        if (!snapshot.hasData) return FinanceStates.loading();
        final bills = snapshot.data!;
        if (bills.isEmpty) {
          return FinanceStates.empty(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'No bills yet',
            message:
                'Billing starts once a fee plan is published and the '
                'learner is activated.',
          );
        }
        return _StatementBody(
          schoolId: schoolId,
          studentId: studentId,
          studentName: studentName,
          bills: bills,
          canManage: canManage,
          embedded: embedded,
        );
      },
    );

    if (embedded) return body;
    return FinanceScaffold(title: 'Student Statement', body: body);
  }
}

class _StatementBody extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;
  final List<StudentBill> bills;
  final bool canManage;
  final bool embedded;

  const _StatementBody({
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.bills,
    required this.canManage,
    required this.embedded,
  });

  @override
  State<_StatementBody> createState() => _StatementBodyState();
}

class _StatementBodyState extends State<_StatementBody> {
  late StudentBill _selected = widget.bills.first;

  int get _scholarshipDiscount => widget.bills
      .where((b) => b.id == _selected.id)
      .fold(0, (s, b) => s + b.adjustmentTotalUgx);

  @override
  Widget build(BuildContext context) {
    final bill = _selected;
    final overallOverdue = bill.status != 'paid' && bill.balanceUgx > 0;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        widget.embedded ? AppSpacing.l : AppSpacing.x3l,
      ),
      children: [
        // Learner header
        Row(
          children: [
            CircleAvatar(
              radius: 22,
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
                    widget.studentName.isEmpty ? 'Learner' : widget.studentName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    'Class ${bill.classId}',
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
        const SizedBox(height: AppSpacing.l),

        // Term selector + status
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: bill.id,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.m,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                items: [
                  for (final b in widget.bills)
                    DropdownMenuItem(
                      value: b.id,
                      child: Text(
                        b.issuedAt != null
                            ? 'Bill • ${DateFormatter.format(b.issuedAt!)}'
                            : 'Bill ${b.id}',
                      ),
                    ),
                ],
                onChanged: (id) => setState(
                  () => _selected = widget.bills.firstWhere((b) => b.id == id),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            FinanceStatusChip(
              label: overallOverdue ? 'Overdue' : 'Settled',
              tone: overallOverdue
                  ? FinanceStatusTone.negative
                  : FinanceStatusTone.positive,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),

        // Fee breakdown
        SectionCard(
          title: 'FEE BREAKDOWN',
          child: Column(
            children: [
              for (final line in bill.lines)
                KeyValueRow(
                  line.name,
                  CurrencyFormatter.ugx(line.amountUgx.toDouble()),
                ),
              const Divider(height: AppSpacing.x2l),
              KeyValueRow(
                'Issued total',
                CurrencyFormatter.ugx(bill.issuedTotalUgx.toDouble()),
              ),
              if (_scholarshipDiscount > 0)
                KeyValueRow(
                  'Scholarship / discount',
                  '- ${CurrencyFormatter.ugx(_scholarshipDiscount.toDouble())}',
                  valueColor: AppColors.success(context),
                ),
              if (bill.paidTotalUgx > 0)
                KeyValueRow(
                  'Paid to date',
                  '- ${CurrencyFormatter.ugx(bill.paidTotalUgx.toDouble())}',
                  valueColor: AppColors.success(context),
                ),
              const Divider(height: AppSpacing.x2l),
              KeyValueRow(
                'Amount due',
                CurrencyFormatter.ugx(bill.balanceUgx.toDouble()),
                bold: true,
                valueColor: bill.balanceUgx > 0
                    ? AppColors.danger(context)
                    : AppColors.success(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Payment history
        _PaymentHistory(
          schoolId: widget.schoolId,
          studentId: widget.studentId,
          studentName: widget.studentName,
          bill: bill,
          canManage: widget.canManage,
        ),
        const SizedBox(height: AppSpacing.l),

        // Actions
        if (!widget.embedded)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareStatement(context, bill),
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text('Share statement'),
                ),
              ),
              if (widget.canManage) ...[
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.background(context),
                    ),
                    onPressed: bill.balanceUgx <= 0
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReceivePaymentScreen(
                                schoolId: widget.schoolId,
                                studentId: widget.studentId,
                                studentName: widget.studentName,
                                bill: bill,
                              ),
                            ),
                          ),
                    child: const Text('Record payment'),
                  ),
                ),
              ],
            ],
          ),
        if (widget.canManage && !widget.embedded) ...[
          const SizedBox(height: AppSpacing.m),
          TextButton.icon(
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
            icon: const Icon(Icons.percent_rounded, size: 16),
            label: const Text('Apply scholarship / discount'),
          ),
        ],
      ],
    );
  }

  void _shareStatement(BuildContext context, StudentBill bill) {
    final buffer = StringBuffer()
      ..writeln('Statement for ${widget.studentName}')
      ..writeln('Class ${bill.classId}')
      ..writeln('');
    for (final line in bill.lines) {
      buffer.writeln(
        '${line.name}: ${CurrencyFormatter.ugx(line.amountUgx.toDouble())}',
      );
    }
    buffer
      ..writeln('')
      ..writeln(
        'Issued total: ${CurrencyFormatter.ugx(bill.issuedTotalUgx.toDouble())}',
      )
      ..writeln('Paid: ${CurrencyFormatter.ugx(bill.paidTotalUgx.toDouble())}')
      ..writeln(
        'Amount due: ${CurrencyFormatter.ugx(bill.balanceUgx.toDouble())}',
      );
    Share.share(buffer.toString(), subject: 'Fee statement');
  }
}

class _PaymentHistory extends StatelessWidget {
  final String schoolId;
  final String studentId;
  final String studentName;
  final StudentBill bill;
  final bool canManage;

  const _PaymentHistory({
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.bill,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudentPayment>>(
      stream: sl<StudentBillingRepository>().watchPayments(
        schoolId,
        studentId,
        bill.id,
      ),
      builder: (context, snapshot) {
        final payments = snapshot.data ?? const <StudentPayment>[];
        return SectionCard(
          title: 'PAYMENT HISTORY',
          child: payments.isEmpty
              ? Text(
                  'No payments recorded yet.',
                  style: TextStyle(color: AppColors.textMuted(context)),
                )
              : Column(
                  children: [
                    for (final p in payments)
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReceiptDetailScreen(
                              schoolId: schoolId,
                              studentId: studentId,
                              studentName: studentName,
                              billId: bill.id,
                              payment: p,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                p.isReversal
                                    ? Icons.undo_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 16,
                                color: p.isReversal
                                    ? AppColors.danger(context)
                                    : AppColors.success(context),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.isReversal
                                          ? 'Reversal • ${p.receiptNumber}'
                                          : 'Receipt ${p.receiptNumber}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${p.method}'
                                      '${p.recordedAt != null ? ' • ${DateFormatter.format(p.recordedAt!)}' : ''}'
                                      '${p.isReversed ? ' • reversed' : ''}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${p.amountUgx < 0 ? '- ' : ''}'
                                '${CurrencyFormatter.ugx(p.amountUgx.abs().toDouble())}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: p.isReversal
                                      ? AppColors.danger(context)
                                      : AppColors.success(context),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.textMuted(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
