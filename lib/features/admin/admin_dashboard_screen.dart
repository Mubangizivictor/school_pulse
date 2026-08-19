import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:school_pulse/features/admin/presentation/widgets/quick_access_prefs.dart';
import 'package:school_pulse/features/admin/data/models/audit_log.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/widgets/role_switcher_sheet.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<AdminDashboardBloc>()..add(LoadAdminDashboardStats()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 3,
          titleSpacing: 0,
          toolbarHeight: kToolbarHeight + 16,
          title: _DashboardHeader(),
        ),
        body: Builder(
          builder: (context) => RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats());
              await context.read<AdminDashboardBloc>().stream.firstWhere(
                (state) => state is! AdminDashboardLoading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.l,
                      AppSpacing.xl,
                      AppSpacing.x3l,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroSummaryCard(),
                        const SizedBox(height: AppSpacing.xl),
                        _QuickAccessSection(),
                        const SizedBox(height: AppSpacing.xl),
                        const _PendingApprovalsCard(),
                        const SizedBox(height: AppSpacing.l),
                        const _RecentActivityCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Left: school badge + "School Admin" + real school name. Right:
/// notification bell (real unread count) + profile button routing into the
/// existing shared More/account hub.
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brandingState = context.watch<BrandingBloc>().state;
    final branding = brandingState is BrandingLoaded
        ? brandingState.branding
        : null;

    final authState = context.watch<AuthBloc>().state;
    final roles = authState is AuthAuthenticated
        ? authState.user.roles
        : const <UserRole>[];
    final activeRole =
        context.watch<AppRoleSessionCubit>().state ??
        (roles.isNotEmpty ? roles.first : null);
    final roleLabel = activeRole != null
        ? UserRoleDisplay.name(activeRole)
        : 'School Admin';
    final canSwitchRoles = roles.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.s,
        AppSpacing.xl,
        AppSpacing.s,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(
            children: [
              SchoolBadge(
                badgeUrl: branding?.badgeUrl ?? branding?.logoUrl,
                size: 56,
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: canSwitchRoles
                          ? () => RoleSwitcherSheet.show(context)
                          : null,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              roleLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (canSwitchRoles) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.unfold_more_rounded,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      branding?.schoolName ?? 'School Pulse',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const NotificationBellButton(
                key: Key('admin-dashboard-notifications-button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large rounded gradient card: "Welcome back, {firstName}", the active
/// academic period, and the 4 KPI tiles. Uses the theme's own primary and
/// secondary colors, which are already school-branded via
/// BrandingThemeEngine, so this looks correct per-tenant without any new
/// branding plumbing.
class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final fullName = authState is AuthAuthenticated ? authState.user.name : '';
    final firstName = fullName.trim().isEmpty
        ? 'Admin'
        : fullName.trim().split(RegExp(r'\s+')).first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: AppRadius.extraLarge,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
                builder: (context, state) {
                  final label = state is AdminDashboardLoaded
                      ? state.stats.currentPeriodLabel
                      : null;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withValues(alpha: 0.16),
                      borderRadius: AppRadius.full,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: scheme.onPrimary,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          label ?? 'This Term',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  '${_greeting()}, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          const _KpiRow(),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading || state is AdminDashboardInitial) {
          return const _KpiRowSkeleton();
        }
        if (state is AdminDashboardError) {
          return AlertBanner(
            title: "Couldn't load dashboard stats",
            message:
                'Something went wrong on our end. Pull to refresh or check back shortly.',
            color: Theme.of(context).extension<SemanticColors>()!.error,
            icon: Icons.error_outline_rounded,
          );
        }
        final stats = (state as AdminDashboardLoaded).stats;
        final feesLabel = stats.termFeesCollected == null
            ? null
            : _formatUgx(stats.termFeesCollected!);

        final tiles = [
          _KpiTileData(
            title: 'Students',
            valueText: '${stats.totalStudentsCount}',
            subtitle: 'Active students',
            icon: Icons.school_rounded,
          ),
          _KpiTileData(
            title: 'Staff',
            valueText: '${stats.activeStaffCount}',
            subtitle: 'Active staff',
            icon: Icons.badge_rounded,
          ),
          _KpiTileData(
            title: 'Attendance',
            valueText: stats.studentAttendancePercent == null
                ? '—'
                : '${stats.studentAttendancePercent!.round()}%',
            subtitle: 'This week',
            icon: Icons.fact_check_rounded,
          ),
          _KpiTileData(
            title: 'Fees Collected',
            valueText: feesLabel ?? '—',
            subtitle: 'This year',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;
            if (!isNarrow) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.m),
                    Expanded(child: _KpiTile(data: tiles[i])),
                  ],
                ],
              );
            }
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _KpiTile(data: tiles[0])),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(child: _KpiTile(data: tiles[1])),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _KpiTile(data: tiles[2])),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(child: _KpiTile(data: tiles[3])),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _formatUgx(double amount) {
    if (amount >= 1000000) {
      return 'UGX ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return 'UGX ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'UGX ${amount.toStringAsFixed(0)}';
  }
}

class _KpiTileData {
  final String title;
  final String valueText;
  final String subtitle;
  final IconData icon;

  const _KpiTileData({
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.icon,
  });
}

class _KpiTile extends StatelessWidget {
  final _KpiTileData data;

  const _KpiTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.valueText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.8,
              height: 1.1,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRowSkeleton extends StatelessWidget {
  const _KpiRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.m),
          const Expanded(child: Skeleton(height: 72, borderRadius: 16)),
        ],
      ],
    );
  }
}

