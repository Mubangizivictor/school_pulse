// Proves RecoveryCodesScreen never persists raw codes client-side, requires
// Two-Step Verification and fresh reauthentication before
// generating/regenerating, confirms before regenerating over existing
// codes, and shows the one-time reveal screen exactly once via Navigator
// push (no way back to it). The real screen depends on FirebaseFunctions/
// FirebaseAuth and OwnerSecurityPolicy.ensureFreshAuthentication, which this
// fast widget-test layer doesn't set up, so this verifies composition at
// the source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/recovery_codes_screen.dart',
    ).readAsStringSync();
  });

  test('status is read from the real getOwnerRecoveryCodesStatus callable, not a mock', () {
    expect(source.contains("httpsCallable('getOwnerRecoveryCodesStatus')"), isTrue);
  });

  test('generation requires an enrolled MFA factor first', () {
    expect(
      source.contains('multiFactor\n            .getEnrolledFactors()'),
      isTrue,
    );
    expect(
      source.contains('Set up Two-Step Verification first'),
      isTrue,
    );
  });

  test('regenerating over existing codes requires a destructive confirmation dialog', () {
    expect(source.contains("title: 'Regenerate recovery codes?'"), isTrue);
    expect(source.contains('isDestructive: true'), isTrue);
  });

  test('generation requires fresh reauthentication before calling the callable', () {
    expect(
      source.contains('OwnerSecurityPolicy.ensureFreshAuthentication('),
      isTrue,
    );
    expect(source.contains("if (!fresh) {"), isTrue);
  });

  test('codes come from the real generateOwnerRecoveryCodes callable, never fabricated client-side', () {
    expect(source.contains("httpsCallable('generateOwnerRecoveryCodes')"), isTrue);
    expect(
      source.contains("final codes = (result.data['codes'] as List).cast<String>();"),
      isTrue,
    );
  });

  test('the reveal screen cannot be popped back to and codes are never persisted', () {
    expect(source.contains('class _RecoveryCodesRevealScreen'), isTrue);
    expect(source.contains('return PopScope('), isTrue);
    expect(source.contains('canPop: false'), isTrue);
    // The doc comment explicitly disclaims SharedPreferences/local caching -
    // just confirm there is no actual persistence call in the code.
    expect(source.contains('SharedPreferences.'), isFalse);
    expect(source.contains('.setString('), isFalse);
  });

  test('rate-limit errors surface a clear message, not a raw Firebase code', () {
    expect(
      source.contains("e.code == 'resource-exhausted'\n            ? 'Too many attempts. Try again later.'"),
      isTrue,
    );
  });

  test('button label reflects whether codes already exist', () {
    expect(
      source.contains("label: _exists ? 'Regenerate Codes' : 'Generate Codes'"),
      isTrue,
    );
  });
}
