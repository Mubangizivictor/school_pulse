import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import 'school_management_screen.dart';
import 'subscription_plans_screen.dart';
import 'audit_logs_screen.dart';
import 'billing_page.dart';

const _kSections = [
  (icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Overview'),
  (icon: Icons.school_outlined, selectedIcon: Icons.school, label: 'Schools'),
  (icon: Icons.subscriptions_outlined, selectedIcon: Icons.subscriptions, label: 'Plans'),
  (icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Billing'),
  (icon: Icons.history_outlined, selectedIcon: Icons.history, label: 'Audit Logs'),
];

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final content = IndexedStack(
      index: _selectedIndex,
      children: const [
        SuperAdminOverview(),
        SchoolManagementScreen(),
        SubscriptionPlansScreen(),
        BillingPage(),
        AuditLogsScreen(),
      ],
    );

    if (isSuperAdminWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          for (final section in _kSections)
            NavigationDestination(
              icon: Icon(section.icon),
              selectedIcon: Icon(section.selectedIcon),
              label: section.label,
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.bolt, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Pulse Owner',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          for (final (index, section) in _kSections.indexed)
            _SidebarItem(
              icon: section.icon,
              selectedIcon: section.selectedIcon,
              label: section.label,
              isSelected: _selectedIndex == index,
              onTap: () => setState(() => _selectedIndex = index),
            ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Sign Out',
            isSelected: false,
            onTap: () => handleSuperAdminLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          isSelected ? (selectedIcon ?? icon) : icon,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        tileColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
      ),
    );
  }
}

class SuperAdminOverview extends StatelessWidget {
  const SuperAdminOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SuperAdminBloc, SuperAdminState>(
      builder: (context, state) {
        if (state.status == SuperAdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = state.stats;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Platform Overview'),
            actions: isSuperAdminWide(context) ? null : const [SuperAdminLogoutButton()],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Owner',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: isSuperAdminWide(context) ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _StatCard(
                      label: 'Total Schools',
                      value: '${stats['totalSchools'] ?? 0}',
                      icon: Icons.school,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: 'Active Students',
                      value: '${stats['totalStudents'] ?? 0}',
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: 'Monthly Revenue',
                      value: 'UGX ${stats['monthlyRevenue'] ?? 0}',
                      icon: Icons.payments,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      label: 'System Health',
                      value: '99.9%',
                      icon: Icons.speed,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Recent Activity', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      return const ListTile(
                        leading: CircleAvatar(child: Icon(Icons.info_outline)),
                        title: Text('New school registered: Mary Hill Academy'),
                        subtitle: Text('2 hours ago'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
