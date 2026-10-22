import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/data/datasources/apple_nonce.dart';
import 'package:school_pulse/features/auth/data/datasources/google_sign_in_config.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);

  /// Platform Owner Access first factor: email/password. Distinct from
  /// [loginWithEmail] because a successful Firebase sign-in here is NOT
  /// sufficient on its own - this also calls the server-side
  /// `assertPlatformOwnerAccess` callable, and immediately signs back out
  /// (throwing a generic [AuthFailure]) if the authenticated UID isn't the
  /// seeded platform owner. Never reached from the Staff Gateway.
  Future<UserModel> loginOwnerWithEmail(String email, String password);

  /// Platform Owner Access first factor: Google. Same server-side owner
  /// check and same-UID-only guarantee as [loginOwnerWithEmail]; a Google
  /// account that authenticates successfully but isn't the linked owner
  /// identity is signed out before this returns.
  Future<UserModel> loginOwnerWithGoogle();

  /// Platform Owner Access first factor: Apple. Same server-side owner
  /// check and same-UID-only guarantee as [loginOwnerWithGoogle]; an Apple
  /// identity that authenticates successfully but isn't the linked owner
  /// identity is signed out before this returns. Never authorizes by the
  /// Apple-supplied name/email (including private relay addresses) - only
  /// the resulting Firebase UID is ever checked.
  Future<UserModel> loginOwnerWithApple();

  /// Re-runs the server-side `assertPlatformOwnerAccess` check for the
  /// already-signed-in Firebase user, without re-authenticating. Used
  /// whenever a session reaches [AuthAuthenticated] through a path that
  /// didn't already go through [loginOwnerWithEmail]/[loginOwnerWithGoogle]
  /// - namely an MFA-resolved sign-in, and a restored session on app
  /// restart - for any profile whose role is `superAdmin`. Signs the
  /// session out and throws [AuthFailure] on denial, same as the login
  /// paths above.
  Future<void> verifyOwnerSession();

  /// Authenticates a parent using their special access code, phone number, and PIN.
  Future<UserModel> loginParent({
    required String code,
    required String phoneNumber,
    required String pin,
  });

  /// Updates the parent's PIN and clears the mustChangePin flag.
  Future<void> completeParentPinSetup(
    String code,
    String phoneNumber,
    String newPin,
  );

  Future<void> logout();
  Future<UserModel?> getCurrentUser();

  /// Calls the `createStaffAccount` Cloud Function, which verifies the
  /// caller is a school administrator before provisioning the Firebase Auth
  /// account and Firestore profile with the Admin SDK. No password is ever
  /// generated, seen, or transmitted by the client - the Auth user is
  /// created with a securely random internal password, and the staff member
  /// sets their own via a verified invitation (signInMethod "invite" issues
  /// one immediately; "noLogin" leaves the profile unable to sign in until
  /// an administrator later calls [createStaffInvitation]). Returns the
  /// created staffCode.
  Future<String> createStaffAccount({
    required String name,
    required String email,
    required String schoolId,
    required List<UserRole> roles,
    String? signInMethod,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
    String? idempotencyKey,
    bool sendLoginDetailsViaEmail = false,
    Map<String, dynamic>? staffData,
    Map<String, dynamic>? roleConfigs,
  });

  /// Calls `createStaffInvitation`, which generates a verified, time-limited
  /// Firebase Auth password-reset action link and emails it to the staff
  /// member. Server enforces resend cooldown, tenant match, and admin-only
  /// access. No password or token is ever returned to the client.
  Future<void> createStaffInvitation(String uid);

  /// Calls `cancelStaffInvitation` to revoke a pending invitation.
  Future<void> cancelStaffInvitation(String uid);

  /// Sets a new password for the currently signed-in user and clears their
  /// mustChangePassword flag. Used the first time a staff member logs in
  /// with an admin-issued temporary password.
  Future<void> completePasswordReset(String newPassword);

  /// All non-parent user profiles for a specific school, for the admin Staff tab.
  Future<List<UserModel>> getStaffMembers(String schoolId);

  Future<void> toggleStaffActiveStatus(
    String userId,
    bool isActive, {
    String? reason,
  });

  Future<void> updateStaffMember(UserModel user);

  Future<void> deleteStaffMember(String userId);

  /// Calls the `adminResetStaffPassword` Cloud Function, which verifies the
  /// caller is a school administrator for [userId]'s school before using the
  /// Admin SDK to set a new temporary password. Returns that password for
  /// the admin to hand to the staff member.
  Future<String> adminResetStaffPassword(String userId);

  /// Reauthenticates via `EmailAuthProvider.credential` +
  /// `reauthenticateWithCredential`, then calls `updatePassword`. Throws
  /// [AuthFailure] with a friendly message on wrong-password/requires-recent-
  /// login/weak-password FirebaseAuthExceptions.
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Updates the signed-in user's own profile doc (name/phone/photoUrl).
  Future<void> updateProfile(UserModel user);

  /// Updates the signed-in user's own `mfaEnabled` flag.
  Future<void> updateMfaEnabled(bool enabled);

  /// Calls the `enterSupportMode` Cloud Function (must be called while
  /// signed in as the owner), then signs into the returned custom token for
  /// the target school's admin. Returns the admin's profile plus the
  /// session metadata the UI needs for the "acting as" banner.
  Future<SupportModeLogin> enterSupportMode({
    required String schoolId,
    required String reason,
  });

  /// Calls `exitSupportMode` (while still signed in as the impersonated
  /// admin) to tear down the server-side session doc, then signs out so the
  /// owner can sign back in.
  Future<void> exitSupportMode({required String ownerId, String? schoolId});
}

