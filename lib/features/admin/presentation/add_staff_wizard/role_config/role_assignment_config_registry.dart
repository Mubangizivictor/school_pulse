import 'package:school_pulse/core/user_roles.dart';

/// The kind of scope field a role's configuration step needs. One generic
/// RoleConfigForm renders whichever fields a role's spec lists - adding a
/// new role's config is adding a spec entry here, not a new screen.
enum RoleFieldKind {
  academicYearAndClass, // Class Teacher: academic year + class + stream
  subjectClassList, // Subject Teacher: one or more subject+class pairs
  department,
  dormitoryWing,
  route,
  facility,
  approvalScope,
}

class RoleAssignmentConfigSpec {
  final UserRole role;
  final List<RoleFieldKind> fields;

  const RoleAssignmentConfigSpec({required this.role, required this.fields});

  bool get isEmpty => fields.isEmpty;
}

/// UserRole -> RoleAssignmentConfigSpec. Kept comment-linked to
/// functions/index.js's ROLE_TO_RESPONSIBILITY_TYPE to avoid drift, same
/// convention as UserRoleDisplay.adminRoles.
class RoleAssignmentConfigRegistry {
  RoleAssignmentConfigRegistry._();

  static RoleAssignmentConfigSpec forRole(UserRole role) {
    switch (role) {
      case UserRole.classTeacher:
        return const RoleAssignmentConfigSpec(
          role: UserRole.classTeacher,
          fields: [RoleFieldKind.academicYearAndClass],
        );
      case UserRole.subjectTeacher:
        return const RoleAssignmentConfigSpec(
          role: UserRole.subjectTeacher,
          fields: [RoleFieldKind.subjectClassList],
        );
      case UserRole.deanOfStudies:
      case UserRole.guidanceDiscipline:
        return RoleAssignmentConfigSpec(
          role: role,
          fields: const [RoleFieldKind.approvalScope],
        );
      case UserRole.bursar:
      case UserRole.hrOfficer:
        return RoleAssignmentConfigSpec(
          role: role,
          fields: const [RoleFieldKind.department],
        );
      case UserRole.librarian:
      case UserRole.storeInventory:
      case UserRole.cateringManager:
        return RoleAssignmentConfigSpec(
          role: role,
          fields: const [RoleFieldKind.facility],
        );
      case UserRole.nurse:
        return const RoleAssignmentConfigSpec(
          role: UserRole.nurse,
          fields: [RoleFieldKind.facility],
        );
      case UserRole.boardingMatron:
      case UserRole.boardingPatron:
        return RoleAssignmentConfigSpec(
          role: role,
          fields: const [RoleFieldKind.dormitoryWing],
        );
      case UserRole.transportCoordinator:
        return const RoleAssignmentConfigSpec(
          role: UserRole.transportCoordinator,
          fields: [RoleFieldKind.route],
        );
      case UserRole.gatekeeper:
      case UserRole.securityHead:
        return RoleAssignmentConfigSpec(
          role: role,
          fields: const [RoleFieldKind.facility],
        );
      case UserRole.gamesMaster:
      case UserRole.religiousLeader:
      case UserRole.receptionist:
        return RoleAssignmentConfigSpec(role: role, fields: const []);
      case UserRole.director:
      case UserRole.headTeacher:
      case UserRole.deputyHead:
      case UserRole.schoolAdmin:
      case UserRole.superAdmin:
      case UserRole.parent:
      case UserRole.student:
        return RoleAssignmentConfigSpec(role: role, fields: const []);
    }
  }
}
