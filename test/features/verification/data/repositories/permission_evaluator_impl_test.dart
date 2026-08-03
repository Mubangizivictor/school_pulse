import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/admin/domain/entities/role_permission_override.dart';
import 'package:school_pulse/features/admin/domain/repositories/role_permission_override_repository.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/verification/data/repositories/permission_evaluator_impl.dart';

class MockVerificationLocalDataSource extends Mock implements VerificationLocalDataSource {}

class MockRolePermissionOverrideRepository extends Mock implements RolePermissionOverrideRepository {}

void main() {
  late PermissionEvaluatorImpl evaluator;
  late MockVerificationLocalDataSource localDataSource;
  late MockRolePermissionOverrideRepository overrideRepository;

  const gatekeeper = UserEntity(
    id: 'op-1',
    name: 'Gate Officer',
    email: 'officer@example.com',
    schoolId: 'school-1',
    roles: [UserRole.gatekeeper],
  );

  const securityHead = UserEntity(
    id: 'op-2',
    name: 'Security Head',
    email: 'head@example.com',
    schoolId: 'school-1',
    roles: [UserRole.securityHead],
  );

  const ordinaryTeacher = UserEntity(
    id: 'op-3',
    name: 'A Teacher',
    email: 'teacher@example.com',
    schoolId: 'school-1',
    roles: [UserRole.subjectTeacher],
  );

  Gate buildGate({List<String> assignedOfficerIds = const [], List<String> allowedUserRoles = const []}) {
    return Gate(
      id: 'gate-1',
      name: 'Main Gate',
      type: 'Main Entrance',
      location: 'Front',
      assignedOfficerIds: assignedOfficerIds,
      operatingHours: const {},
      allowedUserRoles: allowedUserRoles,
      requiredVerificationMethods: const [],
      schoolId: 'school-1',
    );
  }

  setUpAll(() {
    registerFallbackValue(OperatorPermissionSnapshotIsar());
  });

  setUp(() {
    localDataSource = MockVerificationLocalDataSource();
    overrideRepository = MockRolePermissionOverrideRepository();
    evaluator = PermissionEvaluatorImpl(
      localDataSource: localDataSource,
      overrideRepository: overrideRepository,
    );
    when(() => localDataSource.getPermissionSnapshot(any())).thenAnswer((_) async => null);
    when(() => localDataSource.savePermissionSnapshot(any())).thenAnswer((_) async {});
    when(() => overrideRepository.getOverrides(any()))
        .thenAnswer((_) async => const Right(<UserRole, RolePermissionOverride>{}));
  });

  group('role-level permission', () {
    test('grants a gatekeeper security.identity.verify by default', () async {
      final result = await evaluator.can(Permission.securityIdentityVerify, gatekeeper);
      expect(result.getOrElse(() => false), isTrue);
    });

    test('denies an ordinary subject teacher (no security permissions by default)', () async {
      final result = await evaluator.can(Permission.securityIdentityVerify, ordinaryTeacher);
      expect(result.getOrElse(() => true), isFalse);
    });

    test('denies a permission the role does not have even if others are granted', () async {
      final result = await evaluator.can(Permission.verificationDeviceManage, gatekeeper);
      expect(result.getOrElse(() => true), isFalse);
    });
  });

  group('gate resource scoping', () {
    test('denies a gatekeeper not in assignedOfficerIds when the gate restricts officers', () async {
      final gate = buildGate(assignedOfficerIds: ['someone-else']);
      final result = await evaluator.can(Permission.securityIdentityVerify, gatekeeper, gate: gate);
      expect(result.getOrElse(() => true), isFalse);
    });

    test('allows a gatekeeper who IS in assignedOfficerIds', () async {
      final gate = buildGate(assignedOfficerIds: [gatekeeper.id]);
      final result = await evaluator.can(Permission.securityIdentityVerify, gatekeeper, gate: gate);
      expect(result.getOrElse(() => false), isTrue);
    });

    test('an empty assignedOfficerIds list does not restrict anyone (matches today\'s unenforced default)', () async {
      final gate = buildGate();
      final result = await evaluator.can(Permission.securityIdentityVerify, gatekeeper, gate: gate);
      expect(result.getOrElse(() => false), isTrue);
    });

    test('securityOverride bypasses gate officer/role scoping', () async {
      final gate = buildGate(assignedOfficerIds: ['someone-else']);
      final result = await evaluator.can(Permission.securityIdentityVerify, securityHead, gate: gate);
      expect(result.getOrElse(() => false), isTrue);
    });

    test('denies when gate restricts by role and operator holds none of them', () async {
      final gate = buildGate(allowedUserRoles: ['securityHead']);
      final result = await evaluator.can(Permission.securityIdentityVerify, gatekeeper, gate: gate);
      expect(result.getOrElse(() => true), isFalse);
    });
  });

  group('permission cache', () {
    test('uses a fresh cached snapshot instead of recomputing from role defaults', () async {
      when(() => localDataSource.getPermissionSnapshot(ordinaryTeacher.id)).thenAnswer(
        (_) async => OperatorPermissionSnapshotIsar()
          ..operatorId = ordinaryTeacher.id
          ..schoolId = ordinaryTeacher.schoolId
          ..permissionIds = [Permission.securityIdentityVerify]
          ..version = 2
          ..expiresAt = DateTime.now().add(const Duration(hours: 1)),
      );

      final result = await evaluator.can(Permission.securityIdentityVerify, ordinaryTeacher);
      expect(result.getOrElse(() => false), isTrue);
      verifyNever(() => localDataSource.savePermissionSnapshot(any()));
    });

    test('falls back to role defaults (fail-open) when the cached snapshot has expired', () async {
      when(() => localDataSource.getPermissionSnapshot(gatekeeper.id)).thenAnswer(
        (_) async => OperatorPermissionSnapshotIsar()
          ..operatorId = gatekeeper.id
          ..schoolId = gatekeeper.schoolId
          ..permissionIds = <String>[]
          ..version = 1
          ..expiresAt = DateTime.now().subtract(const Duration(hours: 1)),
      );

      final result = await evaluator.can(Permission.securityIdentityVerify, gatekeeper);
      expect(result.getOrElse(() => false), isTrue);
      verify(() => localDataSource.savePermissionSnapshot(any())).called(1);
    });
  });
}
