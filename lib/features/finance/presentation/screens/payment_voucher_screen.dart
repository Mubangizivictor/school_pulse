import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_operations_remote_data_source.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_forms.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

const _voucherOperatorRoles = {
  'bursar',
  'schoolAdmin',
  'headTeacher',
  'director',
};

/// Payment Voucher detail.
///
/// Shows a voucher (supplier, amount, budget vote, funding account,
/// attachment, approval route, narration, line items) and a
/// status-contextual action: submit a draft/returned voucher for approval,
/// or mark an approved voucher paid (reference + proof). Backed by the
/// `payment_vouchers.js` callables. Opened from the Payment Vouchers list.
class PaymentVoucherScreen extends StatefulWidget {
  final String voucherId;
  const PaymentVoucherScreen({super.key, required this.voucherId});

  @override
  State<PaymentVoucherScreen> createState() => _PaymentVoucherScreenState();
}

class _PaymentVoucherScreenState extends State<PaymentVoucherScreen> {
  Future<PaymentVoucher?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final auth = context.read<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    setState(() {
      _future = sl<BursarOpsReadRepository>().getPaymentVoucher(
        schoolId,
        widget.voucherId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final canOperate =
        auth is AuthAuthenticated &&
        auth.user.roles.map((r) => r.name).any(_voucherOperatorRoles.contains);

    return FinanceScaffold(
      title: 'Payment Voucher',
      body: FutureBuilder<PaymentVoucher?>(
        future: _future,
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
          return _VoucherBody(
            voucher: v,
            schoolId: schoolId,
            canOperate: canOperate,
            onChanged: _load,
          );
        },
      ),
    );
  }
}

class _VoucherBody extends StatelessWidget {
  final PaymentVoucher voucher;
  final String schoolId;
  final bool canOperate;
  final VoidCallback onChanged;

  const _VoucherBody({
    required this.voucher,
    required this.schoolId,
    required this.canOperate,
    required this.onChanged,
  });

  bool get _canSubmit =>
      voucher.status == 'draft' || voucher.status == 'returned';
  bool get _canPay => voucher.status == 'approved';

  @override
  Widget build(BuildContext context) {
    final v = voucher;
    final body = ListView(
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
        _Field(label: 'Approval Route', value: v.approvalRoute.join('  →  ')),
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

    if (!canOperate || (!_canSubmit && !_canPay)) return body;
    return Column(
      children: [
        Expanded(child: body),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: _canSubmit
                ? FinanceSubmitButton(
                    label: 'Submit for approval',
                    onPressed: () => runFinanceAction(
                      context,
                      successMessage: 'Voucher submitted for approval',
                      action: () => sl<FinanceOperationsRemoteDataSource>()
                          .submitPaymentVoucher(
                            schoolId: schoolId,
                            voucherId: v.id,
                          ),
                    ).then((_) => onChanged()),
                  )
                : FinanceSubmitButton(
                    label: 'Mark paid',
                    onPressed: () => _openMarkPaid(context, v),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMarkPaid(BuildContext context, PaymentVoucher v) async {
    final reference = TextEditingController();
    final proof = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mark ${v.number} paid',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(sheetContext),
                ),
              ),
              const SizedBox(height: 12),
              FinanceField(
                controller: reference,
                label: 'Payment reference',
                required: true,
              ),
              FinanceField(
                controller: proof,
                label: 'Proof attachment path',
                required: true,
                hint: 'e.g. gs://…/vouchers/${v.id}/proof.pdf',
              ),
              const SizedBox(height: 8),
              FinanceSubmitButton(
                label: 'Confirm payment',
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  await runFinanceAction(
                    sheetContext,
                    successMessage: 'Voucher marked paid',
                    popOnDone: 1,
                    action: () =>
                        sl<FinanceOperationsRemoteDataSource>().markVoucherPaid(
                          schoolId: schoolId,
                          voucherId: v.id,
                          paymentReference: reference.text.trim(),
                          proofPath: proof.text.trim(),
                        ),
                  );
                  onChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
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
