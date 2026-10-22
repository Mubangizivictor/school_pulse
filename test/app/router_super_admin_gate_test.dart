// Structural counterpart to router_owner_staff_gate_test.dart: proves the
// router source contains the guard that denies a non-superAdmin session
// (School Admin, or any other staff role) access to every /super-admin*
// route, redirecting them to their own dashboard instead. As with the
// sibling test, the router's redirect callback depends on BuildContext-
// scoped AuthBloc/FirebaseAuth/OwnerSecuritySessionService state that this
// fast unit-test suite has no lightweight way to fake end-to-end, so this
// checks the guard exists and rejects (not merely observes) the session.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test(
    'redirect callback denies School Admin / staff access to every /super-admin* route',
    () {
      final guardIndex = source.indexOf("state.uri.path.startsWith('/super-admin')");
      expect(
        guardIndex,
        isNot(-1),
        reason: 'router must guard every /super-admin* route, not just the root',
      );

      final window = source.substring(
        guardIndex,
        (guardIndex + 600).clamp(0, source.length),
      );

      expect(
        window.contains('authState.user.role != UserRole.superAdmin'),
        isTrue,
        reason:
            'the /super-admin guard must deny any role other than '
            'superAdmin - this is what keeps School Admin and every other '
            'staff role off the owner console',
      );
      expect(
        window.contains('dashboardPath'),
        isTrue,
        reason:
            'a denied non-superAdmin session must be redirected to its own '
            'dashboard, not merely blocked with no destination',
      );
    },
  );

  test(
    'an unauthenticated caller cannot reach /super-admin either',
    () {
      final guardIndex = source.indexOf("state.uri.path.startsWith('/super-admin')");
      final window = source.substring(
        guardIndex,
        (guardIndex + 2500).clamp(0, source.length),
      );
      expect(
        window.contains('AuthAuthenticated'),
        isTrue,
        reason:
            'the /super-admin guard must branch on authentication state, '
            'not assume authState is always AuthAuthenticated',
      );
      expect(
        window.contains("return '/welcome'"),
        isTrue,
        reason:
            'an unauthenticated session hitting /super-admin* must be '
            'redirected away (to /welcome), not fall through unguarded',
      );
    },
  );

  test(
    'the async MFA-enrollment + owner-security-session gate still runs, '
    'now on the /super-admin subtree route',
    () {
      // The async gate moved OFF the global redirect (so a slow session
      // check no longer runs on every navigation anywhere) and ONTO
      // superAdminRoute\'s own redirect. It must still be there.
      final routes = File(
        'lib/features/super_admin/presentation/super_admin_routes.dart',
      ).readAsStringSync();

      expect(routes.contains('redirect: (context, state) => _superAdminRedirect'),
          isTrue);
      expect(routes.contains("return '/owner/mfa-setup'"), isTrue,
          reason: 'mandatory TOTP enrollment gate must survive the move');
      expect(
        routes.contains('validateOrReestablishOutcome()'),
        isTrue,
        reason: 'owner-security-session validation must survive the move',
      );
      expect(routes.contains("if (outcome.isInvalid) return '/owner-login'"),
          isTrue,
          reason:
              'only a server-confirmed-invalid session redirects to '
              '/owner-login; a transient failure must leave the user in place');
      // The global redirect must no longer await anything for /super-admin.
      final guardIdx =
          source.indexOf("state.uri.path.startsWith('/super-admin')");
      final guardWindow = source.substring(
        guardIdx,
        (guardIdx + 700).clamp(0, source.length),
      );
      expect(guardWindow.contains('await'), isFalse,
          reason:
              'the global /super-admin guard must stay synchronous - the '
              'await moved to the subtree redirect');
    },
  );
}
