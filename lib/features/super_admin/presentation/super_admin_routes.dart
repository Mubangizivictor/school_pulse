import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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

GoRoute _fadeRoute(
  String path, {
  required Widget Function(BuildContext, GoRouterState) child,
  List<RouteBase> routes = const [],
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) =>
        fadeThroughPage(key: state.pageKey, child: child(context, state)),
    routes: routes,
  );
}

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
final RouteBase superAdminRoute = GoRoute(
  path: '/super-admin',
  redirect: (context, state) => _superAdminRedirect(state),
  pageBuilder: (context, state) =>
      fadeThroughPage(key: state.pageKey, child: const SuperAdminDashboard()),
  routes: [
    // Top-level sidebar/bottom-nav sections. Each renders the same
    // SuperAdminDashboard, which reads the active section back out of the
    // URL (see `superAdminSectionForPath`) - giving every section its own
    // real, refreshable, back/forward-able address without duplicating the
    // dashboard's IndexedStack/nested-Navigator shell per route.
    //
    // Detail screens (School Details, Application Review, Payment Review)
    // are deliberately NOT full GoRoutes: they're pushed onto the section's
    // own nested Navigator (SuperAdminTabNavigator) so the sidebar/bottom
    // nav stays visible. Their :id child routes below exist only so the URL
    // bar reflects that a detail screen is open and Back/Forward has a
    // history entry to land on.
    _fadeRoute(
      'schools',
      child: (context, state) => const SuperAdminDashboard(),
      routes: [
        _fadeRoute(
          ':schoolId',
          child: (context, state) => const SuperAdminDashboard(),
          routes: [
            _fadeRoute(
              'subscription',
              child: (context, state) => const SuperAdminDashboard(),
            ),
            _fadeRoute(
              'modules',
              child: (context, state) => const SuperAdminDashboard(),
            ),
            _fadeRoute(
              'admins',
              child: (context, state) => const SuperAdminDashboard(),
            ),
          ],
        ),
        _fadeRoute(
          'applications/:applicationId',
          child: (context, state) => const SuperAdminDashboard(),
        ),
      ],
    ),
    _fadeRoute(
      'payments',
      child: (context, state) => const SuperAdminDashboard(),
      routes: [
        _fadeRoute(
          ':paymentId',
          child: (context, state) => const SuperAdminDashboard(),
        ),
      ],
    ),
    _fadeRoute(
      'plans',
      child: (context, state) => const SuperAdminDashboard(),
    ),
    _fadeRoute(
      // Owner Notifications is reached from the Overview bell, not nested
      // under Settings - the bottom nav highlights Overview while it's
      // open (see superAdminSectionForPath).
      'notifications',
      child: (context, state) => const SuperAdminMobileNavShell(
        child: SuperAdminNotificationsScreen(),
      ),
      routes: [
        _fadeRoute(
          'history',
          child: (context, state) => const SuperAdminMobileNavShell(
            child: OwnerNotificationHistoryScreen(),
          ),
        ),
      ],
    ),
    _fadeRoute(
      'audit-logs',
      child: (context, state) => const SuperAdminDashboard(),
    ),
    _fadeRoute(
      'settings',
      child: (context, state) => const SuperAdminDashboard(),
    ),
    _fadeRoute(
      'settings/security',
      child: (context, state) =>
          const SuperAdminMobileNavShell(child: SecurityCenterScreen()),
    ),
    _fadeRoute(
      'settings/custom-domains',
      child: (context, state) =>
          const SuperAdminMobileNavShell(child: CustomDomainsScreen()),
    ),
    _fadeRoute(
      'settings/subdomain-requests',
      child: (context, state) => const SuperAdminMobileNavShell(
        child: SubdomainChangeRequestsScreen(),
      ),
    ),
    _fadeRoute(
      'platform-health',
      child: (context, state) =>
          const SuperAdminMobileNavShell(child: PlatformHealthScreen()),
    ),
    _fadeRoute(
      'settings/support',
      child: (context, state) =>
          const SuperAdminMobileNavShell(child: HelpSupportHomeScreen()),
      routes: [
        _fadeRoute(
          'help-center',
          child: (context, state) => const SuperAdminMobileNavShell(
            child: SupportHelpCenterScreen(),
          ),
        ),
        _fadeRoute(
          'faqs',
          child: (context, state) =>
              const SuperAdminMobileNavShell(child: SupportFaqsScreen()),
        ),
        _fadeRoute(
          'new',
          child: (context, state) => SuperAdminMobileNavShell(
            child: SubmitSupportRequestScreen(
              args:
                  state.extra as SubmitSupportRequestArgs? ??
                  const SubmitSupportRequestArgs(origin: 'submit_request'),
            ),
          ),
        ),
        _fadeRoute(
          'ticket/:id',
          child: (context, state) => SuperAdminMobileNavShell(
            child: SupportTicketConversationScreen(
              ticketId: state.pathParameters['id']!,
            ),
          ),
        ),
      ],
    ),
    _fadeRoute(
      'settings/about',
      child: (context, state) =>
          const SuperAdminMobileNavShell(child: ContactAboutScreen()),
      routes: [
        _fadeRoute(
          'privacy-policy',
          child: (context, state) =>
              const SuperAdminMobileNavShell(child: PrivacyPolicyScreen()),
        ),
      ],
    ),
  ],
);
