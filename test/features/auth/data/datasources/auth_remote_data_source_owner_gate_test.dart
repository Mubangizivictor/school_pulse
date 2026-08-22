// Structural test: AuthRemoteDataSourceImpl wraps the real Firebase Auth /
// Firestore / Cloud Functions SDKs directly, and this repo has no
// Firebase-Auth/Functions mocking package (only fake_cloud_firestore, which
// doesn't cover FirebaseAuth.signInWithEmailAndPassword or
// FirebaseFunctions.httpsCallable). Exercising loginWithEmail/getCurrentUser
// behaviorally would need a Firebase emulator, which this fast unit-test
// suite doesn't run. Instead - matching the pattern already used by
// public_functions/__tests__/owner_security_session.test.js on the Cloud
// Functions side - this proves the source itself calls the right gate, in
// the right order, so the seeded owner can never slip through Staff
// Gateway's loginWithEmail.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;
  late String implSource;

  setUpAll(() {
    source = File(
      'lib/features/auth/data/datasources/auth_remote_data_source.dart',
    ).readAsStringSync();
    // The file declares both the abstract AuthRemoteDataSource interface
    // and its AuthRemoteDataSourceImpl implementation; every lookup below
    // must search only the implementation, not the interface's matching
    // method signature.
    final implClassStart = source.indexOf(
      'class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {',
    );
    expect(
      implClassStart,
      isNot(-1),
      reason: 'AuthRemoteDataSourceImpl must exist',
    );
    implSource = source.substring(implClassStart);
  });

  test(
    'loginWithEmail (Staff Gateway) calls _rejectIfOwner before returning any user profile',
    () {
      final source = implSource;
      final loginStart = source.indexOf('Future<UserModel> loginWithEmail(');
      expect(loginStart, isNot(-1), reason: 'loginWithEmail must exist');
      final nextMethod = source.indexOf('\n  @override', loginStart + 1);
      final body = source.substring(loginStart, nextMethod);

      final rejectIndex = body.indexOf('_rejectIfOwner(');
      final getUserIndex = body.indexOf('_getUser(');
      expect(
        rejectIndex,
        isNot(-1),
        reason: 'Staff Gateway login must call _rejectIfOwner',
      );
      expect(
        getUserIndex,
        isNot(-1),
        reason: 'Staff Gateway login must still resolve a user profile',
      );
      expect(
        rejectIndex < getUserIndex,
        isTrue,
        reason:
            'the owner-UID rejection must run before the Firestore profile '
            'read, so an owner login cannot observe whether a staff '
            'profile doc exists for that UID',
      );
    },
  );

  test(
    '_rejectIfOwner calls the server-side assertNotPlatformOwner callable and signs out on denial',
    () {
      final source = implSource;
      final start = source.indexOf('Future<void> _rejectIfOwner(');
      expect(start, isNot(-1));
      final nextMethod = source.indexOf('\n  ', start + 40);
      final body = source.substring(
        start,
        nextMethod == -1 ? source.length : nextMethod + 400,
      );

      expect(
        body.contains("httpsCallable('assertNotPlatformOwner')"),
        isTrue,
        reason: 'must call the server-side assertNotPlatformOwner callable',
      );
      expect(
        body.contains('ownerFunctions'),
        isTrue,
        reason:
            'must call it via the europe-west1 ownerFunctions instance, not '
            'the default-region functions instance (see the class-level '
            'doc comment on why using the wrong region silently misroutes '
            'to a not-found error)',
      );
      expect(
        body.contains('firebaseAuth.signOut()'),
        isTrue,
        reason: 'must sign out immediately on denial',
      );
      expect(
        body.contains("AuthFailure('Access denied.')"),
        isTrue,
        reason:
            'must surface the same generic message assertPlatformOwnerAccess '
            'denials use, so Staff Gateway leaks nothing about whether an '
            'owner account exists',
      );
    },
  );

  test(
    'the owner-only login paths (loginOwnerWithEmail/Google/Apple) still use the opposite gate (_assertOwnerAndGetUser), never _rejectIfOwner',
    () {
      final source = implSource;
      for (final method in [
        'loginOwnerWithEmail',
        'loginOwnerWithGoogle',
        'loginOwnerWithApple',
      ]) {
        final start = source.indexOf('Future<UserModel> $method(');
        expect(start, isNot(-1), reason: '$method must exist');
        final nextMethod = source.indexOf('\n  @override', start + 1);
        final body = source.substring(start, nextMethod);
        expect(
          body.contains('_assertOwnerAndGetUser('),
          isTrue,
          reason: '$method must require owner authorization, not reject it',
        );
        expect(
          body.contains('_rejectIfOwner('),
          isFalse,
          reason:
              '$method must never call the non-owner rejection gate - that '
              'would lock the real owner out of their own hidden entry point',
        );
      }
    },
  );
}
