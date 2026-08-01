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

  // Notification send/manage permissions. `notification.view` and
  // `notification.acknowledge` are NOT listed here - every authenticated user
  // may read and acknowledge their own notifications, so gating them by role
  // would lock parents and students out of their own notification centre.
  // What follows is only the authority to *originate* and *administer*
  // notifications, which is genuinely role-scoped.

  /// Staff who may send targeted notifications within their own remit
  /// (a class teacher messaging their class's parents, for example).
  static const Set<String> _notificationSenderPermissions = {
    Permission.notificationSend,
    Permission.notificationSendToParent,
    Permission.notificationSendToStudent,
    Permission.notificationUseImages,
    Permission.notificationUseAttachments,
    Permission.notificationArchive,
  };

  /// Office roles that additionally broadcast school-wide, schedule ahead and
  /// read delivery reports for what they sent.
  static const Set<String> _notificationOfficePermissions = {
    ..._notificationSenderPermissions,
    Permission.notificationSendToStaff,
    Permission.notificationBroadcast,
    Permission.notificationSchedule,
    Permission.notificationCancel,
    Permission.notificationViewDeliveryReports,
  };

  /// School leadership: full notification administration including emergency
  /// alerts, templates and school-level notification settings.
  static const Set<String> _notificationAdminPermissions = {
    ..._notificationOfficePermissions,
    Permission.notificationSendEmergency,
    Permission.notificationManageTemplates,
    Permission.notificationManageSettings,
    Permission.notificationDelete,
    Permission.notificationRunDeliveryTest,
  };

  static const Map<UserRole, Set<String>> defaults = {
    UserRole.gatekeeper: _gatekeeperPermissions,
    UserRole.receptionist: {
      ..._gatekeeperPermissions,
      ..._admissionsPermissions,
      ..._notificationSenderPermissions,
    },
    UserRole.securityHead: {
      ..._securityLeadPermissions,
      ..._notificationOfficePermissions,
      // Security leads raise emergency alerts (lockdown, intruder, missing
      // student) without needing a head teacher to be reachable first.
      Permission.notificationSendEmergency,
    },
    UserRole.schoolAdmin: {
      ..._securityLeadPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
    },
    UserRole.director: {
      ..._securityLeadPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
    },
    UserRole.headTeacher: {
      ..._securityLeadPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
    },
    UserRole.deputyHead: {
      ..._securityLeadPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
    },
    UserRole.deanOfStudies: {
      ..._admissionsPermissions,
      ..._notificationOfficePermissions,
    },
    UserRole.hrOfficer: {
      ..._admissionsPermissions,
      ..._notificationOfficePermissions,
    },
    UserRole.nurse: {..._nursePermissions, ..._notificationSenderPermissions},
    UserRole.bursar: {..._bursarPermissions, ..._notificationOfficePermissions},
    UserRole.librarian: {..._librarianPermissions, ..._notificationSenderPermissions},
    UserRole.transportCoordinator: {
      ..._transportCoordinatorPermissions,
      ..._notificationOfficePermissions,
    },
    UserRole.cateringManager: {
      ..._cateringManagerPermissions,
      ..._notificationSenderPermissions,
    },
    UserRole.classTeacher: _notificationSenderPermissions,
    UserRole.subjectTeacher: _notificationSenderPermissions,
    UserRole.boardingMatron: _notificationSenderPermissions,
    UserRole.boardingPatron: _notificationSenderPermissions,
    UserRole.guidanceDiscipline: _notificationSenderPermissions,
    UserRole.gamesMaster: _notificationSenderPermissions,
    UserRole.religiousLeader: _notificationSenderPermissions,
  };

  static Set<String> permissionsFor(List<UserRole> roles) {
    final result = <String>{};
    for (final role in roles) {
      result.addAll(defaults[role] ?? const {});
    }
    return result;
  }
}