class SupportModeLogin {
  final UserModel user;
  final String ownerId;
  final String schoolName;
  final DateTime expiresAt;

  const SupportModeLogin({
    required this.user,
    required this.ownerId,
    required this.schoolName,
    required this.expiresAt,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  /// The `publicwebsite` Cloud Functions codebase (public_functions/) - and
  /// every owner-auth callable on it, including `assertPlatformOwnerAccess` -
  /// is deployed to europe-west1, while [functions] (the plain
  /// `FirebaseFunctions.instance` default region) is what the `default`
  /// codebase's callables actually live in (loginParent, createStaffAccount,
  /// enterSupportMode, etc). Calling an europe-west1-only callable through
  /// the default-region instance resolves to a function that doesn't exist
  /// there, which Firebase reports as `not-found` - surfaced generically as
  /// "Access denied" by this file's existing catch blocks, indistinguishable
  /// from a real owner-authorization denial. This field exists so
  /// owner-authorization calls always reach the region they're actually
  /// deployed in.
  final FirebaseFunctions ownerFunctions;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.functions,
    required this.ownerFunctions,
  });

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      // The seeded SaaS Owner must never obtain a staff session through
      // Staff Gateway, even with correct credentials - only the hidden
      // Platform Owner Access entry may authenticate that UID. Checked
      // before the Firestore profile read below so an owner login can't
      // even observe whether a staff profile doc exists for that UID.
      await _rejectIfOwner(uid);
      // Staff accounts are provisioned ahead of time (with their real role)
      // by an admin, never auto-created here.
      return await _getUser(uid);
    } on FirebaseAuthMultiFactorException {
      // The caller needs the resolver to complete the authenticator challenge.
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication failed');
    }
  }

  /// Server-side gate (the `assertNotPlatformOwner` callable) that rejects
  /// the authenticated UID if it is the canonical seeded owner
  /// (`platform_config/owner_seed.ownerUid`) - the inverse of
  /// [_assertOwnerAndGetUser]'s "deny if not owner" check, used by every
  /// authentication surface that is NOT the dedicated owner login. On
  /// denial the (owner's) Firebase session is signed out immediately and a
  /// generic message is thrown, identical in shape to a real credential
  /// failure so Staff Gateway leaks nothing about the owner account's
  /// existence.
  Future<void> _rejectIfOwner(String uid) async {
    try {
      await ownerFunctions
          .httpsCallable('assertNotPlatformOwner')
          .call<Map<String, dynamic>>();
    } on FirebaseFunctionsException catch (e) {
      _logOwnerCallableFailure('assertNotPlatformOwner', e);
      await firebaseAuth.signOut();
      throw const AuthFailure('Access denied.');
    }
  }

  @override
  Future<UserModel> loginOwnerWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _assertOwnerAndGetUser(credential.user!.uid);
    } on FirebaseAuthMultiFactorException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication failed');
    }
  }

  @override
  Future<UserModel> loginOwnerWithGoogle() async {
    final googleSignIn = ownerGoogleSignIn();
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Sign-in cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      return await _assertOwnerAndGetUser(userCredential.user!.uid);
    } on FirebaseAuthMultiFactorException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      await _denyAndSignOut(googleSignIn);
      throw AuthFailure(e.message ?? 'Authentication failed');
    } on AuthFailure {
      await _denyAndSignOut(googleSignIn);
      rethrow;
    }
  }

  /// Calls the server-side `assertPlatformOwnerAccess` callable, which is
  /// the actual authorization boundary: it checks the authenticated UID
  /// against `platform_config/owner_seed.ownerUid` plus an active owner
  /// role on the profile, never trusting anything the client asserts. A
  /// denial signs the (non-owner) Firebase session back out immediately -
  /// this method never returns a user for a UID the server rejected - and
  /// surfaces the same generic message the spec requires regardless of
  /// *why* the caller isn't the owner.
  Future<UserModel> _assertOwnerAndGetUser(String uid) async {
    try {
      await ownerFunctions
          .httpsCallable('assertPlatformOwnerAccess')
          .call<Map<String, dynamic>>();
    } on FirebaseFunctionsException catch (e) {
      _logOwnerCallableFailure('assertPlatformOwnerAccess', e);
      await firebaseAuth.signOut();
      throw const AuthFailure('Access denied.');
    }
    return await _getUser(uid);
  }

  Future<void> _denyAndSignOut(GoogleSignIn googleSignIn) async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Future<UserModel> loginOwnerWithApple() async {
    try {
      // Web uses Firebase Auth's own OAuth popup flow: the Service ID and
      // redirect URI are configured directly in the Firebase Console's
      // Apple provider settings, so no Service ID/nonce handling is needed
      // client-side here (unlike native, where this app mints its own
      // nonce and talks to Apple's SDK directly).
      final userCredential = kIsWeb
          ? await firebaseAuth.signInWithPopup(
              OAuthProvider('apple.com')
                ..addScope('email')
                ..addScope('name'),
            )
          : await _signInWithAppleNative();
      return await _assertOwnerAndGetUser(userCredential.user!.uid);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthFailure('Sign-in cancelled.');
      }
      throw const AuthFailure('Apple sign-in failed.');
    } on FirebaseAuthMultiFactorException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      await firebaseAuth.signOut();
      throw AuthFailure(e.message ?? 'Authentication failed');
    } on AuthFailure {
      await firebaseAuth.signOut();
      rethrow;
    }
  }

  Future<UserCredential> _signInWithAppleNative() async {
    final nonce = AppleNonce.generate();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce.hashed,
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: nonce.raw,
      accessToken: appleCredential.authorizationCode,
    );
    return firebaseAuth.signInWithCredential(oauthCredential);
  }

  @override
  Future<void> verifyOwnerSession() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) return;
    try {
      await ownerFunctions
          .httpsCallable('assertPlatformOwnerAccess')
          .call<Map<String, dynamic>>();
    } on FirebaseFunctionsException catch (e) {
      _logOwnerCallableFailure('assertPlatformOwnerAccess', e);
      await firebaseAuth.signOut();
      throw const AuthFailure('Access denied.');
    }
  }

  /// Logs enough to diagnose a failed owner-auth callable (which callable,
  /// which region it was configured for, and Firebase's error code) without
  /// ever touching anything sensitive - never the password, ID token, TOTP
  /// code, Apple/Google token, or recovery code involved in the same flow.
  void _logOwnerCallableFailure(
    String callableName,
    FirebaseFunctionsException e,
  ) {
    debugPrint(
      'OwnerCallableFailure callable=$callableName '
      'region=${ownerFunctions.app.name}:${_ownerFunctionsRegion()} '
      'code=${e.code}',
    );
  }

  String _ownerFunctionsRegion() {
    // FirebaseFunctions has no public region getter, but this data source
    // always constructs `ownerFunctions` via instanceFor(region: ...) - see
    // injection_container.dart - so the region is fixed and known here for
    // logging purposes without reflecting into the SDK's internals.
    return 'europe-west1';
  }

  @override
  Future<UserModel> loginParent({
    required String code,
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      // Verifies code+phone+pin server-side (Admin SDK) and mints a custom
      // token, giving the parent a real Firebase Auth session - required
      // for push notifications (users/{uid}/tokens write rule) and
      // broadcast reads (alerts targets rule) to work at all.
      final callable = functions.httpsCallable('loginParent');
      final result = await callable.call<Map<String, dynamic>>({
        'code': code,
        'phoneNumber': phoneNumber,
        'pin': pin,
      });
      final token = result.data['token'] as String;
      final credential = await firebaseAuth.signInWithCustomToken(token);
      return await _getUser(credential.user!.uid);
    } on FirebaseFunctionsException catch (e) {
      throw AuthFailure(e.message ?? 'Login failed.');
    }
  }

  @override
  Future<void> completeParentPinSetup(
    String code,
    String phoneNumber,
    String newPin,
  ) async {
    try {
      final callable = functions.httpsCallable('completeParentPinSetup');
      await callable.call<Map<String, dynamic>>({
        'code': code,
        'phoneNumber': phoneNumber,
        'newPin': newPin,
      });
    } on FirebaseFunctionsException catch (e) {
      throw AuthFailure(e.message ?? 'Could not set PIN.');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  /// Staff/parent sessions persist on the device indefinitely (Firebase
  /// Auth's own default) and are never time-boxed by a token-expiry check -
  /// the only thing that ends a session automatically is this idle window.
  /// Anyone who opens the app again before it elapses stays signed in with
  /// no re-login prompt; only a manual "Log out" or exceeding this window
  /// forces one.
  static const Duration _inactivityLimit = Duration(days: 120);

  @override
  Future<UserModel?> getCurrentUser() async {
    var user = firebaseAuth.currentUser;
    // On web, Firebase Auth restores a persisted session from IndexedDB
    // asynchronously - right after page load `currentUser` is reliably
    // null for a brief window even when the browser still holds a valid
    // session. Reading it synchronously here (as on native, where
    // Firebase.initializeApp already guarantees it's settled) would
    // intermittently sign a still-logged-in owner/user out on refresh.
    // authStateChanges()'s first emission reflects the restored session.
    if (user == null && kIsWeb) {
      user = await firebaseAuth.authStateChanges().first;
    }
    if (user == null) return null;

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final profile = UserModel.fromJson({...data, 'id': doc.id});
      // A persisted Firebase Auth token is not proof that the school account
      // remains active. Re-check the profile on every session restore, just
      // as the interactive login path does, and revoke the local session if
      // an administrator has deactivated the account.
      if (!profile.isActive) {
        await firebaseAuth.signOut();
        throw const AuthFailure('This account has been disabled.');
      }
      final lastActive = _parseDate(data['lastActiveAt']);
      if (lastActive != null &&
          DateTime.now().difference(lastActive) > _inactivityLimit) {
        await firebaseAuth.signOut();
        return null;
      }
      unawaited(_touchLastActive(user.uid));
      return profile;
    }
    // Session survives but the profile is missing (e.g. account created via
    // phone auth was never completed) - treat as signed-out rather than
    // silently fabricating a profile.
    return null;
  }

  Future<UserModel> _getUser(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
      if (!user.isActive) {
        final reason = user.deactivationReason != null
            ? '\nReason: ${user.deactivationReason}'
            : '';
        throw AuthFailure(
          'This account has been disabled.$reason\nPlease contact your school administrator.',
        );
      }
      unawaited(_touchLastActive(uid));
      return user;
    }
    throw const AuthFailure(
      'No profile found for this account. Contact your school administrator.',
    );
  }

  /// Cheap heartbeat so the idle-timeout check above has a real timestamp to
  /// compare against. Best-effort: a failed write here must never block or
  /// fail a login/session-restore.
  Future<void> _touchLastActive(String uid) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-fatal - the next successful login/restore will retry.
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  @override
  Future<String> createStaffAccount({
    required String name,
    required String email,
    required String schoolId,
    required List<UserRole> roles,
    String? signInMethod,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
    String? idempotencyKey,
    bool sendLoginDetailsViaEmail = false,
    Map<String, dynamic>? staffData,
    Map<String, dynamic>? roleConfigs,
  }) async {
    try {
      final callable = functions.httpsCallable('createStaffAccount');
      final result = await callable.call<Map<String, dynamic>>({
        'name': name,
        'email': email,
        'schoolId': schoolId,
        'roles': roles.map((r) => r.name).toList(),
        'signInMethod': signInMethod,
        'assignedClass': assignedClass,
        'subjects': subjects?.map((e) => e.toJson()).toList(),
        'academicYearId': academicYearId,
        'departmentId': departmentId,
        'designationId': designationId,
        'campusId': campusId,
        'employmentType': employmentType,
        'dateJoined': dateJoined?.toIso8601String(),
        'idempotencyKey': idempotencyKey,
        'sendLoginDetailsViaEmail': sendLoginDetailsViaEmail,
        ...?staffData,
        'roleConfigs': roleConfigs,
      });
      // The callable never generates, sees, or returns a password - the
      // Auth user is created with a securely random internal password and
      // the staff member sets their own via a verified invitation (see
      // createStaffAccount/issueStaffInvitation in functions/index.js). The
      // staffCode is the only meaningful identifier it returns; callers
      // that need uid look it up separately (see
      // AddStaffWizardController._lookupStaffCodeAndUid).
      return (result.data['staffCode'] as String?) ?? '';
    } catch (e) {
      // Staff identities, their tenant membership, and their initial
      // credential must be created together by the privileged callable.
      // Falling back to client-created accounts bypasses that authorization
      // boundary and can leave a partial Auth/profile pair behind.
      if (e is FirebaseFunctionsException) {
        throw AuthFailure(e.message ?? 'Failed to create staff account');
      }
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> createStaffInvitation(String uid) async {
    try {
      final callable = functions.httpsCallable('createStaffInvitation');
      await callable.call<Map<String, dynamic>>({'uid': uid});
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        throw AuthFailure(e.message ?? 'Failed to send invitation');
      }
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> cancelStaffInvitation(String uid) async {
    try {
      final callable = functions.httpsCallable('cancelStaffInvitation');
      await callable.call<Map<String, dynamic>>({'uid': uid});
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        throw AuthFailure(e.message ?? 'Failed to cancel invitation');
      }
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> completePasswordReset(String newPassword) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthFailure('You are not signed in.');
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to update password');
    }
    await firestore.collection('users').doc(user.uid).update({
      'mustChangePassword': false,
    });
  }

  @override
  Future<List<UserModel>> getStaffMembers(String schoolId) async {
    final snapshot = await firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('role', isNotEqualTo: 'parent')
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<void> toggleStaffActiveStatus(
    String userId,
    bool isActive, {
    String? reason,
  }) async {
    final userReference = firestore.collection('users').doc(userId);
    final snapshot = await userReference.get();
    if (!snapshot.exists) throw StateError('Staff member not found.');
    final user = UserModel.fromJson({...snapshot.data()!, 'id': userId});
    final batch = firestore.batch();
    batch.update(userReference, {
      'isActive': isActive,
      'deactivationReason': reason,
    });
    batch.set(firestore.collection('school_contacts').doc(userId), {
      ..._schoolContactData(user),
      'isActive': isActive,
    }, SetOptions(merge: true));
    await batch.commit();

    // Mirror the disabled state onto the actual Firebase Auth account so a
    // deactivated staff member's credentials stop working outright, not just
    // this app's own profile-fetch gate. Best-effort: the Firestore flag is
    // the source of truth and already blocks this app's own login path, so a
    // sync failure here shouldn't roll back the deactivation itself.
    try {
      final callable = functions.httpsCallable('setStaffAuthDisabled');
      await callable.call({'userId': userId, 'disabled': !isActive});
    } catch (_) {
      // Swallowed: Firestore-side deactivation already succeeded and is
      // enforced by this app's own login checks.
    }
  }

  @override
  Future<void> updateStaffMember(UserModel user) async {
    final batch = firestore.batch();
    batch.update(firestore.collection('users').doc(user.id), user.toJson());
    batch.set(
      firestore.collection('school_contacts').doc(user.id),
      _schoolContactData(user),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> deleteStaffMember(String userId) async {
    // Deleting only the profile leaves a live Firebase Auth identity behind;
    // deleting Auth needs an audited Admin SDK workflow. The supported staff
    // lifecycle is deactivate/reactivate, so fail closed until a server-side
    // offboarding workflow exists.
    throw const AuthFailure(
      'Staff accounts cannot be deleted. Deactivate the account instead.',
    );
  }

  @override
  Future<String> adminResetStaffPassword(String userId) async {
    try {
      final callable = functions.httpsCallable('adminResetStaffPassword');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
      });
      return result.data['temporaryPassword'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to reset password');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthFailure('You are not signed in.');
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthFailure('Your current password is incorrect.');
        case 'requires-recent-login':
          throw const AuthFailure(
            'For your security, please log out and log back in before '
            'changing your password.',
          );
        case 'weak-password':
          throw const AuthFailure('Your new password is too weak.');
        default:
          throw AuthFailure(e.message ?? 'Failed to change password.');
      }
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    final current = firebaseAuth.currentUser;
    if (current == null) {
      throw const AuthFailure('You are not signed in.');
    }
    final batch = firestore.batch();
    batch.update(firestore.collection('users').doc(user.id), {
      'name': user.name,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoUrl,
    });
    if (user.role != UserRole.superAdmin) {
      batch.set(
        firestore.collection('school_contacts').doc(user.id),
        {..._schoolContactData(user)},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    await _syncProfileIntoConversations(user);
  }

  @override
  Future<void> updateMfaEnabled(bool enabled) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthFailure('You are not signed in.');
    }
    await firestore.collection('users').doc(user.uid).update({
      'mfaEnabled': enabled,
    });
  }

  @override
  Future<SupportModeLogin> enterSupportMode({
    required String schoolId,
    required String reason,
  }) async {
    final ownerId = firebaseAuth.currentUser?.uid;
    if (ownerId == null) {
      throw const AuthFailure('You are not signed in.');
    }
    try {
      final callable = functions.httpsCallable('enterSupportMode');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'reason': reason,
      });
      final data = result.data;
      final token = data['token'] as String;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        (data['expiresAt'] as num).toInt(),
      );

      // Owner's own Firebase Auth session is deliberately left untouched
      // server-side. Signing into the custom token here replaces it in this
      // client instance, which is the intended trade-off of the
      // single-window design: the owner must sign back in after exiting.
      final credential = await firebaseAuth.signInWithCustomToken(token);
      final user = await _getUser(credential.user!.uid);

      return SupportModeLogin(
        user: user,
        ownerId: ownerId,
        schoolName: data['schoolName'] as String? ?? '',
        expiresAt: expiresAt,
      );
    } on FirebaseFunctionsException catch (e) {
      throw AuthFailure(e.message ?? 'Could not enter support mode.');
    }
  }

  @override
  Future<void> exitSupportMode({
    required String ownerId,
    String? schoolId,
  }) async {
    try {
      final callable = functions.httpsCallable('exitSupportMode');
      final payload = <String, dynamic>{'ownerId': ownerId};
      if (schoolId != null) payload['schoolId'] = schoolId;
      await callable.call<Map<String, dynamic>>(payload);
    } on FirebaseFunctionsException catch (e) {
      throw AuthFailure(e.message ?? 'Could not exit support mode.');
    } finally {
      // Always end the impersonated session locally, even if the server
      // call fails, so the owner is never stuck signed in as the admin.
      await firebaseAuth.signOut();
    }
  }

  Map<String, dynamic> _schoolContactData(UserModel user) => {
    'name': user.name,
    'role': user.role.name,
    'roles': user.roles.map((role) => role.name).toList(),
    'schoolId': user.schoolId,
    'isActive': user.isActive,
    'phone': user.phoneNumber,
    'photoUrl': user.photoUrl,
  };

  /// Conversation participants are denormalized for a one-query inbox.
  /// Refresh the safe display fields when a person changes their profile.
  Future<void> _syncProfileIntoConversations(UserModel user) async {
    final snapshot = await firestore
        .collection('conversations')
        .where('participantIds', arrayContains: user.id)
        .get();

    for (final doc in snapshot.docs) {
      final participants = (doc.data()['participants'] as List? ?? const [])
          .map<Map<String, dynamic>>(
            (value) => Map<String, dynamic>.from(value as Map),
          )
          .map((participant) {
            if (participant['id'] != user.id) return participant;
            return {
              ...participant,
              'name': user.name,
              'role': user.role.name,
              'avatarUrl': user.photoUrl,
            };
          })
          .toList();
      await doc.reference.update({'participants': participants});
    }
  }
}
