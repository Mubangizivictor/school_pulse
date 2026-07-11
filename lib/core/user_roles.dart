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
}

class PlatformAccess {
  static bool isAllowedOnCurrentPlatform(UserRole role) {
    if (kIsWeb) {
      // Parent is restricted to Mobile only
      if (role == UserRole.parent) return false;
      return true;
    } else {
      // Mobile Build: Everyone is allowed to use the mobile app
      return true;
    }
  }

  static String getBlockedMessage(UserRole role) {
    if (role == UserRole.parent) {
      return 'Parent access is only available on the mobile app. Please download the app to continue.';
    }
    return '${_roleDisplayName(role)} accounts are managed from the web app — please sign in at portal.schoolpulse.ug on a computer or tablet browser.';
  }

  static String _roleDisplayName(UserRole role) => UserRoleDisplay.name(role);
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
        return '/staff/admin';
      case UserRole.deanOfStudies:
        return '/staff/dean';
      case UserRole.religiousLeader:
        return '/staff/religious-leader';
      default:
        return '/staff/dashboard';
    }
  }
}
