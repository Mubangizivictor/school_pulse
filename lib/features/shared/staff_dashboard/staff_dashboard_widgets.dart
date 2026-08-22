import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/widgets/role_switcher_sheet.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

/// Shared AppBar header used across every staff role's home/dashboard
/// screen: school badge, role name (+ role switcher if multi-role), school
/// name, theme toggle, and notification bell. Matches the Dean of Studies
/// dashboard pattern exactly so every staff role gets the same top section.
class StaffDashboardHeader extends StatelessWidget {
  const StaffDashboardHeader({
    super.key,
    required this.roleLabel,
    this.onSwitchTap,
    this.showHeaderActions = true,
  });

  final String roleLabel;

  /// Overrides the default RoleSwitcherSheet (which only lists role types,
  /// e.g. "Class Teacher"/"Subject Teacher") with a caller-supplied action -
  /// used by the teacher dashboards to open ResponsibilitySwitcherSheet
  /// instead, which lists the specific assignment (e.g. which class, for a
  /// teacher holding more than one Subject Teacher assignment).
  final VoidCallback? onSwitchTap;
  final bool showHeaderActions;

  @override
  Widget build(BuildContext context) {
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
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    final brandingState = context.watch<BrandingBloc>().state;
                    final branding = brandingState is BrandingLoaded
                        ? brandingState.branding
                        : null;
                    return SchoolBadge(
                      badgeUrl: branding?.badgeUrl ?? branding?.logoUrl,
                      size: 56,
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final authState = context.watch<AuthBloc>().state;
                          final roles = authState is AuthAuthenticated
                              ? authState.user.roles
                              : const <UserRole>[];
                          final canSwitchRoles = roles.length > 1;
                          return InkWell(
                            onTap: !canSwitchRoles
                                ? null
                                : onSwitchTap ??
                                      () => RoleSwitcherSheet.show(context),
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
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
                          );
                        },
                      ),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final schoolName = (state is AuthAuthenticated)
                              ? (state.user.schoolName ?? 'School Pulse')
                              : 'School Pulse';
                          return Text(
                            schoolName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (showHeaderActions) ...[
                  _DashboardHeaderAction(
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.chat_bubble_outline),
                      tooltip: 'Messages',
                      onPressed: () => context.push('/staff/messages'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  const _DashboardHeaderAction(child: NotificationBellButton()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A fixed, shared shell for the dashboard message and notification actions.
/// The bell provides its own badge while this widget provides the identical
/// Compact shared shell for the dashboard message and notification actions.
class _DashboardHeaderAction extends StatelessWidget {
  final Widget child;

  const _DashboardHeaderAction({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(child: SizedBox(width: 40, height: 40, child: child)),
      ),
    );
  }
}

/// Data for a single stat card in the shared 2x2 KPI grid.
class StaffKpiData {
  final String title;
  final String valueText;
  final String subtitle;
  final IconData icon;
  final Color color;

  /// Called when the tile is tapped. If null, the tile is inert (its
  /// chevron is still shown, since most dashboards use this purely as a
  /// "more detail this way" affordance even before every tile is wired).
  final VoidCallback? onTap;

  const StaffKpiData({
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// Shared high-contrast hero card: greeting + term/date pill + 2x2 KPI grid.
/// Pass exactly 4 [StaffKpiData] items (or null to show the loading
/// skeleton) — everything else (layout, gradient, pill, tile styling) is
/// identical across every staff role.
class StaffHeroSummaryCard extends StatelessWidget {
  const StaffHeroSummaryCard({
    super.key,
    required this.kpis,
    this.periodLabel,
    this.onPeriodTap,
    this.greetingNameFallback = 'there',
    this.useGlassIconContainers = false,
  });

  /// Exactly 4 items, or null to render the loading skeleton.
  final List<StaffKpiData>? kpis;

  /// Label shown in the pill, e.g. "2024 • Term 3". Defaults to "This Term".
  final String? periodLabel;

  /// Called when the period pill is tapped. If null, the pill is inert.
  final VoidCallback? onPeriodTap;

  final String greetingNameFallback;

  /// Gives KPI icons a translucent, bordered surface without changing the
  /// card layout for dashboards that use the standard treatment.
  final bool useGlassIconContainers;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // Compact timeline-style hierarchy: black surfaces, white type, and a
    // crisp dividing rule rather than dim grey cards.
    final heroBackground = Colors.black;
    final heroForeground = Colors.white;
    final authState = context.watch<AuthBloc>().state;
    final fullName = authState is AuthAuthenticated ? authState.user.name : '';
    final firstName = fullName.trim().isEmpty
        ? greetingNameFallback
        : fullName.trim().split(RegExp(r'\s+')).first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: AppRadius.extraLarge,
        color: heroBackground,
        border: Border.all(color: heroForeground, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_greeting()}, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: heroForeground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              InkWell(
                borderRadius: AppRadius.full,
                onTap: onPeriodTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: heroForeground,
                    borderRadius: AppRadius.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: heroBackground,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        periodLabel ?? 'This Term',
                        style: TextStyle(
                          color: heroBackground,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (onPeriodTap != null) ...[
                        const SizedBox(width: 2),
                        Icon(
                          Icons.unfold_more_rounded,
                          size: 14,
                          color: heroBackground,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (kpis == null)
            const _StaffKpiRowSkeleton()
          else
            _StaffKpiRow(
              kpis: kpis!,
              useGlassIconContainers: useGlassIconContainers,
            ),
        ],
      ),
    );
  }
}

class _StaffKpiRow extends StatelessWidget {
  const _StaffKpiRow({
    required this.kpis,
    required this.useGlassIconContainers,
  });

  final List<StaffKpiData> kpis;
  final bool useGlassIconContainers;

  @override
  Widget build(BuildContext context) {
    assert(kpis.length == 4, 'StaffHeroSummaryCard expects exactly 4 kpis');
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StaffKpiTile(
                data: kpis[0],
                useGlassIconContainers: useGlassIconContainers,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _StaffKpiTile(
                data: kpis[1],
                useGlassIconContainers: useGlassIconContainers,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StaffKpiTile(
                data: kpis[2],
                useGlassIconContainers: useGlassIconContainers,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _StaffKpiTile(
                data: kpis[3],
                useGlassIconContainers: useGlassIconContainers,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StaffKpiTile extends StatelessWidget {
  final StaffKpiData data;
  final bool useGlassIconContainers;

  const _StaffKpiTile({
    required this.data,
    required this.useGlassIconContainers,
  });

  @override
  Widget build(BuildContext context) {
    final tileBackground = Colors.black;
    final tileForeground = Colors.white;
    return Material(
      color: tileBackground,
      borderRadius: AppRadius.large,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: AppRadius.large,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            borderRadius: AppRadius.large,
            border: Border.all(color: tileForeground),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tileForeground,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: tileForeground),
                ),
                child: Icon(data.icon, color: tileBackground, size: 24),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: tileForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.valueText,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.5,
                          height: 1.1,
                          color: tileForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: tileForeground),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: tileForeground,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffKpiRowSkeleton extends StatelessWidget {
  const _StaffKpiRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.m),
              const Expanded(child: Skeleton(height: 108, borderRadius: 16)),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            for (var i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.m),
              const Expanded(child: Skeleton(height: 108, borderRadius: 16)),
            ],
          ],
        ),
      ],
    );
  }
}

/// Standard [AppBar] wrapper for staff dashboards: puts
/// [StaffDashboardHeader] in the title slot with the same sizing as the
/// Dean of Studies dashboard.
PreferredSizeWidget staffDashboardAppBar(
  BuildContext context, {
  required String roleLabel,
  List<Widget>? actions,
  VoidCallback? onSwitchTap,
  bool showHeaderActions = true,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 3,
    titleSpacing: 0,
    toolbarHeight: kToolbarHeight + 16,
    title: StaffDashboardHeader(
      roleLabel: roleLabel,
      onSwitchTap: onSwitchTap,
      showHeaderActions: showHeaderActions,
    ),
    actions: actions,
  );
}
