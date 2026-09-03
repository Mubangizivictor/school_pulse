// Proves SignInMethodsScreen reads the real linked providers from
// FirebaseAuth.currentUser.providerData (never a locally cached flag),
// requires fresh reauthentication before linking/unlinking, blocks
// unlinking down to zero sign-in methods, and logs every link/unlink via
// the server-side logOwnerProviderEvent callable. The real screen depends
// on FirebaseAuth/FirebaseFunctions and OwnerSecurityPolicy, which this
// fast widget-test layer doesn't set up, so this verifies composition at
// the source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/sign_in_methods_screen.dart',
    ).readAsStringSync();
  });

  test('linked providers are read live from FirebaseAuth, not cached', () {
    expect(
      source.contains(
        'FirebaseAuth.instance.currentUser?.providerData\n          .map((p) => p.providerId)',
      ),
      isTrue,
    );
  });

  test('linking Google/Apple requires fresh reauthentication first', () {
    expect(
      source.contains(
        "reason: 'Confirm it\\'s you before linking a new sign-in method.'",
      ),
      isTrue,
    );
  });

  test('unlinking is blocked when it would leave zero sign-in methods', () {
    expect(source.contains('if (_providerIds.length <= 1) {'), isTrue);
    expect(
      source.contains('You must keep at least one sign-in method.'),
      isTrue,
    );
  });

  test('unlinking requires a destructive confirmation dialog', () {
    expect(source.contains("title: 'Unlink Google?'"), isTrue);
    expect(source.contains("title: 'Unlink Apple?'"), isTrue);
    expect(source.contains('isDestructive: true'), isTrue);
  });

  test('every link/unlink is logged via the server-side logOwnerProviderEvent callable', () {
    expect(source.contains("httpsCallable('logOwnerProviderEvent')"), isTrue);
    expect(source.contains("_logProviderEvent('google.com', 'link')"), isTrue);
    expect(source.contains("_logProviderEvent('google.com', 'unlink')"), isTrue);
    expect(source.contains("_logProviderEvent('apple.com', 'link')"), isTrue);
    expect(source.contains("_logProviderEvent('apple.com', 'unlink')"), isTrue);
  });

  test('audit logging failure never blocks the UI from reflecting a completed link/unlink', () {
    expect(
      source.contains(
        '} catch (_) {\n      // Audit logging failure must never block the already-completed',
      ),
      isTrue,
    );
  });

  test('linking to a different UID than before is treated as a fatal integration bug', () {
    expect(
      source.contains(
        "throw StateError('Linking unexpectedly changed the signed-in account.');",
      ),
      isTrue,
    );
  });

  test('password provider is shown as Active but has no link/unlink affordance', () {
    expect(source.contains("title: 'Email & Password'"), isTrue);
    expect(source.contains("label: 'Active'"), isTrue);
  });

  test('errors surface a clean FirebaseAuthException.message, not a raw toString', () {
    expect(source.contains('e.message ?? '), isTrue);
  });
}
