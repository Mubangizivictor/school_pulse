import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/admin/admin_search_delegate.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/inventory/presentation/screens/stores_assets_dashboard.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<AdminDashboardBloc>()..add(LoadAdminDashboardStats()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        body: Row(
          children: [
            Expanded(
              child: Builder(
                builder: (context) => RefreshIndicator(
                  onRefresh: () async {
                    context.read<AdminDashboardBloc>().add(
                      LoadAdminDashboardStats(),
                    );
                    await context.read<AdminDashboardBloc>().stream.firstWhere(
                      (state) => state is! AdminDashboardLoading,
                    );
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInSlide(
                                duration: const Duration(milliseconds: 400),
                                child: _buildHighLevelStats(context),
                              ),
                              const SizedBox(height: 15),
                              FadeInSlide(
                                delay: const Duration(milliseconds: 100),
                                child: _buildMainGrid(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return SliverAppBar(
      pinned: true,
      expandedHeight: isDesktop ? 76 : 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
      title: isDesktop
          ? Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pulse Console',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Cloud Infrastructure • Term 3',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => showSearch(
                      context: context,
                      delegate: AdminSearchDelegate(),
                    ),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 18,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search anything (staff, students, settings...)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            )
          : const Text(
              'Pulse Console',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
      actions: [
        if (isDesktop) ...[_buildLiveIndicator(), const SizedBox(width: 16)],
        NotificationBellButton(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        const SizedBox(width: 8),
        const _LogoutButton(),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'SYSTEM LIVE',
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighLevelStats(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is AdminDashboardError) {
          return AlertBanner(
            title: 'Couldn\'t load dashboard stats',
            message:
                'Something went wrong on our end. Pull to refresh or check back shortly.',
            color: Theme.of(context).extension<SemanticColors>()!.error,
            icon: Icons.error_outline_rounded,
          );
        }
        if (state is AdminDashboardLoaded) {
          final stats = state.stats;
          final screenWidth = MediaQuery.of(context).size.width;
          final isMobile = screenWidth < 600;

          if (isMobile) {
            // Row/Expanded instead of a fixed-aspect-ratio grid: each card
            // sizes to its own content height, so it's structurally
            // impossible for the number/label text to overflow the cell
            // no matter the text-scale factor or content length.
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Health',
                        value: stats.systemHealth,
                        suffix: '%',
                        icon: Icons.cloud_done_rounded,
                        color: Colors.teal,
                        trend: 'STABLE',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Visitors',
                        value: stats.visitorsTodayCount.toDouble(),
                        icon: Icons.people_rounded,
                        color: Colors.blue,
                        trend: '${stats.activeVisitorsCount} LIVE',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Staff',
                        value: stats.activeStaffCount.toDouble(),
                        icon: Icons.badge_rounded,
                        color: Colors.indigo,
                        trend: 'VERIFIED',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Students',
                        value: stats.totalStudentsCount.toDouble(),
                        icon: Icons.school_rounded,
                        color: Colors.orange,
                        trend: 'ENROLLED',
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: 'System Health',
                  value: stats.systemHealth,
                  suffix: '%',
                  icon: Icons.cloud_done_rounded,
                  color: Colors.teal,
                  trend: 'STABLE',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardStatCard(
                  title: 'Visitors Today',
                  value: stats.visitorsTodayCount.toDouble(),
                  icon: Icons.people_rounded,
                  color: Colors.blue,
                  trend: '${stats.activeVisitorsCount} LIVE',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardStatCard(
                  title: 'Active Staff',
                  value: stats.activeStaffCount.toDouble(),
                  icon: Icons.badge_rounded,
                  color: Colors.indigo,
                  trend: 'VERIFIED',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardStatCard(
                  title: 'Total Students',
                  value: stats.totalStudentsCount.toDouble(),
                  icon: Icons.school_rounded,
                  color: Colors.orange,
                  trend: 'ENROLLED',
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (!isWide) {
          return Column(
            children: [
              _buildShortcutSection(context),
              const SizedBox(height: 24),
              _buildSystemAlerts(context),
              const SizedBox(height: 24),
              _buildServiceStatus(context),
            ],
          );
        }

        final isExtraWide = constraints.maxWidth > 1100;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildShortcutSection(context),
                  const SizedBox(height: 24),
                  if (isExtraWide)
                    _buildServiceStatus(context)
                  else ...[
                    _buildServiceStatus(context),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(children: [_buildSystemAlerts(context)]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShortcutSection(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: MediaQuery.of(context).size.width > 1200
          ? 6
          : (MediaQuery.of(context).size.width > 600 ? 4 : 3),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.5 : 1.1,
      children: [
        _AdminShortcut(
          icon: Icons.people_rounded,
          label: 'Users',
          color: Colors.blueAccent,
          onTap: () => context.go('/staff/admin/users'),
        ),
        _AdminShortcut(
          icon: Icons.meeting_room_rounded,
          label: 'Visitors',
          color: Colors.purple,
          onTap: () => context.go('/staff/security/visitors'),
        ),
        _AdminShortcut(
          icon: Icons.fact_check_rounded,
          label: 'Take Attendance',
          color: Colors.teal,
          onTap: () => context.go('/staff/attendance'),
        ),
        _AdminShortcut(
          icon: Icons.event_available_rounded,
          label: 'Appointments',
          color: Colors.lightBlue,
          onTap: () => context.go('/staff/admin/appointments'),
        ),
        _AdminShortcut(
          icon: Icons.badge_rounded,
          label: 'Batch ID Cards',
          color: Colors.teal,
          onTap: () => context.go('/staff/admin/batch-id-cards'),
        ),
        _AdminShortcut(
          icon: Icons.campaign_rounded,
          label: 'Broadcast',
          color: Colors.red,
          onTap: () => context.go('/staff/admin/broadcast-sms'),
        ),
        _AdminShortcut(
          icon: Icons.warehouse_rounded,
          label: 'Procurement',
          color: Colors.deepPurple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StoresAssetsDashboard(),
            ),
          ),
        ),
        _AdminShortcut(
          icon: Icons.local_library_rounded,
          label: 'Library',
          color: Colors.orange,
          onTap: () => context.go(
            '/staff/library',
          ), // Assuming Librarian/Admin dashboard path
        ),
      ],
    );
  }

  Widget _buildServiceStatus(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final services = state is AdminDashboardLoaded
            ? state.stats.serviceStatuses
            : const <ServiceStatusItem>[];
        final allOperational = services.every((s) => s.status == 'Operational');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Live Services',
              trailing: StatusBadge(
                label: services.isEmpty
                    ? 'Checking...'
                    : (allOperational ? 'Global: Stable' : 'Global: Degraded'),
                color: services.isEmpty
                    ? Colors.grey
                    : (allOperational ? Colors.green : Colors.orange),
                icon: allOperational
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
              ),
            ),
            if (services.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Skeleton(height: 48),
              )
            else
              ...services.map(
                (s) => _StatusRow(
                  label: s.label,
                  status: s.status,
                  color: _statusColor(s.status),
                ),
              ),
          ],
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Operational':
        return Colors.green;
      case 'Degraded':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _buildSystemAlerts(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final items = <String>[];
        if (state is AdminDashboardLoaded) {
          final stats = state.stats;
          if (stats.staffPendingSetupCount > 0) {
            items.add(
              '${stats.staffPendingSetupCount} staff account${stats.staffPendingSetupCount == 1 ? '' : 's'} pending first-login setup',
            );
          }
          if (stats.overdueVisitorsCount > 0) {
            items.add(
              '${stats.overdueVisitorsCount} visitor${stats.overdueVisitorsCount == 1 ? '' : 's'} on premises over 2 hours - check them out',
            );
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (items.isEmpty ? semantic.success : semantic.warning)
                .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    items.isEmpty
                        ? Icons.check_circle_outline_rounded
                        : Icons.warning_amber_rounded,
                    color: items.isEmpty ? semantic.success : semantic.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: items.isEmpty
                          ? semantic.success
                          : semantic.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Text(
                  'All clear - nothing needs your attention.',
                  style: TextStyle(fontSize: 13),
                )
              else
                ...items.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $text',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      showShadow: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.status,
    required this.color,
  });

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
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  void _handleLogout(BuildContext context) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Logout',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.logout_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      tooltip: 'Logout',
      onPressed: () => _handleLogout(context),
    );
  }
}
