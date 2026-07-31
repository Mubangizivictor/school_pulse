import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/patron/presentation/screens/boarding_attendance_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/communication_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/discipline_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/dormitory_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/leave_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/reports_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/welfare_management_screen.dart';

class PatronDashboard extends StatefulWidget {
  const PatronDashboard({super.key});

  @override
  State<PatronDashboard> createState() => _PatronDashboardState();
}

class _PatronDashboardState extends State<PatronDashboard> {
  String? _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : null;
  }

  void _loadData() {
    final schoolId = _schoolId(context);
    if (schoolId != null) {
      context.read<PatronBloc>().add(WatchDashboardOverview(schoolId));
    }
    context.read<PatronBloc>().add(WatchDormitories());
    context.read<PatronBloc>().add(WatchAnnouncements());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // PatronBloc is provided once at the app root (see main.dart), so this
  // screen's State - and its original stream subscriptions - survive
  // Navigator.push/pop instead of being recreated. Without this,
  // navigating to another patron screen and back leaves the dashboard
  // showing whatever it last rendered before the push, since initState()
  // never runs again. Re-running _loadData() on return keeps it fresh.
  void _navigateAndReload(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'User';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const SizedBox(height: 48), // Space for status bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ],
                  ),
                ),
                const NotificationBellButton(),
              ],
            ),
            const SizedBox(height: 20),
            _buildManagementGrid(context),
            const SizedBox(height: 12),
            BlocBuilder<PatronBloc, PatronState>(
              buildWhen: (previous, current) => current is DashboardOverviewLoaded,
              builder: (context, state) {
                if (state is DashboardOverviewLoaded &&
                    (state.overview.missingStudentCount > 0 || state.overview.overdueLeaveCount > 0)) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAlerts(context, state.overview, semanticColors),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SectionHeader(title: 'Dormitories'),
            BlocBuilder<PatronBloc, PatronState>(
              buildWhen: (previous, current) => current is DormitoriesLoaded,
              builder: (context, state) {
                if (state is DormitoriesLoaded) {
                  if (state.dormitories.isEmpty) {
                    return const EmptyState(
                      icon: Icons.hotel_outlined,
                      title: 'No Dormitories Yet',
                      message: 'Add a dormitory to start allocating boarders.',
                    );
                  }
                  return Column(
                    children: state.dormitories
                        .map((dorm) => _DormitoryStatusCard(dorm: dorm))
                        .toList(),
                  );
                }
                return const Skeleton(height: 96, borderRadius: 12);
              },
            ),
            const SizedBox(height: 12),
            const SectionHeader(title: 'Recent Announcements'),
            BlocBuilder<PatronBloc, PatronState>(
              buildWhen: (previous, current) => current is AnnouncementsLoaded,
              builder: (context, state) {
                if (state is AnnouncementsLoaded) {
                  if (state.announcements.isEmpty) {
                    return const EmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'No Announcements',
                      message: 'Boarding announcements will appear here.',
                    );
                  }
                  return Column(
                    children: state.announcements.take(3).map((a) {
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.campaign_outlined, color: Colors.orange),
                          title: Text(a.title),
                          subtitle: Text(a.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Skeleton(height: 72, borderRadius: 12);
              },
            ),
            const SizedBox(height: 20),
            _AnalyticsCta(onTap: () => _navigateAndReload(const ReportsScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(BuildContext context, PatronDashboardOverview data, SemanticColors semanticColors) {
    final alerts = <Widget>[];
    if (data.missingStudentCount > 0) {
      alerts.add(_AlertBanner(
        icon: Icons.person_search_outlined,
        color: semanticColors.error,
        message: '${data.missingStudentCount} boarder(s) unaccounted for at last roll call.',
        onTap: () => _navigateAndReload(const BoardingAttendanceScreen()),
      ));
    }
    if (data.overdueLeaveCount > 0) {
      alerts.add(_AlertBanner(
        icon: Icons.watch_later_outlined,
        color: semanticColors.warning,
        message: '${data.overdueLeaveCount} student(s) overdue from leave.',
        onTap: () => _navigateAndReload(const LeaveManagementScreen()),
      ));
    }
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(children: alerts);
  }

  Widget _buildManagementGrid(BuildContext context) {
    return QuickActionGrid(
      items: [
        QuickActionItem(
          label: 'Dormitories',
          icon: Icons.hotel_outlined,
          color: Colors.blue,
          onTap: () => _navigateAndReload(const DormitoryManagementScreen()),
        ),
        QuickActionItem(
          label: 'Beds',
          icon: Icons.bed_outlined,
          color: Colors.indigo,
          onTap: () => _navigateAndReload(const DormitoryManagementScreen()),
        ),
        QuickActionItem(
          label: 'Attendance',
          icon: Icons.how_to_reg_outlined,
          color: Colors.green,
          onTap: () => _navigateAndReload(const BoardingAttendanceScreen()),
        ),
        QuickActionItem(
          label: 'Leave',
          icon: Icons.exit_to_app,
          color: Colors.deepOrange,
          onTap: () => _navigateAndReload(const LeaveManagementScreen()),
        ),
        QuickActionItem(
          label: 'Welfare',
          icon: Icons.favorite_outline,
          color: Colors.pink,
          onTap: () => _navigateAndReload(const WelfareManagementScreen()),
        ),
        QuickActionItem(
          label: 'Discipline',
          icon: Icons.gavel_outlined,
          color: Colors.red,
          onTap: () => _navigateAndReload(const DisciplineManagementScreen()),
        ),
        QuickActionItem(
          label: 'Communication',
          icon: Icons.campaign_outlined,
          color: Colors.teal,
          onTap: () => _navigateAndReload(const CommunicationScreen()),
        ),
        QuickActionItem(
          label: 'Reports',
          icon: Icons.assessment_outlined,
          color: Colors.purple,
          onTap: () => _navigateAndReload(const ReportsScreen()),
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback onTap;

  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }
}

class _AnalyticsCta extends StatelessWidget {
  final VoidCallback onTap;

  const _AnalyticsCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights_outlined, color: Colors.purple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Boarding Analytics',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Occupancy, discipline, welfare & leave trends',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}

class _DormitoryStatusCard extends StatelessWidget {
  final dynamic dorm;

  const _DormitoryStatusCard({required this.dorm});

  @override
  Widget build(BuildContext context) {
    final occupancy = dorm.capacity == 0 ? 0.0 : dorm.occupantCount / dorm.capacity;
    final isFull = dorm.occupantCount >= dorm.capacity;
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dorm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                StatusBadge(
                  label: isFull ? 'Full' : 'Available',
                  color: isFull ? semanticColors.error : semanticColors.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: occupancy,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  occupancy > 1.0 ? semanticColors.error : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${dorm.occupantCount} / ${dorm.capacity} Occupants', style: Theme.of(context).textTheme.bodySmall),
                if (dorm.roomLeaderName != null)
                  Text(
                    'Leader: ${dorm.roomLeaderName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
