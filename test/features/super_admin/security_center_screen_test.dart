// Proves SecurityCenterScreen (SaaS Owner Settings > Security > Overview)
// wires MFA/biometrics/session-revocation state from real sources (Firebase
// Auth currentUser, AuthBloc, SecuritySettingsCubit, OwnerSessionCubit) and
// carries the mounted-check fix on the revoke-session path: `if (!mounted)
// return;` must guard the read of context after the async
// signInWithCustomToken/assertPlatformOwnerAccess round trip, otherwise a
// BuildContext could be used after the widget was disposed mid-revocation.
// The real screen depends on FirebaseAuth.instance, FirebaseFunctions, and
// several sl<> DI-registered services, none of which this fast widget-test
// layer sets up, so this verifies composition at the source level - the
// same approach used by school_admin_management_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/security_center_screen.dart',
    ).readAsStringSync();
  });

  test('account-secure banner is driven by the real AuthBloc mfaEnabled flag', () {
    expect(
      source.contains(
        'authState is AuthAuthenticated && authState.user.mfaEnabled',
      ),
      isTrue,
    );
    expect(source.contains('_SecureStatusBanner(secure: mfaEnabled)'), isTrue);
  });

  test('Two-Step Verification and Recovery Codes rows reflect the real mfaEnabled state', () {
    expect(source.contains("title: 'Two-Step Verification'"), isTrue);
    expect(source.contains("title: 'Recovery Codes'"), isTrue);
    // Recovery codes navigation is gated on MFA being enabled.
    expect(
      source.contains('onTap: mfaEnabled'),
      isTrue,
    );
  });

  test('biometric toggle requires device capability and a fresh biometric prompt', () {
    expect(source.contains('sl<BiometricAuthService>().isDeviceCapable()'), isTrue);
    expect(source.contains('sl<BiometricAuthService>().authenticate('), isTrue);
    expect(source.contains('cubit.setBiometricEnabled(true)'), isTrue);
  });

  test('App Lock switch is disabled until biometric unlock is enabled', () {
    expect(source.contains("title: 'App Lock'"), isTrue);
    expect(
      source.contains(
        'onChanged: settings.biometricEnabled\n                      ? (value) => context',
      ),
      isTrue,
    );
  });

  test('Sign Out Other Devices requires confirmation before revoking', () {
    expect(source.contains('onPressed: _revoking ? null : _confirmRevoke'), isTrue);
    expect(source.contains("title: 'Sign out other devices?'"), isTrue);
    expect(source.contains('isDestructive: true'), isTrue);
  });

  test('revoke goes through the owner-only revokeOwnerSessions callable and re-establishes the session', () {
    expect(source.contains("httpsCallable('revokeOwnerSessions')"), isTrue);
    expect(source.contains('FirebaseAuth.instance.signInWithCustomToken(customToken)'), isTrue);
    expect(source.contains("httpsCallable('assertPlatformOwnerAccess')"), isTrue);
    expect(source.contains('OwnerSecuritySessionService.instance.establish('), isTrue);
  });

  test('revoke logs a REVOKE_SESSION audit event via SecuritySettingsCubit', () {
    expect(source.contains("action: 'REVOKE_SESSION'"), isTrue);
  });

  test('regression: revoke guards context/state access with a mounted check after the async round trip', () {
    // This is the exact fix under test: without it, a widget disposed
    // mid-revocation (e.g. the owner navigates away while the network call
    // is in flight) could use a stale BuildContext or call setState after
    // dispose.
    expect(source.contains("httpsCallable('assertPlatformOwnerAccess').call();"), isTrue);
    expect(source.contains('if (!mounted) return;'), isTrue);
    expect(
      source.contains('await context.read<SecuritySettingsCubit>().logSecurityEvent('),
      isTrue,
    );
    // The mounted check must appear immediately before the logSecurityEvent
    // call, guarding it - not just exist somewhere else in the file.
    final idx = source.indexOf('await context.read<SecuritySettingsCubit>().logSecurityEvent(');
    final before = source.substring(0, idx);
    expect(before.trim().endsWith('if (!mounted) return;'), isTrue);
  });

  test('trusted device count is sourced from the real OwnerSessionCubit state, not a hardcoded number', () {
    expect(source.contains('final trustedCount = sessionState.sessions'), isTrue);
    expect(source.contains('.where((s) => s.trusted)'), isTrue);
  });

  test('suspicious activity is streamed from super_admin_sign_in_events, not a fabricated all-clear', () {
    expect(
      source.contains("collection('super_admin_sign_in_events')"),
      isTrue,
    );
    expect(source.contains("where('suspicious', isEqualTo: true)"), isTrue);
  });
}
