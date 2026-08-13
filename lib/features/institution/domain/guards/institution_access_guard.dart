import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';

/// Client-side defense-in-depth check for whether [user] may access
/// [context]'s institution-scoped routes/data. This mirrors, but does not
/// replace, the real enforcement in Firestore rules and Cloud Functions -
/// it exists so the router and blocs can fail fast and show a clear
/// access-denied state instead of a permission-denied exception mid-write.
bool canAccessInstitution(UserEntity user, InstitutionContext context) {
  if (user.role == UserRole.superAdmin) return true;
  if (context.isSuspended) return false;
  return user.schoolId == context.institutionId;
}

bool isInstitutionAdministrator(UserEntity user) {
  // Authorization is multi-role. The legacy `role` accessor is only the
  // first role for presentation compatibility and must not hide a valid
  // administrator responsibility that appears later in the assignment.
  return user.roles.any(UserRoleDisplay.adminRoles.contains);
}

bool isSaasOwner(UserEntity user) {
  return user.role == UserRole.superAdmin;
}
