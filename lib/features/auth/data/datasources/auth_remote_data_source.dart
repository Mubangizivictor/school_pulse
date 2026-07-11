import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);

  /// Kicks off Firebase Phone Auth verification and resolves with the
  /// verificationId once the SMS code has been sent.
  Future<String> loginWithPhone(String phoneNumber);

  /// Confirms the SMS code. If this is the first time this phone number has
  /// signed in, a new parent profile is created (optionally pre-linked to
  /// [linkedStudentIds]) rather than failing.
  Future<UserModel> verifyOtp(String verificationId, String smsCode, {List<String>? linkedStudentIds});
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
    required UserRole role,
    required String password,
  });

  /// Sets a new password for the currently signed-in user and clears their
  /// mustChangePassword flag. Used the first time a staff member logs in
  /// with an admin-issued temporary password.
  Future<void> completePasswordReset(String newPassword);

  /// All non-parent user profiles, for the admin Staff tab.
  Future<List<UserModel>> getStaffMembers();

  Future<void> toggleStaffActiveStatus(String userId, bool isActive);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore, required this.functions});

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      // Staff accounts are provisioned ahead of time (with their real role)
      // by an admin, never auto-created here.
      return await _getUser(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication failed');
    }
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    final completer = Completer<String>();
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-verification (Android instant retrieval / already-verified
        // device). We still drive confirmation through the manual OTP step,
        // so nothing to do here beyond letting codeSent/timeout resolve.
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthFailure(e.message ?? 'Phone verification failed'));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  @override
  Future<UserModel> verifyOtp(String verificationId, String smsCode, {List<String>? linkedStudentIds}) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      return await _getOrCreateParentUser(
        userCredential.user!.uid,
        phoneNumber: userCredential.user!.phoneNumber,
        linkedStudentIds: linkedStudentIds,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'OTP Verification failed');
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
        throw const AuthFailure('This account has been disabled. Please contact your school administrator.');
      }
      return user;
    }
    throw const AuthFailure('No profile found for this account. Contact your school administrator.');
  }

  /// Reads users/{uid}. Phone auth is self-service for parents, so if this
  /// is their first sign-in a new parent profile is created for them.
  /// [linkedStudentIds] (from a family access code, which can cover
  /// multiple siblings) are merged into whatever the parent already has.
  Future<UserModel> _getOrCreateParentUser(
    String uid, {
    String? phoneNumber,
    List<String>? linkedStudentIds,
  }) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final existing = UserModel.fromJson({...doc.data()!, 'id': doc.id});
      final newIds = (linkedStudentIds ?? const []).where((id) => !existing.studentIds.contains(id));
      if (newIds.isNotEmpty) {
        final updated = [...existing.studentIds, ...newIds];
        await firestore.collection('users').doc(uid).update({'studentIds': updated});
        return UserModel(
          id: existing.id,
          name: existing.name,
          email: existing.email,
          phoneNumber: existing.phoneNumber,
          role: existing.role,
          photoUrl: existing.photoUrl,
          studentIds: updated,
          mustChangePassword: existing.mustChangePassword,
        );
      }
      return existing;
    }

    final newUser = UserModel(
      id: uid,
      name: '',
      email: '',
      phoneNumber: phoneNumber,
      role: UserRole.parent,
      studentIds: linkedStudentIds ?? const [],
    );
    await firestore.collection('users').doc(uid).set(newUser.toJson());
    return newUser;
  }

  @override
  Future<String> createStaffAccount({
    required String name,
    required String email,
    required UserRole role,
    required String password,
  }) async {
    try {
      final callable = functions.httpsCallable('createStaffAccount');
      final result = await callable.call<Map<String, dynamic>>({
        'name': name,
        'email': email,
        'role': role.name,
        'password': password,
      });
      return result.data['temporaryPassword'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to create staff account');
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
    await firestore.collection('users').doc(user.uid).update({'mustChangePassword': false});
  }

  @override
  Future<List<UserModel>> getStaffMembers() async {
    final snapshot = await firestore.collection('users').where('role', isNotEqualTo: 'parent').get();
    return snapshot.docs.map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  @override
  Future<void> toggleStaffActiveStatus(String userId, bool isActive) async {
    await firestore.collection('users').doc(userId).update({'isActive': isActive});
  }
}
