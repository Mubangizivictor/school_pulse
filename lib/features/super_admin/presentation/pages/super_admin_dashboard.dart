import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import '../../domain/entities/school_application.dart';
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
  (
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Overview',
  ),
  (icon: Icons.school_outlined, selectedIcon: Icons.school, label: 'Schools'),
  (
    icon: Icons.subscriptions_outlined,
    selectedIcon: Icons.subscriptions,
    label: 'Plans',
  ),
  (
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: 'Billing',
  ),
  (
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: 'Audit Logs',
  ),
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
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.x4l),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: PulseLogo(variant: PulseLogoVariant.full, size: 40),
          ),
          const SizedBox(height: AppSpacing.x4l),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              children: [
                for (final (index, section) in _kSections.indexed)
                  _SidebarItem(
                    icon: section.icon,
                    selectedIcon: section.selectedIcon,
                    label: section.label,
                    isSelected: _selectedIndex == index,
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
              ],
            ),
          ),
          const Divider(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            isSelected: false,
            onTap: () => handleSuperAdminLogout(context),
            isDestructive: true,
          ),
          const SizedBox(height: AppSpacing.xl),
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
  final bool isDestructive;

  const _SidebarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.deepOrange
        : (isSelected
              ? AppColors.primary(context)
              : AppColors.textSecondary(context));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? AppColors.primary(context).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            isSelected ? (selectedIcon ?? icon) : icon,
            color: color,
            size: 22,
          ),
          title: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ),
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
          return const Center(child: SchoolPulseLoader());
        }

        final stats = state.stats;
        final recentApplications = List<SchoolApplication>.from(
          state.applications,
        )..sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
            final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Platform Overview'),
            actions: [
              IconButton(
                onPressed: () => context.read<SuperAdminBloc>().add(
                      LoadSuperAdminDashboard(),
                    ),
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
              ),
              if (!isSuperAdminWide(context)) const SuperAdminLogoutButton(),
            ],
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
                const SizedBox(height: 6),
                Text(
                  'Live platform data from School Pulse and public school registrations.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
                      label: 'Active Schools',
                      value: '${stats['activeSchools'] ?? 0}',
                      icon: Icons.verified_outlined,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: 'Pending Reviews',
                      value: '${stats['pendingApplications'] ?? 0}',
                      icon: Icons.rate_review_outlined,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      label: 'Total Students',
                      value: '${stats['totalStudents'] ?? 0}',
                      icon: Icons.people_outline,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Recent Applications', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Card(
                  child: recentApplications.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'No public school applications have been submitted yet.',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentApplications.length > 5
                              ? 5
                              : recentApplications.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final application = recentApplications[index];
                            final date = application.updatedAt ?? application.createdAt;
                            return ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  application.status ==
                                          SchoolApplicationStatus.pendingReview
                                      ? Icons.pending_actions_outlined
                                      : application.status ==
                                              SchoolApplicationStatus.approved
                                          ? Icons.check_rounded
                                          : application.status ==
                                                  SchoolApplicationStatus.rejected
                                              ? Icons.close_rounded
                                              : Icons.edit_note_outlined,
                                ),
                              ),
                              title: Text(
                                application.schoolName.isEmpty
                                    ? 'School registration'
                                    : application.schoolName,
                              ),
                              subtitle: Text(
                                '${application.status.label}${date == null ? '' : ' • ${DateFormat('dd MMM, h:mm a').format(date.toLocal())}'}',
                              ),
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
    return PulseCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
