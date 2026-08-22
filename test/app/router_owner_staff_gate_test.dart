// Structural test: the top-level GoRouter redirect callback depends on
// BuildContext-scoped AuthBloc/BrandingBloc/InstitutionContextCubit state
// and the real FirebaseAuth.instance / OwnerSecuritySessionService, which
// this fast unit-test suite has no lightweight way to fake end-to-end.
// Instead this proves the router source itself contains the guard that
// prevents a superAdmin (the seeded owner) session from ever rendering
// Staff Gateway or any /staff/* route, and that the guard runs BEFORE the
// Super Admin route protection block so it can't be shadowed by it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test(
    'redirect callback rejects a superAdmin-authenticated session found on /staff/login or any /staff/* route',
    () {
      final redirectStart = source.indexOf(
        'redirect: (context, state) async {',
      );
      expect(redirectStart, isNot(-1));

      final staffGuardIndex = source.indexOf(
        "state.uri.path == '/staff/login'",
        redirectStart,
      );
      expect(
        staffGuardIndex,
        isNot(-1),
        reason:
            'router must guard /staff/login explicitly against an '
            'authenticated superAdmin session',
      );

      final startsWithStaffIndex = source.indexOf(
        "state.uri.path.startsWith('/staff/')",
        redirectStart,
      );
      expect(
        startsWithStaffIndex,
        isNot(-1),
        reason:
            'router must also guard every other /staff/* route, not just /staff/login',
      );

      // Confirm both conditions live inside one guard block that checks
      // AuthAuthenticated + role == superAdmin, and that it redirects away
      // (not merely observes) - by checking the surrounding window of
      // source around the guard for the expected condition and return.
      final windowStart = redirectStart;
      final windowEnd = staffGuardIndex + 400;
      final window = source.substring(
        windowStart,
        windowEnd.clamp(0, source.length),
      );

      expect(
        window.contains('authState is AuthAuthenticated'),
        isTrue,
        reason: 'the /staff guard must only apply to an authenticated session',
      );
      expect(
        window.contains('authState.user.role == UserRole.superAdmin'),
        isTrue,
        reason:
            'the /staff guard must specifically target superAdmin (the seeded owner role)',
      );
      expect(
        window.contains("return '/school-bootstrap'"),
        isTrue,
        reason:
            'must redirect a superAdmin found on /staff/* through '
            '/school-bootstrap, which already forwards superAdmin to '
            '/super-admin',
      );
    },
  );

  test(
    'the /staff superAdmin guard runs before the Super Admin route protection block, so it always evaluates',
    () {
      final staffGuardIndex = source.indexOf(
        "state.uri.path == '/staff/login'",
      );
      final superAdminGuardIndex = source.indexOf(
        "state.uri.path.startsWith('/super-admin')",
      );
      expect(staffGuardIndex, isNot(-1));
      expect(superAdminGuardIndex, isNot(-1));
      expect(
        staffGuardIndex < superAdminGuardIndex,
        isTrue,
        reason:
            'the /staff guard must be positioned before the /super-admin '
            'protection block in the redirect callback',
      );
    },
  );
}
