import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

/// Shared "More" menu for the Patron/Matron boarding modules. Takes a
/// [basePath] ('/staff/patron' or '/staff/matron') so both roles get an
/// identical layout that only differs by route target and gender label -
/// same convention as the rest of `lib/features/shared/boarding/`.
///
/// Rows with no real backing data/repo method (per the Phase 4 "no fake
/// data" constraint and the plan's "Descoped from v1" list) either omit
/// entirely or navigate to a genuine existing screen rather than a new one:
/// - Room Leaders -> deep-links to the existing dormitory list, where the
///   "Set Dorm Leadership" bottom sheet already lives (per-dorm, via the
///   overflow menu) - no new Room Leaders list screen (descoped).
/// - Boarding Settings -> nothing backs this; shown as "Coming soon".
/// - Export Data -> nothing backs this; omitted entirely.
/// - Profile Settings / Preferences -> no shared account routes exist for
///   any role in this app (checked other roles' More menus - none reuse a
///   generic route), so both are shown as "Coming soon" rather than
///   inventing new routes/screens.
class BoardingMoreScreen extends StatelessWidget {
  final String basePath;
  final String genderLabel; // 'Boys' | 'Girls'

  const BoardingMoreScreen({
    super.key,
    required this.basePath,
    required this.genderLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          MoreMenuSection(
            title: 'Boarding Management',
            rows: [
              MoreMenuRow(
                icon: Icons.home_outlined,
                label: 'Dormitory Management',
                subtitle: '$genderLabel dormitories',
                onTap: () => context.push('$basePath/dorms'),
              ),
              MoreMenuRow(
                icon: Icons.bed_outlined,
                label: 'Bed Allocation',
                subtitle: 'Assign and manage beds',
                onTap: () => context.push('$basePath/dorms'),
              ),
              MoreMenuRow(
                icon: Icons.workspace_premium_outlined,
                label: 'Room Leaders',
                subtitle: 'Set leadership from a dormitory',
                onTap: () => context.push('$basePath/dorms'),
              ),
              MoreMenuRow(
                icon: Icons.settings_outlined,
                label: 'Boarding Settings',
                subtitle: 'Coming soon',
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          MoreMenuSection(
            title: 'Student Care',
            rows: [
              MoreMenuRow(
                icon: Icons.health_and_safety_outlined,
                label: 'Welfare',
                onTap: () => context.push('$basePath/welfare'),
              ),
              MoreMenuRow(
                icon: Icons.gavel_outlined,
                label: 'Discipline',
                onTap: () => context.push('$basePath/discipline'),
              ),
              MoreMenuRow(
                icon: Icons.exit_to_app,
                label: 'Leave Requests',
                onTap: () => context.push('$basePath/leave'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          MoreMenuSection(
            title: 'Communication',
            rows: [
              MoreMenuRow(
                icon: Icons.campaign_outlined,
                label: 'Announcements',
                onTap: () => context.push('$basePath/communication'),
              ),
              MoreMenuRow(
                icon: Icons.message_outlined,
                label: 'Messages',
                onTap: () => context.push('/staff/messages'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          MoreMenuSection(
            title: 'Reports',
            rows: [
              MoreMenuRow(
                icon: Icons.bar_chart_outlined,
                label: 'Boarding Reports',
                onTap: () => context.push('$basePath/reports'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          MoreMenuSection(
            title: 'Account',
            rows: [
              MoreMenuRow(
                icon: Icons.person_outline,
                label: 'Profile Settings',
                subtitle: 'Coming soon',
                onTap: null,
              ),
              MoreMenuRow(
                icon: Icons.tune_outlined,
                label: 'Preferences',
                subtitle: 'Coming soon',
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
