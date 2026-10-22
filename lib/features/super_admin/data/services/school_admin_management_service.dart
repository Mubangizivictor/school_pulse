import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

enum SchoolAdminAction { setPrimary, disable, enable, remove }

extension on SchoolAdminAction {
  String get wire => switch (this) {
    SchoolAdminAction.setPrimary => 'setPrimary',
    SchoolAdminAction.disable => 'disable',
    SchoolAdminAction.enable => 'enable',
    SchoolAdminAction.remove => 'remove',
  };
}

/// Owner-console boundary around School Admin lifecycle actions. Invite
/// writes to `school_admin_invitations` directly (Super Admin already has
/// create permission there per firestore.rules; the existing
/// `provisionSchoolAdmin` trigger in functions/index.js is the real
/// account-creation path - this service never creates an Auth account or a
/// users/ doc itself). setPrimary/disable/enable/remove all go through the
/// owner-only `manageSchoolAdmin` callable (public_functions/
/// portal_domains.js), since institution_memberships and the role-bearing
/// fields on users/{uid} deny all client writes.
class SchoolAdminManagementService {
  SchoolAdminManagementService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Generates the same shape of one-time temporary password the original
  /// createSchool() client flow used to hand provisionSchoolAdmin, before
  /// it scrubs the plaintext value once the account is created.
  String _generateTempPassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#%';
    final random = Random.secure();
    return List.generate(14, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> inviteAdmin({
    required String schoolId,
    required String tenantId,
    required String email,
  }) async {
    await _firestore.collection('school_admin_invitations').add({
      'email': email.trim(),
      'schoolId': schoolId,
      'tenantId': tenantId,
      'tempPassword': _generateTempPassword(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> manage({
    required String schoolId,
    required String targetUid,
    required SchoolAdminAction action,
    String? reason,
    String? replacementUid,
  }) async {
    await _functions.httpsCallable('manageSchoolAdmin').call({
      'schoolId': schoolId,
      'targetUid': targetUid,
      'action': action.wire,
      'reason': ?reason,
      'replacementUid': ?replacementUid,
    });
  }
}
