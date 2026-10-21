import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/app_role_session_service.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';

class _FakeService extends Fake implements AppRoleSessionService {
  UserRole? _current;
  final _controller = StreamController<UserRole?>.broadcast();

  @override
  UserRole? get current => _current;

  @override
  Stream<UserRole?> get changes => _controller.stream;

  @override
  Future<UserRole> resolve(UserEntity user) async {
    _current ??= user.roles.first;
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<UserRole?> switchTo({
    required UserEntity user,
    required UserRole role,
  }) async {
    if (!user.roles.contains(role)) return null;
    _current = role;
    _controller.add(role);
    return role;
  }

  @override
  Future<UserRole> revalidate(UserEntity user) => resolve(user);

  @override
  Future<void> clear() async {
    _current = null;
    _controller.add(null);
  }
}

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
  group('AppRoleSessionCubit', () {
    late _FakeService service;

    setUp(() {
      service = _FakeService();
    });

    blocTest<AppRoleSessionCubit, UserRole?>(
      'seed resolves and emits the resolved role',
      build: () => AppRoleSessionCubit(service: service),
      act: (cubit) =>
          cubit.seed(_user(roles: [UserRole.bursar, UserRole.classTeacher])),
      expect: () => [UserRole.bursar],
    );

    blocTest<AppRoleSessionCubit, UserRole?>(
      'switchTo emits the newly active role',
      build: () => AppRoleSessionCubit(service: service),
      act: (cubit) => cubit.switchTo(
        user: _user(roles: [UserRole.bursar, UserRole.classTeacher]),
        role: UserRole.classTeacher,
      ),
      expect: () => [UserRole.classTeacher],
    );
  });
}
