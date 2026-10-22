import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/dean/presentation/widgets/glass_icon_button.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/curriculum_management_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/observations/class_observations_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/homework_monitoring_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/approvals/dean_approvals_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/interventions/academic_interventions_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/analytics/performance_analytics_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/academic_calendar_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/schemes_of_work_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/meetings_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/announcements_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/documents_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/academic_reports_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/dean_settings_screen.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class _MoreItem {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final WidgetBuilder builder;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.builder,
  });
}

/// More menu — root of the More tab. Gradient header + a single "Academic
/// Management" section of rows, each with a colored icon, title and
/// one-line description, routing to real dean sub-pages.
class DeanMoreScreen extends StatelessWidget {
  const DeanMoreScreen({super.key});

  static final _items = [
    _MoreItem(
      icon: Icons.menu_book_rounded,
      label: 'Curriculum & Subjects',
      description: 'Manage curriculum, subjects and learning areas',
      color: Colors.black,
      builder: (_) => const CurriculumManagementScreen(),
    ),
    _MoreItem(
      icon: Icons.visibility_rounded,
      label: 'Class Observations',
      description: 'Record and review classroom observations',
      color: Colors.black,
      builder: (_) => const ClassObservationsScreen(),
    ),
    _MoreItem(
      icon: Icons.assignment_turned_in_rounded,
      label: 'Homework Monitoring',
      description: 'Track homework assignments and submissions',
      color: Colors.black,
      builder: (_) => const HomeworkMonitoringScreen(),
    ),
    _MoreItem(
      icon: Icons.verified_user_rounded,
      label: 'Report Approvals',
      description: 'Review and approve academic reports',
      color: Colors.black,
      builder: (_) => const DeanApprovalsScreen(),
    ),
    _MoreItem(
      icon: Icons.track_changes_rounded,
      label: 'Interventions',
      description: 'Create and manage academic interventions',
      color: Colors.black,
      builder: (_) => const AcademicInterventionsScreen(),
    ),
    _MoreItem(
      icon: Icons.bar_chart_rounded,
      label: 'Performance & Reports',
      description: 'Monitor performance, reports and readiness',
      color: Colors.black,
      builder: (_) => const PerformanceAnalyticsScreen(),
    ),
    _MoreItem(
      icon: Icons.calendar_month_rounded,
      label: 'Academic Calendar',
      description: 'View academic calendar and key activities',
      color: Colors.black,
      builder: (_) => const AcademicCalendarScreen(),
    ),
    _MoreItem(
      icon: Icons.schema_rounded,
      label: 'Schemes of Work',
      description: 'Create and review schemes of work',
      color: Colors.black,
      builder: (_) => const SchemesOfWorkScreen(),
    ),
    _MoreItem(
      icon: Icons.groups_2_rounded,
      label: 'Meetings',
      description: 'Schedule and manage academic meetings',
      color: Colors.black,
      builder: (_) => const MeetingsScreen(),
    ),
    _MoreItem(
      icon: Icons.campaign_rounded,
      label: 'Announcements',
      description: 'Send announcements to staff and students',
      color: Colors.black,
      builder: (_) => const AnnouncementsScreen(),
    ),
    _MoreItem(
      icon: Icons.folder_rounded,
      label: 'Documents',
      description: 'Access academic documents and resources',
      color: Colors.black,
      builder: (_) => const DocumentsScreen(),
    ),
    _MoreItem(
      icon: Icons.summarize_rounded,
      label: 'Academic Reports',
      description: 'Generate and export academic reports',
      color: Colors.black,
      builder: (_) => const AcademicReportsScreen(),
    ),
    _MoreItem(
      icon: Icons.settings_rounded,
      label: 'Settings',
      description: 'Configure academic preferences and options',
      color: Colors.black,
      builder: (_) => const DeanSettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            sliver: SliverList.list(
              children: [
                _SectionLabel(
                  icon: Icons.school_rounded,
                  title: 'Academic Management',
                ),
                const SizedBox(height: AppSpacing.l),
                for (final item in _items)
                  _MoreRow(
                    item: item,
                    onTap: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: item.builder)),
                  ),
                const SizedBox(height: AppSpacing.l),
                _LogoutRow(onTap: () => _confirmLogout(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(dialogContext);
              context.go('/welcome');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        decoration: BoxDecoration(
          color: AppColors.danger(context).withValues(alpha: 0.12),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.danger(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.of(context).padding.top + AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.x2l,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated(context), scheme.primary],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage all academic operations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final themeProvider = context.watch<ThemeProvider>();
              final icon = switch (themeProvider.themeMode) {
                ThemeMode.light => Icons.light_mode_rounded,
                ThemeMode.dark => Icons.dark_mode_rounded,
                ThemeMode.system => Icons.brightness_auto_rounded,
              };
              return GlassIconButton(
                icon: icon,
                tooltip: 'Toggle theme',
                onPressed: () {
                  final next = switch (themeProvider.themeMode) {
                    ThemeMode.light => ThemeMode.dark,
                    ThemeMode.dark => ThemeMode.system,
                    ThemeMode.system => ThemeMode.light,
                  };
                  themeProvider.setThemeMode(next);
                },
              );
            },
          ),
          const SizedBox(width: AppSpacing.m),
          GlassIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            tooltip: 'Messages',
            onPressed: () => context.push('/staff/messages'),
          ),
          const SizedBox(width: AppSpacing.m),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.primary(context)),
            ),
            child: const NotificationBellButton(),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.s),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: Divider(color: AppColors.border(context), height: 1)),
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  final _MoreItem item;
  final VoidCallback onTap;

  const _MoreRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: AppRadius.medium,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}
