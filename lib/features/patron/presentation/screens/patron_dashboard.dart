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

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patron Dashboard (Boys)'),
        actions: const [NotificationBellButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FadeInSlide(
              child: Text(
                'Boarding Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<PatronBloc, PatronState>(
              buildWhen: (previous, current) => current is DashboardOverviewLoaded || current is PatronLoading,
              builder: (context, state) {
                if (state is DashboardOverviewLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(context, state.overview, semanticColors),
                      const SizedBox(height: 16),
                      _buildAlerts(context, state.overview, semanticColors),
                    ],
                  );
                }
                return const _StatsSkeleton();
              },
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Management Hub'),
            const SizedBox(height: 12),
            _buildManagementGrid(context),
            const SizedBox(height: 24),
            SectionHeader(title: 'Dormitories'),
            const SizedBox(height: 12),
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
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Recent Announcements'),
            const SizedBox(height: 12),
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
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, PatronDashboardOverview data, SemanticColors semanticColors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isMobile ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            DashboardStatCard(
              title: 'Boarders',
              value: data.totalStudents.toDouble(),
              icon: Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            DashboardStatCard(
              title: 'Present',
              value: data.studentsPresent.toDouble(),
              icon: Icons.check_circle_outline,
              color: semanticColors.success,
            ),
            DashboardStatCard(
              title: 'On Leave',
              value: data.studentsOnLeave.toDouble(),
              icon: Icons.exit_to_app,
              color: semanticColors.warning,
            ),
            DashboardStatCard(
              title: 'Bed Occupancy',
              value: data.totalBeds == 0 ? 0 : (data.occupiedBeds / data.totalBeds) * 100,
              icon: Icons.bed_outlined,
              color: Colors.blue,
              suffix: '%',
            ),
            DashboardStatCard(
              title: 'Discipline Cases',
              value: data.openDisciplineCases.toDouble(),
              icon: Icons.gavel_outlined,
              color: semanticColors.error,
            ),
            DashboardStatCard(
              title: 'Welfare Concerns',
              value: data.pendingWelfareConcerns.toDouble(),
              icon: Icons.favorite_outline,
              color: Colors.pink,
            ),
            DashboardStatCard(
              title: 'Pending Leave',
              value: data.pendingLeaveRequests.toDouble(),
              icon: Icons.pending_actions_outlined,
              color: Colors.purple,
            ),
            DashboardStatCard(
              title: 'Missing',
              value: data.missingStudentCount.toDouble(),
              icon: Icons.person_search_outlined,
              color: semanticColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlerts(BuildContext context, PatronDashboardOverview data, SemanticColors semanticColors) {
    final alerts = <Widget>[];
    if (data.missingStudentCount > 0) {
      alerts.add(_AlertBanner(
        icon: Icons.person_search_outlined,
        color: semanticColors.error,
        message: '${data.missingStudentCount} boarder(s) unaccounted for at last roll call.',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardingAttendanceScreen())),
      ));
    }
    if (data.overdueLeaveCount > 0) {
      alerts.add(_AlertBanner(
        icon: Icons.watch_later_outlined,
        color: semanticColors.warning,
        message: '${data.overdueLeaveCount} student(s) overdue from leave.',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveManagementScreen())),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DormitoryManagementScreen())),
        ),
        QuickActionItem(
          label: 'Beds',
          icon: Icons.bed_outlined,
          color: Colors.indigo,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DormitoryManagementScreen())),
        ),
        QuickActionItem(
          label: 'Attendance',
          icon: Icons.how_to_reg_outlined,
          color: Colors.green,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardingAttendanceScreen())),
        ),
        QuickActionItem(
          label: 'Leave',
          icon: Icons.exit_to_app,
          color: Colors.deepOrange,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveManagementScreen())),
        ),
        QuickActionItem(
          label: 'Welfare',
          icon: Icons.favorite_outline,
          color: Colors.pink,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WelfareManagementScreen())),
        ),
        QuickActionItem(
          label: 'Discipline',
          icon: Icons.gavel_outlined,
          color: Colors.red,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisciplineManagementScreen())),
        ),
        QuickActionItem(
          label: 'Communication',
          icon: Icons.campaign_outlined,
          color: Colors.teal,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunicationScreen())),
        ),
        QuickActionItem(
          label: 'Reports',
          icon: Icons.assessment_outlined,
          color: Colors.purple,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
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

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => const Skeleton(borderRadius: 12)),
    );
  }
}
