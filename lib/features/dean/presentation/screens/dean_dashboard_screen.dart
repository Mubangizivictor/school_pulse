import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import '../../domain/entities/academic_dashboard_stats.dart';

class DeanDashboardScreen extends StatelessWidget {
  const DeanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(AcademicDashboardRequested()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            NotificationBellButton(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context),
                    const SizedBox(height: 24),
                    _buildActionGrid(context),
                    const SizedBox(height: 24),
                    _buildStatsOverview(context),
                    const SizedBox(height: 24),
                    _buildPerformanceSection(context),
                    const SizedBox(height: 24),
                    _buildAlertsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = (state is AuthAuthenticated) ? state.user.name : 'Dean';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            BlocBuilder<DeanBloc, DeanState>(
              builder: (context, state) {
                if (state is AcademicDashboardLoaded) {
                  return Text(
                    '${state.stats.currentAcademicYear} • ${state.stats.currentTerm}',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  );
                }
                return const Text('Loading academic session...');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.menu_book,
        label: 'Curriculum',
        color: Colors.blue,
        route: '/staff/dean/curriculum',
      ),
      _ActionItem(
        icon: Icons.assignment_ind,
        label: 'Workload',
        color: Colors.purple,
        route: '/staff/dean/workload',
      ),
      _ActionItem(
        icon: Icons.history_edu,
        label: 'Lessons',
        color: Colors.orange,
        route: '/staff/dean/lessons',
      ),
      _ActionItem(
        icon: Icons.grading,
        label: 'Quality QA',
        color: Colors.green,
        route: '/staff/dean/marks-qa',
      ),
      _ActionItem(
        icon: Icons.verified_user,
        label: 'Report Approvals',
        color: Colors.red,
        route: '/staff/dean/approvals',
      ),
      _ActionItem(
        icon: Icons.psychology,
        label: 'Interventions',
        color: Colors.teal,
        route: '/staff/dean/interventions',
      ),
      _ActionItem(
        icon: Icons.visibility,
        label: 'Observations',
        color: Colors.indigo,
        route: '/staff/dean/observations',
      ),
      _ActionItem(
        icon: Icons.analytics,
        label: 'Analytics',
        color: Colors.amber,
        route: '/staff/dean/analytics',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return AppCard(
              onTap: () => GoRouter.of(context).push(action.route),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      action.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        if (state is AcademicDashboardLoaded) {
          final stats = state.stats;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Academic Pulse'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatBox(
                    label: 'Lessons Today',
                    value: '${stats.lessonsConductedToday}',
                    subValue: '${stats.lessonsMissedToday} missed',
                    icon: Icons.class_,
                    color: Colors.blue,
                  ),
                  _StatBox(
                    label: 'Pending Marks',
                    value: '${stats.marksPendingEntry}',
                    subValue: 'Assessments: ${stats.assessmentsPending}',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  _StatBox(
                    label: 'Reports to Approve',
                    value: '${stats.reportCardsPendingApproval}',
                    subValue: '${stats.reportCardsPublished} published',
                    icon: Icons.fact_check,
                    color: Colors.green,
                  ),
                  _StatBox(
                    label: 'School Average',
                    value: '${stats.overallSchoolAverage.toStringAsFixed(1)}%',
                    subValue:
                        'Trend: ${stats.attendanceTrend > 0 ? "+" : ""}${stats.attendanceTrend}%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ],
              ),
            ],
          );
        }
        return const Center(child: SchoolPulseLoader());
      },
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        if (state is AcademicDashboardLoaded) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Performing Classes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...state.stats.topPerformingClasses.map(
                        (c) => ListTile(
                          dense: true,
                          title: Text(c.className),
                          trailing: Text(
                            '${c.average}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subject Rankings',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...state.stats.subjectRankings
                          .take(5)
                          .map(
                            (s) => ListTile(
                              dense: true,
                              title: Text(s.subjectName),
                              trailing: Text(
                                '${s.average}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        if (state is AcademicDashboardLoaded &&
            state.stats.activeAlerts.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Academic Alerts'),
              const SizedBox(height: 12),
              ...state.stats.activeAlerts.map(
                (alert) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: _getAlertColor(alert.severity).withValues(alpha: 0.05),
                  child: ListTile(
                    leading: Icon(
                      Icons.warning_amber,
                      color: _getAlertColor(alert.severity),
                    ),
                    title: Text(
                      alert.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(alert.message),
                    trailing: Text(
                      _formatTime(alert.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.high:
        return Colors.orange;
      case AlertSeverity.medium:
        return Colors.blue;
      case AlertSeverity.low:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 48) / 2;
    return Container(
      width: width > 200 ? 200 : width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
