import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Web side rail matching the reference desktop screenshot: branded header
/// (shield + school name + "Academy" subtitle), Home/Students/Staff/
/// Parents(active)/Reports/Notifications/Settings, then Help/Logout pinned
/// to the bottom below a divider. This screen already sits inside StaffShell
/// on mobile - this rail is purely local chrome so the workspace reads like
/// the reference at desktop width rather than reusing the mobile bottom nav.
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.shield_outlined, size: 18, color: AppColors.background(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schoolName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Academy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _NavItem(icon: Icons.home_outlined, label: 'Home'),
          _NavItem(icon: Icons.groups_outlined, label: 'Students'),
          _NavItem(icon: Icons.badge_outlined, label: 'Staff'),
          _NavItem(icon: Icons.family_restroom_outlined, label: 'Parents', selected: true),
          _NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
          _NavItem(icon: Icons.notifications_outlined, label: 'Notifications'),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
          const Spacer(),
          Divider(color: AppColors.border(context), height: 24),
          _NavItem(icon: Icons.help_outline, label: 'Help'),
          _NavItem(icon: Icons.logout, label: 'Logout'),
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.background(context)
                    : AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
