import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/features/auth/data/services/app_role_session_service_impl.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

UserEntity _user({required List<UserRole> roles}) {
  return UserEntity(
    id: 'staff-1',
    name: 'Test Staff',
    email: 'staff@example.com',
    schoolId: 'school-1',
    roles: roles,
  );
}

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  group('AppRoleSessionServiceImpl', () {
    test(
      'resolve falls back to roles.first with no persisted selection, and does not mark it as current',
      () async {
        final service = AppRoleSessionServiceImpl(preferences: preferences);
        final user = _user(roles: [UserRole.bursar, UserRole.classTeacher]);

        final resolved = await service.resolve(user);

        expect(resolved, UserRole.bursar);
        // Falling back to roles.first is not the same as the user having
        // explicitly chosen a role - `current` stays null so callers can
        // distinguish "nothing to restore" from "restored a real choice".
        expect(service.current, isNull);
      },
    );

    test(
      'resolve marks a single-role user as current even with no persisted '
      'selection, since there is no picker to withhold it for',
      () async {
        final service = AppRoleSessionServiceImpl(preferences: preferences);
        final user = _user(roles: [UserRole.schoolAdmin]);

        final resolved = await service.resolve(user);

        expect(resolved, UserRole.schoolAdmin);
        expect(service.current, UserRole.schoolAdmin);
      },
    );

    test(
      'switchTo persists and restores the chosen role on relaunch',
      () async {
        final first = AppRoleSessionServiceImpl(preferences: preferences);
        final user = _user(roles: [UserRole.bursar, UserRole.classTeacher]);

        final switched = await first.switchTo(
          user: user,
          role: UserRole.classTeacher,
        );
        expect(switched, UserRole.classTeacher);
        expect(first.current, UserRole.classTeacher);

        // Simulate app relaunch: a fresh service instance backed by the same
        // (now-populated) SharedPreferences.
        final second = AppRoleSessionServiceImpl(preferences: preferences);
        final resolved = await second.resolve(user);

        expect(resolved, UserRole.classTeacher);
        expect(second.current, UserRole.classTeacher);
      },
    );

    test('switchTo rejects a role not held by the user', () async {
      final service = AppRoleSessionServiceImpl(preferences: preferences);
      final user = _user(roles: [UserRole.bursar]);

      final result = await service.switchTo(user: user, role: UserRole.nurse);

      expect(result, isNull);
      expect(service.current, isNull);
    });

    test(
      'resolve ignores a persisted role the user no longer holds, falling back to roles.first',
      () async {
        final first = AppRoleSessionServiceImpl(preferences: preferences);
        final original = _user(roles: [UserRole.bursar, UserRole.classTeacher]);
        await first.switchTo(user: original, role: UserRole.classTeacher);

        // Role revoked server-side: the fresh user no longer holds it.
        final revoked = _user(roles: [UserRole.bursar]);
        final second = AppRoleSessionServiceImpl(preferences: preferences);
        final resolved = await second.resolve(revoked);

        expect(resolved, UserRole.bursar);
      },
    );

    test(
      'revalidate keeps the current role if still held, otherwise re-resolves',
      () async {
        final service = AppRoleSessionServiceImpl(preferences: preferences);
        final user = _user(roles: [UserRole.bursar, UserRole.classTeacher]);
        await service.switchTo(user: user, role: UserRole.classTeacher);

        final stillValid = await service.revalidate(user);
        expect(stillValid, UserRole.classTeacher);

        final revokedUser = _user(roles: [UserRole.bursar]);
        final fallenBack = await service.revalidate(revokedUser);
        expect(fallenBack, UserRole.bursar);
      },
    );

    test('clear resets current to null', () async {
      final service = AppRoleSessionServiceImpl(preferences: preferences);
      final user = _user(roles: [UserRole.bursar, UserRole.classTeacher]);
      await service.switchTo(user: user, role: UserRole.classTeacher);
      expect(service.current, isNotNull);

      await service.clear();

      expect(service.current, isNull);
    });
  });
}
