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
import 'package:school_pulse/features/finance/presentation/screens/financial_reports_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_forms.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

const _reconcileRoles = {'bursar', 'schoolAdmin'};

/// Cash & Bank tab (bottom-nav slot 3).
///
/// Till / bank / mobile-money accounts with balance + reconciliation
/// progress + unmatched counts, then a recent ledger. Data comes from
/// `schools/{id}/bank_accounts` / `schools/{id}/bank_ledger` (server-written
/// only). Tapping an account opens its reconciliation screen: match an
/// entry to a bank-statement reference or pair it with an opposite entry,
/// unmatch, and post manual adjustments — all via the
/// `finance_reconciliation.js` callables.
class BursarCashBankScreen extends StatelessWidget {
  const BursarCashBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final roles = auth is AuthAuthenticated
        ? auth.user.roles.map((r) => r.name).toSet()
        : <String>{};
    final canReconcile = roles.any(_reconcileRoles.contains);
    final repo = sl<BursarOpsReadRepository>();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.l,
        title: Text(
          'Cash & Bank',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Cashbook report',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FinancialReportsScreen()),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<BankAccount>>(
          stream: repo.watchBankAccounts(schoolId),
          builder: (context, accSnap) {
            if (!accSnap.hasData) return FinanceStates.loading();
            final accounts = accSnap.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                  'Accounts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                if (accounts.isEmpty)
                  FinanceCard(
                    child: Text(
                      'No accounts configured yet.',
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                  )
                else
                  for (final a in accounts)
                    _AccountCard(
                      account: a,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _AccountReconScreen(
                            schoolId: schoolId,
                            account: a,
                            canReconcile: canReconcile,
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 24),
                Text(
                  'Recent ledger',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<LedgerEntry>>(
                  stream: repo.watchBankLedger(schoolId),
                  builder: (context, ledSnap) {
                    final entries = ledSnap.data ?? const <LedgerEntry>[];
                    if (entries.isEmpty) {
                      return FinanceCard(
                        child: Text(
                          'No ledger entries yet.',
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      );
                    }
                    return FinanceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < entries.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                color: AppColors.border(context),
                              ),
                            _LedgerRow(entry: entries[i]),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onTap;
  const _AccountCard({required this.account, this.onTap});

  IconData get _icon => switch (account.kind) {
    'cash' => Icons.payments_outlined,
    'mobile_money' => Icons.smartphone_outlined,
    _ => Icons.account_balance_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final unmatched = account.unmatchedCount;
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 18, color: AppColors.textSecondary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  account.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.ugx(account.balanceUgx.toDouble()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Reconciliation',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
              const Spacer(),
              Text(
                unmatched > 0 ? 'Unmatched: $unmatched' : 'All matched',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: unmatched > 0
                      ? AppColors.danger(context)
                      : AppColors.success(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: account.reconciledPercent / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceContainer(context),
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primary(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${account.reconciledPercent}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final LedgerEntry entry;
  const _LedgerRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final positive = entry.amountUgx >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  '${entry.type}'
                  '${entry.date != null ? ' • ${DateFormatter.format(entry.date!)}' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '' : '- '}'
            '${CurrencyFormatter.ugx(entry.amountUgx.abs().toDouble())}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: positive
                  ? AppColors.success(context)
                  : AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Account reconciliation (audit area 4)
// ---------------------------------------------------------------------------

/// Per-account ledger with All / Unmatched tabs. Bursars can match an
/// unmatched entry (statement reference or a paired entry), unmatch a
/// wrongly-matched one, and post a manual adjustment — all callable-backed
/// via `finance_reconciliation.js`.
class _AccountReconScreen extends StatelessWidget {
  final String schoolId;
  final BankAccount account;
  final bool canReconcile;

  const _AccountReconScreen({
    required this.schoolId,
    required this.account,
    required this.canReconcile,
  });

  @override
  Widget build(BuildContext context) {
    final repo = sl<BursarOpsReadRepository>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.background(context),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            account.name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Unmatched'),
            ],
          ),
        ),
        floatingActionButton: canReconcile
            ? FloatingActionButton.extended(
                onPressed: () => _openAdjustment(context, schoolId, account),
                icon: const Icon(Icons.post_add_outlined),
                label: const Text('Adjustment'),
              )
            : null,
        body: TabBarView(
          children: [
            _LedgerList(
              schoolId: schoolId,
              account: account,
              canReconcile: canReconcile,
              stream: repo.watchBankLedger(schoolId, accountId: account.id),
            ),
            _LedgerList(
              schoolId: schoolId,
              account: account,
              canReconcile: canReconcile,
              stream: repo.watchBankLedger(
                schoolId,
                accountId: account.id,
                reconciled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerList extends StatelessWidget {
  final String schoolId;
  final BankAccount account;
  final bool canReconcile;
  final Stream<List<LedgerEntry>> stream;

  const _LedgerList({
    required this.schoolId,
    required this.account,
    required this.canReconcile,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LedgerEntry>>(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) return FinanceStates.loading();
        final entries = snap.data!;
        if (entries.isEmpty) {
          return FinanceStates.empty(
            context,
            icon: Icons.check_circle_outline,
            title: 'Nothing here',
            message: 'No matching ledger entries.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final e = entries[i];
            return FinanceCard(
              onTap: canReconcile
                  ? () => _openEntryActions(
                      context,
                      schoolId,
                      account,
                      e,
                      entries,
                    )
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          '${e.type}'
                          '${e.date != null ? ' • ${DateFormatter.format(e.date!)}' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${e.amountUgx >= 0 ? '' : '- '}'
                        '${CurrencyFormatter.ugx(e.amountUgx.abs().toDouble())}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: e.amountUgx >= 0
                              ? AppColors.success(context)
                              : AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FinanceStatusChip.forStatus(
                        e.reconciled ? 'matched' : 'unmatched',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

void _openEntryActions(
  BuildContext context,
  String schoolId,
  BankAccount account,
  LedgerEntry entry,
  List<LedgerEntry> all,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(sheetContext).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            entry.description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(sheetContext),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.ugx(entry.amountUgx.abs().toDouble()),
            style: TextStyle(color: AppColors.textMuted(sheetContext)),
          ),
          const SizedBox(height: 16),
          if (!entry.reconciled) ...[
            FinanceSubmitButton(
              label: 'Match to bank statement',
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await _openStatementMatch(context, schoolId, entry);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _openPairMatch(context, schoolId, entry, all);
              },
              child: const Text('Match to another entry'),
            ),
          ] else
            FinanceSubmitButton(
              label: 'Unmatch',
              danger: true,
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await _openUnmatch(context, schoolId, entry);
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _openStatementMatch(
  BuildContext context,
  String schoolId,
  LedgerEntry entry,
) async {
  final reference = TextEditingController();
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
            FinanceField(
              controller: reference,
              label: 'Bank statement reference',
              required: true,
            ),
            const SizedBox(height: 8),
            FinanceSubmitButton(
              label: 'Match',
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                await runFinanceAction(
                  sheetContext,
                  successMessage: 'Entry matched',
                  popOnDone: 1,
                  action: () => sl<FinanceOperationsRemoteDataSource>()
                      .matchBankLedgerEntry(
                        schoolId: schoolId,
                        entryId: entry.id,
                        statementReference: reference.text.trim(),
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

void _openPairMatch(
  BuildContext context,
  String schoolId,
  LedgerEntry entry,
  List<LedgerEntry> all,
) {
  final candidates = all
      .where(
        (e) =>
            e.id != entry.id &&
            !e.reconciled &&
            e.amountUgx == -entry.amountUgx,
      )
      .toList();
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pair with an opposite entry',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(sheetContext),
            ),
          ),
          const SizedBox(height: 12),
          if (candidates.isEmpty)
            Text(
              'No unmatched entry of the opposite sign and equal amount.',
              style: TextStyle(color: AppColors.textMuted(sheetContext)),
            )
          else
            for (final c in candidates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c.description, maxLines: 1),
                subtitle: Text(
                  c.date != null ? DateFormatter.format(c.date!) : c.type,
                ),
                trailing: Text(
                  CurrencyFormatter.ugx(c.amountUgx.abs().toDouble()),
                ),
                onTap: () => runFinanceAction(
                  sheetContext,
                  successMessage: 'Entries matched',
                  popOnDone: 1,
                  action: () => sl<FinanceOperationsRemoteDataSource>()
                      .matchBankLedgerEntry(
                        schoolId: schoolId,
                        entryId: entry.id,
                        counterEntryId: c.id,
                      ),
                ),
              ),
        ],
      ),
    ),
  );
}

Future<void> _openUnmatch(
  BuildContext context,
  String schoolId,
  LedgerEntry entry,
) async {
  final reason = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Unmatch entry'),
      content: TextField(
        controller: reason,
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
          label: 'Unmatch',
          danger: true,
          onPressed: () async {
            if (reason.text.trim().isEmpty) return;
            await runFinanceAction(
              dialogContext,
              successMessage: 'Entry unmatched',
              popOnDone: 1,
              action: () => sl<FinanceOperationsRemoteDataSource>()
                  .unmatchBankLedgerEntry(
                    schoolId: schoolId,
                    entryId: entry.id,
                    reason: reason.text.trim(),
                  ),
            );
          },
        ),
      ],
    ),
  );
}

Future<void> _openAdjustment(
  BuildContext context,
  String schoolId,
  BankAccount account,
) async {
  final amount = TextEditingController();
  final description = TextEditingController();
  final reference = TextEditingController();
  var credit = true;
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => Padding(
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
                'Manual adjustment — ${account.name}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(sheetContext),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Credit (+)')),
                  ButtonSegment(value: false, label: Text('Debit (−)')),
                ],
                selected: {credit},
                onSelectionChanged: (s) => setSheet(() => credit = s.first),
              ),
              const SizedBox(height: 12),
              FinanceField(
                controller: amount,
                label: 'Amount',
                moneyUgx: true,
                required: true,
              ),
              FinanceField(
                controller: description,
                label: 'Description',
                required: true,
              ),
              FinanceField(
                controller: reference,
                label: 'Reference',
                required: true,
              ),
              const SizedBox(height: 8),
              FinanceSubmitButton(
                label: 'Post adjustment',
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final magnitude = int.parse(amount.text.trim());
                  await runFinanceAction(
                    sheetContext,
                    successMessage: 'Adjustment posted',
                    popOnDone: 1,
                    action: () => sl<FinanceOperationsRemoteDataSource>()
                        .recordBankLedgerAdjustment(
                          schoolId: schoolId,
                          accountId: account.id,
                          amountUgx: credit ? magnitude : -magnitude,
                          description: description.text.trim(),
                          reference: reference.text.trim(),
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
