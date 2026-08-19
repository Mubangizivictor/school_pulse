import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/audit_log.dart';
import '../../data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../screens/access_codes_screen.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AdminAppBar(
        title: 'Account Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/staff/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/staff/more/help-center'),
          ),
        ],
      ),
      body: const UsersOverviewView(),
    );
  }
}

class UsersOverviewView extends StatelessWidget {
  const UsersOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStats(context),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        QuickActionGrid(
          items: [
            QuickActionItem(
              label: 'Add Staff',
              icon: Icons.person_add_outlined,
              color: AppColors.primary(context),
              onTap: () => context.push('/staff/admin/users/add-staff'),
            ),
            QuickActionItem(
              label: 'Add Student',
              icon: Icons.school_outlined,
              color: AppColors.secondary(context),
              onTap: () {
                final auth = context.read<AuthBloc>().state;
                if (auth is AuthAuthenticated) {
                  context.push(
                    '/staff/admin/admissions/new',
                    extra: auth.user.schoolId,
                  );
                }
              },
            ),
            QuickActionItem(
              label: 'Add Parents',
              icon: Icons.person_add_outlined,
              color: AppColors.success(context),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccessCodesScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Recent Activity',
          actionLabel: 'View All',
          onActionPressed: () => context.push('/staff/admin/audit-log'),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AuditLog>>(
          stream: schoolId == null
              ? const Stream.empty()
              : di.sl<AuditRepository>().watchRecentLogs(
                  limit: 5,
                  schoolId: schoolId,
                ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: SchoolPulseLoader(),
                ),
              );
            }
            final logs = snapshot.data!;
            if (logs.isEmpty) {
              return const AppCard(
                child: Center(child: Text('No recent activity found')),
              );
            }
            return Column(
              children: logs
                  .map<Widget>((log) => _ActivityItem(log: log))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return FutureBuilder(
      future: di.sl<GetAdminDashboardStats>()(const AdminDashboardStatsParams()),
      builder: (context, snapshot) {
        final stats = snapshot.data?.getOrElse(
          () => const AdminDashboardStats(
            activeStaffCount: 0,
            totalStudentsCount: 0,
            visitorsTodayCount: 0,
            activeVisitorsCount: 0,
            systemHealth: 100,
          ),
        );

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Total Staff',
                    value: (stats?.activeStaffCount ?? 0).toDouble(),
                    icon: Icons.people_alt_outlined,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Students',
                    value: (stats?.totalStudentsCount ?? 0).toDouble(),
                    icon: Icons.school_outlined,
                    color: AppColors.secondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Visitors Today',
                    value: (stats?.visitorsTodayCount ?? 0).toDouble(),
                    icon: Icons.family_restroom_outlined,
                    color: AppColors.success(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'System Health',
                    value: stats?.systemHealth ?? 100,
                    suffix: '%',
                    icon: Icons.bolt_outlined,
                    color: AppColors.information(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final AuditLog log;
  const _ActivityItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(
                int.parse('0x${log.colorHex}'),
              ).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconData(log.iconName),
              color: Color(int.parse('0x${log.colorHex}')),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  log.description,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTimestamp(log.timestamp),
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 11),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'person_add':
        return Icons.person_add;
      case 'gpp_maybe':
        return Icons.gpp_maybe;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'lock_reset':
        return Icons.lock_reset;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}';
  }
}
