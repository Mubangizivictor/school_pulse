import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/today_operations.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/meetings_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/workload/teacher_workload_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/widgets/role_switcher_sheet.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/injection_container.dart';

class TodaysOperationsScreen extends StatelessWidget {
  const TodaysOperationsScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<DeanBloc>()..add(TodaysOperationsRequested()),
    child: const _View(),
  );
}

class _View extends StatelessWidget {
  const _View();
  void _load(BuildContext c) =>
      c.read<DeanBloc>().add(TodaysOperationsRequested());
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    body: SafeArea(
      child: BlocBuilder<DeanBloc, DeanState>(
        builder: (c, state) {
          if (state is TodaysOperationsLoaded) {
            return _Body(ops: state.operations, refresh: () => _load(c));
          }
          if (state is DeanError) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load today’s operations',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: () => _load(c),
            );
          }
          return const _Loading();
        },
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  final TodaysOperations ops;
  final VoidCallback refresh;
  const _Body({required this.ops, required this.refresh});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => RefreshIndicator(
      onRefresh: () async => refresh(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              box.maxWidth > 720 ? 24 : 16,
              16,
              box.maxWidth > 720 ? 24 : 16,
              28,
            ),
            children: [
              const _Header(),
              const SizedBox(height: 16),
              _Progress(ops),
              const SizedBox(height: 12),
              _Grid(ops),
              const SizedBox(height: 18),
              Text('Coming up today', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              _Meetings(ops.meetingsToday),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext c) {
    final n = DateTime.now();
    final g = n.hour < 12
        ? 'Good morning'
        : n.hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    g,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 16,
                      color: AppColors.textSecondary(c),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<AppRoleSessionCubit, UserRole?>(
                    builder: (context, active) {
                      final label = active == UserRole.deanOfStudies
                          ? 'DOS'
                          : active == null
                          ? 'Role'
                          : UserRoleDisplay.name(active);
                      final auth = context.read<AuthBloc>().state;
                      final enabled =
                          auth is AuthAuthenticated &&
                          auth.user.roles.length > 1;
                      return InkWell(
                        onTap: enabled
                            ? () => RoleSwitcherSheet.show(context)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              if (enabled)
                                const Icon(Icons.keyboard_arrow_down, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(n),
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  color: AppColors.textMuted(c),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Today’s Operations',
                style: AppTypography.headlineLarge.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
        NotificationBellButton(backgroundColor: AppColors.surfaceElevated(c)),
        _MessagesButton(),
      ],
    );
  }
}

class _MessagesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MessagingBloc, MessagingState>(
        builder: (context, state) => Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Messages',
              onPressed: () => context.push('/staff/messages'),
              icon: const Icon(Icons.chat_bubble_outline),
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                backgroundColor: AppColors.surfaceElevated(context),
                side: BorderSide(color: AppColors.border(context)),
              ),
            ),
            if (state.totalUnreadCount > 0)
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.totalUnreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _Progress extends StatelessWidget {
  final TodaysOperations o;
  const _Progress(this.o);
  @override
  Widget build(BuildContext c) {
    final p = lessonProgressPercentage(
      completed: o.lessonsCompleted,
      scheduled: o.lessonsScheduled,
    );
    return AppCard(
      onTap: () => Navigator.of(c).pushNamed('lessons'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lesson progress', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${o.lessonsCompleted}',
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success(c),
                        ),
                      ),
                      TextSpan(
                        text: ' of ${o.lessonsScheduled} completed',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimary(c),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '$p%',
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success(c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: p / 100,
            minHeight: 10,
            color: AppColors.success(c),
            backgroundColor: AppColors.surfaceContainerHigh(c),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Dot('${o.lessonsInProgress} in progress', AppColors.success(c)),
              _Dot('${o.lessonsMissed} missed', AppColors.danger(c)),
              _Dot('${o.awaitingConfirmation} awaiting', AppColors.warning(c)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final String text;
  final Color color;
  const _Dot(this.text, this.color);
  @override
  Widget build(BuildContext c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(text, style: AppTypography.bodyLarge.copyWith(fontSize: 13)),
    ],
  );
}

class _Grid extends StatelessWidget {
  final TodaysOperations o;
  const _Grid(this.o);
  @override
  Widget build(BuildContext c) => LayoutBuilder(
    builder: (c, b) => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: b.maxWidth >= 920 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: b.maxWidth >= 920 ? 1.48 : 1.28,
      children: [
        _Card(
          'Lessons',
          Icons.event_note_outlined,
          AppColors.success(c),
          o.lessonsScheduled,
          'scheduled',
          o.lessonsCompleted,
          'completed',
          () => Navigator.of(c).pushNamed('lessons'),
        ),
        _Card(
          'Attention',
          Icons.warning_amber_rounded,
          AppColors.danger(c),
          o.lessonsMissed,
          'missed',
          o.awaitingConfirmation,
          'awaiting',
          () => Navigator.of(c).pushNamed('missed-lessons'),
        ),
        _Card(
          'Staff coverage',
          Icons.person_outline,
          AppColors.information(c),
          o.teacherAbsences,
          'absences',
          o.substituteLessons,
          'substitutes',
          () => Navigator.of(c).push(
            MaterialPageRoute(builder: (_) => const TeacherWorkloadScreen()),
          ),
        ),
        _Card(
          'Academic events',
          Icons.school_outlined,
          Colors.deepPurple,
          o.assessmentsToday,
          'assessments',
          o.examinationsToday,
          'examinations',
          () => Navigator.of(c).pushNamed('assessments'),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final String title, a, b;
  final IconData icon;
  final Color color;
  final int x, y;
  final VoidCallback tap;
  const _Card(
    this.title,
    this.icon,
    this.color,
    this.x,
    this.a,
    this.y,
    this.b,
    this.tap,
  );
  @override
  Widget build(BuildContext c) => AppCard(
    onTap: tap,
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleLarge.copyWith(fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        const SizedBox(height: 6),
        _line(c, x, a),
        Divider(color: AppColors.border(c)),
        _line(c, y, b),
        Container(height: 3, color: color),
      ],
    ),
  );
  Widget _line(BuildContext c, int n, String l) => Row(
    children: [
      Text(
        '$n',
        style: AppTypography.kpiStyle.copyWith(fontSize: 18, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          l,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyLarge.copyWith(fontSize: 12),
        ),
      ),
    ],
  );
}

class _Meetings extends StatelessWidget {
  final int count;
  const _Meetings(this.count);
  @override
  Widget build(BuildContext c) => AppCard(
    onTap: () => Navigator.of(
      c,
    ).push(MaterialPageRoute(builder: (_) => const MeetingsScreen())),
    child: Row(
      children: [
        Icon(Icons.groups_outlined, color: AppColors.success(c), size: 32),
        const SizedBox(width: 12),
        Text(
          '$count',
          style: AppTypography.kpiStyle.copyWith(
            fontSize: 24,
            color: AppColors.success(c),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meetings',
                style: AppTypography.titleLarge.copyWith(fontSize: 14),
              ),
              Text(
                'View today’s schedule',
                style: AppTypography.bodyLarge.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    ),
  );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Skeleton(width: 130, height: 18),
      const SizedBox(height: 8),
      const Skeleton(width: 280, height: 32),
      const SizedBox(height: 24),
      const Skeleton(height: 180),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .93,
        children: const [Skeleton(), Skeleton(), Skeleton(), Skeleton()],
      ),
    ],
  );
}

int lessonProgressPercentage({
  required int completed,
  required int scheduled,
}) =>
    scheduled <= 0 ? 0 : ((completed / scheduled) * 100).round().clamp(0, 100);
