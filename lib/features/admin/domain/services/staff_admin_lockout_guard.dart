import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:school_pulse/core/user_roles.dart';

/// Guards against a school being left with zero holders of the roles that
/// let someone manage staff/settings from the admin console (Director, Head
/// Teacher, School Admin - see [UserRoleConfig.adminRoles]). Used before
/// deactivating a staff account or removing account roles, so one admin
/// can't lock the whole school out by disabling or de-roling the only other
/// admin. schoolAdmin is provisioned only at registration and never
/// reassignable in-app (see [_AccountRolesEditorSheet]'s own note), but it
/// still counts as an active admin holder for this check, and can still be
/// deactivated - so it participates in the count on both sides.
class StaffAdminLockoutGuard {
  const StaffAdminLockoutGuard._();

  /// True if [staffId] holding at least one of [candidateRoles] (their
  /// current admin-capable roles, e.g. before removal) is the ONLY active
  /// admin-capable staff member left in [schoolId]. Pass the roles the
  /// action would remove/deactivate; if none of them are admin roles this
  /// always returns false without a query.
  static Future<bool> isLastAdmin({
    required String schoolId,
    required String staffId,
    required List<UserRole> candidateRoles,
    FirebaseFirestore? firestore,
  }) async {
    final adminRolesBeingLost = candidateRoles
        .where(UserRoleDisplay.adminRoles.contains)
        .toSet();
    if (adminRolesBeingLost.isEmpty) return false;

    final db = firestore ?? FirebaseFirestore.instance;
    final snapshot = await db
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .get();

    final otherActiveAdmins = snapshot.docs.where((doc) {
      if (doc.id == staffId) return false;
      final roles = (doc.data()['roles'] as List<dynamic>? ?? const [])
          .whereType<String>();
      return roles.any(
        (r) => UserRoleDisplay.adminRoles.any((role) => role.name == r),
      );
    });
    return otherActiveAdmins.isEmpty;
  }
}
