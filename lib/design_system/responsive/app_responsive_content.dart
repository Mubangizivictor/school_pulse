import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';

/// Caps a scrollable content column's width on tablet/desktop so text and
/// lists don't stretch edge-to-edge on wide viewports, while staying full
/// width (no-op) on mobile. Wrap the body of a screen's Scaffold with this
/// - it does not affect scroll behavior, just horizontal centering/padding.
class AppResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 840,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppBreakpoints.tablet) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
