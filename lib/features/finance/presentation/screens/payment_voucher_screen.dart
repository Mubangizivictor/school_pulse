import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// New Expense / Payment Voucher.
///
/// Read-only detail view matching the reference voucher screenshot:
/// supplier, amount, budget vote, funding account, attachment, approval
/// route, narration, and Save draft / Submit for approval actions (which
/// are disabled placeholders until the write flow ships). Opened from the
/// Payment Vouchers list.
class PaymentVoucherScreen extends StatelessWidget {
  final String voucherId;
  const PaymentVoucherScreen({super.key, required this.voucherId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final repo = sl<BursarOpsReadRepository>();

    return FinanceScaffold(
      title: 'New Expense / Payment Voucher',
      bottomBar: PrimaryActionBar(
        label: 'Submit for approval',
        secondaryLabel: 'Save draft',
        onSecondary: () => _soon(context),
        onPressed: () => _soon(context),
      ),
      body: FutureBuilder<PaymentVoucher?>(
        future: repo.getPaymentVoucher(schoolId, voucherId),
        builder: (context, snap) {
          if (!snap.hasData && snap.connectionState != ConnectionState.done) {
            return FinanceStates.loading();
          }
          final v = snap.data;
          if (v == null) {
            return FinanceStates.empty(
              context,
              icon: Icons.description_outlined,
              title: 'Voucher not found',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Field(label: 'Supplier', value: v.supplierName),
              _Field(
                label: 'Amount (UGX)',
                value: CurrencyFormatter.ugx(v.amountUgx.toDouble()),
              ),
              _Field(label: 'Budget Vote', value: v.budgetVote),
              _Field(label: 'Funding Account', value: v.fundingAccount),
              _Field(
                label: 'Attachment',
                value: v.attachmentName ?? 'None',
                trailingIcon: v.attachmentName != null
                    ? Icons.attach_file_rounded
                    : null,
              ),
              _Field(
                label: 'Approval Route',
                value: v.approvalRoute.join('  →  '),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Narration',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 6),
              FinanceCard(
                child: Text(
                  v.narration,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (v.lines.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.l),
                SectionCard(
                  title: 'LINE ITEMS',
                  child: Column(
                    children: [
                      for (final l in v.lines)
                        KeyValueRow(
                          l.description,
                          CurrencyFormatter.ugx(l.amountUgx.toDouble()),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  FinanceStatusChip.forStatus(v.status),
                  const Spacer(),
                  if (v.createdAt != null)
                    Text(
                      DateFormatter.format(v.createdAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _soon(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voucher editing is coming soon.')),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final IconData? trailingIcon;

  const _Field({required this.label, required this.value, this.trailingIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Divider(height: 1, color: AppColors.border(context)),
        ],
      ),
    );
  }
}

/// The list of existing payment vouchers, opened from the More menu.
class PaymentVouchersListScreen extends StatelessWidget {
  const PaymentVouchersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final repo = sl<BursarOpsReadRepository>();

    return FinanceScaffold(
      title: 'Payment Vouchers',
      body: StreamBuilder<List<PaymentVoucher>>(
        stream: repo.watchPaymentVouchers(schoolId),
        builder: (context, snap) {
          if (!snap.hasData) return FinanceStates.loading();
          final vouchers = snap.data!;
          if (vouchers.isEmpty) {
            return FinanceStates.empty(
              context,
              icon: Icons.description_outlined,
              title: 'No vouchers yet',
              message:
                  'Expense and payment vouchers you raise will appear here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              for (final v in vouchers)
                FinanceListRow(
                  leadingIcon: Icons.description_outlined,
                  title: '${v.number} · ${v.supplierName}',
                  subtitle: v.budgetVote,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentVoucherScreen(voucherId: v.id),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FinanceStatusChip.forStatus(v.status),
                      const SizedBox(width: AppSpacing.m),
                      Text(
                        CurrencyFormatter.ugx(v.amountUgx.toDouble()),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
