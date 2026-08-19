import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/circular_progress_gauge.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/academic_dashboard_stats.dart';

class DeanDashboardScreen extends StatelessWidget {
  const DeanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(AcademicDashboardRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context),
                    const SizedBox(height: AppSpacing.x3l),
                    _buildAcademicHealthGauge(context),
                    const SizedBox(height: AppSpacing.x3l),
                    _buildActionGrid(context),
                    const SizedBox(height: AppSpacing.x3l),
                    _buildStatsOverview(context),
                    const SizedBox(height: AppSpacing.x3l),
                    _buildPerformanceSection(context),
                    const SizedBox(height: AppSpacing.x3l),
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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: AppColors.surface(context),
      title: Text('Academic Command Centre', style: AppTypography.titleLarge),
      actions: [
        const NotificationBellButton(),
        const SizedBox(width: AppSpacing.m),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        const SizedBox(width: AppSpacing.m),
      ],
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
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            BlocBuilder<DeanBloc, DeanState>(
              builder: (context, state) {
                if (state is AcademicDashboardLoaded) {
                  return Text(
                    '${state.stats.currentAcademicYear} • ${state.stats.currentTerm}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  );
                }
                return Text(
                  'Loading academic session...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAcademicHealthGauge(BuildContext context) {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        if (state is! AcademicDashboardLoaded) {
          return const SizedBox.shrink();
        }
        final stats = state.stats;
        final health = (stats.overallSchoolAverage / 100).clamp(0.0, 1.0);
        return AppCard(
          child: Row(
            children: [
              CircularProgressGauge(
                value: health,
                label: 'Academic Health',
                size: 108,
                strokeWidth: 10,
              ),
              const SizedBox(width: AppSpacing.x3l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'School Average',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      '${stats.overallSchoolAverage.toStringAsFixed(1)}%',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Trend: ${stats.attendanceTrend > 0 ? "+" : ""}${stats.attendanceTrend}%',
                      style: AppTypography.labelMedium.copyWith(
                        color: stats.attendanceTrend >= 0
                            ? AppColors.success(context)
                            : AppColors.danger(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.menu_book,
        label: 'Curriculum',
        route: '/staff/dean/curriculum',
      ),
      _ActionItem(
        icon: Icons.assignment_ind,
        label: 'Workload',
        route: '/staff/dean/workload',
      ),
      _ActionItem(
        icon: Icons.history_edu,
        label: 'Lessons',
        route: '/staff/dean/lessons',
      ),
      _ActionItem(
        icon: Icons.grading,
        label: 'Quality QA',
        route: '/staff/dean/marks-qa',
      ),
      _ActionItem(
        icon: Icons.verified_user,
        label: 'Report Approvals',
        route: '/staff/dean/approvals',
      ),
      _ActionItem(
        icon: Icons.psychology,
        label: 'Interventions',
        route: '/staff/dean/interventions',
      ),
      _ActionItem(
        icon: Icons.visibility,
        label: 'Observations',
        route: '/staff/dean/observations',
      ),
      _ActionItem(
        icon: Icons.analytics,
        label: 'Analytics',
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
            crossAxisSpacing: AppSpacing.l,
            mainAxisSpacing: AppSpacing.l,
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
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.1),
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(
                      action.icon,
                      color: AppColors.primary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Text(action.label, style: AppTypography.titleSmall),
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
              const SizedBox(height: AppSpacing.l),
              Wrap(
                spacing: AppSpacing.l,
                runSpacing: AppSpacing.l,
                children: [
                  _StatBox(
                    label: 'Lessons Today',
                    value: '${stats.lessonsConductedToday}',
                    subValue: '${stats.lessonsMissedToday} missed',
                    icon: Icons.class_,
                    color: AppColors.primary(context),
                  ),
                  _StatBox(
                    label: 'Pending Marks',
                    value: '${stats.marksPendingEntry}',
                    subValue: 'Assessments: ${stats.assessmentsPending}',
                    icon: Icons.pending_actions,
                    color: AppColors.warning(context),
                  ),
                  _StatBox(
                    label: 'Reports to Approve',
                    value: '${stats.reportCardsPendingApproval}',
                    subValue: '${stats.reportCardsPublished} published',
                    icon: Icons.fact_check,
                    color: AppColors.success(context),
                  ),
                  _StatBox(
                    label: 'School Average',
                    value: '${stats.overallSchoolAverage.toStringAsFixed(1)}%',
                    subValue:
                        'Trend: ${stats.attendanceTrend > 0 ? "+" : ""}${stats.attendanceTrend}%',
                    icon: Icons.trending_up,
                    color: AppColors.secondary(context),
                  ),
                ],
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
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
                      Text(
                        'Top Performing Classes',
                        style: AppTypography.titleSmall,
                      ),
                      Divider(color: AppColors.border(context)),
                      ...state.stats.topPerformingClasses.map(
                        (c) => ListTile(
                          dense: true,
                          title: Text(
                            c.className,
                            style: AppTypography.bodyMedium,
                          ),
                          trailing: Text(
                            '${c.average}%',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.success(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject Rankings', style: AppTypography.titleSmall),
                      Divider(color: AppColors.border(context)),
                      ...state.stats.subjectRankings
                          .take(5)
                          .map(
                            (s) => ListTile(
                              dense: true,
                              title: Text(
                                s.subjectName,
                                style: AppTypography.bodyMedium,
                              ),
                              trailing: Text(
                                '${s.average}%',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary(context),
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
              const SectionHeader(title: 'Critical Attention'),
              const SizedBox(height: AppSpacing.l),
              ...state.stats.activeAlerts.map(
                (alert) => AlertBanner(
                  title: alert.title,
                  message:
                      '${alert.message}  •  ${_formatTime(alert.timestamp)}',
                  color: _getAlertColor(context, alert.severity),
                  icon: Icons.warning_amber,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Color _getAlertColor(BuildContext context, AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.danger(context);
      case AlertSeverity.high:
        return AppColors.warning(context);
      case AlertSeverity.medium:
        return AppColors.information(context);
      case AlertSeverity.low:
        return AppColors.textMuted(context);
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String route;

  _ActionItem({required this.icon, required this.label, required this.route});
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.l),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subValue,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}
