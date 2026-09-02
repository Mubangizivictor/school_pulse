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
}
