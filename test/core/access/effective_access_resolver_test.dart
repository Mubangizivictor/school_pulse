import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/access/effective_access_resolver.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockActiveResponsibilityService extends Mock implements ActiveResponsibilityService {}

void main() {
  late MockPermissionEvaluator permissionEvaluator;
  late MockActiveResponsibilityService responsibilityService;
  late EffectiveAccessResolver resolver;

  const teacher = UserEntity(
    id: 'teacher-1',
    name: 'A Teacher',
    email: 'teacher@example.com',
    schoolId: 'school-1',
    roles: [UserRole.subjectTeacher],
  );

  ActiveResponsibilityContext buildContext({required Set<String> permissions, String? classId}) {
    return ActiveResponsibilityContext(
      schoolId: 'school-1',
      academicYearId: '2026',
      staffId: teacher.id,
      userId: teacher.id,
      roleAssignmentId: 'assign-1',
      roleType: StaffResponsibilityType.subjectTeacher,
      classId: classId,
      permissionScope: PermissionScope(permissions: permissions, classId: classId),
      assignmentStartDate: DateTime(2026, 1, 1),
    );
  }

  setUpAll(() {
    registerFallbackValue(teacher);
  });

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    responsibilityService = MockActiveResponsibilityService();
    resolver = EffectiveAccessResolver(
      permissionEvaluator: permissionEvaluator,
      responsibilityService: responsibilityService,
    );
  });

  test('grants access when the active responsibility scope covers the permission and coordinates', () async {
    when(() => responsibilityService.current).thenReturn(
      buildContext(permissions: {'class.attendance.take'}, classId: 'p7'),
    );

    final result = await resolver.can('class.attendance.take', teacher, classId: 'p7');

    expect(result.getOrElse(() => false), isTrue);
    verifyNever(() => permissionEvaluator.can(any(), any(), gate: any(named: 'gate')));
  });

  test('falls back to role-level PermissionEvaluator when no active responsibility is loaded', () async {
    when(() => responsibilityService.current).thenReturn(null);
    when(() => permissionEvaluator.can(Permission.securityIdentityVerify, teacher))
        .thenAnswer((_) async => const Right(true));

    final result = await resolver.can(Permission.securityIdentityVerify, teacher);

    expect(result.getOrElse(() => false), isTrue);
    verify(() => permissionEvaluator.can(Permission.securityIdentityVerify, teacher)).called(1);
  });

  test('falls back to role-level check when the active context does not cover the requested coordinates', () async {
    when(() => responsibilityService.current).thenReturn(
      buildContext(permissions: {'class.attendance.take'}, classId: 'p6'),
    );
    when(() => permissionEvaluator.can('class.attendance.take', teacher))
        .thenAnswer((_) async => const Right(false));

    final result = await resolver.can('class.attendance.take', teacher, classId: 'p7');

    expect(result.getOrElse(() => true), isFalse);
    verify(() => permissionEvaluator.can('class.attendance.take', teacher)).called(1);
  });

  test('falls back to role-level check when the active context belongs to a different user', () async {
    when(() => responsibilityService.current).thenReturn(
      buildContext(permissions: {'class.attendance.take'}, classId: 'p7').copyWith(),
    );
    when(() => permissionEvaluator.can('class.attendance.take', any(that: isA<UserEntity>())))
        .thenAnswer((_) async => const Right(false));

    final result = await resolver.can(
      'class.attendance.take',
      const UserEntity(
        id: 'someone-else',
        name: 'Someone Else',
        email: 'someone@example.com',
        schoolId: 'school-1',
        roles: [UserRole.subjectTeacher],
      ),
      classId: 'p7',
    );

    expect(result.getOrElse(() => true), isFalse);
  });
}
