// Structural test: the top-level GoRouter redirect callback depends on
// BuildContext-scoped AuthBloc state, which this fast unit-test suite has
// no lightweight way to fake end-to-end. Instead this proves the router
// source itself contains a guard that re-checks mustChangePassword on
// every navigation - not just once at the login-screen listener - so a
// session restored on relaunch or reached via a deep link cannot bypass
// the forced password/PIN change.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test(
    'redirect callback forces an AuthAuthenticated session with mustChangePassword true to /auth/force-setup or /auth/onboarding',
    () {
      final redirectStart = source.indexOf(
        'redirect: (context, state) async {',
      );
      expect(redirectStart, isNot(-1));

      final guardIndex = source.indexOf(
        'authState.user.mustChangePassword',
        redirectStart,
      );
      expect(
        guardIndex,
        isNot(-1),
        reason:
            'router redirect must check mustChangePassword on every '
            'navigation, not only in the login-screen listener',
      );

      final window = source.substring(
        guardIndex,
        (guardIndex + 600).clamp(0, source.length),
      );

      expect(
        window.contains("'/auth/onboarding'"),
        isTrue,
        reason: 'schoolAdmin must be routed to onboarding, not force-setup',
      );
      expect(
        window.contains("'/auth/force-setup'"),
        isTrue,
        reason: 'non-schoolAdmin staff must be routed to force-setup',
      );
      expect(
        window.contains('UserRole.schoolAdmin'),
        isTrue,
        reason: 'the guard must branch on role to pick the correct target',
      );
    },
  );

  test(
    'the mustChangePassword guard runs after the pipeline/school-bootstrap redirect block, to avoid a redirect loop',
    () {
      final guardIndex = source.indexOf('authState.user.mustChangePassword');
      final pipelineIndex = source.indexOf('isPipelineRoute');
      expect(guardIndex, isNot(-1));
      expect(pipelineIndex, isNot(-1));
      expect(
        pipelineIndex < guardIndex,
        isTrue,
        reason:
            'the mustChangePassword guard must be positioned after the '
            'school-bootstrap pipeline guard, otherwise a schoolAdmin with '
            'mustChangePassword true gets bounced to /school-bootstrap '
            'before ever reaching /auth/onboarding',
      );
    },
  );

  test(
    'the guard only redirects when not already on the target route (no redirect loop)',
    () {
      final guardIndex = source.indexOf('authState.user.mustChangePassword');
      final window = source.substring(
        guardIndex,
        (guardIndex + 600).clamp(0, source.length),
      );
      expect(
        window.contains('state.uri.path != targetPath'),
        isTrue,
        reason:
            'must not redirect when already on the force-setup/onboarding '
            'route, or the router would loop',
      );
    },
  );
}
