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

const _financeApproverRoles = {
  'bursar',
  'schoolAdmin',
  'headTeacher',
  'director',
};
const _financeOperatorRoles = {'bursar', 'schoolAdmin'};

/// Suppliers workspace — supplier profiles with payable balances, plus the
/// full invoice lifecycle: record → approve/reject/return → pay from a
/// bank account. Every write is a callable (`finance_operations.js`).
class BursarSuppliersScreen extends StatelessWidget {
  const BursarSuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final roles = auth is AuthAuthenticated
        ? auth.user.roles.map((r) => r.name).toSet()
        : <String>{};
    final canOperate = roles.any(_financeOperatorRoles.contains);
    final repo = sl<BursarOpsReadRepository>();

    return FinanceScaffold(
      title: 'Suppliers',
      actions: canOperate
          ? [
              IconButton(
                tooltip: 'Add supplier',
                icon: const Icon(Icons.add_business_outlined),
                onPressed: () => _openSupplierForm(context, schoolId),
              ),
            ]
          : null,
      body: StreamBuilder<List<Supplier>>(
        stream: repo.watchSuppliers(schoolId),
        builder: (context, snap) {
          if (!snap.hasData) return FinanceStates.loading();
          final suppliers = snap.data!;
          if (suppliers.isEmpty) {
            return FinanceStates.empty(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'No suppliers yet',
              message: canOperate
                  ? 'Add a supplier to start recording invoices.'
                  : 'Suppliers you pay will appear here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              for (final s in suppliers)
                FinanceListRow(
                  leadingIcon: Icons.storefront_outlined,
                  title: s.name,
                  subtitle: s.category,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _SupplierDetailScreen(
                        schoolId: schoolId,
                        supplier: s,
                        canOperate: canOperate,
                        canApprove: roles.any(_financeApproverRoles.contains),
                      ),
                    ),
                  ),
                  trailing: _PayableTag(amount: s.payableBalanceUgx),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PayableTag extends StatelessWidget {
  final int amount;
  const _PayableTag({required this.amount});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          CurrencyFormatter.ugx(amount.toDouble()),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: amount > 0
                ? AppColors.danger(context)
                : AppColors.textPrimary(context),
          ),
        ),
        Text(
          'payable',
          style: TextStyle(fontSize: 10, color: AppColors.textMuted(context)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  Supplier detail
// ---------------------------------------------------------------------------

class _SupplierDetailScreen extends StatelessWidget {
  final String schoolId;
  final Supplier supplier;
  final bool canOperate;
  final bool canApprove;

  const _SupplierDetailScreen({
    required this.schoolId,
    required this.supplier,
    required this.canOperate,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    final repo = sl<BursarOpsReadRepository>();
    return FinanceScaffold(
      title: supplier.name,
      actions: canOperate
          ? [
              IconButton(
                tooltip: 'Edit supplier',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    _openSupplierForm(context, schoolId, existing: supplier),
              ),
              IconButton(
                tooltip: 'Archive supplier',
                icon: const Icon(Icons.archive_outlined),
                onPressed: () => runFinanceAction(
                  context,
                  successMessage: 'Supplier archived',
                  popOnDone: 1,
                  action: () =>
                      sl<FinanceOperationsRemoteDataSource>().archiveSupplier(
                        schoolId: schoolId,
                        supplierId: supplier.id,
                      ),
                ),
              ),
            ]
          : null,
      bottomBar: canOperate
          ? PrimaryActionBar(
              label: 'Record invoice',
              onPressed: () => _openInvoiceForm(context, schoolId, supplier),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          SectionCard(
            child: Column(
              children: [
                KeyValueRow('Category', supplier.category),
                if (supplier.phone != null)
                  KeyValueRow('Phone', supplier.phone!),
                KeyValueRow(
                  'Payable balance',
                  CurrencyFormatter.ugx(supplier.payableBalanceUgx.toDouble()),
                  bold: true,
                  valueColor: supplier.payableBalanceUgx > 0
                      ? AppColors.danger(context)
                      : AppColors.success(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Invoices',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<SupplierInvoice>>(
            stream: repo.watchSupplierInvoices(
              schoolId,
              supplierId: supplier.id,
            ),
            builder: (context, snap) {
              final invoices = snap.data ?? const <SupplierInvoice>[];
              if (invoices.isEmpty) {
                return FinanceCard(
                  child: Text(
                    'No invoices recorded.',
                    style: TextStyle(color: AppColors.textMuted(context)),
                  ),
                );
              }
              return Column(
                children: [
                  for (final inv in invoices)
                    _InvoiceRow(
                      schoolId: schoolId,
                      invoice: inv,
                      canOperate: canOperate,
                      canApprove: canApprove,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String schoolId;
  final SupplierInvoice invoice;
  final bool canOperate;
  final bool canApprove;

  const _InvoiceRow({
    required this.schoolId,
    required this.invoice,
    required this.canOperate,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceListRow(
      leadingIcon: Icons.receipt_outlined,
      title: invoice.invoiceNumber,
      subtitle: invoice.issuedAt != null
          ? DateFormatter.format(invoice.issuedAt!)
          : invoice.category,
      showChevron: canOperate || canApprove,
      onTap: (canOperate || canApprove)
          ? () => _openInvoiceActions(
              context,
              schoolId,
              invoice,
              canOperate: canOperate,
              canApprove: canApprove,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FinanceStatusChip.forStatus(
            invoice.status == 'pending_approval' ? 'pending' : invoice.status,
          ),
          const SizedBox(width: AppSpacing.m),
          Text(
            CurrencyFormatter.ugx(invoice.amountUgx.toDouble()),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Forms
// ---------------------------------------------------------------------------

void _openSupplierForm(
  BuildContext context,
  String schoolId, {
  Supplier? existing,
}) {
  final name = TextEditingController(text: existing?.name ?? '');
  final category = TextEditingController(text: existing?.category ?? '');
  final phone = TextEditingController(text: existing?.phone ?? '');
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _Sheet(
      title: existing == null ? 'Add supplier' : 'Edit supplier',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FinanceField(controller: name, label: 'Name', required: true),
            FinanceField(controller: category, label: 'Category'),
            FinanceField(controller: phone, label: 'Phone'),
            const SizedBox(height: 8),
            FinanceSubmitButton(
              label: existing == null ? 'Add supplier' : 'Save changes',
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                await runFinanceAction(
                  sheetContext,
                  successMessage: existing == null
                      ? 'Supplier added'
                      : 'Supplier updated',
                  popOnDone: 1,
                  action: () =>
                      sl<FinanceOperationsRemoteDataSource>().saveSupplier(
                        schoolId: schoolId,
                        supplierId: existing?.id,
                        name: name.text.trim(),
                        category: category.text.trim(),
                        phone: phone.text.trim().isEmpty
                            ? null
                            : phone.text.trim(),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _openInvoiceForm(
  BuildContext context,
  String schoolId,
  Supplier supplier,
) {
  final number = TextEditingController();
  final amount = TextEditingController();
  final category = TextEditingController(text: supplier.category);
  final reference = TextEditingController();
  DateTime? issuedAt;
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => _Sheet(
        title: 'Record invoice — ${supplier.name}',
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FinanceField(
                controller: number,
                label: 'Invoice number',
                required: true,
              ),
              FinanceField(
                controller: amount,
                label: 'Amount',
                moneyUgx: true,
                required: true,
              ),
              FinanceField(controller: category, label: 'Category'),
              FinanceField(controller: reference, label: 'Reference / notes'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  issuedAt == null
                      ? 'Invoice date (optional)'
                      : 'Invoice date: ${DateFormatter.format(issuedAt!)}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: sheetContext,
                    initialDate: issuedAt ?? now,
                    firstDate: DateTime(now.year - 2),
                    lastDate: DateTime(now.year + 1),
                  );
                  if (picked != null) setSheet(() => issuedAt = picked);
                },
              ),
              const SizedBox(height: 8),
              FinanceSubmitButton(
                label: 'Record invoice',
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  await runFinanceAction(
                    sheetContext,
                    successMessage: 'Invoice recorded — pending approval',
                    popOnDone: 1,
                    action: () => sl<FinanceOperationsRemoteDataSource>()
                        .recordSupplierInvoice(
                          schoolId: schoolId,
                          supplierId: supplier.id,
                          invoiceNumber: number.text.trim(),
                          amountUgx: int.parse(amount.text.trim()),
                          category: category.text.trim().isEmpty
                              ? null
                              : category.text.trim(),
                          reference: reference.text.trim().isEmpty
                              ? null
                              : reference.text.trim(),
                          issuedAt: issuedAt,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _openInvoiceActions(
  BuildContext context,
  String schoolId,
  SupplierInvoice invoice, {
  required bool canOperate,
  required bool canApprove,
}) {
  final ops = sl<FinanceOperationsRemoteDataSource>();
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => _Sheet(
      title: 'Invoice ${invoice.invoiceNumber}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyValueRow('Supplier', invoice.supplierName),
          KeyValueRow(
            'Amount',
            CurrencyFormatter.ugx(invoice.amountUgx.toDouble()),
            bold: true,
          ),
          KeyValueRow('Status', invoice.status.replaceAll('_', ' ')),
          const SizedBox(height: 12),
          if (canApprove && invoice.isPendingApproval) ...[
            FinanceSubmitButton(
              label: 'Approve',
              onPressed: () => runFinanceAction(
                sheetContext,
                successMessage: 'Invoice approved',
                popOnDone: 1,
                action: () => ops.decideSupplierInvoice(
                  schoolId: schoolId,
                  invoiceId: invoice.id,
                  decision: 'approve',
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _openDecisionComment(
                sheetContext,
                schoolId,
                invoice,
                'return',
              ),
              child: const Text('Return for changes'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger(sheetContext),
              ),
              onPressed: () => _openDecisionComment(
                sheetContext,
                schoolId,
                invoice,
                'reject',
              ),
              child: const Text('Reject'),
            ),
          ],
          if (canOperate && invoice.isPayable)
            FinanceSubmitButton(
              label: 'Pay this invoice',
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await _openPayInvoice(context, schoolId, invoice);
              },
            ),
          if (!invoice.isPendingApproval && !invoice.isPayable)
            Text(
              'No actions available for a ${invoice.status.replaceAll('_', ' ')} invoice.',
              style: TextStyle(color: AppColors.textMuted(sheetContext)),
            ),
        ],
      ),
    ),
  );
}

void _openDecisionComment(
  BuildContext context,
  String schoolId,
  SupplierInvoice invoice,
  String decision,
) {
  final comment = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(decision == 'reject' ? 'Reject invoice' : 'Return invoice'),
      content: TextField(
        controller: comment,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Reason (required)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FinanceSubmitButton(
          label: decision == 'reject' ? 'Reject' : 'Return',
          danger: decision == 'reject',
          onPressed: () async {
            if (comment.text.trim().isEmpty) return;
            await runFinanceAction(
              dialogContext,
              successMessage: decision == 'reject'
                  ? 'Invoice rejected'
                  : 'Invoice returned',
              popOnDone: 2,
              action: () =>
                  sl<FinanceOperationsRemoteDataSource>().decideSupplierInvoice(
                    schoolId: schoolId,
                    invoiceId: invoice.id,
                    decision: decision,
                    comment: comment.text.trim(),
                  ),
            );
          },
        ),
      ],
    ),
  );
}

Future<void> _openPayInvoice(
  BuildContext context,
  String schoolId,
  SupplierInvoice invoice,
) async {
  final accounts = await sl<BursarOpsReadRepository>()
      .watchBankAccounts(schoolId)
      .first;
  final payable = accounts
      .where((a) => a.kind == 'bank' || a.kind == 'cash')
      .toList();
  if (!context.mounted) return;
  if (payable.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No cash or bank account to pay from.')),
    );
    return;
  }
  String accountId = payable.first.id;
  final reference = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => _Sheet(
        title: 'Pay ${invoice.invoiceNumber}',
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KeyValueRow(
                'Amount',
                CurrencyFormatter.ugx(invoice.amountUgx.toDouble()),
                bold: true,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: accountId,
                decoration: const InputDecoration(
                  labelText: 'Pay from',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final a in payable)
                    DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        '${a.name} · ${CurrencyFormatter.ugx(a.balanceUgx.toDouble())}',
                      ),
                    ),
                ],
                onChanged: (v) => setSheet(() => accountId = v ?? accountId),
              ),
              const SizedBox(height: 12),
              FinanceField(
                controller: reference,
                label: 'Payment reference',
                required: true,
              ),
              const SizedBox(height: 8),
              FinanceSubmitButton(
                label: 'Confirm payment',
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  await runFinanceAction(
                    sheetContext,
                    successMessage: 'Invoice paid',
                    popOnDone: 1,
                    action: () => sl<FinanceOperationsRemoteDataSource>()
                        .paySupplierInvoice(
                          schoolId: schoolId,
                          invoiceId: invoice.id,
                          accountId: accountId,
                          paymentReference: reference.text.trim(),
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _Sheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
