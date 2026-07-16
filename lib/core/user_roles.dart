import 'package:flutter/foundation.dart';

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
  transportCoordinator,
  guidanceDiscipline,
  storeInventory,
  examsOfficer,
  gatekeeper,
  securityHead,
  gamesMaster,
  cateringManager,
  religiousLeader,
  receptionist,
}

class UserRoleDisplay {
  static String name(UserRole role) {
    switch (role) {
      case UserRole.parent: return 'Parent';
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
      case UserRole.boardingMatron: return 'Matron / Patron';
      case UserRole.transportCoordinator: return 'Transport';
      case UserRole.guidanceDiscipline: return 'Guidance & Discipline';
      case UserRole.storeInventory: return 'Store Inventory';
      case UserRole.examsOfficer: return 'Exams Officer';
      case UserRole.gatekeeper: return 'Gatekeeper';
      case UserRole.securityHead: return 'Head of Security';
      case UserRole.gamesMaster: return 'Games Master';
      case UserRole.cateringManager: return 'Catering Manager';
      case UserRole.religiousLeader: return 'Religious Leader';
      case UserRole.receptionist: return 'Receptionist';
    }
  }

  /// Roles allowed to reach the /staff/admin screen and invite new staff -
  /// mirrors the routing in StaffCredentialsScreen and the Cloud Function's
  /// own server-side check.
  static const List<UserRole> adminRoles = [
    UserRole.director,
    UserRole.headTeacher,
    UserRole.schoolAdmin,
  ];
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

  static List<String> forRole(UserRole role) {
    if (role == UserRole.parent) return const ['Parents'];
    final groups = <String>['All Staff'];
    if (teacherRoles.contains(role)) groups.add('Teachers Only');
    if (adminRoles.contains(role)) groups.add('Bursars & Admin');
    return groups;
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
        return '/staff/gatekeeper';
      case UserRole.schoolAdmin:
      case UserRole.director:
      case UserRole.headTeacher:
      case UserRole.deputyHead:
        return '/staff/admin';
      case UserRole.deanOfStudies:
      case UserRole.examsOfficer:
        return '/staff/dean';
      case UserRole.boardingMatron:
        return '/staff/matron';
      case UserRole.transportCoordinator:
        return '/staff/transport';
      case UserRole.guidanceDiscipline:
        return '/staff/discipline';
      case UserRole.cateringManager:
        return '/staff/catering';
      case UserRole.gamesMaster:
        return '/staff/games';
      case UserRole.securityHead:
        return '/staff/security';
      case UserRole.religiousLeader:
        return '/staff/religious-leader';
      case UserRole.receptionist:
        return '/staff/receptionist';
      case UserRole.storeInventory:
        return '/staff/inventory';
      default:
        return '/staff/dashboard';
    }
  }
}
