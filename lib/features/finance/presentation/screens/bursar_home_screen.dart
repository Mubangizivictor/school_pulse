import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_student_lookup_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/budget_management_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/expenditure_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/financial_reports_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Finance Home dashboard (bottom-nav slot 0).
///
/// Matches the reference "Finance" screenshot: a large Total-balance header
/// with a period pill, a 2x2 KPI band (Today's collections / Fee arrears /
/// Pending approvals / Unbanked cash), a weekly cash-flow line, and a
/// Quick actions row. All figures come from the existing
/// `FinanceBloc.LoadFinanceDashboard` → `getFinancialDashboardKPIs`
/// (client-computed from `payments` + `student_financials` + `expenditures`).
class BursarHomeScreen extends StatefulWidget {
  const BursarHomeScreen({super.key});

  @override
  State<BursarHomeScreen> createState() => _BursarHomeScreenState();
}

class _BursarHomeScreenState extends State<BursarHomeScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.l,
        title: Text(
          'Finance',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading || state is FinanceInitial) {
              return FinanceStates.loading();
            }
            if (state is FinanceError) {
              return FinanceStates.error(
                context,
                state.message,
                onRetry: _load,
              );
            }
            if (state is! FinanceDashboardLoaded) {
              return const SizedBox.shrink();
            }

            final k = state.kpis;
            final totalBalance =
                _kpi(k, 'cashPosition') +
                _kpi(k, 'bankPosition') +
                _kpi(k, 'mobileMoneyPosition');

            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  AppSpacing.x3l,
                ),
                children: [
                  _BalanceHeader(total: totalBalance),
                  const SizedBox(height: AppSpacing.l),
                  _KpiBand(
                    todayCollections: _kpi(k, 'todayCollections'),
                    arrears: _kpi(k, 'outstandingFees'),
                    pendingApprovals:
                        (k['pendingExpenditureRequests'] as num?)?.toInt() ?? 0,
                    unbankedCash: _kpi(k, 'cashPosition'),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  _CashFlow(transactions: state.recentTransactions),
                  const SizedBox(height: AppSpacing.x2l),
                  const _QuickActions(),
                  const SizedBox(height: AppSpacing.x2l),
                  _RecentTransactions(transactions: state.recentTransactions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final double total;
  const _BalanceHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total balance',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.ugx(total),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'As of ${DateFormat('d MMM, h:mm a').format(DateTime.now())}',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
        ),
        const SizedBox(height: AppSpacing.m),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.s),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                'This term',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiBand extends StatelessWidget {
  final double todayCollections;
  final double arrears;
  final int pendingApprovals;
  final double unbankedCash;

  const _KpiBand({
    required this.todayCollections,
    required this.arrears,
    required this.pendingApprovals,
    required this.unbankedCash,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.m,
      mainAxisSpacing: AppSpacing.m,
      childAspectRatio: 1.55,
      children: [
        FinanceStatTile(
          label: "Today's collections",
          value: CurrencyFormatter.ugx(todayCollections),
          emphasisColor: AppColors.success(context),
        ),
        FinanceStatTile(
          label: 'Fee arrears',
          value: CurrencyFormatter.ugx(arrears),
          emphasisColor: arrears > 0 ? AppColors.danger(context) : null,
        ),
        FinanceStatTile(label: 'Pending approvals', value: '$pendingApprovals'),
        FinanceStatTile(
          label: 'Unbanked cash',
          value: CurrencyFormatter.ugx(unbankedCash),
        ),
      ],
    );
  }
}

class _CashFlow extends StatelessWidget {
  final List<PaymentRecord> transactions;
  const _CashFlow({required this.transactions});

  /// Buckets the last 7 days of recorded payments into a daily total, so the
  /// week line reflects real collections rather than a fabricated curve.
  List<double> get _weekTotals {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    final totals = List<double>.filled(7, 0);
    for (final t in transactions) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final idx = d.difference(start).inDays;
      if (idx >= 0 && idx < 7) totals[idx] += t.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final totals = _weekTotals;
    final peak = totals.fold<double>(0, (m, v) => v > m ? v : m);
    return SectionCard(
      title: 'CASH FLOW — THIS WEEK',
      child: SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: peak == 0 ? 2 : (totals[i] / peak) * 74 + 2,
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _dayLabel(i),
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(int i) {
    final d = DateTime.now().subtract(Duration(days: 6 - i));
    return DateFormat('E').format(d).substring(0, 1);
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.add_card_rounded,
        label: 'Receive\npayment',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BursarStudentLookupScreen()),
        ),
      ),
      (
        icon: Icons.people_alt_outlined,
        label: 'Student\nfees',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BursarStudentLookupScreen()),
        ),
      ),
      (
        icon: Icons.request_page_outlined,
        label: 'Expenses',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ExpenditureScreen())),
      ),
      (
        icon: Icons.pie_chart_outline_rounded,
        label: 'Budgets',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetManagementScreen()),
        ),
      ),
      (
        icon: Icons.assessment_outlined,
        label: 'Reports',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FinancialReportsScreen()),
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary(context),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
          childAspectRatio: 0.92,
          children: [
            for (final it in items)
              InkWell(
                borderRadius: AppRadius.large,
                onTap: it.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    borderRadius: AppRadius.large,
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        it.icon,
                        size: 20,
                        color: AppColors.textPrimary(context),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        it.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<PaymentRecord> transactions;
  const _RecentTransactions({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary(context),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        if (transactions.isEmpty)
          FinanceCard(
            child: Text(
              'No recent transactions.',
              style: TextStyle(color: AppColors.textMuted(context)),
            ),
          )
        else
          for (final t in transactions.take(6))
            FinanceListRow(
              leadingIcon: Icons.south_west_rounded,
              title: t.receiptNumber.isNotEmpty
                  ? 'Receipt ${t.receiptNumber}'
                  : 'Payment',
              subtitle: '${t.method} • ${DateFormatter.format(t.date)}',
              trailingText: CurrencyFormatter.ugx(t.amount),
              trailingColor: AppColors.success(context),
              showChevron: false,
            ),
      ],
    );
  }
}
