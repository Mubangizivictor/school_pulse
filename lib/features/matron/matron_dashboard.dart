import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';
import 'package:school_pulse/features/matron/presentation/screens/dorm_management_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/boarding_attendance_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/welfare_management_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/boarding_discipline_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/hygiene_management_screen.dart';

class MatronDashboardScreen extends StatefulWidget {
  const MatronDashboardScreen({super.key});

  @override
  State<MatronDashboardScreen> createState() => _MatronDashboardScreenState();
}

class _MatronDashboardScreenState extends State<MatronDashboardScreen> {
  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  String? _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : null;
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(
      MatronDashboardRequested(
        schoolId: _schoolId(context),
        gender: _genderScope(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final genderScope = _genderScope(context);
    final isPatron = genderScope == 'Male';

    return Scaffold(
      body: BlocBuilder<MatronBloc, MatronState>(
        builder: (context, state) {
          if (state is MatronLoading) {
            return const _MatronSkeleton();
          }

          if (state is MatronError) {
            return Center(child: Text(state.message));
          }

          if (state is MatronDashboardLoaded) {
            final data = state.data;
            final authState = context.watch<AuthBloc>().state;
            final userName = authState is AuthAuthenticated ? authState.user.name : 'User';

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MatronBloc>().add(
                  MatronDashboardRequested(
                    schoolId: _schoolId(context),
                    gender: genderScope,
                  ),
                );
              },
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
                  _buildManagementGrid(context, isPatron),
                  const SizedBox(height: 12),
                  const SectionHeader(title: 'Dormitories Status'),
                  ...data.dormitories.map(
                    (dorm) => _DormitoryStatusCard(dorm: dorm),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Boarding Analytics'),
                  const SizedBox(height: 8),
                  _buildStatsGrid(context, data, semanticColors),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    dynamic data,
    SemanticColors semanticColors,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isMobile ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            AnalyticalStatCard(
              title: 'Boarders',
              value: data.totalStudents.toDouble(),
              icon: Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            AnalyticalStatCard(
              title: 'Present',
              value: data.studentsPresent.toDouble(),
              icon: Icons.check_circle_outline,
              color: semanticColors.success,
            ),
            AnalyticalStatCard(
              title: 'Leave',
              value: data.studentsOnLeave.toDouble(),
              icon: Icons.exit_to_app,
              color: semanticColors.warning,
            ),
            AnalyticalStatCard(
              title: 'Discipline',
              value: data.activeDisciplineCases.toDouble(),
              icon: Icons.gavel_outlined,
              color: semanticColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildManagementGrid(BuildContext context, bool isPatron) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: [
        _QuickActionCard(
          label: 'Dormitories',
          icon: Icons.hotel_outlined,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DormManagementScreen()),
          ),
        ),
        _QuickActionCard(
          label: 'Attendance',
          icon: Icons.how_to_reg_outlined,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BoardingAttendanceScreen()),
          ),
        ),
        _QuickActionCard(
          label: 'Welfare',
          icon: Icons.favorite_outline,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WelfareManagementScreen()),
          ),
        ),
        _QuickActionCard(
          label: 'Discipline',
          icon: Icons.gavel_outlined,
          color: Colors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BoardingDisciplineScreen()),
          ),
        ),
        if (!isPatron)
          _QuickActionCard(
            label: 'Hygiene',
            icon: Icons.clean_hands_outlined,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HygieneManagementScreen(),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.05)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DormitoryStatusCard extends StatelessWidget {
  final dynamic dorm;

  const _DormitoryStatusCard({required this.dorm});

  @override
  Widget build(BuildContext context) {
    final occupancy = dorm.occupantCount / dorm.capacity;
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
                Text(
                  dorm.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  occupancy > 1.0
                      ? semanticColors.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dorm.occupantCount} / ${dorm.capacity} Occupants',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (dorm.roomLeaderName != null)
                  Text(
                    'Leader: ${dorm.roomLeaderName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatronSkeleton extends StatelessWidget {
  const _MatronSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: List.generate(
            4,
            (index) => const Skeleton(borderRadius: 16),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: List.generate(
            4,
            (index) => const Skeleton(borderRadius: 16),
          ),
        ),
        const SizedBox(height: 12),
        const Skeleton(width: 160, height: 24, borderRadius: 4),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Skeleton(height: 110, borderRadius: 16),
        )),
      ],
    );
  }
}
