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
      onGenerateRoute: (settings) => PageRouteBuilder(
        settings: settings,
        // The section root never animates - it is the IndexedStack child
        // and is only ever "navigated to" as the initial route.
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => child,
      ),
    );
  }
}

/// The 180ms fade used for detail pushes onto a section's nested Navigator,
/// matching the app-wide `fadeThroughPage` policy so an in-section push
/// (School Details, Payment Review, ...) looks identical to a full-page
/// route change. [name] carries the detail URL so a duplicate push can be
/// detected and skipped.
PageRoute<T> ownerDetailRoute<T>(Widget child, {String? name}) {
  return PageRouteBuilder<T>(
    settings: RouteSettings(name: name),
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
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
  final detailUrl = '$sectionUrl/$detailPath';

  // Dedupe: a re-tap on a card that already opened this exact detail must
  // not stack a second identical push (or fire a redundant router
  // navigation). `settings.name` on the pushed route carries the detail
  // URL so we can recognise it.
  final navigator = Navigator.of(context);
  if (ModalRoute.of(context)?.settings.name == detailUrl) {
    return Future<T?>.value(null);
  }

  if (GoRouterState.of(context).uri.path != detailUrl) {
    context.go(detailUrl);
  }

  return navigator.push<T>(
    ownerDetailRoute<T>(
      PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if (didPop && context.mounted) context.go(sectionUrl);
        },
        child: detail,
      ),
      name: detailUrl,
    ),
  );
}
