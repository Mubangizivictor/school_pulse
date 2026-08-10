import 'package:flutter/material.dart';

/// Wraps one section of the SaaS Owner console in its own [Navigator] so
/// that screens pushed from within it (e.g. School Details from Schools,
/// Payment Review from Payments & Billing) layer on top of that section's
/// content instead of replacing the whole app — keeping the bottom
/// navigation bar / sidebar visible everywhere, not just on the top-level
/// tab screens.
///
/// Each [SuperAdminTabNavigator] gets a stable [navigatorKey] supplied by
/// the parent shell so the shell can pop a tab's stack back to its root
/// when the user re-taps an already-selected destination.
class SuperAdminTabNavigator extends StatelessWidget {
  const SuperAdminTabNavigator({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => child, settings: settings),
    );
  }
}
