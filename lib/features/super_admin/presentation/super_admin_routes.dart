import 'package:go_router/go_router.dart';

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

/// The `/super-admin` (SaaS owner console) route subtree, extracted whole
/// from `lib/app/router.dart` so every owner-console screen, path and nested
/// Navigator lives inside `features/super_admin/`. `router.dart` splices this
/// in with a single `superAdminRoute` entry - behaviour is byte-for-byte the
/// same as when this block was inline.
///
/// Deliberately outside every ShellRoute in `router.dart` - the owner
/// console has its own complete navigation (sidebar on wide, bottom nav on
/// mobile) and must never be wrapped in StaffShell's staff-facing bottom nav.
final RouteBase superAdminRoute = GoRoute(
  path: '/super-admin',
  builder: (context, state) => const SuperAdminDashboard(),
  routes: [
    // Top-level sidebar/bottom-nav sections. Each renders the same
    // SuperAdminDashboard, which reads the active section back out of
    // the URL (see `_sectionIndexForLocation` in super_admin_dashboard
    // .dart) - giving every section its own real, refreshable,
    // back/forward-able address without duplicating the dashboard's
    // IndexedStack/nested-Navigator shell per route.
    //
    // Detail screens (School Details, Application Review, Payment
    // Review) are deliberately NOT full GoRoutes: they're pushed onto
    // the section's own nested Navigator (SuperAdminTabNavigator) so
    // the sidebar/bottom-nav stays visible, exactly as before this
    // change. Their :id child routes below exist only so the URL bar
    // reflects that a detail screen is open and Back/Forward has a
    // history entry to land on - navigating to one directly (no
    // `extra`, e.g. a cold refresh) falls back to the section list,
    // since there is no fetch-by-id path yet for these entities.
    GoRoute(
      path: 'schools',
      builder: (context, state) => const SuperAdminDashboard(),
      routes: [
        GoRoute(
          path: ':schoolId',
          builder: (context, state) => const SuperAdminDashboard(),
          routes: [
            // School Details' Screen B/C/D sub-pushes (Subscription,
            // Modules, School Admins & Actions) each sync the URL via
            // pushSuperAdminDetail before pushing onto the nested
            // Navigator - same cosmetic-URL-only pattern as
            // schools/:schoolId itself. Missing entries here throw a
            // GoException (no matching route) that replaces the whole
            // app with GoRouter's error page, since context.go() is
            // called unconditionally on every push.
            GoRoute(
              path: 'subscription',
              builder: (context, state) => const SuperAdminDashboard(),
            ),
            GoRoute(
              path: 'modules',
              builder: (context, state) => const SuperAdminDashboard(),
            ),
            GoRoute(
              path: 'admins',
              builder: (context, state) => const SuperAdminDashboard(),
            ),
          ],
        ),
        GoRoute(
          path: 'applications/:applicationId',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
      ],
    ),
    GoRoute(
      path: 'payments',
      builder: (context, state) => const SuperAdminDashboard(),
      routes: [
        GoRoute(
          path: ':paymentId',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
      ],
    ),
    GoRoute(
      path: 'plans',
      builder: (context, state) => const SuperAdminDashboard(),
    ),
    GoRoute(
      // Owner Notifications is reached from the Overview bell, not
      // nested under Settings - the bottom nav highlights Overview
      // while it's open (see superAdminSectionForPath). Owner alerts
      // always deliver everything by default - there is deliberately
      // no notification-settings screen to opt out of any category,
      // channel or quiet hours.
      path: 'notifications',
      builder: (context, state) => const SuperAdminMobileNavShell(
        child: SuperAdminNotificationsScreen(),
      ),
      routes: [
        GoRoute(
          path: 'history',
          builder: (context, state) => const SuperAdminMobileNavShell(
            child: OwnerNotificationHistoryScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: 'audit-logs',
      builder: (context, state) => const SuperAdminDashboard(),
    ),
    GoRoute(
      path: 'settings',
      builder: (context, state) => const SuperAdminDashboard(),
    ),
    GoRoute(
      path: 'settings/security',
      builder: (context, state) =>
          const SuperAdminMobileNavShell(child: SecurityCenterScreen()),
    ),
    GoRoute(
      path: 'settings/custom-domains',
      builder: (context, state) =>
          const SuperAdminMobileNavShell(child: CustomDomainsScreen()),
    ),
    GoRoute(
      path: 'settings/subdomain-requests',
      builder: (context, state) => const SuperAdminMobileNavShell(
        child: SubdomainChangeRequestsScreen(),
      ),
    ),
    GoRoute(
      path: 'platform-health',
      builder: (context, state) =>
          const SuperAdminMobileNavShell(child: PlatformHealthScreen()),
    ),
    GoRoute(
      path: 'settings/support',
      builder: (context, state) =>
          const SuperAdminMobileNavShell(child: HelpSupportHomeScreen()),
      routes: [
        GoRoute(
          path: 'help-center',
          builder: (context, state) => const SuperAdminMobileNavShell(
            child: SupportHelpCenterScreen(),
          ),
        ),
        GoRoute(
          path: 'faqs',
          builder: (context, state) =>
              const SuperAdminMobileNavShell(child: SupportFaqsScreen()),
        ),
        GoRoute(
          path: 'new',
          builder: (context, state) => SuperAdminMobileNavShell(
            child: SubmitSupportRequestScreen(
              args:
                  state.extra as SubmitSupportRequestArgs? ??
                  const SubmitSupportRequestArgs(origin: 'submit_request'),
            ),
          ),
        ),
        GoRoute(
          path: 'ticket/:id',
          builder: (context, state) => SuperAdminMobileNavShell(
            child: SupportTicketConversationScreen(
              ticketId: state.pathParameters['id']!,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: 'settings/about',
      builder: (context, state) =>
          const SuperAdminMobileNavShell(child: ContactAboutScreen()),
      routes: [
        GoRoute(
          path: 'privacy-policy',
          builder: (context, state) =>
              const SuperAdminMobileNavShell(child: PrivacyPolicyScreen()),
        ),
      ],
    ),
  ],
);
