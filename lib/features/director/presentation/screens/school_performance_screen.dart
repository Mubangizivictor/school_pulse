import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "School Performance" screen from the reference design: a big circular
/// Overall Performance Index gauge, a 4-metric breakdown, and a trend chart.
///
/// [DirectorDashboardStats] only exposes a single [overallSchoolAverage] and
/// [improvementTrend] figure plus a handful of adjacent metrics (collection
/// percentage, budget utilization, staff attendance, parent portal usage) -
/// there is no distinct "Operational" sub-score in the domain model. Rather
/// than invent one, this screen composes the breakdown from the real metrics
/// that already exist on the stats object and labels them accordingly, and
/// the "Performance Trend" chart is intentionally omitted (see TODO below)
/// since the bloc does not expose historical term-over-term data.
class SchoolPerformanceScreen extends StatelessWidget {
  const SchoolPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('School Performance')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;
          final isPositive = stats.improvementTrend >= 0;
          final semantic = Theme.of(context).extension<SemanticColors>()!;
          final gaugeColor = stats.overallSchoolAverage >= 75
              ? semantic.success
              : stats.overallSchoolAverage >= 50
              ? semantic.warning
              : semantic.error;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.x3l,
            ),
            children: [
              AppCard(
                child: Column(
                  children: [
                    CircularPercentGauge(
                      percent: stats.overallSchoolAverage / 100,
                      centerLabel: '${stats.overallSchoolAverage.round()}%',
                      subLabel: stats.overallSchoolAverage >= 75
                          ? 'Good'
                          : stats.overallSchoolAverage >= 50
                          ? 'Fair'
                          : 'Needs Attention',
                      color: gaugeColor,
                      size: 180,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Overall Performance Index',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    StatusBadge(
                      label:
                          '${isPositive ? "+" : ""}${stats.improvementTrend}% vs Last Term',
                      color: isPositive ? semantic.success : semantic.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Performance Breakdown'),
              AppCard(
                child: Column(
                  children: [
                    LabeledProgressRow(
                      label: 'Academic',
                      percent: stats.overallSchoolAverage / 100,
                      color: Colors.black,
                    ),
                    LabeledProgressRow(
                      label: 'Financial (Fee Collection)',
                      percent: stats.collectionPercentage / 100,
                      color: Colors.black,
                    ),
                    LabeledProgressRow(
                      label: 'Operational (Staff Attendance)',
                      percent: stats.staffAttendanceRate / 100,
                      color: Colors.black,
                    ),
                    LabeledProgressRow(
                      label: 'Engagement (Parent Portal Usage)',
                      percent: stats.parentPortalUsageRate / 100,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // TODO: Wire to a real historical-terms data source once the
              // director module exposes term-over-term performance history.
              // Until then, an honest empty state replaces a fabricated
              // trend line.
              const SectionHeader(title: 'Performance Trend'),
              AppCard(
                child: EmptyState(
                  icon: Icons.show_chart,
                  title: 'Trend history not available yet',
                  message:
                      'Term-over-term performance history will appear here once tracked.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
