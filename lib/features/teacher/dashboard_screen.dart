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
          if (state is TeacherLoading) {
            return const _TeacherDashboardSkeleton();
          }

          if (state is TeacherError) {
            return Center(child: Text(state.message));
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
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      'Hello, ${context.select((AuthBloc bloc) => (bloc.state as AuthAuthenticated).user.name)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Students Today',
                          value: state.studentsToday.toDouble(),
                          suffix: '/${state.totalStudents}',
                          icon: Icons.people_outline,
                          color: Theme.of(context).colorScheme.primary,
                          trend: '+2',
                          isPositiveTrend: true,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 300),
                        child: DashboardStatCard(
                          title: 'Submissions',
                          value: state.submissionsDue.toDouble(),
                          icon: Icons.assignment_outlined,
                          color: semanticColors.warning,
                          trend: 'Due today',
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 400),
                        child: DashboardStatCard(
                          title: 'Classes Today',
                          value: state.classesToday.toDouble(),
                          icon: Icons.calendar_today_outlined,
                          color: semanticColors.info,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 500),
                        child: DashboardStatCard(
                          title: 'Notifications',
                          value: state.activeNotifications.toDouble(),
                          icon: Icons.notifications_active_outlined,
                          color: semanticColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 600),
                    child: SectionHeader(title: 'Class Progress'),
                  ),
                  ...state.classProgress.asMap().entries.map((entry) {
                    final index = entry.key;
                    final progress = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInSlide(
                        delay: Duration(milliseconds: 700 + (index * 100)),
                        child: ProgressCard(
                          title: progress.title,
                          progress: progress.progress,
                          subtitle: progress.subtitle,
                          color: index.isOdd ? semanticColors.info : null,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 900),
                    child: SectionHeader(title: 'Quick Actions'),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FadeInSlide(
                        delay: const Duration(milliseconds: 1000),
                        child: _QuickAction(
                          label: 'Take Attendance',
                          icon: Icons.how_to_reg,
                          color: semanticColors.info,
                          onTap: () => context.push('/staff/attendance'),
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 1100),
                        child: _QuickAction(
                          label: 'Enter Marks',
                          icon: Icons.edit_note,
                          color: semanticColors.warning,
                          onTap: () => context.push('/staff/marks'),
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 1200),
                        child: _QuickAction(
                          label: 'Lesson Plan',
                          icon: Icons.menu_book,
                          color: semanticColors.success,
                          onTap: () {},
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 1300),
                        child: _QuickAction(
                          label: 'Send Broadcast',
                          icon: Icons.campaign,
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () {},
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.all(16),
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
          childAspectRatio: 1.1,
          children: List.generate(4, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        const Skeleton(height: 100, borderRadius: 12),
        const SizedBox(height: 12),
        const Skeleton(height: 100, borderRadius: 12),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            4,
            (index) => Skeleton(
              width: (MediaQuery.of(context).size.width - 44) / 2,
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

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
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
