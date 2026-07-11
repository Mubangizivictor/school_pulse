import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: Row(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(context),
                        const SizedBox(height: 24),
                        _buildHighLevelStats(context),
                        const SizedBox(height: 32),
                        _buildMainGrid(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('School Management Console', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications_none_outlined), onPressed: () {}),
        const SizedBox(width: 16),
        _AdminProfileToggle(),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = (state is AuthAuthenticated) ? state.user.name : 'Administrator';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $name', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Today is Monday, October 23rd • Term 3 - Week 6', style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        );
      },
    );
  }

  Widget _buildHighLevelStats(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DashboardStatCard(title: 'System Health', value: 100, suffix: '%', icon: Icons.cloud_done, color: Colors.teal, trend: 'All systems live')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Visitors Today', value: 12, icon: Icons.people_outline, color: Colors.blue, trend: '4 currently on site')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Active Staff', value: 48, icon: Icons.badge, color: Colors.indigo, trend: '2 pending sync')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Storage Used', value: 42, suffix: '%', icon: Icons.storage, color: Colors.orange, trend: '2.4 TB free')),
      ],
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildShortcutSection(context),
              const SizedBox(height: 24),
              _buildDataHealth(context),
              const SizedBox(height: 24),
              _buildRecentActivityLog(context),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildServiceStatus(context),
              const SizedBox(height: 24),
              _buildSchoolAnnouncements(context),
              const SizedBox(height: 24),
              _buildSystemAlerts(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System & Front Desk Commands', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _AdminShortcut(
                icon: Icons.badge, 
                label: 'Staff Accounts', 
                color: Colors.orange, 
                onTap: () => context.go('/staff/admin/users?tab=1'),
              ),
              _AdminShortcut(
                icon: Icons.qr_code_2, 
                label: 'Parent Codes', 
                color: Colors.teal, 
                onTap: () => context.go('/staff/admin/users?tab=2'),
              ),
              _AdminShortcut(
                icon: Icons.transfer_within_a_station, 
                label: 'Visitor Log', 
                color: Colors.purple, 
                onTap: () => context.go('/staff/admin/visitors'),
              ),
              _AdminShortcut(
                icon: Icons.calendar_month, 
                label: 'Appointments', 
                color: Colors.blue, 
                onTap: () {},
              ),
              _AdminShortcut(
                icon: Icons.how_to_reg, 
                label: 'Attendance', 
                color: Colors.cyan, 
                onTap: () => context.go('/staff/admin/staff-attendance'),
              ),
              _AdminShortcut(
                icon: Icons.account_tree, 
                label: 'Structure', 
                color: Colors.indigo, 
                onTap: () => context.go('/staff/admin/structure'),
              ),
              _AdminShortcut(
                icon: Icons.campaign, 
                label: 'Broadcast', 
                color: Colors.red, 
                onTap: () => context.go('/staff/admin/broadcast-sms'),
              ),
              _AdminShortcut(
                icon: Icons.settings, 
                label: 'Config', 
                color: Colors.grey, 
                onTap: () => context.go('/staff/admin/config'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatus(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Service Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _StatusRow(label: 'Database (Firestore)', status: 'Operational', color: Colors.green),
          _StatusRow(label: 'SMS Gateway', status: 'Operational', color: Colors.green),
          _StatusRow(label: 'File Storage', status: 'Operational', color: Colors.green),
          _StatusRow(label: 'Auth Service', status: 'High Latency', color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildDataHealth(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Integrity & Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: _TechMetric(label: 'Sync Rate', value: '99.9%', color: Colors.blue)),
              Expanded(child: _TechMetric(label: 'Error Logs', value: '12', color: Colors.orange)),
              Expanded(child: _TechMetric(label: 'Uptime', value: '14d', color: Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityLog(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('System Audit Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final logs = [
                {'title': 'New Staff Account', 'desc': 'Account created for Mrs. Namono', 'time': '10m ago', 'icon': Icons.person_add},
                {'title': 'Parent Code Regenerated', 'desc': 'Family: Mugisha (s1, s4)', 'time': '2h ago', 'icon': Icons.refresh},
                {'title': 'System Config Updated', 'desc': 'Modified SMS Gateway settings', 'time': '4h ago', 'icon': Icons.settings},
                {'title': 'Security Audit', 'desc': 'Periodic permissions review completed', 'time': 'Yesterday', 'icon': Icons.security},
              ];
              final log = logs[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, child: Icon(log['icon'] as IconData, size: 18)),
                title: Text(log['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(log['desc'] as String, style: const TextStyle(fontSize: 12)),
                trailing: Text(log['time'] as String, style: Theme.of(context).textTheme.labelSmall),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolAnnouncements(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Staff Notices', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _NoticeItem(title: 'Annual Sports Day', subtitle: 'Scheduled for Friday, 27th Oct'),
          _NoticeItem(title: 'End of Term Exams', subtitle: 'Timetables to be released tomorrow'),
        ],
      ),
    );
  }

  Widget _buildSystemAlerts(BuildContext context) {
    return AppCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Pending Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            SizedBox(height: 12),
            Text('• 3 Staff profiles missing NID numbers', style: TextStyle(fontSize: 13)),
            Text('• Backup failed for 2nd Oct (Retrying...)', style: TextStyle(fontSize: 13)),
            Text('• 14 Unresolved parent queries (>24h)', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _AdminShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminShortcut({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TechMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TechMetric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _StatusRow({required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _NoticeItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 32, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProfileToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final initials = (state is AuthAuthenticated) ? state.user.name[0] : 'A';
        final roleName = (state is AuthAuthenticated) ? UserRoleDisplay.name(state.user.role) : 'Admin';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Theme.of(context).colorScheme.primary, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Text(roleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        );
      },
    );
  }
}
