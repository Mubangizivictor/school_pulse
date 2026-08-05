import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

class StudentFeesScreen extends StatelessWidget {
  const StudentFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('School Fees')),
      body: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
        builder: (context, selectedState) {
          if (selectedState is! SelectedStudentLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, financeState) {
              if (financeState is FinanceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (financeState is FinanceLoaded) {
                final feeItems = financeState.fees;
                final totalBalance = feeItems
                    .where((item) => item.status != FeeStatus.paid)
                    .fold(0.0, (sum, item) => sum + item.amount);

                if (feeItems.isEmpty) {
                  return const EmptyState(
                    title: 'No fee records',
                    message: 'Your fee information will appear here.',
                    icon: Icons.account_balance_wallet_outlined,
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          Text(
                            'Outstanding Balance',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'UGX ${NumberFormat('#,###').format(totalBalance)}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: totalBalance > 0
                                      ? semanticColors.warning
                                      : semanticColors.success,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Fee Breakdown'),
                    ...feeItems.map(
                      (item) => _buildFeeItemRow(context, item, semanticColors),
                    ),
                  ],
                );
              }

              return const Center(child: Text('Could not load fees'));
            },
          );
        },
      ),
    );
  }

  Widget _buildFeeItemRow(
    BuildContext context,
    FeeItem item,
    SemanticColors colors,
  ) {
    Color statusColor;
    String statusLabel;

    switch (item.status) {
      case FeeStatus.paid:
        statusColor = colors.success;
        statusLabel = 'Paid';
        break;
      case FeeStatus.due:
        statusColor = colors.warning;
        statusLabel = 'Due';
        break;
      case FeeStatus.overdue:
        statusColor = colors.error;
        statusLabel = 'Overdue';
        break;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Due: ${DateFormat('dd MMM yyyy').format(item.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'UGX ${NumberFormat('#,###').format(item.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
        ],
      ),
    );
  }
}
