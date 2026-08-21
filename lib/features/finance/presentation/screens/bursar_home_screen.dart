import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import 'fee_collection_screen.dart';
import 'expenditure_screen.dart';
import 'fee_configuration_screen.dart';
import 'receipt_verification_result_screen.dart';
import 'bursar_report_release_screen.dart';

/// Bursar Home tab — mirrors the reference dashboard layout: greeting row
/// with Messages/Notifications, "Today's Overview" KPI band, Quick Actions,
/// Recent Transactions, Pending Approvals. Backed by the same [FinanceBloc]
/// dashboard data as the legacy dashboard screen.
class BursarHomeScreen extends StatefulWidget {
  const BursarHomeScreen({super.key});

  @override
  State<BursarHomeScreen> createState() => _BursarHomeScreenState();
}

class _BursarHomeScreenState extends State<BursarHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadFinanceDashboard(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: staffDashboardAppBar(context, roleLabel: 'Bursar'),
      body: SafeArea(
        child: BlocListener<FinanceBloc, FinanceState>(
          listener: (context, state) {
            if (state is ReceiptVerified) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReceiptVerificationResultScreen(payment: state.payment),
                ),
              );
            }
          },
          child: BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
              if (state is FinanceLoading || state is FinanceInitial) {
                return const Center(child: SchoolPulseLoader());
              }

              if (state is FinanceError) {
                return Center(child: Text(state.message));
              }

              if (state is FinanceDashboardLoaded) {
                return RefreshIndicator(
                  onRefresh: () async => _loadDashboard(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.m,
                      AppSpacing.l,
                      AppSpacing.xl,
                    ),
                    children: [
                      StaffHeroSummaryCard(
                        greetingNameFallback: 'Bursar',
                        kpis: [
                          StaffKpiData(
                            title: "Today's Collections",
                            valueText: CurrencyFormatter.ugx(
                              state.kpis['todayCollections'] ?? 0,
                            ),
                            subtitle: 'Collected today',
                            icon: Icons.savings_rounded,
                            color: AppColors.success(context),
                          ),
                          StaffKpiData(
                            title: 'Outstanding Fees',
                            valueText: CurrencyFormatter.ugx(
                              state.kpis['outstandingFees'] ?? 0,
                            ),
                            subtitle: 'Owed by students',
                            icon: Icons.stacked_line_chart_rounded,
                            color: AppColors.danger(context),
                          ),
                          StaffKpiData(
                            title: 'Pending Approvals',
                            valueText:
                                '${state.kpis['pendingExpenditureRequests'] ?? 0}',
                            subtitle: 'Expenditure requests',
                            icon: Icons.assignment_late_rounded,
                            color: AppColors.information(context),
                          ),
                          StaffKpiData(
                            title: 'Cash Position',
                            valueText: CurrencyFormatter.ugx(
                              state.kpis['cashPosition'] ?? 0,
                            ),
                            subtitle: 'On hand',
                            icon: Icons.account_balance_rounded,
                            color: AppColors.warning(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _QuickActions(),
                      const SizedBox(height: AppSpacing.xl),
                      _RecentTransactions(
                        transactions: state.recentTransactions,
                        colors: semanticColors,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _PendingApprovals(
                        approvals: state.pendingApprovals,
                        colors: semanticColors,
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: AppSpacing.s),
        QuickActionGrid(
          items: [
            QuickActionItem(
              label: 'Record\nPayment',
              icon: Icons.sync_alt_rounded,
              color: semanticColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeeCollectionScreen()),
              ),
            ),
            QuickActionItem(
              label: 'Generate\nReceipt',
              icon: Icons.receipt_long_rounded,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeeCollectionScreen()),
              ),
            ),
            QuickActionItem(
              label: 'Invoices',
              icon: Icons.description_rounded,
              color: Colors.deepPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeeCollectionScreen()),
              ),
            ),
            QuickActionItem(
              label: 'Expenditure\nRequests',
              icon: Icons.request_page_rounded,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenditureScreen()),
              ),
            ),
            QuickActionItem(
              label: 'Fee\nStructures',
              icon: Icons.fact_check_rounded,
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeeConfigurationScreen(),
                ),
              ),
            ),
            QuickActionItem(
              label: 'Report\nRelease',
              icon: Icons.lock_open_rounded,
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BursarReportReleaseScreen(),
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
  final List transactions;
  final SemanticColors colors;

  const _RecentTransactions({required this.transactions, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Transactions',
          actionLabel: 'View All',
          onActionPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeeCollectionScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        if (transactions.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(AppSpacing.l),
            child: Center(child: Text('No recent transactions')),
          )
        else
          ...transactions
              .take(4)
              .map((t) => _TransactionRow(t: t, colors: colors)),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final dynamic t;
  final SemanticColors colors;

  const _TransactionRow({required this.t, required this.colors});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.success.withValues(alpha: 0.1),
            child: Icon(Icons.arrow_downward, color: colors.success, size: 18),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student ID: ${t.studentId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(t.method, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.ugx(t.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.success,
                ),
              ),
              Text(
                DateFormatter.format(t.date),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingApprovals extends StatelessWidget {
  final List approvals;
  final SemanticColors colors;

  const _PendingApprovals({required this.approvals, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          actionLabel: 'View All',
          onActionPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenditureScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        if (approvals.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(AppSpacing.l),
            child: Center(child: Text('No pending expenditure requests')),
          )
        else
          ...approvals.take(3).map((a) => _ApprovalRow(a: a, colors: colors)),
      ],
    );
  }
}

class _ApprovalRow extends StatelessWidget {
  final dynamic a;
  final SemanticColors colors;

  const _ApprovalRow({required this.a, required this.colors});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.error.withValues(alpha: 0.1),
            child: Icon(Icons.arrow_upward, color: colors.error, size: 18),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'By: ${a.requesterName}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.ugx(a.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.error,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
