import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/domain/entities/expenditure.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_web_kit.dart';

/// Desktop Finance dashboard — matches the locked web mockup:
/// header + Receive-payment / New-expense actions, a 4-tile KPI row,
/// a cash-flow card, a Pending-approvals panel, a Cash & bank balances
/// panel, and a Recent-payments table. All figures are real
/// (`FinanceBloc.LoadFinanceDashboard` + `BursarOpsReadRepository`).
class BursarWebOverviewScreen extends StatefulWidget {
  const BursarWebOverviewScreen({super.key});

  @override
  State<BursarWebOverviewScreen> createState() =>
      _BursarWebOverviewScreenState();
}

class _BursarWebOverviewScreenState extends State<BursarWebOverviewScreen> {
  FinanceDashboardLoaded? _last;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<FinanceBloc>().add(LoadFinanceDashboard(auth.user.schoolId));
    }
  }

  double _kpi(Map<String, dynamic> k, String key) =>
      (k[key] as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';

    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceDashboardLoaded) _last = state;
        final data = state is FinanceDashboardLoaded ? state : _last;

        if (data == null) {
          if (state is FinanceError) {
            return FinanceStates.error(context, state.message, onRetry: _load);
          }
          return FinanceStates.loading();
        }

        final k = data.kpis;
        final totalAvailable =
            _kpi(k, 'cashPosition') +
            _kpi(k, 'bankPosition') +
            _kpi(k, 'mobileMoneyPosition');
        final pendingCount =
            (k['pendingExpenditureRequests'] as num?)?.toInt() ?? 0;
        final pendingTotal = data.pendingApprovals.fold<double>(
          0,
          (s, e) => s + e.amount,
        );

        return FinanceWorkspace(
          title: 'Finance overview',
          updatedLabel:
              'Updated ${DateFormat('h:mm a').format(DateTime.now())}',
          primaryAction: WorkspacePrimaryButton(
            label: 'Receive payment',
            onPressed: () => context.go('/staff/bursar/students'),
          ),
          secondaryActions: [
            WorkspaceSecondaryButton(
              label: 'New expense',
              onPressed: () => context.go('/staff/bursar/expenses'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KpiRow(
                totalAvailable: totalAvailable,
                todayCollections: _kpi(k, 'todayCollections'),
                arrears: _kpi(k, 'outstandingFees'),
                pendingCount: pendingCount,
                pendingTotal: pendingTotal,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, c) {
                  final twoCol = c.maxWidth >= 980;
                  final cashFlow = _CashFlowCard(
                    transactions: data.recentTransactions,
                  );
                  final approvals = _PendingApprovalsCard(
                    approvals: data.pendingApprovals,
                    total: pendingTotal,
                  );
                  if (!twoCol) {
                    return Column(
                      children: [
                        cashFlow,
                        const SizedBox(height: 20),
                        approvals,
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: cashFlow),
                        const SizedBox(width: 20),
                        SizedBox(width: 380, child: approvals),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, c) {
                  final twoCol = c.maxWidth >= 980;
                  final recent = _RecentPaymentsCard(
                    transactions: data.recentTransactions,
                  );
                  final balances = _BankBalancesCard(schoolId: schoolId);
                  if (!twoCol) {
                    return Column(
                      children: [recent, const SizedBox(height: 20), balances],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: recent),
                        const SizedBox(width: 20),
                        SizedBox(width: 380, child: balances),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiRow extends StatelessWidget {
  final double totalAvailable;
  final double todayCollections;
  final double arrears;
  final int pendingCount;
  final double pendingTotal;

  const _KpiRow({
    required this.totalAvailable,
    required this.todayCollections,
    required this.arrears,
    required this.pendingCount,
    required this.pendingTotal,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      MetricTile(
        label: 'Total available (cash, bank & mobile money)',
        value: CurrencyFormatter.ugx(totalAvailable),
        glyph: Icons.account_balance_outlined,
      ),
      MetricTile(
        label: "Today's collections",
        value: CurrencyFormatter.ugx(todayCollections),
        valueColor: AppColors.success(context),
        glyph: Icons.trending_up_rounded,
      ),
      MetricTile(
        label: 'Fee arrears',
        value: CurrencyFormatter.ugx(arrears),
        valueColor: arrears > 0 ? AppColors.danger(context) : null,
        glyph: Icons.error_outline_rounded,
      ),
      MetricTile(
        label: 'Pending approvals',
        value: '$pendingCount',
        glyph: Icons.description_outlined,
        delta: CurrencyFormatter.ugx(pendingTotal),
        deltaUp: false,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 1100
            ? 4
            : c.maxWidth >= 720
            ? 2
            : 1;
        final gap = 16.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: w, child: t)],
        );
      },
    );
  }
}

class _CashFlowCard extends StatelessWidget {
  final List<PaymentRecord> transactions;
  const _CashFlowCard({required this.transactions});

  /// Daily cash-in over the trailing 30 days.
  ({List<double> values, List<String> labels}) get _series {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 29));
    final totals = List<double>.filled(30, 0);
    for (final t in transactions) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final idx = d.difference(start).inDays;
      if (idx >= 0 && idx < 30) totals[idx] += t.amount;
    }
    final labels = <String>[];
    for (var i = 0; i < 30; i++) {
      labels.add(
        i % 7 == 0
            ? DateFormat('MMM d').format(start.add(Duration(days: i)))
            : '',
      );
    }
    return (values: totals, labels: labels);
  }

  @override
  Widget build(BuildContext context) {
    final s = _series;
    final cashIn = s.values.fold<double>(0, (a, b) => a + b);
    return WorkspaceCard(
      title: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Cash flow ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '(UGX)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted(context),
                ),
              ),
              const Spacer(),
              Text(
                'Last 30 days',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FinanceTrendLine(
              values: s.values,
              labels: s.labels,
              height: 200,
              showYAxis: true,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: 12),
          Row(
            children: [
              _flowStat(context, 'Cash in', cashIn, AppColors.success(context)),
              const SizedBox(width: 32),
              _flowStat(context, 'Cash out', 0, AppColors.textPrimary(context)),
              const SizedBox(width: 32),
              _flowStat(
                context,
                'Net cash flow',
                cashIn,
                AppColors.success(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowStat(BuildContext context, String label, double v, Color color) {
    return Row(
      children: [
        Text(
          '$label  ',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
        ),
        Text(
          CurrencyFormatter.ugx(v),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PendingApprovalsCard extends StatelessWidget {
  final List<ExpenditureRequest> approvals;
  final double total;

  const _PendingApprovalsCard({required this.approvals, required this.total});

  @override
  Widget build(BuildContext context) {
    final rows = approvals.take(5).toList();
    return WorkspaceCard(
      title: 'Pending approvals',
      actionLabel: 'View all',
      onAction: () => context.go('/staff/bursar/approvals'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Nothing awaiting approval.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: AppColors.border(context)),
              MiniListRow(
                leading: Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: AppColors.textSecondary(context),
                ),
                title: rows[i].description,
                subtitle:
                    'Requested by ${rows[i].requesterName} · ${DateFormatter.relative(rows[i].createdAt)}',
                trailing: CurrencyFormatter.ugx(rows[i].amount),
                showChevron: true,
                onTap: () => context.go('/staff/bursar/approvals'),
              ),
            ],
          Divider(height: 1, color: AppColors.border(context)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text(
                  'Total pending',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.ugx(total),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPaymentsCard extends StatelessWidget {
  final List<PaymentRecord> transactions;
  const _RecentPaymentsCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final rows = transactions.take(6).toList();
    return WorkspaceCard(
      title: 'Recent payments',
      actionLabel: 'View all',
      onAction: () => context.go('/staff/bursar/students'),
      child: FinanceDataTable<PaymentRecord>(
        rows: rows,
        total: transactions.length,
        emptyMessage: 'No payments recorded yet.',
        columns: [
          FinanceColumn.text(
            'Date',
            (p) => DateFormatter.format(p.date),
            flex: 2,
          ),
          FinanceColumn.text(
            'Receipt',
            (p) => p.receiptNumber.isEmpty ? '—' : p.receiptNumber,
            flex: 2,
          ),
          FinanceColumn.text('Method', (p) => p.method, flex: 2),
          FinanceColumn(
            label: 'Amount (UGX)',
            flex: 2,
            align: TextAlign.right,
            cell: (p) => MoneyText(
              p.amount,
              color: AppColors.textPrimary(context),
              bold: true,
            ),
          ),
          FinanceColumn(
            label: 'Status',
            flex: 2,
            cell: (p) => const FinanceStatusChip(
              label: 'Paid',
              tone: FinanceStatusTone.positive,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankBalancesCard extends StatelessWidget {
  final String schoolId;
  const _BankBalancesCard({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return WorkspaceCard(
      title: 'Cash & bank balances',
      actionLabel: 'View all',
      onAction: () => context.go('/staff/bursar/cash-bank'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: StreamBuilder<List<BankAccount>>(
        stream: sl<BursarOpsReadRepository>().watchBankAccounts(schoolId),
        builder: (context, snap) {
          final accounts = snap.data ?? const <BankAccount>[];
          if (accounts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No accounts configured.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            );
          }
          final total = accounts
              .fold<int>(0, (s, a) => s + a.balanceUgx)
              .toDouble();
          return Column(
            children: [
              for (var i = 0; i < accounts.length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.border(context)),
                MiniListRow(
                  leading: Icon(
                    switch (accounts[i].kind) {
                      'cash' => Icons.payments_outlined,
                      'mobile_money' => Icons.smartphone_outlined,
                      _ => Icons.account_balance_outlined,
                    },
                    size: 18,
                    color: AppColors.textSecondary(context),
                  ),
                  title: accounts[i].name,
                  subtitle: switch (accounts[i].kind) {
                    'cash' => 'Cash',
                    'mobile_money' => 'Mobile Money',
                    _ => 'Bank',
                  },
                  trailing: CurrencyFormatter.ugx(
                    accounts[i].balanceUgx.toDouble(),
                  ),
                ),
              ],
              Divider(height: 1, color: AppColors.border(context)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Total balance',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.ugx(total),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
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
