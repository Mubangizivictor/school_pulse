import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/app/router.dart' show fadeThroughPage;
import 'package:school_pulse/features/super_admin/domain/owner_security_session_service.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_dashboard.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/super_admin_mobile_nav_shell.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_notifications_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/owner_notification_history_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/security_center_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/custom_domains_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/subdomain_change_requests_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/platform_health_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/help_support_home_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/submit_support_request_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/support_ticket_conversation_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/contact_about_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/privacy_policy_screen.dart';

/// Async gate for the whole `/super-admin` subtree. This was previously
/// inline in `lib/app/router.dart`'s global `redirect`, where it ran on
/// *every* navigation anywhere in the app and, being `async`, let a slow
/// Cloud Function call resolve against a route the user had already left -
/// the flash/return behaviour. Here it only runs for `/super-admin*`, and
/// [OwnerSecuritySessionService] now memoises a confirmed-valid session for
/// a short window so repeated entries do not re-hit the backend.
///
/// The synchronous role check (`role != superAdmin`) still lives in the
/// global redirect so a wrong-role user never even reaches this subtree.
Future<String?> _superAdminRedirect(GoRouterState state) async {
  // Super admin console is web-only. Redirect any mobile/desktop-app visitor
  // to /welcome before the MFA and security-session checks below.
  if (!kIsWeb) return '/welcome';

  // DEV-ONLY local emulator bypass. The Firebase Auth Emulator cannot
  // generate a TOTP secret, so the mandatory-MFA + owner-security-session
  // gates below can never be satisfied against emulators. Triple-guarded:
  // debug build + --dart-define=USE_FIREBASE_EMULATOR + --dart-define=
  // SKIP_OWNER_MFA. Impossible to reach in a release build.
  const emulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
  const skipOwnerMfa = bool.fromEnvironment('SKIP_OWNER_MFA');
  if (kDebugMode && emulator && skipOwnerMfa) {
    return null;
  }

  // Mandatory TOTP enrollment. Firebase only *enforces* an MFA challenge at
  // sign-in for a user who already has a factor enrolled; it does not
  // require enrollment to exist, so an owner who never set up an
  // authenticator app reaches here on the first factor alone. Force
  // enrollment before the console renders. A transient failure reading the
  // factor list must NOT bounce the user - treat only a definitive empty
  // list as "needs setup".
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    try {
      final factors = await currentUser.multiFactor.getEnrolledFactors();
      if (factors.isEmpty) return '/owner/mfa-setup';
    } catch (_) {
      // Could not read enrollment right now - stay put; the redirect
      // re-evaluates on the next router refresh.
    }
  }

  // The unified elevated session every owner login path converges into
  // (password+TOTP, Google+TOTP, recovery code). Re-derived from the
  // still-live Firebase session on an app restart rather than forcing a
  // full re-login. A session explicitly revoked (Revoke All Sessions)
  // fails closed here. A transport/availability failure is deliberately
  // NOT a redirect - the current screen stays and we re-check later.
  final outcome = await OwnerSecuritySessionService.instance
      .validateOrReestablishOutcome();
  if (outcome.isInvalid) return '/owner-login';
  return null;
}

/// One stable key for every page in the `/super-admin` subtree that renders
/// the console shell ([SuperAdminDashboard]). Because it never changes,
/// GoRouter treats a move between e.g. `/super-admin/schools` and
/// `/super-admin/schools/applications/:id` as *the same page* - it does NOT
/// dispose and rebuild the dashboard (and with it the section's nested
/// Navigator). That rebuild was the bug behind "tap Review, it flashes back,
/// works on the 2nd/3rd try": `pushSuperAdminDetail` calls `context.go` to
/// sync the URL and then `Navigator.push` onto the section's nested
/// Navigator, but the `context.go` was tearing down the very Navigator the
/// push targeted. The dashboard already derives its active section from the
/// URL, and detail screens live on the nested Navigator, so a single
/// persistent shell page is correct.
///
/// This key must never appear on more than one [Page] in the *same*
/// Navigator's page list at once, or the Navigator throws "A GlobalKey was
/// used multiple times". See [superAdminRoutes] for why every shell-
/// rendering route below is a flat, non-nested sibling rather than a
/// parent/child GoRoute tree.
const ValueKey<String> _kConsoleShellPageKey = ValueKey('super-admin-shell');

