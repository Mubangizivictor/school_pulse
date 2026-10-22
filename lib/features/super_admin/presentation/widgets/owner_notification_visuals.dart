import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';

/// Shared visual language for the owner-only notification surfaces. Kept
/// separate from every school-role notification widget: this file is
/// imported only by the three owner notification screens.
class OwnerNotificationVisuals {
  const OwnerNotificationVisuals._();

  /// The tonal icon + accent colour for a category. Platform health is the
  /// only one whose colour depends on state (red pulse when degraded, green
  /// pulse when operational).
  static ({IconData icon, Color accent}) forNotification(
    BuildContext context,
    OwnerNotification n,
  ) {
    switch (n.category) {
      case OwnerNotificationCategory.billing:
        return (icon: Icons.payments_rounded, accent: AppColors.warning(context));
      case OwnerNotificationCategory.platform:
        return (
          icon: Icons.monitor_heart_rounded,
          accent: n.platformHealthDegraded
              ? AppColors.danger(context)
              : AppColors.success(context),
        );
      case OwnerNotificationCategory.schools:
        return (
          icon: Icons.school_rounded,
          accent: AppColors.information(context),
        );
      case OwnerNotificationCategory.security:
        return (
          icon: Icons.shield_rounded,
          accent: AppColors.success(context),
        );
      case OwnerNotificationCategory.digest:
        return (
          icon: Icons.summarize_rounded,
          accent: AppColors.textMuted(context),
        );
    }
  }

  static Color severityColor(BuildContext context, OwnerNotificationSeverity s) {
    switch (s) {
      case OwnerNotificationSeverity.requiresReview:
        return AppColors.warning(context);
      case OwnerNotificationSeverity.critical:
        return AppColors.danger(context);
      case OwnerNotificationSeverity.resolved:
        return AppColors.success(context);
      case OwnerNotificationSeverity.information:
        return AppColors.textMuted(context);
    }
  }
}

/// Small 40px tonal icon square used on every owner tile / detail card.
class OwnerIconSquare extends StatelessWidget {
  const OwnerIconSquare({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 40,
  });

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size * 0.5, color: accent),
    );
  }
}

/// Uppercase micro severity chip (`REQUIRES REVIEW`, `CRITICAL`, …).
class OwnerSeverityChip extends StatelessWidget {
  const OwnerSeverityChip({super.key, required this.severity});

  final OwnerNotificationSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = OwnerNotificationVisuals.severityColor(context, severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Compact horizontal filter chip row for the Owner Notifications screen.
class OwnerFilterChips extends StatelessWidget {
  const OwnerFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OwnerNotificationFilter selected;
  final ValueChanged<OwnerNotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.information(context);
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OwnerNotificationFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = OwnerNotificationFilter.values[i];
          final isSel = filter == selected;
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSel
                    ? accent.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSel ? accent : AppColors.border(context),
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? accent : AppColors.textSecondary(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small outlined unread-count chip, e.g. `3 NEW`.
class OwnerUnreadChip extends StatelessWidget {
  const OwnerUnreadChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.information(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent),
      ),
      child: Text(
        '$count NEW',
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
