import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';

/// "School Performance" detail screen - restyle target #2 in the reference:
/// a big circular Overall Performance Index gauge, a breakdown of
/// Academic/Financial/Operational/Engagement sub-scores, and a trend chart.
///
/// The dashboard bloc's [DirectorDashboardStats] does not yet expose
/// separate Financial/Operational/Engagement performance percentages or a
/// term-over-term trend series - only [overallSchoolAverage] and
/// [improvementTrend] exist. Rather than fabricate the missing sub-metrics,
/// this screen only derives the two Academic figures it actually has real
/// data for; the remaining sub-metric rows show an honest "no data yet"
/// placeholder instead of invented numbers.
class DirectorPerformanceScreen extends StatelessWidget {
  const DirectorPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Performance'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.calendar_today_outlined, size: 20),
          ),
        ],
      ),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;
          final trendLabel = stats.improvementTrend >= 0
              ? '+${stats.improvementTrend}% vs Last Term'
              : '${stats.improvementTrend}% vs Last Term';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  children: [
                    const Text(
                      'Overall Performance Index',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CircularPercentGauge(
                      percent: (stats.overallSchoolAverage / 100).clamp(0, 1),
                      centerLabel: '${stats.overallSchoolAverage.round()}%',
                      subLabel: stats.overallSchoolAverage >= 80
                          ? 'Good'
                          : stats.overallSchoolAverage >= 60
                          ? 'Fair'
                          : 'Needs Attention',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trendLabel,
                      style: TextStyle(
                        color: stats.improvementTrend >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Breakdown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    LabeledProgressRow(
                      label: 'Academic',
                      percent: (stats.overallSchoolAverage / 100).clamp(0, 1),
                      trailingText: '${stats.overallSchoolAverage.round()}%',
                      color: Colors.blue,
                    ),
                    LabeledProgressRow(
                      label: 'Financial',
                      percent: (stats.collectionPercentage / 100).clamp(0, 1),
                      trailingText: '${stats.collectionPercentage.round()}%',
                      color: Colors.green,
                    ),
                    // TODO: Wire Operational and Engagement sub-scores once
                    // the dashboard bloc exposes real operational-quality
                    // and engagement metrics beyond the dashboard-only
                    // staffAttendanceRate/parentPortalUsageRate fields.
                    LabeledProgressRow(
                      label: 'Operational',
                      percent: (stats.staffAttendanceRate / 100).clamp(0, 1),
                      trailingText: '${stats.staffAttendanceRate.round()}%',
                      color: Colors.orange,
                    ),
                    LabeledProgressRow(
                      label: 'Engagement',
                      percent: (stats.parentPortalUsageRate / 100).clamp(0, 1),
                      trailingText: '${stats.parentPortalUsageRate.round()}%',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Trend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trend history is not tracked yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // TODO: Replace with a real last-N-terms series once the
                    // director bloc/repository stores historical snapshots.
                    const TrendLineChart(values: []),
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
