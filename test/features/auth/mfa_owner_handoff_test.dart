import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'MFA completion refreshes its Firebase token before owner session setup',
    () {
      final source = File(
        'lib/features/auth/login_flow/mfa_challenge_screen.dart',
      ).readAsStringSync();

      final resolveIndex = source.indexOf(
        'await widget.resolver.resolveSignIn',
      );
      final tokenRefreshIndex = source.indexOf(
        'getIdToken(true)',
        resolveIndex,
      );
      final ownerSessionIndex = source.indexOf(
        '_establishOwnerSecuritySessionIfOwner()',
        resolveIndex,
      );

      expect(resolveIndex, isNot(-1));
      expect(tokenRefreshIndex, greaterThan(resolveIndex));
      expect(ownerSessionIndex, greaterThan(tokenRefreshIndex));
    },
  );

  test('an owner completing MFA is not sent to the staff gateway', () {
    final source = File(
      'lib/features/auth/login_flow/mfa_challenge_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains("context.go(isOwner ? '/school-splash' : '/staff/login')"),
    );
  });

  test(
    'school splash waits for MFA auth verification instead of returning to welcome',
    () {
      final source = File('lib/app/router.dart').readAsStringSync();
      final splashRouteIndex = source.indexOf("path: '/school-splash'");
      final loadingGuardIndex = source.indexOf(
        'authState is AuthLoading || authState is AuthInitial',
        splashRouteIndex,
      );
      final welcomeRedirectIndex = source.indexOf(
        "return '/welcome'",
        splashRouteIndex,
      );

      expect(splashRouteIndex, isNot(-1));
      expect(loadingGuardIndex, greaterThan(splashRouteIndex));
      expect(welcomeRedirectIndex, greaterThan(loadingGuardIndex));
    },
  );
}
