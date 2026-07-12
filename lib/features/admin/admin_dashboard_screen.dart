import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/admin/admin_search_delegate.dart';
import 'package:school_pulse/features/admin/data/models/visitor.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AdminDashboardBloc>()..add(LoadAdminDashboardStats()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        body: Row(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInSlide(
                            duration: const Duration(milliseconds: 400),
                            child: _buildHighLevelStats(context),
                          ),
                          const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 76,
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
      title: isDesktop ? Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pulse Console', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
              Text('Cloud Infrastructure • Term 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
            ],
          ),
          const SizedBox(width: 48),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showSearch(context: context, delegate: AdminSearchDelegate()),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(width: 12),
                    Text('Search anything (staff, students, settings...)', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ) : const Text('Pulse Console', style: TextStyle(fontWeight: FontWeight.w900)),
      actions: [
        if (isDesktop) ...[
          _buildLiveIndicator(),
          const SizedBox(width: 16),
        ],
        NotificationBellButton(backgroundColor: Theme.of(context).colorScheme.surfaceContainer),
        const SizedBox(width: 12),
        _AdminProfileToggle(),
        const SizedBox(width: 24),
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
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text('SYSTEM LIVE', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }


  Widget _buildHighLevelStats(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminDashboardError) {
          return AlertBanner(
            title: 'Couldn\'t load dashboard stats',
            message: 'Something went wrong on our end. Pull to refresh or check back shortly.',
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
                    Expanded(child: DashboardStatCard(title: 'Health', value: stats.systemHealth, suffix: '%', icon: Icons.cloud_done_rounded, color: Colors.teal, trend: 'STABLE')),
                    const SizedBox(width: 10),
                    Expanded(child: DashboardStatCard(title: 'Visitors', value: stats.visitorsTodayCount.toDouble(), icon: Icons.people_rounded, color: Colors.blue, trend: '${stats.activeVisitorsCount} LIVE')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: DashboardStatCard(title: 'Staff', value: stats.activeStaffCount.toDouble(), icon: Icons.badge_rounded, color: Colors.indigo, trend: 'VERIFIED')),
                    const SizedBox(width: 10),
                    Expanded(child: DashboardStatCard(title: 'Students', value: stats.totalStudentsCount.toDouble(), icon: Icons.school_rounded, color: Colors.orange, trend: 'ENROLLED')),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: DashboardStatCard(title: 'System Health', value: stats.systemHealth, suffix: '%', icon: Icons.cloud_done_rounded, color: Colors.teal, trend: 'STABLE')),
              const SizedBox(width: 16),
              Expanded(child: DashboardStatCard(title: 'Visitors Today', value: stats.visitorsTodayCount.toDouble(), icon: Icons.people_rounded, color: Colors.blue, trend: '${stats.activeVisitorsCount} LIVE')),
              const SizedBox(width: 16),
              Expanded(child: DashboardStatCard(title: 'Active Staff', value: stats.activeStaffCount.toDouble(), icon: Icons.badge_rounded, color: Colors.indigo, trend: 'VERIFIED')),
              const SizedBox(width: 16),
              Expanded(child: DashboardStatCard(title: 'Total Students', value: stats.totalStudentsCount.toDouble(), icon: Icons.school_rounded, color: Colors.orange, trend: 'ENROLLED')),
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
              _buildVisitorTraffic(context),
              const SizedBox(height: 24),
              _buildServiceStatus(context),
              const SizedBox(height: 24),
              _buildUpcomingDeadlines(context),
              const SizedBox(height: 24),
              _buildRecentActivityLog(context),
              const SizedBox(height: 24),
              _buildDataHealth(context),
              const SizedBox(height: 24),
              _buildSchoolAnnouncements(context),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildVisitorTraffic(context)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildServiceStatus(context)),
                      ],
                    )
                  else ...[
                    _buildVisitorTraffic(context),
                    const SizedBox(height: 24),
                    _buildServiceStatus(context),
                  ],
                  const SizedBox(height: 24),
                  _buildRecentActivityLog(context),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildSystemAlerts(context),
                  const SizedBox(height: 24),
                  _buildUpcomingDeadlines(context),
                  const SizedBox(height: 24),
                  _buildDataHealth(context),
                  const SizedBox(height: 24),
                  _buildSchoolAnnouncements(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVisitorTraffic(BuildContext context) {
    return StreamBuilder<List<Visitor>>(
      stream: di.sl<VisitorRepository>().getVisitors(),
      builder: (context, snapshot) {
        final visitors = snapshot.data ?? const [];
        final now = DateTime.now();
        const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final counts = {for (final label in weekdayLabels) label: 0.0};

        for (final v in visitors) {
          final checkInDay = DateTime(v.checkIn.year, v.checkIn.month, v.checkIn.day);
          final daysAgo = DateTime(now.year, now.month, now.day).difference(checkInDay).inDays;
          if (daysAgo >= 0 && daysAgo < 7) {
            final label = weekdayLabels[v.checkIn.weekday - 1];
            counts[label] = (counts[label] ?? 0) + 1;
          }
        }

        final maxCount = counts.values.fold<double>(0, (a, b) => a > b ? a : b);
        return PerformanceBarChart(
          title: 'Visitor Traffic (Last 7 Days)',
          color: Colors.blue,
          data: counts,
          maxValue: maxCount == 0 ? 1 : maxCount,
          showPercentSign: false,
        );
      },
    );
  }

  Widget _buildUpcomingDeadlines(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Upcoming Deadlines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          _DeadlineItem(label: 'Grade Entry', date: 'Tomorrow', progress: 0.8, color: Colors.blue),
          _DeadlineItem(label: 'Inventory Audit', date: 'Oct 30', progress: 0.3, color: Colors.orange),
          _DeadlineItem(label: 'Report Signing', date: 'Nov 02', progress: 0.0, color: Theme.of(context).colorScheme.outline),
        ],
      ),
    );
  }

  Widget _buildShortcutSection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Command Center',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Operational modules for school management',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _showQuickActions(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: MediaQuery.of(context).size.width < 400 ? const Text('Add') : const Text('Quick Action'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              _AdminShortcut(
                icon: Icons.badge_outlined,
                label: 'Staff Portal',
                color: Colors.orange,
                onTap: () => context.go('/staff/admin/users?tab=0'),
              ),
              _AdminShortcut(
                icon: Icons.qr_code_scanner,
                label: 'Passcodes',
                color: Colors.teal,
                onTap: () => context.go('/staff/admin/users?tab=1'),
              ),
              _AdminShortcut(
                icon: Icons.meeting_room_outlined,
                label: 'Visitor Log',
                color: Colors.purple,
                onTap: () => context.go('/staff/admin/visitors'),
              ),
              _AdminShortcut(
                icon: Icons.event_available_outlined,
                label: 'Schedule',
                color: Colors.blue,
                onTap: () => context.go('/staff/admin/appointments'),
              ),
              _AdminShortcut(
                icon: Icons.verified_user_outlined, 
                label: 'Attendance', 
                color: Colors.cyan, 
                onTap: () => context.go('/staff/admin/staff-attendance'),
              ),
              _AdminShortcut(
                icon: Icons.hub_outlined, 
                label: 'Structure', 
                color: Colors.indigo, 
                onTap: () => context.go('/staff/admin/structure'),
              ),
              _AdminShortcut(
                icon: Icons.cell_tower_outlined, 
                label: 'SMS Center', 
                color: Colors.red, 
                onTap: () => context.go('/staff/admin/broadcast-sms'),
              ),
              _AdminShortcut(
                icon: Icons.settings_input_component_outlined, 
                label: 'System Config', 
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              StatusBadge(label: 'Global: Stable', color: Colors.green, icon: Icons.check_circle),
            ],
          ),
          const SizedBox(height: 20),
          _StatusRow(label: 'Database', status: 'Operational', color: Colors.green),
          _StatusRow(label: 'SMS Engine', status: 'Operational', color: Colors.green),
          _StatusRow(label: 'File CDN', status: 'Operational', color: Colors.green),
          _StatusRow(label: 'Identity', status: 'Latency', color: Colors.orange),
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
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Live Audit Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => context.go('/staff/admin/audit-log'),
                      child: const Text('View All Logs'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (state is AdminDashboardLoaded && state.recentLogs.isNotEmpty) 
                    ? state.recentLogs.length 
                    : 5,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (state is AdminDashboardLoaded && state.recentLogs.isNotEmpty) {
                    final log = state.recentLogs[index];
                    final color = Color(int.parse(log.colorHex, radix: 16));
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_getIconData(log.iconName), size: 16, color: color),
                      ),
                      title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(log.description, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                      trailing: Text(_formatTimestamp(log.timestamp), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline)),
                    );
                  }
                  
                  // Fallback/Mock data while loading or if empty
                  final logs = [
                    {'title': 'New Staff Account', 'desc': 'Mrs. Namono assigned to P.4 Blue', 'time': '10m ago', 'icon': Icons.person_add, 'color': Colors.blue},
                    {'title': 'Parent Access', 'desc': 'Family: Mugisha regenerated codes', 'time': '2h ago', 'icon': Icons.vpn_key, 'color': Colors.teal},
                    {'title': 'SMS Broadcast', 'desc': 'Term 3 fees reminder sent to 450 parents', 'time': '3h ago', 'icon': Icons.send, 'color': Colors.purple},
                    {'title': 'Security Alert', 'desc': 'Unauthorized login attempt from 192.168.1.1', 'time': '5h ago', 'icon': Icons.gpp_maybe, 'color': Colors.red},
                    {'title': 'Inventory Update', 'desc': '200 new textbooks logged by Librarian', 'time': 'Yesterday', 'icon': Icons.inventory_2, 'color': Colors.orange},
                  ];
                  final log = logs[index];
                  final color = log['color'] as Color;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(log['icon'] as IconData, size: 16, color: color),
                    ),
                    title: Text(log['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(log['desc'] as String, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                    trailing: Text(log['time'] as String, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'person_add': return Icons.person_add;
      case 'vpn_key': return Icons.vpn_key;
      case 'send': return Icons.send;
      case 'gpp_maybe': return Icons.gpp_maybe;
      case 'inventory_2': return Icons.inventory_2;
      default: return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return 'Yesterday';
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
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final items = <String>[];
        if (state is AdminDashboardLoaded) {
          final stats = state.stats;
          if (stats.staffPendingSetupCount > 0) {
            items.add('${stats.staffPendingSetupCount} staff account${stats.staffPendingSetupCount == 1 ? '' : 's'} pending first-login setup');
          }
          if (stats.overdueVisitorsCount > 0) {
            items.add('${stats.overdueVisitorsCount} visitor${stats.overdueVisitorsCount == 1 ? '' : 's'} on premises over 2 hours - check them out');
          }
        }

        return AppCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (items.isEmpty ? semantic.success : semantic.warning).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      items.isEmpty ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                      color: items.isEmpty ? semantic.success : semantic.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Actions',
                      style: TextStyle(fontWeight: FontWeight.bold, color: items.isEmpty ? semantic.success : semantic.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Text('All clear - nothing needs your attention.', style: TextStyle(fontSize: 13))
                else
                  ...items.map((text) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $text', style: const TextStyle(fontSize: 13)),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              _QuickActionTile(
                icon: Icons.person_add_alt_1_outlined,
                label: 'Add Staff Member',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/staff/admin/users?tab=0');
                },
              ),
              _QuickActionTile(
                icon: Icons.meeting_room_outlined,
                label: 'Log New Visitor',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/staff/admin/visitors');
                },
              ),
              _QuickActionTile(
                icon: Icons.event_available_outlined,
                label: 'Schedule Appointment',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/staff/admin/appointments');
                },
              ),
              _QuickActionTile(
                icon: Icons.campaign_outlined,
                label: 'Send Broadcast',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/staff/admin/broadcast-sms');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
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
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

class _DeadlineItem extends StatelessWidget {
  final String label;
  final String date;
  final double progress;
  final Color color;

  const _DeadlineItem({required this.label, required this.date, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(date, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
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
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final initials = (state is AuthAuthenticated) ? state.user.name[0] : 'A';
        final roleName = (state is AuthAuthenticated) ? UserRoleDisplay.name(state.user.role) : 'Admin';
        return Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12, 
                backgroundColor: Theme.of(context).colorScheme.primary, 
                child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    roleName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}