/// Quick Access destination: fixed metadata (icon/color/route) keyed by id,
/// so the persisted preference only ever stores ids, never widgets/routes.
class _QuickAccessItem {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAccessItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

final Map<String, _QuickAccessItem> _quickAccessCatalog = {
  'students': const _QuickAccessItem(
    id: 'students',
    label: 'Students',
    icon: Icons.school_rounded,
    color: Colors.blueAccent,
    route: '/staff/admin/students',
  ),
  'staff': const _QuickAccessItem(
    id: 'staff',
    label: 'Staff',
    icon: Icons.badge_rounded,
    color: Colors.indigo,
    route: '/staff/admin/users',
  ),
  'attendance': const _QuickAccessItem(
    id: 'attendance',
    label: 'Attendance',
    icon: Icons.fact_check_rounded,
    color: Colors.teal,
    route: '/staff/attendance',
  ),
  'classes': const _QuickAccessItem(
    id: 'classes',
    label: 'Classes',
    icon: Icons.class_rounded,
    color: Colors.deepPurple,
    route: '/staff/classes',
  ),
  'exams': const _QuickAccessItem(
    id: 'exams',
    label: 'Exams & Marks',
    icon: Icons.assignment_rounded,
    color: Colors.cyan,
    route: '/staff/exams',
  ),
  'finance': const _QuickAccessItem(
    id: 'finance',
    label: 'Finance',
    icon: Icons.account_balance_wallet_rounded,
    color: Colors.green,
    route: '/staff/bursar',
  ),
  'transport': const _QuickAccessItem(
    id: 'transport',
    label: 'Transport',
    icon: Icons.directions_bus_rounded,
    color: Colors.amber,
    route: '/staff/transport',
  ),
  'library': const _QuickAccessItem(
    id: 'library',
    label: 'Library',
    icon: Icons.local_library_rounded,
    color: Colors.orange,
    route: '/staff/librarian',
  ),
  'announcements': const _QuickAccessItem(
    id: 'announcements',
    label: 'Announcements',
    icon: Icons.campaign_rounded,
    color: Colors.redAccent,
    route: '/staff/more/announcements',
  ),
  'communication': const _QuickAccessItem(
    id: 'communication',
    label: 'Communication',
    icon: Icons.chat_bubble_rounded,
    color: Colors.blue,
    route: '/staff/messages',
  ),
  'reports': const _QuickAccessItem(
    id: 'reports',
    label: 'Reports',
    icon: Icons.bar_chart_rounded,
    color: Colors.teal,
    route: '/staff/admin/reports',
  ),
  'calendar': const _QuickAccessItem(
    id: 'calendar',
    label: 'Calendar',
    icon: Icons.calendar_month_rounded,
    color: Colors.indigoAccent,
    route: '/staff/calendar',
  ),
  'security': const _QuickAccessItem(
    id: 'security',
    label: 'Security',
    icon: Icons.shield_rounded,
    color: Colors.deepOrange,
    route: '/staff/admin/security',
  ),
  'institution_health': const _QuickAccessItem(
    id: 'institution_health',
    label: 'Institution Health',
    icon: Icons.health_and_safety_rounded,
    color: Colors.purple,
    route: '/staff/admin/institution-health',
  ),
  'data_management': const _QuickAccessItem(
    id: 'data_management',
    label: 'Data Management',
    icon: Icons.storage_rounded,
    color: Colors.blueGrey,
    route: '/staff/admin/data-management',
  ),
  'communication_center': const _QuickAccessItem(
    id: 'communication_center',
    label: 'Communication Center',
    icon: Icons.campaign_rounded,
    color: Colors.teal,
    route: '/staff/admin/communication-center',
  ),
};

class _QuickAccessSection extends StatefulWidget {
  @override
  State<_QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<_QuickAccessSection> {
  List<String>? _ids;

  @override
  void initState() {
    super.initState();
    QuickAccessPrefs.load().then((ids) {
      if (mounted) setState(() => _ids = ids);
    });
  }

  Future<void> _openEditSheet() async {
    final current = _ids ?? List.of(QuickAccessPrefs.allIds);
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickAccessEditSheet(initialIds: current),
    );
    if (result != null) {
      await QuickAccessPrefs.save(result);
      if (mounted) setState(() => _ids = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ids = _ids ?? QuickAccessPrefs.allIds;
    final items = ids
        .map((id) => _quickAccessCatalog[id])
        .whereType<_QuickAccessItem>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Quick Access',
          actionLabel: 'Edit',
          onActionPressed: _openEditSheet,
        ),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            childAspectRatio: 2.05,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _QuickAccessTile(item: item);
          },
        ),
      ],
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final _QuickAccessItem item;

