import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Minimal web side rail for the workspace - a lightweight NavigationRail
/// wrapper, not a repo-wide nav shell (this screen already sits inside
/// StaffShell on mobile; on web width this rail is purely local chrome so
/// the Parents/Access-codes surface reads like the reference desktop
/// screenshot rather than reusing the mobile bottom nav at desktop width).
class ParentAccessSideRail extends StatelessWidget {
  final String schoolName;

  const ParentAccessSideRail({super.key, required this.schoolName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.surfaceElevated(context),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.textPrimary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schoolName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _NavItem(icon: Icons.home_outlined, label: 'Home'),
          _NavItem(icon: Icons.groups_outlined, label: 'Students'),
          _NavItem(icon: Icons.badge_outlined, label: 'Staff'),
          _NavItem(
            icon: Icons.family_restroom_outlined,
            label: 'Parents',
            selected: true,
          ),
          _NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary(context) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: selected
                ? AppColors.background(context)
                : AppColors.textSecondary(context),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.background(context)
                  : AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
