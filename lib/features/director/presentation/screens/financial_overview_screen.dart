import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "Financial Overview" screen from the reference design: a fee Collection
/// Summary banner, a Revenue Overview card, and an Expense Overview card.
///
/// [DirectorDashboardStats] carries the current collection/revenue/expense
/// totals but no monthly-bucketed history or year-over-year deltas, so the
/// monthly bar chart and YoY comparisons from the reference are intentionally
/// left as an honest empty state (see TODO) rather than inventing numbers.
class FinancialOverviewScreen extends StatelessWidget {
  const FinancialOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Financial Overview')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;
          final semantic = Theme.of(context).extension<SemanticColors>()!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.x3l,
            ),
            children: [
              AppCard(
                color: semantic.success,
                borderColor: semantic.success,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: semantic.success),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          'Collection Summary — ${stats.currentTerm}, ${stats.activeAcademicYear}',
                          style: TextStyle(
                            color: semantic.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _MoneyRow(
                      label: 'Expected Fees',
                      value: stats.expectedFees,
                    ),
                    _MoneyRow(
                      label: 'Collected Fees',
                      value: stats.collectedFees,
                    ),
                    _MoneyRow(
                      label: 'Outstanding Fees',
                      value: stats.outstandingFees,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    LabeledProgressRow(
                      label: 'Collection Percentage',
                      percent: stats.collectionPercentage / 100,
                      color: semantic.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Revenue Overview — This Year'),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.yearRevenue.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Total revenue this year',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    // TODO: Wire to a real monthly revenue breakdown once the
                    // director module exposes month-bucketed revenue history.
                    // An honest empty state replaces the reference design's
                    // fabricated Jan-Jun monthly bar chart.
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Monthly revenue breakdown not available yet',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Expense Overview — This Year'),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.totalExpenditure.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Total expenditure this year',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    LabeledProgressRow(
                      label: 'Budget Utilization',
                      percent: stats.budgetUtilization / 100,
                      color: semantic.warning,
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

class _MoneyRow extends StatelessWidget {
  final String label;
  final double value;

  const _MoneyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value.toStringAsFixed(0),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
