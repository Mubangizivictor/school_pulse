import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/screens/admin_more_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/profile/presentation/screens/profile_more_screen.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';

/// Roles whose account can hold a Class/Subject Teacher responsibility and
/// so has a ClassTeacherContextBloc assignment worth waiting on here.
/// Mirrors StaffShell._teacherRoles in shell_screen.dart.
const _teacherFamilyRoles = [UserRole.classTeacher, UserRole.subjectTeacher];

/// Lower-frequency, class-scoped workflows. Counts are projections from the
/// existing dashboard query; every destination owns its own authorization and
/// data loading, so this menu never becomes a second source of truth.
class ClassTeacherMoreScreen extends StatefulWidget {
  const ClassTeacherMoreScreen({super.key});

  @override
  State<ClassTeacherMoreScreen> createState() => _ClassTeacherMoreScreenState();
}

class _ClassTeacherMoreScreenState extends State<ClassTeacherMoreScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated &&
        _teacherFamilyRoles.contains(auth.user.role)) {
      context.read<ClassTeacherContextBloc>().add(
        ClassContextRequested(
          schoolId: auth.user.schoolId,
          userId: auth.user.id,
        ),
      );
    }
  }

  Future<void> _switchRole(ClassTeacherContextState state) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final selected = await _AccountRoleSheet.show(
      context,
      user: auth.user,
      state: state,
    );
    if (!mounted || selected == null) return;
    if (selected == _AccountRoleSheet.profileAction) {
      context.push('/staff/more/edit-profile');
      return;
    }
    context.read<ClassTeacherContextBloc>().add(ClassContextSwitched(selected));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();

    // School Admin / Head Teacher / Deputy Head / Director get the
    // admin-operational More hub (School structure, Roles & access, Reports,
    // School settings) instead of the generic personal-only screen.
    if (auth.user.roles.any(UserRoleDisplay.adminConsoleRoles.contains)) {
      return const AdminMoreScreen();
    }

    // This screen only has a class-scoped More for roles.first in the
    // Class/Subject Teacher family - everyone else who lands on the shared
    // `/staff/more` route (Bursar, ...) has no ClassTeacherContextBloc
    // assignment to resolve, so waiting on it here would spin the skeleton
    // forever. Route them to the generic profile More screen immediately
    // instead of joining the BlocConsumer below.
    if (!_teacherFamilyRoles.contains(auth.user.role)) {
      return const ProfileMoreScreen();
    }

    return BlocConsumer<ClassTeacherContextBloc, ClassTeacherContextState>(
      listenWhen: (before, after) => before.handOffTo != after.handOffTo,
      listener: (context, state) {
        if (state.handOffTo == StaffResponsibilityType.subjectTeacher) {
          final auth = context.read<AuthBloc>().state;
          if (auth is AuthAuthenticated) {
            context.read<SubjectTeacherContextBloc>().add(
              ContextRequested(
                schoolId: auth.user.schoolId,
                userId: auth.user.id,
              ),
            );
          }
          context.go('/staff/dashboard');
          context.read<ClassTeacherContextBloc>().add(
            const ClassContextHandOffConsumed(),
          );
        }
      },
      builder: (context, contextState) {
        final active = contextState.active;
        // A Subject Teacher's existing profile More remains intact. This
        // avoids accidentally giving its class-only tools a broader surface.
        if (active != null && !active.isClassTeacher) {
          return const ProfileMoreScreen();
        }
        if (contextState.isLoading || active == null) {
          return const _MoreSkeleton();
        }
        return BlocBuilder<
          ClassTeacherDashboardBloc,
          ClassTeacherDashboardState
        >(
          builder: (context, dashboard) {
            if (dashboard.roleAssignmentId != active.roleAssignmentId &&
                !dashboard.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<ClassTeacherDashboardBloc>().add(
                    ClassDashboardRequested(active),
                  );
                }
              });
            }
            return _MoreBody(
              user: auth.user,
              active: active,
              state: contextState,
              dashboard: dashboard,
              onSwitch: () => _switchRole(contextState),
            );
          },
        );
      },
    );
  }
}

class _MoreBody extends StatelessWidget {
  const _MoreBody({
    required this.user,
    required this.active,
    required this.state,
    required this.dashboard,
    required this.onSwitch,
  });

