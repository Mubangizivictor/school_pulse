import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Default role -> permission-set seed used when no cached
/// `OperatorPermissionSnapshotIsar` exists yet (first run on a fresh
/// device) or as the source of truth when a snapshot is refreshed.
///
/// Phase 1 only seeds the security/gate permissions, deliberately
/// mirroring the permitted-role set already used for the `/staff/security`
/// route guard in `lib/app/router.dart` - no role that has dashboard
/// access today loses it under the new permission layer.
class RolePermissionDefaults {
  const RolePermissionDefaults._();

  static const Set<String> _gatekeeperPermissions = {
    Permission.securityIdentityVerify,
    Permission.securityEntryRecord,
    Permission.securityExitRecord,
  };

  static const Set<String> _securityLeadPermissions = {
    ..._gatekeeperPermissions,
    Permission.securityOverride,
    Permission.verificationOverride,
    Permission.verificationAuditRead,
    Permission.verificationDeviceManage,
  };

  // Enrollment Permission (spec term) - never granted by job title alone,
  // only through this role-default seed (or a future custom-role grant).
  // Mirrors the doc's "Enrollment may only be performed by users with
  // Enrollment Permission" requirement: School Admin, Headteacher, Deputy
  // Head, Dean, Director, Receptionist, HR - the subset of that list that
  // exists as a UserRole today (no dedicated Registrar/Admissions Officer
  // role exists in this codebase yet).
  static const Set<String> _admissionsPermissions = {
    Permission.admissionApplicationCreate,
    Permission.admissionApplicationReview,
    Permission.admissionEnroll,
  };

  // Information-projection permissions for the roles whose whole job is
  // "look up one student's slice of data" - Nurse/Bursar/Librarian/
  // Transport Coordinator/Catering Manager. Each set is deliberately
  // narrow to its own domain; none of these roles gain any other role's
  // permissions by being added here.
  static const Set<String> _nursePermissions = {
    Permission.healthStudentVerify,
    Permission.healthStudentBasicRead,
    Permission.healthStudentClinicalRead,
    Permission.healthStudentVisitCreate,
    Permission.healthStudentEmergencyRead,
  };

  static const Set<String> _bursarPermissions = {
    Permission.financeStudentVerify,
    Permission.financeStudentBalanceRead,
  };

  static const Set<String> _librarianPermissions = {
    Permission.libraryMemberVerify,
    Permission.libraryBorrow,
    Permission.libraryReturn,
  };

  static const Set<String> _transportCoordinatorPermissions = {
    Permission.transportBoardingVerify,
    Permission.transportBoardingRecord,
    Permission.transportDropoffRecord,
  };

  static const Set<String> _cateringManagerPermissions = {
    Permission.mealsVerify,
    Permission.mealsServe,
  };

  static const Map<UserRole, Set<String>> defaults = {
    UserRole.gatekeeper: _gatekeeperPermissions,
    UserRole.receptionist: {..._gatekeeperPermissions, ..._admissionsPermissions},
    UserRole.securityHead: _securityLeadPermissions,
    UserRole.schoolAdmin: {..._securityLeadPermissions, ..._admissionsPermissions},
    UserRole.director: {..._securityLeadPermissions, ..._admissionsPermissions},
    UserRole.headTeacher: {..._securityLeadPermissions, ..._admissionsPermissions},
    UserRole.deputyHead: {..._securityLeadPermissions, ..._admissionsPermissions},
    UserRole.deanOfStudies: _admissionsPermissions,
    UserRole.hrOfficer: _admissionsPermissions,
    UserRole.nurse: _nursePermissions,
    UserRole.bursar: _bursarPermissions,
    UserRole.librarian: _librarianPermissions,
    UserRole.transportCoordinator: _transportCoordinatorPermissions,
    UserRole.cateringManager: _cateringManagerPermissions,
  };

  static Set<String> permissionsFor(List<UserRole> roles) {
    final result = <String>{};
    for (final role in roles) {
      result.addAll(defaults[role] ?? const {});
    }
    return result;
  }
}
