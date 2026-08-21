import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "Finance Analytics" screen from the reference: Revenue / Expenses / Budget
/// segmented tabs, each showing a headline figure and a trend chart.
///
/// [DirectorDashboardStats] exposes only point-in-time totals (no monthly
/// series, no year-over-year deltas, no budget-by-category breakdown), so
/// each tab shows the one real figure it has and an honest "not tracked yet"
/// placeholder where the reference shows a fabricated trend line.
class FinanceAnalyticsScreen extends StatefulWidget {
  const FinanceAnalyticsScreen({super.key});

  @override
  State<FinanceAnalyticsScreen> createState() => _FinanceAnalyticsScreenState();
}

class _FinanceAnalyticsScreenState extends State<FinanceAnalyticsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Finance Analytics')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;
          final semantic = Theme.of(context).extension<SemanticColors>()!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.l, AppSpacing.xl, AppSpacing.x3l),
            children: [
              SegmentedTabControl(
                labels: const ['Revenue', 'Expenses', 'Budget'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_tab == 0) ...[
                const SectionHeader(title: 'Revenue Trend — This Year'),
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
                      // TODO: Wire to a real monthly revenue series once the
                      // director module tracks month-bucketed history.
                      const TrendLineChart(values: []),
                    ],
                  ),
                ),
              ] else if (_tab == 1) ...[
                const SectionHeader(title: 'Expense Trend — This Year'),
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
                      const SizedBox(height: AppSpacing.l),
                      // TODO: Wire to a real monthly expense series once the
                      // director module tracks month-bucketed history.
                      const TrendLineChart(values: []),
                    ],
                  ),
                ),
              ] else ...[
                const SectionHeader(title: 'Collection Trend — This Year'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.collectionPercentage}%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Fee collection percentage',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      LabeledProgressRow(
                        label: 'Budget Utilization',
                        percent: (stats.budgetUtilization / 100).clamp(0, 1),
                        trailingText: '${stats.budgetUtilization}%',
                        color: semantic.warning,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      // TODO: Wire to a real collection-trend series once the
                      // director module tracks month-bucketed history.
                      const TrendLineChart(values: []),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
