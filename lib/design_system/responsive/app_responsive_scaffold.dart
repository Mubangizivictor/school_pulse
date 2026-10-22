import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_responsive_content.dart';
import 'responsive_builder.dart';

/// Standard full-page screen: app bar + a body that is padded per layout
/// and width-capped on tablet/desktop via [AppResponsiveContent].
///
/// This is for standalone pages. Role shells (AdminWebShell, BursarShell,
/// StaffShell, ...) already own their sidebar/bottom navigation; screens
/// rendered inside a shell can use it with [showAppBar] false, or just
/// [AppResponsiveContent] directly.
class AppResponsiveScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double maxContentWidth;
  final bool showAppBar;

  /// Scroll the body. Turn off when [body] is itself a scrollable
  /// (ListView, CustomScrollView) so scrolling isn't nested.
  final bool scrollable;

  const AppResponsiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.maxContentWidth = 840,
    this.showAppBar = true,
    this.scrollable = true,
  });

  static double horizontalPadding(ResponsiveLayout layout) => switch (layout) {
    ResponsiveLayout.mobile => AppSpacing.l,
    ResponsiveLayout.tablet => AppSpacing.x2l,
    ResponsiveLayout.desktop => AppSpacing.x3l,
  };

  @override
  Widget build(BuildContext context) {
    final padding = horizontalPadding(ResponsiveBuilder.getLayout(context));
    // Full width of the (capped) content column: AppResponsiveContent's
    // Align loosens constraints, so without this a body that doesn't size
    // itself would shrink-wrap instead of filling the column.
    final padded = SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: AppSpacing.l,
        ),
        child: body,
      ),
    );
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: title == null ? null : Text(title!), actions: actions)
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: !showAppBar,
        child: AppResponsiveContent(
          maxWidth: maxContentWidth,
          child: scrollable ? SingleChildScrollView(child: padded) : padded,
        ),
      ),
    );
  }
}
