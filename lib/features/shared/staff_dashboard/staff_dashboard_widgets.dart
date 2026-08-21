import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/theme_provider.dart';
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
  const StaffDashboardHeader({super.key, required this.roleLabel});

  final String roleLabel;

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
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: AppRadius.large,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round_outlined,
                  ),
                  tooltip: 'Toggle theme',
                  onPressed: () {
                    final provider = context.read<ThemeProvider>();
                    provider.setThemeMode(
                      Theme.of(context).brightness == Brightness.dark
                          ? ThemeMode.light
                          : ThemeMode.dark,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: AppRadius.large,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  tooltip: 'Messages',
                  onPressed: () => context.push('/staff/messages'),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: AppRadius.large,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: const NotificationBellButton(),
              ),
            ],
          ),
        ),
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

/// Shared gradient hero card: greeting + term/date pill + 2x2 KPI grid.
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
    final scheme = Theme.of(context).colorScheme;
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
              Expanded(
                child: Text(
                  '${_greeting()}, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onPrimary,
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
                        periodLabel ?? 'This Term',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (onPeriodTap != null) ...[
                        const SizedBox(width: 2),
                        Icon(
                          Icons.unfold_more_rounded,
                          size: 14,
                          color: scheme.onPrimary.withValues(alpha: 0.85),
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: AppRadius.large,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: AppRadius.large,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: useGlassIconContainers
                      ? Colors.white.withValues(alpha: 0.12)
                      : data.color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.medium,
                  border: useGlassIconContainers
                      ? Border.all(color: Colors.white.withValues(alpha: 0.24))
                      : null,
                ),
                child: Icon(data.icon, color: data.color, size: 24),
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
                        color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 3,
    titleSpacing: 0,
    toolbarHeight: kToolbarHeight + 16,
    title: StaffDashboardHeader(roleLabel: roleLabel),
    actions: actions,
  );
}
