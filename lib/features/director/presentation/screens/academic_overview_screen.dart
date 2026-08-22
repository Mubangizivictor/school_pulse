import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';
import 'package:school_pulse/features/director/domain/entities/director_dashboard_stats.dart';

/// "Academic Overview" screen from the reference: Overview / Subjects /
/// Classes segmented tabs, an overall-performance progress card, and ranked
/// top/weak class lists.
///
/// [DirectorDashboardStats] has no per-subject breakdown, so the Subjects
/// tab shows an honest empty state rather than inventing subject averages.
class AcademicOverviewScreen extends StatefulWidget {
  const AcademicOverviewScreen({super.key});

  @override
  State<AcademicOverviewScreen> createState() => _AcademicOverviewScreenState();
}

class _AcademicOverviewScreenState extends State<AcademicOverviewScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Academic Overview')),
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
              SegmentedTabControl(
                labels: const ['Overview', 'Subjects', 'Classes'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_tab == 0) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Performance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        '${stats.overallSchoolAverage}%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      StatusBadge(
                        label:
                            '${stats.improvementTrend >= 0 ? "+" : ""}${stats.improvementTrend}% vs Last Term',
                        color: stats.improvementTrend >= 0
                            ? semantic.success
                            : semantic.error,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      LabeledProgressRow(
                        label: 'Pass Rate',
                        percent: (stats.passRate / 100).clamp(0, 1),
                        trailingText: '${stats.passRate}%',
                        color: semantic.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Top Performing Classes'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: stats.topClasses.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No class performance data yet.'),
                        )
                      : Column(
                          children: stats.topClasses
                              .map(
                                (c) => _ClassRow(c: c, color: semantic.success),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Classes Needing Attention'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: stats.weakClasses.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No class performance data yet.'),
                        )
                      : Column(
                          children: stats.weakClasses
                              .map(
                                (c) => _ClassRow(c: c, color: semantic.error),
                              )
                              .toList(),
                        ),
                ),
              ] else if (_tab == 1) ...[
                // TODO: Wire to a real per-subject average once the director
                // module exposes subject-level academic data.
                const EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'Subject breakdown not available yet',
                  message:
                      'Per-subject averages will appear here once tracked.',
                ),
              ] else ...[
                // TODO: Wire to a real per-class listing beyond the
                // top/weak-classes summary once the director module exposes
                // a full class roster with performance figures.
                const EmptyState(
                  icon: Icons.class_outlined,
                  title: 'Full class listing not available yet',
                  message:
                      'A complete class-by-class breakdown will appear here.',
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final ClassPerformance c;
  final Color color;
  const _ClassRow({required this.c, required this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      c.className,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${c.average}%',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(width: 4),
        Icon(
          c.trend > 0 ? Icons.trending_up : Icons.trending_down,
          size: 16,
          color: color,
        ),
        const Icon(Icons.chevron_right, size: 18),
      ],
    ),
  );
}
