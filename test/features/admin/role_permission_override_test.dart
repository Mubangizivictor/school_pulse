import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/domain/entities/role_permission_override.dart';
import 'package:school_pulse/features/admin/domain/repositories/role_permission_override_repository.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_role_permission_overrides.dart';
import 'package:school_pulse/features/admin/domain/usecases/save_role_permission_override.dart';

class MockRolePermissionOverrideRepository extends Mock implements RolePermissionOverrideRepository {}

void main() {
  late MockRolePermissionOverrideRepository repository;
  late GetRolePermissionOverrides getOverrides;
  late SaveRolePermissionOverride saveOverride;

  setUpAll(() {
    registerFallbackValue(UserRole.nurse);
  });

  setUp(() {
    repository = MockRolePermissionOverrideRepository();
    getOverrides = GetRolePermissionOverrides(repository);
    saveOverride = SaveRolePermissionOverride(repository);
  });

  test('save then get round-trips the same override through the repository', () async {
    final override = RolePermissionOverride(
      role: UserRole.nurse,
      permissions: {'health.clinicVisit.record'},
      updatedBy: 'adminA',
      updatedAt: DateTime(2026, 1, 1),
    );

    when(() => repository.saveOverride(
          schoolId: any(named: 'schoolId'),
          role: any(named: 'role'),
          permissions: any(named: 'permissions'),
          updatedBy: any(named: 'updatedBy'),
        )).thenAnswer((_) async => const Right(null));
    when(() => repository.getOverrides('schoolA')).thenAnswer(
      (_) async => Right({UserRole.nurse: override}),
    );

    final saveResult = await saveOverride(SaveRolePermissionOverrideParams(
      schoolId: 'schoolA',
      role: UserRole.nurse,
      permissions: {'health.clinicVisit.record'},
      updatedBy: 'adminA',
    ));
    expect(saveResult.isRight(), isTrue);

    final getResult = await getOverrides('schoolA');
    expect(
      getResult.getOrElse(() => {})[UserRole.nurse]?.permissions,
      {'health.clinicVisit.record'},
    );
  });

  test('save failure is propagated as a Left', () async {
    when(() => repository.saveOverride(
          schoolId: any(named: 'schoolId'),
          role: any(named: 'role'),
          permissions: any(named: 'permissions'),
          updatedBy: any(named: 'updatedBy'),
        )).thenAnswer((_) async => Left(ServerFailure('write failed')));

    final result = await saveOverride(SaveRolePermissionOverrideParams(
      schoolId: 'schoolA',
      role: UserRole.nurse,
      permissions: {'health.clinicVisit.record'},
      updatedBy: 'adminA',
    ));

    expect(result.isLeft(), isTrue);
  });

  test('a role with no saved override is simply absent from the map', () async {
    when(() => repository.getOverrides('schoolA')).thenAnswer((_) async => const Right({}));

    final result = await getOverrides('schoolA');

    expect(result.getOrElse(() => {})[UserRole.schoolAdmin], isNull);
  });
}
