import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
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
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Portal'),
        actions: const [
          NotificationBellButton(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                  Builder(builder: (context) {
                    final authState = context.watch<AuthBloc>().state;
                    final assignedClass = authState is AuthAuthenticated ? authState.user.assignedClass : null;
                    if (assignedClass == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Class Teacher - $assignedClass',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Builder(builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 600;

                    if (isMobile) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: FadeInSlide(
                                  delay: const Duration(milliseconds: 200),
                                  child: DashboardStatCard(
                                    title: 'Students Today',
                                    value: state.studentsToday.toDouble(),
                                    suffix: '/${state.totalStudents}',
                                    icon: Icons.people_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FadeInSlide(
                                  delay: const Duration(milliseconds: 300),
                                  child: DashboardStatCard(
                                    title: 'Submissions',
                                    value: state.submissionsDue.toDouble(),
                                    icon: Icons.assignment_outlined,
                                    color: semanticColors.warning,
                                    trend: 'Due today',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: FadeInSlide(
                                  delay: const Duration(milliseconds: 400),
                                  child: DashboardStatCard(
                                    title: 'Classes Today',
                                    value: state.classesToday.toDouble(),
                                    icon: Icons.calendar_today_outlined,
                                    color: semanticColors.info,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FadeInSlide(
                                  delay: const Duration(milliseconds: 500),
                                  child: DashboardStatCard(
                                    title: 'Notifications',
                                    value: state.activeNotifications.toDouble(),
                                    icon: Icons.notifications_active_outlined,
                                    color: semanticColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Students Today',
                            value: state.studentsToday.toDouble(),
                            suffix: '/${state.totalStudents}',
                            icon: Icons.people_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Submissions',
                            value: state.submissionsDue.toDouble(),
                            icon: Icons.assignment_outlined,
                            color: semanticColors.warning,
                            trend: 'Due today',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Classes Today',
                            value: state.classesToday.toDouble(),
                            icon: Icons.calendar_today_outlined,
                            color: semanticColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Notifications',
                            value: state.activeNotifications.toDouble(),
                            icon: Icons.notifications_active_outlined,
                            color: semanticColors.error,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 15),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Progress',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...state.classProgress.asMap().entries.map((entry) {
                          final index = entry.key;
                          final progress = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProgressCard(
                              title: progress.title,
                              progress: progress.progress,
                              subtitle: progress.subtitle,
                              color: index.isOdd ? semanticColors.info : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _QuickAction(
                                label: 'Attendance',
                                icon: Icons.how_to_reg,
                                color: semanticColors.info,
                                onTap: () => context.push('/staff/attendance'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'Enter Marks',
                                icon: Icons.edit_note,
                                color: semanticColors.warning,
                                onTap: () => context.push('/staff/marks'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'Homework',
                                icon: Icons.assignment_outlined,
                                color: semanticColors.success,
                                onTap: () => context.push('/staff/homework'),
                                width: itemWidth,
                              ),
                              _QuickAction(
                                label: 'Analytics',
                                icon: Icons.analytics_outlined,
                                color: Theme.of(context).colorScheme.secondary,
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
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TeacherDashboardSkeleton extends StatelessWidget {
  const _TeacherDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 8),
        const Skeleton(width: 150, height: 16),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: List.generate(4, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 24),
        const SizedBox(height: 16),
        const Skeleton(height: 100, borderRadius: 12),
        const SizedBox(height: 12),
        const Skeleton(height: 100, borderRadius: 12),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 24),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            4,
            (index) => Skeleton(
              width: (MediaQuery.of(context).size.width - 36) / 2,
              height: 100,
              borderRadius: 12,
            ),
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        width: width ?? (MediaQuery.of(context).size.width - 36) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? color : color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
