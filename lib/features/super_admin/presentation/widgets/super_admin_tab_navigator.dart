import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

/// Pushes [detail] onto the nearest nested [Navigator] (the same target a
/// plain `Navigator.push(context, ...)` from within a
/// [SuperAdminTabNavigator] would use) while also giving the browser a
/// matching URL/history entry via [detailPath] (a child path of the
/// current section, e.g. `'abc123'` under `/schools`).
///
/// The two stacks are independent, so both directions are wired here: the
/// URL is set going in, and a [PopScope] on [detail] resyncs the URL back
/// to [sectionPath] when the nested screen is popped by any means (in-app
/// back button, browser Back, or the OS back gesture) — otherwise the
/// address bar would keep pointing at the detail URL after the detail
/// screen itself is gone.
Future<T?> pushSuperAdminDetail<T>({
  required BuildContext context,
  required String sectionPath,
  required String detailPath,
  required Widget detail,
}) {
  final sectionUrl = '/super-admin/$sectionPath';
  context.go('$sectionUrl/$detailPath');
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (context) => PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if (didPop && context.mounted) context.go(sectionUrl);
        },
        child: detail,
      ),
    ),
  );
}
