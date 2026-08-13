import 'package:flutter/material.dart';

/// Single AppBar used across every school-admin screen (admin + structure
/// features). Relies entirely on the global `AppBarTheme`
/// (lib/design_system/theme/app_theme.dart) for title style, elevation,
/// background and icon size - screens must not override those here, or the
/// panel drifts out of sync again.
///
/// Action icons are wrapped so every screen gets the same hit target and
/// spacing instead of each one hand-tuning IconButton/SizedBox padding.
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;

  /// Only for screens that close a modal-style flow instead of navigating
  /// back (e.g. a wizard's `Icons.close`) - leave unset everywhere else so
  /// the automatic back button (theme-driven, correct size) is used.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions == null
          ? null
          : [...actions!, const SizedBox(width: 4)],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}
