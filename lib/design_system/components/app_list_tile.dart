import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Themed row for lists of people, records or settings.
///
/// Wraps [ListTile] with the design-system spacing, radius and text colours
/// so lists look the same across modules. Pass [leading] (e.g. an
/// `AvatarInitials` or icon) and [trailing] (e.g. a `StatusBadge` or
/// chevron) as needed; [onTap] makes the whole row tappable.
class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool dense;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      dense: dense,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xs,
      ),
      leading: leading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
      trailing:
          trailing ??
          (showChevron
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted(context),
                )
              : null),
    );
  }
}
