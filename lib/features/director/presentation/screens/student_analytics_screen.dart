import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "Student Analytics" screen from the reference: Enrollment / Performance /
/// Discipline segmented tabs.
///
/// [DirectorDashboardStats] only exposes total student count and an overall
/// growth percentage - no new-admissions/withdrawals/transfers breakdown and
/// no discipline data - so those two tabs show an honest empty state.
class StudentAnalyticsScreen extends StatefulWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  State<StudentAnalyticsScreen> createState() => _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState extends State<StudentAnalyticsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Student Analytics')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.x3l,
            ),
            children: [
              SegmentedTabControl(
                labels: const ['Enrollment', 'Performance', 'Discipline'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_tab == 0) ...[
                const SectionHeader(title: 'Enrollment Summary'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Total Students',
                        value: '${stats.totalStudents}',
                      ),
                      const Divider(),
                      // TODO: Wire New Admissions / Withdrawals / Transfers
                      // once the director module exposes admissions data
                      // beyond the aggregate student count.
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'New admissions, withdrawals and transfers are not tracked yet.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Growth Rate'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.schoolGrowthPercentage}%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'vs Last Year',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      const TrendLineChart(values: []),
                    ],
                  ),
                ),
              ] else if (_tab == 1) ...[
                // TODO: Wire to real per-student academic performance
                // distribution once the director module exposes it.
                const EmptyState(
                  icon: Icons.trending_up,
                  title: 'Performance breakdown not available yet',
                  message: 'Student performance distribution will appear here.',
                ),
              ] else ...[
                // TODO: Wire to real discipline case data once the director
                // module exposes it.
                const EmptyState(
                  icon: Icons.gavel_outlined,
                  title: 'Discipline data not available yet',
                  message: 'Discipline trends will appear here once tracked.',
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
