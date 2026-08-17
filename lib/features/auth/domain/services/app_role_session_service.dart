import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

/// Tracks which top-level [UserRole] a multi-role staff member is currently
/// acting as, independent of authentication identity. This is a UI
/// preference, not a security boundary - Firestore rules and Cloud
/// Function checks are what actually gate data access per role; this
/// service only decides which dashboard/AppBar label the session shows.
///
/// Mirrors ActiveResponsibilityService's shape (resolve/switchTo/
/// revalidate/clear), which does the equivalent job one level down -
/// scoped to a single teacher responsibility (class/subject) rather than
/// the top-level UserRole. The two are deliberately kept separate.
abstract class AppRoleSessionService {
  UserRole? get current;

  Stream<UserRole?> get changes;

  /// Picks the active role for [user]: the persisted last-active role if
  /// still present in user.roles, otherwise user.roles.first. Always
  /// succeeds - a single-role user trivially resolves to it.
  Future<UserRole> resolve(UserEntity user);

  /// Switches to [role] after confirming it is still held by [user].
  /// Returns null (no-op) if [role] is not in user.roles.
  Future<UserRole?> switchTo({
    required UserEntity user,
    required UserRole role,
  });

  /// Re-validates the active role against a freshly-loaded [user] - if the
  /// active role was revoked, falls back to resolve() and returns the new
  /// value.
  Future<UserRole> revalidate(UserEntity user);

  Future<void> clear();
}
