import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/app_role_session_service.dart';

/// Key holding the last top-level role a multi-role staff member picked.
/// Namespaced per user, same convention as
/// StaffAssignmentRepositoryImpl's _selectedAssignmentKey, so a shared
/// device does not restore one staff member's active role into another's
/// session.
String _activeRoleKey(String userId) => 'app_role_session.active_role.$userId';

class AppRoleSessionServiceImpl implements AppRoleSessionService {
  AppRoleSessionServiceImpl({required this.preferences});

  final SharedPreferences preferences;

  UserRole? _current;
  final _controller = StreamController<UserRole?>.broadcast();

  @override
  UserRole? get current => _current;

  @override
  Stream<UserRole?> get changes => _controller.stream;

  @override
  Future<UserRole> resolve(UserEntity user) async {
    final persisted = preferences.getString(_activeRoleKey(user.id));
    UserRole? restored;
    if (persisted != null) {
      try {
        restored = UserRole.values.byName(persisted);
      } catch (_) {
        restored = null;
      }
    }
    final valid = restored != null && user.roles.contains(restored);
    final resolved = valid ? restored : user.roles.first;
    // A genuinely-restored choice is always emitted. A bare roles.first
    // fallback (no persisted choice yet, or it was revoked) is only
    // withheld from `current` when there is more than one role to choose
    // from - a multi-role caller (SchoolSplashScreen) uses "current is
    // still null after resolve" to tell "nothing to restore, show the
    // picker" apart from "restored, skip straight to the dashboard". A
    // single-role user has no picker to show, so withholding it here would
    // leave `current` permanently null and every role-gated UI (shell nav,
    // admin console routes) would fail its role check forever.
    if (valid || user.roles.length == 1) _emit(resolved);
    return resolved;
  }

  @override
  Future<UserRole?> switchTo({
    required UserEntity user,
    required UserRole role,
  }) async {
    if (!user.roles.contains(role)) return null;
    await preferences.setString(_activeRoleKey(user.id), role.name);
    _emit(role);
    return role;
  }

  @override
  Future<UserRole> revalidate(UserEntity user) async {
    if (_current != null && user.roles.contains(_current)) {
      return _current!;
    }
    return resolve(user);
  }

  @override
  Future<void> clear() async {
    _current = null;
    _controller.add(null);
  }

  void _emit(UserRole role) {
    _current = role;
    _controller.add(role);
  }
}
