import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeacherBloc>().add(TeacherDashboardRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Staff Portal',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        actions: const [
          NotificationBellButton(),
          SizedBox(width: AppSpacing.m),
        ],
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading || state is TeacherInitial) {
            return const _TeacherDashboardSkeleton();
          }

          if (state is TeacherError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load dashboard',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context
                      .read<TeacherBloc>()
                      .add(TeacherDashboardRequested(authState.user.id));
                }
              },
            );
          }

          if (state is TeacherLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<TeacherBloc>().add(TeacherDashboardRequested(authState.user.id));
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  FadeInSlide(
                    child: Builder(builder: (context) {
                      final authState = context.watch<AuthBloc>().state;
                      final name = authState is AuthAuthenticated
                          ? authState.user.name
                          : '';
                      return Text(
                        'Hello, $name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      );
                    }),
                  ),
                  Builder(builder: (context) {
                    final authState = context.watch<AuthBloc>().state;
                    final assignedClass = authState is AuthAuthenticated ? authState.user.assignedClass : null;
                    if (assignedClass == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s),
                      child: Text(
                        'Class Teacher - $assignedClass',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.s),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  _buildStatsGrid(context, state),
                  const SizedBox(height: AppSpacing.x3l),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Progress',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ...state.classProgress.asMap().entries.map((entry) {
                          final progress = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.l),
                            child: _PulseProgressCard(
                              title: progress.title,
                              progress: progress.progress,
                              subtitle: progress.subtitle,
                              color: entry.key.isOdd ? AppColors.information(context) : AppColors.primary(context),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        LayoutBuilder(builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - AppSpacing.l) / 2;
                          return Wrap(
                            spacing: AppSpacing.l,
                            runSpacing: AppSpacing.l,
                            children: [
                              _QuickAction(
                                label: 'Attendance',
                                icon: Icons.how_to_reg,
                                color: AppColors.information(context),
                                onTap: () => context.push('/staff/attendance'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'Enter Marks',
                                icon: Icons.edit_note,
                                color: AppColors.warning(context),
                                onTap: () => context.push('/staff/marks'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'Homework',
                                icon: Icons.assignment_outlined,
                                color: AppColors.success(context),
                                onTap: () => context.push('/staff/homework'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'Analytics',
                                icon: Icons.analytics_outlined,
                                color: AppColors.royalBlue,
                                onTap: () => context.push('/staff/class-analytics'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'QR Attendance',
                                icon: Icons.qr_code_scanner,
                                color: Colors.deepPurple,
                                onTap: () => context.push('/staff/attendance/qr-dashboard'),
                                width: itemWidth,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x6l),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, TeacherLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final stats = [
      (
        title: 'Students Today',
        value: state.studentsToday.toDouble(),
        suffix: '/${state.totalStudents}',
        icon: Icons.people_outline,
        color: AppColors.primary(context),
        trend: null,
      ),
      (
        title: 'Submissions',
        value: state.submissionsDue.toDouble(),
        suffix: null,
        icon: Icons.assignment_outlined,
        color: AppColors.warning(context),
        trend: 'Due today',
      ),
      (
        title: 'Classes Today',
        value: state.classesToday.toDouble(),
        suffix: null,
        icon: Icons.calendar_today_outlined,
        color: AppColors.information(context),
        trend: null,
      ),
      (
        title: 'Notifications',
        value: state.activeNotifications.toDouble(),
        suffix: null,
        icon: Icons.notifications_active_outlined,
        color: AppColors.errorRed,
        trend: null,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(stat: stats[0])),
              const SizedBox(width: AppSpacing.l),
              Expanded(child: _StatCard(stat: stats[1])),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(child: _StatCard(stat: stats[2])),
              const SizedBox(width: AppSpacing.l),
              Expanded(child: _StatCard(stat: stats[3])),
            ],
          ),
        ],
      );
    }

    return Row(
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: stat == stats.last ? 0 : AppSpacing.l),
          child: _StatCard(stat: stat),
        ),
      )).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ({String title, double value, String? suffix, IconData icon, Color color, String? trend}) stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      variant: PulseCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              if (stat.trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stat.trend!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${stat.value.toInt()}${stat.suffix ?? ''}',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String subtitle;
  final Color color;

  const _PulseProgressCard({
    required this.title,
    required this.progress,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.s),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherDashboardSkeleton extends StatelessWidget {
  const _TeacherDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Skeleton(width: 200, height: 32),
        const SizedBox(height: AppSpacing.m),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: AppSpacing.x3l),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.l,
          crossAxisSpacing: AppSpacing.l,
          childAspectRatio: 1.3,
          children: List.generate(4, (index) => const Skeleton(borderRadius: AppRadius.l)),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(width: 120, height: 24),
        const SizedBox(height: AppSpacing.xl),
        const Skeleton(height: 120, borderRadius: AppRadius.l),
        const SizedBox(height: AppSpacing.l),
        const Skeleton(height: 120, borderRadius: AppRadius.l),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double? width;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surfaceElevated(context),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

