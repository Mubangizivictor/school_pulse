import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import 'fee_collection_screen.dart';
import 'expenditure_screen.dart';
import 'budget_management_screen.dart';
import 'fee_configuration_screen.dart';
import 'financial_reports_screen.dart';
import 'receipt_verification_result_screen.dart';
import 'student_eligibility_screen.dart';
import '../../../qr_scanner/presentation/screens/qr_scanner_screen.dart';
import '../../../qr_scanner/domain/entities/scanner_mode.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
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
      body: BlocListener<FinanceBloc, FinanceState>(
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
            if (state is FinanceLoading) {
              return const Center(child: SchoolPulseLoader());
            }

            if (state is FinanceError) {
              return Center(child: Text(state.message));
            }

            if (state is FinanceDashboardLoaded) {
              final authState = context.watch<AuthBloc>().state;
              final userName = authState is AuthAuthenticated
                  ? authState.user.name
                  : 'User';

              return RefreshIndicator(
                onRefresh: () async => _loadDashboard(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 48), // Space for status bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                              ),
                              onPressed: () => context.push('/staff/messages'),
                              tooltip: 'Messages',
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () =>
                                  context.push('/staff/bursar/lookup'),
                              tooltip: 'Student Balance Lookup',
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () => _scanReceipt(context),
                              tooltip: 'Verify Receipt',
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            NotificationBellButton(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildKPIs(context, state.kpis, semanticColors),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Quick Actions'),
                    QuickActionGrid(
                      items: [
                        QuickActionItem(
                          label: 'Collect Fees',
                          icon: Icons.add_card,
                          color: semanticColors.success,
                          onTap: () => _navigateToCollectFees(context),
                        ),
                        QuickActionItem(
                          label: 'Expenditure',
                          icon: Icons.outbond,
                          color: semanticColors.error,
                          onTap: () => _navigateToExpenditure(context),
                        ),
                        QuickActionItem(
                          label: 'Budgets',
                          icon: Icons.pie_chart,
                          color: semanticColors.info,
                          onTap: () => _navigateToBudgets(context),
                        ),
                        QuickActionItem(
                          label: 'Structures',
                          icon: Icons.settings_applications,
                          color: Colors.orange,
                          onTap: () => _navigateToFeeStructures(context),
                        ),
                        QuickActionItem(
                          label: 'Reports',
                          icon: Icons.assessment,
                          color: Colors.purple,
                          onTap: () => _navigateToReports(context),
                        ),
                        QuickActionItem(
                          label: 'Eligibility',
                          icon: Icons.verified_user,
                          color: Colors.teal,
                          onTap: () => _navigateToEligibility(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(
                      context,
                      state.recentTransactions,
                      semanticColors,
                    ),
                    const SizedBox(height: 24),
                    _buildPendingApprovals(
                      context,
                      state.pendingApprovals,
                      semanticColors,
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildKPIs(
    BuildContext context,
    Map<String, dynamic> kpis,
    SemanticColors colors,
  ) {
    final cards = [
      (
        'Today\'s collections',
        CurrencyFormatter.ugx(kpis['todayCollections'] ?? 0),
        Icons.today,
        colors.success,
      ),
      (
        'This term',
        CurrencyFormatter.ugx(kpis['termCollections'] ?? 0),
        Icons.date_range,
        colors.info,
      ),
      (
        'This year',
        CurrencyFormatter.ugx(kpis['yearCollections'] ?? 0),
        Icons.calendar_month,
        colors.info,
      ),
      (
        'Collection target',
        CurrencyFormatter.ugx(kpis['collectionTarget'] ?? 0),
        Icons.track_changes,
        Colors.orange,
      ),
      (
        'Target achieved',
        '${kpis['collectionPercentage'] ?? 0}%',
        Icons.donut_large,
        colors.success,
      ),
      (
        'Outstanding fees',
        CurrencyFormatter.ugx(kpis['outstandingFees'] ?? 0),
        Icons.warning_amber_rounded,
        colors.error,
      ),
      (
        'Fully paid',
        '${kpis['studentsFullyPaid'] ?? 0} students',
        Icons.verified,
        colors.success,
      ),
      (
        'Partially paid',
        '${kpis['studentsPartiallyPaid'] ?? 0} students',
        Icons.timelapse,
        Colors.orange,
      ),
      (
        'No payments',
        '${kpis['studentsWithNoPayments'] ?? 0} students',
        Icons.person_off_outlined,
        colors.error,
      ),
      (
        'Pending requests',
        '${kpis['pendingExpenditureRequests'] ?? 0}',
        Icons.pending_actions,
        Colors.orange,
      ),
      (
        'Awaiting release',
        '${kpis['approvedAwaitingRelease'] ?? 0}',
        Icons.approval,
        colors.info,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 600
                ? 3
                : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: width,
                      child: KPICard(
                        title: card.$1,
                        value: card.$2,
                        icon: card.$3,
                        color: card.$4,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Funds position',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _PositionItem(
                  'Cash',
                  kpis['cashPosition'],
                  Icons.payments_outlined,
                ),
              ),
              Expanded(
                child: _PositionItem(
                  'Bank',
                  kpis['bankPosition'],
                  Icons.account_balance_outlined,
                ),
              ),
              Expanded(
                child: _PositionItem(
                  'Mobile money',
                  kpis['mobileMoneyPosition'],
                  Icons.phone_android,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List transactions,
    SemanticColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Transactions',
          actionLabel: 'View All',
          onActionPressed: () {},
        ),
        if (transactions.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No recent transactions')),
          )
        else
          ...transactions
              .take(5)
              .map((t) => TransactionTile(transaction: t, colors: colors)),
      ],
    );
  }

  Widget _buildPendingApprovals(
    BuildContext context,
    List approvals,
    SemanticColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          actionLabel: 'Manage',
          onActionPressed: () => _navigateToExpenditure(context),
        ),
        if (approvals.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No pending expenditure requests')),
          )
        else
          ...approvals
              .take(3)
              .map((a) => ExpenditureTile(request: a, colors: colors)),
      ],
    );
  }

  void _navigateToCollectFees(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeeCollectionScreen()),
    );
  }

  void _navigateToExpenditure(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenditureScreen()),
    );
  }

  void _navigateToBudgets(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BudgetManagementScreen()),
    );
  }

  void _navigateToFeeStructures(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeeConfigurationScreen()),
    );
  }

  void _navigateToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FinancialReportsScreen()),
    );
  }

  void _navigateToEligibility(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentEligibilityScreen()),
    );
  }

  void _scanReceipt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(
          mode: ScannerMode.finance,
          onScan: (qrData) {
            context.read<FinanceBloc>().add(VerifyFinanceReceipt(qrData));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _PositionItem extends StatelessWidget {
  final String label;
  final dynamic amount;
  final IconData icon;
  const _PositionItem(this.label, this.amount, this.icon);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 6),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 3),
      FittedBox(
        child: Text(
          CurrencyFormatter.ugx(amount ?? 0),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final dynamic transaction;
  final SemanticColors colors;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.success.withValues(alpha: 0.1),
            child: Icon(Icons.arrow_downward, color: colors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student ID: ${transaction.studentId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  transaction.method,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.ugx(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.success,
                ),
              ),
              Text(
                DateFormatter.format(transaction.date),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpenditureTile extends StatelessWidget {
  final dynamic request;
  final SemanticColors colors;

  const ExpenditureTile({
    super.key,
    required this.request,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.error.withValues(alpha: 0.1),
            child: Icon(Icons.arrow_upward, color: colors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'By: ${request.requesterName}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.ugx(request.amount),
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
