import 'package:school_pulse/core/user_roles.dart';

/// Every role a staff member can hold - excludes parent/student (not
/// staff), superAdmin (platform-level, never assignable here), and
/// schoolAdmin (provisioned only through SaaS school registration, never
/// reassignable in-app - see firestore.rules users/{uid} update comment
/// for the privilege-escalation reasoning). Shared by the Add Staff
/// wizard's role picker and the Staff Profile roles editor so both stay
/// in sync.
final List<UserRole> assignableStaffRoles = UserRole.values
    .where(
      (r) =>
          r != UserRole.parent &&
          r != UserRole.student &&
          r != UserRole.superAdmin &&
          r != UserRole.schoolAdmin,
    )
    .toList();

/// Groups roles into scannable sections instead of one flat list of 20+.
final Map<String, List<UserRole>> assignableStaffRoleGroups = {
  'Leadership': [
    UserRole.director,
    UserRole.headTeacher,
    UserRole.deputyHead,
    UserRole.deanOfStudies,
  ],
  'Academic': [
    UserRole.classTeacher,
    UserRole.subjectTeacher,
    UserRole.librarian,
    UserRole.guidanceDiscipline,
  ],
  'Operations & Admin': [
    UserRole.bursar,
    UserRole.hrOfficer,
    UserRole.admissions,
    UserRole.registrar,
    UserRole.receptionist,
    UserRole.storeInventory,
  ],
  'Campus & Welfare': [
    UserRole.nurse,
    UserRole.boardingMatron,
    UserRole.boardingPatron,
    UserRole.transportCoordinator,
    UserRole.gatekeeper,
    UserRole.securityHead,
    UserRole.gamesMaster,
    UserRole.cateringManager,
    UserRole.religiousLeader,
  ],
};
