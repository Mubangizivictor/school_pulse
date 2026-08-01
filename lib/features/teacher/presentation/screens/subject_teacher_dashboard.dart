import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/shared/boarding/boarding_dashboard_widgets.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import '../../domain/entities/ongoing_lesson.dart';

class SubjectTeacherDashboard extends StatefulWidget {
  const SubjectTeacherDashboard({super.key});

  @override
  State<SubjectTeacherDashboard> createState() => _SubjectTeacherDashboardState();
}

class _SubjectTeacherDashboardState extends State<SubjectTeacherDashboard> {
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
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading || state is TeacherInitial) {
            return const _DashboardSkeleton();
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.x8l,
                  AppSpacing.xl,
                  AppSpacing.x4l,
                ),
                children: [
                  BoardingDashboardHeader(
                    userName: user?.name ?? 'Subject Teacher',
                    roleLabel: 'Subject Teacher • ${user?.schoolName ?? 'North Campus'}',
                    photoUrl: user?.photoUrl,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          onPressed: () => context.push('/staff/messages'),
                          tooltip: 'Messages',
                        ),
                        const NotificationBellButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3l),

                  // 1. Subject Metrics
                  BoardingOverviewCard(
                    metrics: _buildMetrics(context, state, semanticColors),
                  ),
                  const SizedBox(height: AppSpacing.x3l),

                  // 2. Active Lesson
                  if (state.ongoingLesson != null) ...[
                    _buildOngoingLesson(context, state.ongoingLesson!),
                    const SizedBox(height: AppSpacing.x3l),
                  ],

                  // 3. Quick Actions
                  BoardingSectionHeading(title: 'Quick Actions'),
                  const SizedBox(height: AppSpacing.l),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.x3l),

                  // 4. My Classes (Subject Specific)
                  _buildMyClasses(context, state),
                  const SizedBox(height: AppSpacing.x3l),

                  // 5. What's Next
                  _buildWhatsNext(context),
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

  List<BoardingMetric> _buildMetrics(
    BuildContext context,
    TeacherLoaded state,
    SemanticColors semanticColors,
  ) {
    return [
      BoardingMetric(
        label: 'My Students',
        icon: Icons.groups_outlined,
        color: Theme.of(context).colorScheme.primary,
        value: state.totalStudents,
        caption: 'Enrolled',
        captionUsesColor: false,
        onTap: () => context.push('/staff/students'),
      ),
      BoardingMetric(
        label: 'Attendance',
        icon: Icons.how_to_reg_outlined,
        color: semanticColors.success,
        value: state.studentsToday,
        caption: 'Subject Avg',
        onTap: () => context.push('/staff/attendance'),
      ),
      BoardingMetric(
        label: 'Assessments',
        icon: Icons.assignment_outlined,
        color: semanticColors.warning,
        value: state.submissionsDue,
        caption: 'Pending',
        onTap: () => context.push('/staff/marks'),
      ),
      BoardingMetric(
        label: 'Lesson Plans',
        icon: Icons.menu_book_outlined,
        color: Colors.purple,
        value: 4,
        caption: 'This Week',
        onTap: () => context.push('/staff/lesson-plans'),
      ),
    ];
  }

  Widget _buildOngoingLesson(BuildContext context, OngoingLesson lesson) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoardingSectionHeading(title: 'Current Lesson'),
        const SizedBox(height: AppSpacing.l),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lesson.startTime} - ${lesson.endTime}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          lesson.subjectName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: 'Ongoing',
                    color: semanticColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  _LessonMeta(
                    icon: Icons.room_outlined,
                    label: lesson.room,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _LessonMeta(
                    icon: Icons.class_outlined,
                    label: lesson.className,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Topic: ${lesson.topic}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume Lesson'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return BoardingQuickActionGrid(
      actions: [
        BoardingQuickAction(
          label: 'Start Lesson',
          icon: Icons.play_circle_outline,
          color: AppColors.successGreen,
          onTap: () {},
        ),
        BoardingQuickAction(
          label: 'Lesson Plans',
          icon: Icons.menu_book,
          color: AppColors.royalBlue,
          onTap: () => context.push('/staff/lesson-plans'),
        ),
        BoardingQuickAction(
          label: 'Record Marks',
          icon: Icons.edit_note,
          color: Colors.orange,
          onTap: () => context.push('/staff/marks'),
        ),
      ],
    );
  }

  Widget _buildMyClasses(BuildContext context, TeacherLoaded state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoardingSectionHeading(
          title: 'My Subject Classes',
          onViewAll: () => context.push('/staff/classes'),
        ),
        const SizedBox(height: AppSpacing.l),
        ...state.classProgress.take(2).map((cp) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: AppCard(
                onTap: () {},
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          cp.title.substring(0, 2),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cp.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cp.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: cp.progress,
                      strokeWidth: 3,
                      backgroundColor: theme.colorScheme.outlineVariant,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildWhatsNext(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoardingSectionHeading(title: "What's Next?"),
        const SizedBox(height: AppSpacing.l),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Colors.orange),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Term 2 Progress Reports Due',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Friday, 24th Oct • 3 days left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => context.push('/staff/reports'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LessonMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: AppSpacing.s),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.x8l,
        AppSpacing.xl,
        AppSpacing.x4l,
      ),
      children: [
        const Skeleton(width: 250, height: 80, borderRadius: 12),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(height: 160, borderRadius: 16),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(height: 200, borderRadius: 16),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: AppSpacing.l),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.l,
          crossAxisSpacing: AppSpacing.l,
          childAspectRatio: 1.35,
          children: List.generate(3, (index) => const Skeleton(borderRadius: 12)),
        ),
      ],
    );
  }
}
