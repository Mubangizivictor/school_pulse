import 'package:flutter/material.dart';
import '../theme/app_breakpoints.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, ResponsiveLayout layout);

enum ResponsiveLayout { mobile, tablet, desktop }

class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder builder;

  const ResponsiveBuilder({super.key, required this.builder});

  static ResponsiveLayout getLayout(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= AppBreakpoints.smallDesktop) {
      return ResponsiveLayout.desktop;
    } else if (width >= AppBreakpoints.tablet) {
      return ResponsiveLayout.tablet;
    } else {
      return ResponsiveLayout.mobile;
    }
  }

  static bool isMobile(BuildContext context) =>
      getLayout(context) == ResponsiveLayout.mobile;

  static bool isTablet(BuildContext context) =>
      getLayout(context) == ResponsiveLayout.tablet;

  static bool isDesktop(BuildContext context) =>
      getLayout(context) == ResponsiveLayout.desktop;

  @override
  Widget build(BuildContext context) {
    return builder(context, getLayout(context));
  }
}
