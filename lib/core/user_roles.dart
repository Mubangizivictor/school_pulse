enum UserRole {
  parent,
  director,
  headTeacher,
  deputyHead,
  deanOfStudies,
  schoolAdmin,
  bursar,
  classTeacher,
  subjectTeacher,
  librarian,
  nurse,
  boardingMatron,
  boardingPatron,
  transportCoordinator,
  guidanceDiscipline,
  storeInventory,
  gatekeeper,
  securityHead,
  gamesMaster,
  cateringManager,
  religiousLeader,
  receptionist,
  hrOfficer,
  superAdmin,
  student,
}

class UserRoleDisplay {
  static String name(UserRole role) {
    switch (role) {
      case UserRole.parent: return 'Parent';
      case UserRole.student: return 'Student';
      case UserRole.director: return 'Director';
      case UserRole.headTeacher: return 'Head Teacher';
      case UserRole.deputyHead: return 'Deputy Head';
      case UserRole.deanOfStudies: return 'Dean of Studies';
      case UserRole.schoolAdmin: return 'School Admin';
      case UserRole.bursar: return 'Bursar';
      case UserRole.classTeacher: return 'Class Teacher';
      case UserRole.subjectTeacher: return 'Subject Teacher';
      case UserRole.librarian: return 'Librarian';
      case UserRole.nurse: return 'Nurse';
      case UserRole.boardingMatron: return 'Matron (Girls)';
      case UserRole.boardingPatron: return 'Patron (Boys)';
      case UserRole.transportCoordinator: return 'Transport';
      case UserRole.guidanceDiscipline: return 'Guidance & Discipline';
      case UserRole.storeInventory: return 'Store Inventory';
      case UserRole.gatekeeper: return 'Gatekeeper';
      case UserRole.securityHead: return 'Head of Security';
      case UserRole.gamesMaster: return 'Games Master';
      case UserRole.cateringManager: return 'Catering Manager';
      case UserRole.religiousLeader: return 'Religious Leader';
      case UserRole.receptionist: return 'Receptionist';
      case UserRole.hrOfficer: return 'HR Officer';
      case UserRole.superAdmin: return 'Platform Owner';
    }
  }

  /// Roles allowed to invite new staff - mirrors the Cloud Function's own
  /// server-side ADMIN_ROLES check. Keep this in sync with functions/index.js;
  /// a role here that the Cloud Function doesn't also allow will see an
  /// "invite staff" UI that fails server-side.
  static const List<UserRole> adminRoles = [
    UserRole.director,
    UserRole.headTeacher,
    UserRole.schoolAdmin,
  ];

  /// Roles whose home dashboard is the /staff/admin console (see
  /// UserRoleRouting.dashboardPath) - used to pick the admin-shaped shell
  /// nav/messaging instead of the per-role staff shell. Distinct from
  /// [adminRoles]: Deputy Head shares the admin console UI but isn't
  /// permitted to invite staff server-side.
  static const List<UserRole> adminConsoleRoles = [
    UserRole.director,
    UserRole.headTeacher,
    UserRole.schoolAdmin,
    UserRole.deputyHead,
  ];

  /// The dormitory wing a Matron (girls) or Patron (boys) is scoped to, so
  /// neither sees the other's dormitories/boarders. Null for every other
  /// role (unscoped - e.g. an admin previewing the same screen).
  static String? matronGenderScope(UserRole role) {
    switch (role) {
      case UserRole.boardingMatron: return 'Female';
      case UserRole.boardingPatron: return 'Male';
      default: return null;
    }
  }
}

/// Maps a staff role to the broadcast target-group labels used by
/// BroadcastSmsScreen, so the notification center can find broadcasts
/// addressed to this user's group(s) via a `targets` array-contains query.
class NotificationGroups {
  static const teacherRoles = [UserRole.classTeacher, UserRole.subjectTeacher];
  static const adminRoles = [
    UserRole.schoolAdmin,
    UserRole.director,
    UserRole.headTeacher,
    UserRole.deputyHead,
    UserRole.bursar,
  ];

  static const securityRoles = [UserRole.securityHead, UserRole.gatekeeper];

  static List<String> forRole(UserRole role) {
    if (role == UserRole.parent) return const ['Parents'];
    final groups = <String>['All Staff'];
    if (teacherRoles.contains(role)) groups.add('Teachers Only');
    if (adminRoles.contains(role)) groups.add('Bursars & Admin');
    if (securityRoles.contains(role)) groups.add('Security');
    
    if (role == UserRole.boardingMatron) groups.add('Matrons (Girls)');
    if (role == UserRole.boardingPatron) groups.add('Patrons (Boys)');

    return groups;
  }

  /// Unions the broadcast groups for every role a (multi-role) staff member
  /// holds, so a Class Teacher who is also Bursar gets both sets of
  /// broadcasts.
  static List<String> forRoles(List<UserRole> roles) {
    final groups = <String>{};
    for (final role in roles) {
      groups.addAll(forRole(role));
    }
    return groups.toList();
  }
}

class UserRoleRouting {
  /// The dashboard route a signed-in staff member should land on. Shared by
  /// StaffCredentialsScreen (post-login) and ForceSetPasswordScreen
  /// (post first-time password change).
  static String dashboardPath(UserRole role) {
    switch (role) {
      case UserRole.bursar:
        return '/staff/bursar';
      case UserRole.nurse:
        return '/staff/nurse';
      case UserRole.librarian:
        return '/staff/librarian';
      case UserRole.gatekeeper:
      case UserRole.securityHead:
      case UserRole.receptionist:
        return '/staff/security';
      case UserRole.storeInventory:
        return '/staff/inventory';
      case UserRole.hrOfficer:
        return '/staff/hr';
      case UserRole.superAdmin:
        return '/super-admin';
      case UserRole.parent:
        return '/parent/home';
      case UserRole.director:
        return '/staff/director';
      case UserRole.headTeacher:
      case UserRole.schoolAdmin:
      case UserRole.deputyHead:
        return '/staff/admin';
      case UserRole.boardingPatron:
        return '/staff/patron';
      default:
        return '/staff/dashboard';
    }
  }
}
