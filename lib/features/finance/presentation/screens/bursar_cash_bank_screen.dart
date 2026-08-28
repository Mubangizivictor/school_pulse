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
import 'package:school_pulse/features/finance/presentation/screens/financial_reports_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Cash & Bank tab (bottom-nav slot 3).
///
/// Read-only view matching the reference: till / bank / mobile-money
/// accounts with balance + reconciliation progress + unmatched counts, then
/// a recent ledger. Data comes from `schools/{id}/bank_accounts` and
/// `schools/{id}/bank_ledger` (server-written; the demo seed populates
/// them). Deposit / reconcile write flows land in a later phase.
class BursarCashBankScreen extends StatelessWidget {
  const BursarCashBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
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
                  for (final a in accounts) _AccountCard(account: a),
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
  const _AccountCard({required this.account});

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
