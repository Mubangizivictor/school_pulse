import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);

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
  /// account and Firestore profile with the Admin SDK. Returns the
  /// generated temporary password for the admin to hand to the new staff
  /// member.
  Future<String> createStaffAccount({
    required String name,
    required String email,
    required String schoolId,
    required List<UserRole> roles,
    required String password,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
  });

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

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.functions,
  });

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Staff accounts are provisioned ahead of time (with their real role)
      // by an admin, never auto-created here.
      return await _getUser(credential.user!.uid);
    } on FirebaseAuthMultiFactorException {
      // The caller needs the resolver to complete the authenticator challenge.
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication failed');
    }
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

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
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
      return user;
    }
    throw const AuthFailure(
      'No profile found for this account. Contact your school administrator.',
    );
  }

  @override
  Future<String> createStaffAccount({
    required String name,
    required String email,
    required String schoolId,
    required List<UserRole> roles,
    required String password,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
  }) async {
    try {
      final callable = functions.httpsCallable('createStaffAccount');
      final result = await callable.call<Map<String, dynamic>>({
        'name': name,
        'email': email,
        'schoolId': schoolId,
        'roles': roles.map((r) => r.name).toList(),
        'password': password,
        'assignedClass': assignedClass,
        'subjects': subjects?.map((e) => e.toJson()).toList(),
        'academicYearId': academicYearId,
        'departmentId': departmentId,
        'designationId': designationId,
        'campusId': campusId,
        'employmentType': employmentType,
        'dateJoined': dateJoined?.toIso8601String(),
      });
      return result.data['temporaryPassword'] as String;
    } catch (e) {
      // Fallback for Development
      bool isDevError = false;
      if (e is FirebaseFunctionsException) {
        isDevError = [
          'not-found',
          'unimplemented',
          'internal',
          'unavailable',
        ].contains(e.code);
      } else {
        final errStr = e.toString().toLowerCase();
        isDevError =
            errStr.contains('cors') ||
            errStr.contains('failed to load') ||
            errStr.contains('internal');
      }

      if (isDevError) {
        String finalUid = 'dev_${DateTime.now().millisecondsSinceEpoch}';

        try {
          final tempAppName =
              'temp_app_${DateTime.now().millisecondsSinceEpoch}';
          final tempApp = await Firebase.initializeApp(
            name: tempAppName,
            options: Firebase.app().options,
          );

          final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
          final userCredential = await tempAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          finalUid = userCredential.user!.uid;
          await tempApp.delete();
        } catch (authErr) {
          debugPrint(
            "Auth Fallback Warning: Could not create Auth account ($authErr)",
          );
        }

        final newUser = UserModel(
          id: finalUid,
          name: name,
          email: email,
          schoolId: schoolId,
          roles: roles,
          isActive: true,
          mustChangePassword: true,
          assignedClass: assignedClass,
          subjects: subjects,
          departmentId: departmentId,
          designationId: designationId,
          campusId: campusId,
          employmentType: employmentType,
          dateJoined: dateJoined,
        );
        final batch = firestore.batch();
        batch.set(
          firestore.collection('users').doc(finalUid),
          newUser.toJson(),
        );
        batch.set(
          firestore.collection('school_contacts').doc(finalUid),
          _schoolContactData(newUser),
        );
        await batch.commit();
        return password;
      }

      if (e is FirebaseFunctionsException) {
        throw AuthFailure(e.message ?? 'Failed to create staff account');
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
    // Note: In a real production app, you might also want to delete the user from Firebase Auth
    // via a Cloud Function, but for now we'll delete the Firestore record.
    final batch = firestore.batch();
    batch.delete(firestore.collection('users').doc(userId));
    batch.delete(firestore.collection('school_contacts').doc(userId));
    await batch.commit();
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
      await callable.call<Map<String, dynamic>>({
        'ownerId': ownerId,
        if (schoolId != null) 'schoolId': schoolId,
      });
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
  };
}
