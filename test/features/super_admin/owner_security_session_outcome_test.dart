// Proves OwnerSecuritySessionService distinguishes a server-confirmed
// negative (redirect to /owner-login) from a transport failure (stay put),
// and memoises a confirmed-valid session so repeated router entries into
// /super-admin do not re-hit Cloud Functions - the two changes that stop
// the console flashing in and bouncing back out.
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/domain/owner_security_session_service.dart';

void main() {
  const session = OwnerSecuritySession(
    sessionId: 's1',
    isOwnerAuthorized: true,
    secondFactorVerified: true,
    authenticationMethod: 'password_totp',
    verifiedAt: null,
  );

  tearDown(() {
    OwnerSecuritySessionService.instance.clear();
  });

  group('OwnerSessionOutcome', () {
    test('valid carries the session; invalid/indeterminate do not', () {
      expect(OwnerSessionOutcome.valid(session).isValid, isTrue);
      expect(OwnerSessionOutcome.valid(session).session, session);

      expect(OwnerSessionOutcome.invalid.isInvalid, isTrue);
      expect(OwnerSessionOutcome.invalid.session, isNull);

      expect(OwnerSessionOutcome.indeterminate.isInvalid, isFalse);
      expect(OwnerSessionOutcome.indeterminate.isValid, isFalse);
      expect(OwnerSessionOutcome.indeterminate.session, isNull);
    });
  });

  group('short-lived session cache', () {
    test('a fresh cached session is returned without a network call', () async {
      OwnerSecuritySessionService.instance.debugSetCache(session);

      final outcome = await OwnerSecuritySessionService.instance
          .validateOrReestablishOutcome();

      // No Firebase in this test env: if it fell through to validateOutcome()
      // it would throw / return indeterminate. Getting `valid` back proves
      // the cache short-circuit ran.
      expect(outcome.isValid, isTrue);
      expect(outcome.session, session);
    });

    test('an expired cache entry does not short-circuit', () async {
      OwnerSecuritySessionService.instance.debugSetCache(
        session,
        at: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final outcome = await OwnerSecuritySessionService.instance
          .validateOrReestablishOutcome();

      // Falls through to a real validation which, with no Firebase wired,
      // cannot confirm a session - so anything but `valid`.
      expect(outcome.isValid, isFalse);
    });

    test('clear() invalidates the cache', () async {
      OwnerSecuritySessionService.instance.debugSetCache(session);
      OwnerSecuritySessionService.instance.clear();

      final outcome = await OwnerSecuritySessionService.instance
          .validateOrReestablishOutcome();
      expect(outcome.isValid, isFalse);
    });
  });
}
