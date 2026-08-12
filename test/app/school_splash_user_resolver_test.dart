import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/app/school_splash_user_resolver.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

UserEntity _user({String id = 'user-1'}) {
  return UserEntity(
    id: id,
    name: 'Test User',
    email: 'test@example.com',
    schoolId: 'school-1',
    roles: const [UserRole.schoolAdmin],
  );
}

void main() {
  group('resolveSchoolSplashUser', () {
    test('UserEntity passed directly as extra is used as-is', () {
      final user = _user();
      final resolved = resolveSchoolSplashUser(user, AuthInitial());
      expect(resolved, same(user));
    });

    test('non-UserEntity extra (e.g. a raw serialized map) falls back to '
        'AuthBloc current user rather than crashing', () {
      final authUser = _user(id: 'from-auth-bloc');
      final resolved = resolveSchoolSplashUser(<String, dynamic>{
        'id': 'not-a-user-entity',
      }, AuthAuthenticated(authUser));
      expect(resolved, same(authUser));
    });

    test('missing extra (null) falls back to AuthBloc current user', () {
      final authUser = _user(id: 'from-auth-bloc');
      final resolved = resolveSchoolSplashUser(
        null,
        AuthAuthenticated(authUser),
      );
      expect(resolved, same(authUser));
    });

    test('missing extra and no authenticated session resolves to null '
        '(caller must redirect, never fabricate a user)', () {
      final resolved = resolveSchoolSplashUser(null, AuthInitial());
      expect(resolved, isNull);
    });

    test('missing extra and an explicitly unauthenticated session resolves '
        'to null', () {
      final resolved = resolveSchoolSplashUser(null, AuthUnauthenticated());
      expect(resolved, isNull);
    });

    test(
      'invalid extra type with no authenticated session resolves to null',
      () {
        final resolved = resolveSchoolSplashUser(
          'a plain string',
          AuthInitial(),
        );
        expect(resolved, isNull);
      },
    );
  });
}