  final UserEntity user;
  final ActiveResponsibilityContext active;
  final ClassTeacherContextState state;
  final ClassTeacherDashboardState dashboard;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final summary = dashboard.summary;
    final lessons = summary?.todaysSchedule.length;
    final unread = summary?.unreadMessages ?? 0;
    final followUps = summary?.pendingBehaviourFollowUps ?? 0;
    final canSeeExamFactory = state.subjectAssignments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ClassTeacherContextBloc>().add(
              const ClassContextRevalidated(),
            );
            context.read<ClassTeacherDashboardBloc>().add(
              ClassDashboardRequested(active, forceRefresh: true),
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) => ListView(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth >= 900 ? 32 : AppSpacing.xl,
                AppSpacing.l,
                constraints.maxWidth >= 900 ? 32 : AppSpacing.xl,
                104,
              ),
              children: [
                _Header(
                  user: user,
                  active: active,
                  state: state,
                  unreadCount: unread,
                  onSwitch: onSwitch,
                ),
                if (dashboard.isFromCache) ...[
                  const SizedBox(height: AppSpacing.m),
                  const _OfflineNotice(),
                ],
                const SizedBox(height: AppSpacing.x3l),
                const _SectionTitle('Your day'),
                const SizedBox(height: AppSpacing.m),
                Wrap(
                  spacing: AppSpacing.m,
                  runSpacing: AppSpacing.m,
                  children: [
                    _DayCard(
                      icon: Icons.calendar_month_outlined,
                      color: AppColors.primary(context),
                      title: 'Timetable',
                      subtitle: lessons == null
                          ? 'Loading today’s lessons'
                          : lessons == 0
                          ? 'No more lessons today'
                          : '$lessons lesson${lessons == 1 ? '' : 's'} today',
                      onTap: () => context.push('/staff/more/timetable'),
                    ),
                    _DayCard(
                      icon: Icons.event_outlined,
                      color: AppColors.success(context),
                      title: 'Calendar',
                      subtitle: 'School and class events',
                      onTap: () => context.push('/staff/calendar'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x3l),
                const _SectionTitle('Class management'),
                const SizedBox(height: AppSpacing.m),
                _RowGroup(
                  rows: [
                    _MoreRow(
                      icon: Icons.history_outlined,
                      color: AppColors.primary(context),
                      title: 'Attendance history',
                      subtitle: 'Review submitted registers',
                      onTap: () => context.push('/staff/roll-call/history'),
                    ),
                    _MoreRow(
                      icon: Icons.forum_outlined,
                      color: AppColors.success(context),
                      title: 'Parent communication',
                      subtitle: 'Messages and class announcements',
                      badge: unread,
                      onTap: () => context.push('/staff/messages'),
                    ),
                    if (active.can(Permission.classStudentNoteWrite) ||
                        active.can(Permission.classInterventionNoteWrite))
                      _MoreRow(
                        icon: Icons.note_alt_outlined,
                        color: AppColors.warning(context),
                        title: 'Class notes & follow-up',
                        subtitle: 'Private notes and follow-ups',
                        badge: followUps,
                        onTap: () => context.push('/staff/students'),
                      ),
                    _MoreRow(
                      icon: Icons.folder_outlined,
                      color: Colors.deepPurple,
                      title: 'Resources',
                      subtitle: 'Files, links and learning materials',
                      onTap: () => context.push(
                        '/staff/classes/${active.classId}/resources',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x3l),
                const _SectionTitle('Academic tools'),
                const SizedBox(height: AppSpacing.m),
                _RowGroup(
                  rows: [
                    if (canSeeExamFactory)
                      _MoreRow(
                        icon: Icons.quiz_outlined,
                        color: AppColors.primary(context),
                        title: 'Exam question submissions',
                        subtitle: 'Exam Factory',
                        onTap: () =>
                            context.push('/staff/exam-factory/my-questions'),
                      ),
                    _MoreRow(
                      icon: Icons.bar_chart_outlined,
                      color: AppColors.success(context),
                      title: 'Marks history',
                      subtitle: 'Review submitted subject marks',
                      onTap: () => context.push('/staff/marks/history'),
                    ),
                    if (active.can(Permission.classPerformanceView))
                      _MoreRow(
                        icon: Icons.trending_up_outlined,
                        color: Colors.deepPurple,
                        title: 'Class performance',
                        subtitle: 'Attendance and academic trends',
                        onTap: () => context.push('/staff/class-analytics'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x3l),
                const _SectionTitle('Account & support'),
                const SizedBox(height: AppSpacing.m),
                _RowGroup(
                  rows: [
                    _MoreRow(
                      icon: Icons.person_outline,
                      color: AppColors.primary(context),
                      title: 'My profile',
                      onTap: () => context.push('/staff/more/edit-profile'),
                    ),
                    _MoreRow(
                      icon: Icons.settings_outlined,
                      color: AppColors.textSecondary(context),
                      title: 'Settings',
                      onTap: () => context.push('/staff/more/security-privacy'),
                    ),
                    _MoreRow(
                      icon: Icons.help_outline,
                      color: Colors.deepPurple,
                      title: 'Help & support',
                      onTap: () => context.push('/staff/more/help-center'),
                    ),
                    _MoreRow(
                      icon: Icons.logout_outlined,
                      color: AppColors.danger(context),
                      title: 'Sign out',
                      destructive: true,
                      onTap: () => _confirmSignOut(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.active,
    required this.state,
    required this.unreadCount,
    required this.onSwitch,
  });
  final UserEntity user;
  final ActiveResponsibilityContext active;
  final ClassTeacherContextState state;
  final int unreadCount;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    final classLabel = [
      active.className,
      active.streamName,
    ].where((part) => part != null && part.isNotEmpty).join(' ');
    final hasAlternatives = state.available.length > 1;
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: hasAlternatives ? onSwitch : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '${classLabel.isEmpty ? 'No class assigned' : classLabel} • Class Teacher',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkResponse(
                onTap: hasAlternatives
                    ? onSwitch
                    : () => context.push('/staff/more/edit-profile'),
                radius: 28,
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.surfaceContainer(context),
                  backgroundImage: user.photoUrl?.isNotEmpty == true
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl?.isNotEmpty == true
                      ? null
                      : Text(
                          initials.isEmpty ? '?' : initials,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.information(context),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (hasAlternatives)
            IconButton(
              tooltip: 'Switch account role',
              onPressed: onSwitch,
              icon: const Icon(Icons.expand_more, size: 20),
            ),
        ],
      ),
    );
  }
}

/// The header opens one compact account sheet instead of duplicating identity
/// in the page chrome. Assignment ids come from the validated context state;
/// the sheet cannot invent a role or class.
class _AccountRoleSheet extends StatelessWidget {
  const _AccountRoleSheet({required this.user, required this.state});
  static const profileAction = '__profile__';
  final UserEntity user;
  final ClassTeacherContextState state;

  static Future<String?> show(
    BuildContext context, {
    required UserEntity user,
    required ClassTeacherContextState state,
  }) => showModalBottomSheet<String>(
    context: context,
    builder: (_) => _AccountRoleSheet(user: user, state: state),
  );

  @override
  Widget build(BuildContext context) {
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((v) => v.isNotEmpty)
        .take(2)
        .map((v) => v[0])
        .join()
        .toUpperCase();
    final activeId = state.active?.roleAssignmentId;
    return SafeArea(
      child: Material(
        color: AppColors.surfaceElevated(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.m,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: user.photoUrl?.isNotEmpty == true
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl?.isNotEmpty == true
                        ? null
                        : Text(initials.isEmpty ? '?' : initials),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isEmpty ? 'Your account' : user.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          user.schoolName?.isNotEmpty == true
                              ? user.schoolName!
                              : 'Current institution',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              ...state.available.map(
                (assignment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    assignment.roleType == StaffResponsibilityType.classTeacher
                        ? Icons.people_outline
                        : Icons.menu_book_outlined,
                    color: assignment.id == activeId
                        ? AppColors.information(context)
                        : AppColors.textSecondary(context),
                  ),
                  title: Text(assignment.displayLabel),
                  subtitle: Text(assignment.roleType.label),
                  trailing: assignment.id == activeId
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.information(context),
                        )
                      : null,
                  onTap: assignment.id == activeId
                      ? null
                      : () => Navigator.pop(context, assignment.id),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: const Text('My profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, profileAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 270,
    child: AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

class _RowGroup extends StatelessWidget {
  const _RowGroup({required this.rows});
  final List<Widget> rows;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: List.generate(
        rows.length,
        (index) => Column(
          children: [
            rows[index],
            if (index < rows.length - 1)
              Divider(height: 1, color: AppColors.border(context)),
          ],
        ),
      ),
    ),
  );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.badge = 0,
    this.destructive = false,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final int badge;
  final bool destructive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    child: ListTile(
      minVerticalPadding: 10,
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: destructive ? AppColors.danger(context) : null,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(
                '$badge',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
  );
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();
  @override
  Widget build(BuildContext context) => const ListTile(
    leading: Icon(Icons.cloud_off_outlined),
    title: Text('Showing cached data'),
    dense: true,
  );
}

class _MoreSkeleton extends StatelessWidget {
  const _MoreSkeleton();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 120, height: 24),
          SizedBox(height: 24),
          Skeleton(height: 80),
          SizedBox(height: 16),
          Skeleton(height: 240),
        ],
      ),
    ),
  );
}

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text(
        'Any work waiting to sync will remain queued and sync after you sign in again.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialog, true),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    context.read<AuthBloc>().add(LogoutPressed());
    context.go('/welcome');
  }
}
