import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_shell.dart';
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

class _BursarHomeScreenState extends State<BursarHomeScreen>
    with WidgetsBindingObserver {
  /// The last dashboard payload we successfully rendered. Kept so that when
  /// another Bursar screen drives the shared [FinanceBloc] to a non-dashboard
  /// state (e.g. `FinanceActionSuccess` after recording a payment, or
  /// `ExpendituresLoaded` from the Approvals tab), returning to Home shows
  /// the previous figures instead of a blank page while a fresh load runs.
  FinanceDashboardLoaded? _lastLoaded;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch whenever this tab is (re)shown and the shared bloc has drifted
    // off a dashboard state - the IndexedStack keeps us alive so initState
    // won't fire again.
    final state = context.read<FinanceBloc>().state;
    if (state is! FinanceDashboardLoaded && state is! FinanceLoading) {
      _load();
    }
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
      appBar: bursarAppBar(context),
      body: SafeArea(
        top: false,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceDashboardLoaded) {
              _lastLoaded = state;
            }

            // Prefer the freshest dashboard data; fall back to the last one
            // we rendered so a shared-bloc detour never blanks the tab.
            final loaded = state is FinanceDashboardLoaded
                ? state
                : _lastLoaded;

            if (loaded == null) {
              if (state is FinanceError) {
                return FinanceStates.error(
                  context,
                  state.message,
                  onRetry: _load,
                );
              }
              return FinanceStates.loading();
            }

            final data = loaded;
            final k = data.kpis;
            final totalAvailable =
                _kpi(k, 'cashPosition') +
                _kpi(k, 'bankPosition') +
                _kpi(k, 'mobileMoneyPosition');
            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  const _OverviewHeader(),
                  const SizedBox(height: 20),
                  _TotalAvailableCard(amount: totalAvailable),
                  const SizedBox(height: 16),
                  _KpiBand(
                    todayCollections: _kpi(k, 'todayCollections'),
                    arrears: _kpi(k, 'outstandingFees'),
                    pendingApprovals:
                        (k['pendingExpenditureRequests'] as num?)?.toInt() ?? 0,
                    unbankedCash: _kpi(k, 'cashPosition'),
                  ),
                  const SizedBox(height: 28),
                  _CashFlow(transactions: data.recentTransactions),
                  const SizedBox(height: 28),
                  const _QuickActions(),
                  const SizedBox(height: 24),
                  _RecentTransactions(transactions: data.recentTransactions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A small "Finance overview" label + a black-filled period pill.
class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader();

  String get _termLabel {
    final now = DateTime.now();
    final term = now.month <= 4
        ? 1
        : now.month <= 8
        ? 2
        : 3;
    return 'Term $term, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Finance overview',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _termLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background(context),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.background(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The reference "Total available" card: label, sub-caption, big amount,
/// and a wallet glyph in a grey rounded square top-right.
class _TotalAvailableCard extends StatelessWidget {
  final double amount;
  const _TotalAvailableCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total available',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Across cash, bank & mobile money',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted(context),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  CurrencyFormatter.ugx(amount),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
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
    final tiles = [
      _KpiCard(
        label: "Today's collections",
        value: CurrencyFormatter.ugx(todayCollections),
        valueColor: AppColors.success(context),
        icon: Icons.info_outline_rounded,
        delta: 'vs yesterday  ${CurrencyFormatter.ugx(0)}',
      ),
      _KpiCard(
        label: 'Fee arrears',
        value: CurrencyFormatter.ugx(arrears),
        valueColor: arrears > 0 ? AppColors.danger(context) : null,
        icon: Icons.people_outline_rounded,
        delta: 'vs yesterday  ${CurrencyFormatter.ugx(0)}',
      ),
      _KpiCard(
        label: 'Pending approvals',
        value: '$pendingApprovals',
        icon: Icons.assignment_outlined,
        delta: 'vs yesterday  0',
      ),
      _KpiCard(
        label: 'Unbanked cash',
        value: CurrencyFormatter.ugx(unbankedCash),
        icon: Icons.account_balance_wallet_outlined,
        delta: 'vs yesterday  ${CurrencyFormatter.ugx(0)}',
      ),
    ];
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: 12),
              Expanded(child: tiles[1]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[2]),
              const SizedBox(width: 12),
              Expanded(child: tiles[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData icon;
  final String delta;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.delta,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Icon(icon, size: 15, color: AppColors.textMuted(context)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: valueColor ?? AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            delta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
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

  List<String> get _dayLabels => [
    for (var i = 0; i < 7; i++)
      DateFormat(
        'E',
      ).format(DateTime.now().subtract(Duration(days: 6 - i))).substring(0, 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cash flow',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'This week',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted(context),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'UGX',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        FinanceCard(
          padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
          child: FinanceTrendLine(
            values: _weekTotals,
            labels: _dayLabels,
            height: 180,
            showYAxis: true,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.add_card_outlined,
        label: 'Receive\npayment',
        onTap: () => BursarShellNav.goToTab(context, 1),
      ),
      (
        icon: Icons.receipt_long_outlined,
        label: 'Student\nfees',
        onTap: () => BursarShellNav.goToTab(context, 1),
      ),
      (
        icon: Icons.verified_outlined,
        label: 'Approvals',
        onTap: () => BursarShellNav.goToTab(context, 2),
      ),
      (
        icon: Icons.account_balance_outlined,
        label: 'Cash &\nbank',
        onTap: () => BursarShellNav.goToTab(context, 3),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        FinanceCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border(context),
                  ),
                Expanded(
                  child: InkWell(
                    onTap: items[i].onTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 22,
                          color: AppColors.textPrimary(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          items[i].label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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