  const _QuickAccessTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 6,
      ),
      showShadow: false,
      onTap: () => context.go(item.route),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(item.icon, color: item.color, size: 16),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              item.label,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reorder + show/hide sheet for the Edit action. Core shortcuts
/// (students/staff/attendance) can be reordered but not hidden.
class _QuickAccessEditSheet extends StatefulWidget {
  final List<String> initialIds;

  const _QuickAccessEditSheet({required this.initialIds});

  @override
  State<_QuickAccessEditSheet> createState() => _QuickAccessEditSheetState();
}

class _QuickAccessEditSheetState extends State<_QuickAccessEditSheet> {
  late List<String> _visible;
  late List<String> _hidden;

  @override
  void initState() {
    super.initState();
    _visible = List.of(widget.initialIds);
    _hidden = QuickAccessPrefs.allIds
        .where((id) => !_visible.contains(id))
        .toList();
  }

  void _toggle(String id, bool show) {
    setState(() {
      if (show) {
        _hidden.remove(id);
        _visible.add(id);
      } else {
        _visible.remove(id);
        _hidden.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.m),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: AppRadius.full,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customize Quick Access',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_visible),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  scrollController: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  itemCount: _visible.length + 1 + _hidden.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex >= _visible.length ||
                        newIndex > _visible.length) {
                      return;
                    }
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final id = _visible.removeAt(oldIndex);
                      _visible.insert(newIndex, id);
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index < _visible.length) {
                      final id = _visible[index];
                      final item = _quickAccessCatalog[id];
                      if (item == null)
                        return const SizedBox.shrink(key: ValueKey('_'));
                      final isCore = QuickAccessPrefs.coreIds.contains(id);
                      return ListTile(
                        key: ValueKey('visible_$id'),
                        leading: Icon(item.icon, color: item.color),
                        title: Text(item.label),
                        trailing: isCore
                            ? const Icon(Icons.lock_outline_rounded, size: 18)
                            : IconButton(
                                icon: const Icon(Icons.visibility_off_outlined),
                                onPressed: () => _toggle(id, false),
                              ),
                      );
                    }
                    if (index == _visible.length) {
                      return Padding(
                        key: const ValueKey('divider'),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.m,
                        ),
                        child: Text(
                          _hidden.isEmpty ? '' : 'Hidden',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      );
                    }
                    final id = _hidden[index - _visible.length - 1];
                    final item = _quickAccessCatalog[id];
                    if (item == null)
                      return const SizedBox.shrink(key: ValueKey('_'));
                    return ListTile(
                      key: ValueKey('hidden_$id'),
                      leading: Icon(
                        item.icon,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: () => _toggle(id, true),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Real pending-approvals queue. Today the only backed queue is Finance
/// expenditure requests; other categories from the reference design
/// (leave, visitor, purchase) aren't wired to a real repository yet, so
/// they're intentionally omitted rather than shown with fake counts.
class _PendingApprovalsCard extends StatelessWidget {
  const _PendingApprovalsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final loading =
            state is AdminDashboardLoading || state is AdminDashboardInitial;
        final error = state is AdminDashboardError;
        final count = state is AdminDashboardLoaded
            ? state.stats.pendingExpenditureRequestsCount
            : 0;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Pending Approvals',
                actionLabel: count > 0 ? 'View all' : null,
                onActionPressed: () => context.push('/staff/bursar'),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Skeleton(height: 56),
                )
              else if (error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(
                          context,
                        ).extension<SemanticColors>()!.error,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          'Couldn\'t load approvals. Pull to refresh.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else if (count == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Theme.of(
                          context,
                        ).extension<SemanticColors>()!.success,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          'All clear — nothing needs your attention.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ApprovalStat(
                          icon: Icons.receipt_long_rounded,
                          color: Colors.orange,
                          label: 'Expense\nRequests',
                          count: count,
                          onTap: () => context.push('/staff/bursar'),
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ApprovalStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _ApprovalStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.medium,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the audit-log stream that was already wired into the bloc but
/// never shown in the old UI.
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final logs = state is AdminDashboardLoaded
            ? state.recentLogs
            : const <AuditLog>[];
        final loading =
            state is AdminDashboardLoading || state is AdminDashboardInitial;
        final error = state is AdminDashboardError;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Recent Activity',
                actionLabel: logs.isNotEmpty ? 'View all' : null,
                onActionPressed: () => context.push('/staff/admin/audit-log'),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Skeleton(height: 56),
                )
              else if (error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Text(
                    'Couldn\'t load recent activity. Pull to refresh.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else if (logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Text(
                    'No recent activity yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                ...logs.take(5).map((log) => _ActivityRow(log: log)),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final AuditLog log;

  const _ActivityRow({required this.log});

  Color _color(BuildContext context) {
    try {
      final hex = log.colorHex.replaceFirst('#', '');
      final value = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
      return Color(value);
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  IconData get _icon {
    switch (log.iconName) {
      case 'person_add':
        return Icons.person_add_alt_1_rounded;
      case 'payment':
        return Icons.payments_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'attendance':
        return Icons.fact_check_rounded;
      case 'structure':
        return Icons.account_tree_rounded;
      case 'appointment':
        return Icons.event_available_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(_icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (log.description.isNotEmpty)
                  Text(
                    log.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            _timeAgo(log.timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