/// The `/super-admin` (SaaS owner console) route subtree, extracted whole
/// from `lib/app/router.dart` so every owner-console screen, path and nested
/// Navigator lives inside `features/super_admin/`.
///
/// Deliberately outside every ShellRoute in `router.dart` - the owner
/// console has its own complete navigation (sidebar on wide, bottom nav on
/// mobile) and must never be wrapped in StaffShell's staff-facing bottom
/// nav. Every route uses [fadeThroughPage] so switching sections via
/// `context.go` is a single 180ms fade, with no platform slide/flicker and
/// no animation when reselecting the current route.
///
/// This is a **list of top-level sibling routes**, not one GoRoute with
/// children. GoRouter gives every matched *ancestor* GoRoute along a
/// location its own Page when that ancestor has a pageBuilder - so a single
/// `/super-admin` parent with a pageBuilder AND nested children would push
/// two pages (parent + matched child) under the identical
/// _kConsoleShellPageKey the moment a cached session resumed on any child
/// URL (e.g. `/super-admin/settings`), crashing the Navigator with "A
/// GlobalKey was used multiple times" and leaving it stuck (the debug
/// assertion fires mid-`_updatePages`, which never gets to clear its
/// re-entrancy flag, so no further rebuild - and no gesture - is ever
/// processed again for the session). go_router also rejects an empty-string
/// path for an index child, which rules out the usual index-route pattern.
/// Flat siblings sidestep both problems: exactly one route ever matches a
/// given location, so exactly one page is ever produced. GoRouter tries
/// siblings in declaration order, so the specific `_fadeRoute` paths below
/// (`notifications`, `settings/security`, ...) are declared before the
/// `schools/:rest(.*)`-style catch-alls so they win first.
final List<RouteBase> superAdminRoutes = [
  GoRoute(
    path: '/super-admin',
    redirect: (context, state) => _superAdminRedirect(state),
    pageBuilder: (context, state) => fadeThroughPage(
      key: _kConsoleShellPageKey,
      child: const SuperAdminDashboard(),
    ),
  ),
  // Top-level sidebar/bottom-nav sections, plus their detail children
  // (School Details, Application Review, Payment Review), all collapse
  // onto the identical SuperAdminDashboard, which reads the active
  // section/detail back out of the URL (see `superAdminSectionForPath`) -
  // giving every section its own real, refreshable, back/forward-able
  // address without duplicating the dashboard's IndexedStack/nested-
  // Navigator shell per route. Detail screens are pushed onto the
  // section's own nested Navigator (SuperAdminTabNavigator); the URL
  // segment past the section (:rest) exists only so the address bar
  // reflects that a detail screen is open and Back/Forward has a history
  // entry to land on - nothing here reads :rest as a path parameter.
  _superAdminShellRoute('/super-admin/schools/:rest(.*)'),
  _superAdminShellRoute('/super-admin/payments/:rest(.*)'),
  _superAdminShellRoute('/super-admin/plans'),
  GoRoute(
    // Owner Notifications is reached from the Overview bell, not nested
    // under Settings - the bottom nav highlights Overview while it's open
    // (see superAdminSectionForPath).
    path: '/super-admin/notifications',
    redirect: (context, state) => _superAdminRedirect(state),
    pageBuilder: (context, state) => fadeThroughPage(
      key: state.pageKey,
      child: const SuperAdminMobileNavShell(
        child: SuperAdminNotificationsScreen(),
      ),
    ),
  ),
  GoRoute(
    path: '/super-admin/notifications/history',
    redirect: (context, state) => _superAdminRedirect(state),
    pageBuilder: (context, state) => fadeThroughPage(
      key: state.pageKey,
      child: const SuperAdminMobileNavShell(
        child: OwnerNotificationHistoryScreen(),
      ),
    ),
  ),
  _superAdminShellRoute('/super-admin/audit-logs'),
  _superAdminShellRoute('/super-admin/settings'),
  _superAdminFadeRoute(
    '/super-admin/settings/security',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: SecurityCenterScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/custom-domains',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: CustomDomainsScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/subdomain-requests',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: SubdomainChangeRequestsScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/platform-health',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: PlatformHealthScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/support',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: HelpSupportHomeScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/support/help-center',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: SupportHelpCenterScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/support/faqs',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: SupportFaqsScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/support/new',
    child: (context, state) => SuperAdminMobileNavShell(
      child: SubmitSupportRequestScreen(
        args:
            state.extra as SubmitSupportRequestArgs? ??
            const SubmitSupportRequestArgs(origin: 'submit_request'),
      ),
    ),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/support/ticket/:id',
    child: (context, state) => SuperAdminMobileNavShell(
      child: SupportTicketConversationScreen(
        ticketId: state.pathParameters['id']!,
      ),
    ),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/about',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: ContactAboutScreen()),
  ),
  _superAdminFadeRoute(
    '/super-admin/settings/about/privacy-policy',
    child: (context, state) =>
        const SuperAdminMobileNavShell(child: PrivacyPolicyScreen()),
  ),
];

/// A flat (non-nested) route that renders the shared console shell under
/// the shared shell key, gated by the same async owner-security redirect
/// every `/super-admin*` route needs.
GoRoute _superAdminShellRoute(String path) {
  return GoRoute(
    path: path,
    redirect: (context, state) => _superAdminRedirect(state),
    pageBuilder: (context, state) => fadeThroughPage(
      key: _kConsoleShellPageKey,
      child: const SuperAdminDashboard(),
    ),
  );
}

/// A flat (non-nested) standalone page route (its own screen, its own key),
/// gated by the same async owner-security redirect every `/super-admin*`
/// route needs - used for the full-page owner screens wrapped in
/// [SuperAdminMobileNavShell].
GoRoute _superAdminFadeRoute(
  String path, {
  required Widget Function(BuildContext, GoRouterState) child,
}) {
  return GoRoute(
    path: path,
    redirect: (context, state) => _superAdminRedirect(state),
    pageBuilder: (context, state) =>
        fadeThroughPage(key: state.pageKey, child: child(context, state)),
  );
}
