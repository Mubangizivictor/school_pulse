import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/services/attendance_participant_resolver_impl.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockStaffAssignmentRepository extends Mock
    implements StaffAssignmentRepository {}

class MockAcademicCalendarService extends Mock
    implements AcademicCalendarService {}

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

void main() {
  late AttendanceParticipantResolverImpl resolver;
  late MockStaffAssignmentRepository assignmentRepository;
  late MockAcademicCalendarService calendarService;
  late MockPermissionEvaluator permissionEvaluator;

  const schoolId = 'school-1';
  const academicYearId = 'year-2026';
  const period = AcademicPeriod(
    academicYearId: academicYearId,
    termId: 'term-1',
  );

  setUp(() {
    assignmentRepository = MockStaffAssignmentRepository();
    calendarService = MockAcademicCalendarService();
    permissionEvaluator = MockPermissionEvaluator();
    resolver = AttendanceParticipantResolverImpl(
      assignmentRepository: assignmentRepository,
      calendarService: calendarService,
      permissionEvaluator: permissionEvaluator,
    );

    when(
      () => calendarService.getCurrentPeriod(schoolId),
    ).thenAnswer((_) async => period);
  });

  UserEntity buildUser({
    required String id,
    required List<UserRole> roles,
  }) {
    return UserEntity(
      id: id,
      name: 'Test User',
      email: '$id@example.com',
      schoolId: schoolId,
      roles: roles,
    );
  }

  StaffRoleAssignment buildAssignment({
    required String id,
    required String userId,
    required StaffResponsibilityType roleType,
    String? classId,
    String? subjectId,
    String? houseId,
    AssignmentStatus status = AssignmentStatus.active,
  }) {
    return StaffRoleAssignment(
      id: id,
      schoolId: schoolId,
      staffId: userId,
      userId: userId,
      roleType: roleType,
      academicYearId: academicYearId,
      classId: classId,
      subjectId: subjectId,
      houseId: houseId,
      startDate: DateTime(2026, 1, 1),
      status: status,
      assignedAt: DateTime(2026, 1, 1),
    );
  }

  /// Only grants the given category-level permissions - every other
  /// permission (including attendance.override) resolves to false, so tests
  /// exercise the resolver's own scope logic rather than an accidental
  /// institution-wide bypass.
  void grantOnly(UserEntity user, Set<String> permissionIds) {
    when(() => permissionEvaluator.can(any(), user)).thenAnswer((
      invocation,
    ) async {
      final permissionId = invocation.positionalArguments[0] as String;
      return Right(permissionIds.contains(permissionId));
    });
  }

  group('Class Teacher - one class', () {
    test('sees only their assigned class under students', () async {
      final user = buildUser(id: 'ct-1', roles: [UserRole.classTeacher]);
      grantOnly(user, {Permission.attendanceClassScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-1',
            userId: user.id,
            roleType: StaffResponsibilityType.classTeacher,
            classId: 'p5-blue',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.allowedDomains, contains(AttendanceCategory.students));
      expect(access.canViewAllForCategory(AttendanceCategory.students), isFalse);
      expect(access.canAccessClass('p5-blue'), isTrue);
      expect(access.canAccessClass('p5-red'), isFalse);
      expect(access.canAccessClass('p6'), isFalse);
      expect(
        access.canActOnScope(AttendanceCategory.students, 'p5-blue'),
        isTrue,
      );
      expect(
        access.canActOnScope(AttendanceCategory.students, 'p5-red'),
        isFalse,
      );
      expect(
        access.assignmentIdForScope(AttendanceCategory.students, 'p5-blue'),
        'assign-1',
      );
      // Staff/gate/hostel were never granted - must not leak into scope.
      expect(access.allowedDomains, isNot(contains(AttendanceCategory.staff)));
      expect(access.allowedDomains, isNot(contains(AttendanceCategory.gate)));
      expect(
        access.allowedDomains,
        isNot(contains(AttendanceCategory.hostel)),
      );
    });
  });

  group('Subject Teacher - one subject, multiple classes', () {
    test('sees only the classes that subject was assigned with', () async {
      final user = buildUser(id: 'st-1', roles: [UserRole.subjectTeacher]);
      grantOnly(user, {Permission.attendanceSubjectScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-math-p6',
            userId: user.id,
            roleType: StaffResponsibilityType.subjectTeacher,
            subjectId: 'math',
            classId: 'p6-blue',
          ),
          buildAssignment(
            id: 'assign-math-p7',
            userId: user.id,
            roleType: StaffResponsibilityType.subjectTeacher,
            subjectId: 'math',
            classId: 'p7-red',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.canAccessClass('p6-blue'), isTrue);
      expect(access.canAccessClass('p7-red'), isTrue);
      expect(access.canAccessClass('p6-red'), isFalse);
      expect(access.canAccessClass('p5-blue'), isFalse);
    });
  });

  group('Patron - boys dormitory', () {
    test('sees only their assigned dormitory under hostel', () async {
      final user = buildUser(id: 'pat-1', roles: [UserRole.boardingPatron]);
      grantOnly(user, {Permission.attendanceBoardingScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-hostel-a',
            userId: user.id,
            roleType: StaffResponsibilityType.patron,
            houseId: 'boys-hostel-a',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.canAccessDormitory('boys-hostel-a'), isTrue);
      expect(access.canAccessDormitory('girls-hostel-b'), isFalse);
      expect(access.canAccessDormitory('boys-hostel-b'), isFalse);
      expect(
        access.assignmentIdForScope(
          AttendanceCategory.hostel,
          'boys-hostel-a',
        ),
        'assign-hostel-a',
      );
    });
  });

  group('Matron - girls dormitory', () {
    test('sees only their assigned dormitory, never boys', () async {
      final user = buildUser(id: 'mat-1', roles: [UserRole.boardingMatron]);
      grantOnly(user, {Permission.attendanceBoardingScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-hostel-b',
            userId: user.id,
            roleType: StaffResponsibilityType.matron,
            houseId: 'girls-hostel-b',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.canAccessDormitory('girls-hostel-b'), isTrue);
      expect(access.canAccessDormitory('boys-hostel-a'), isFalse);
    });
  });

  group('Security - gate', () {
    test('gets category-level students/gate access with no class scoping', () async {
      final user = buildUser(id: 'sec-1', roles: [UserRole.gatekeeper]);
      grantOnly(user, {Permission.attendanceGateScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.allowedDomains, {AttendanceCategory.gate});
      // Not scoped to any specific class/dormitory - category permission is
      // the only gate for this category this pass.
      expect(
        access.canActOnScope(AttendanceCategory.gate, 'any-gate-id'),
        isTrue,
      );
      expect(
        access.canActOnScope(AttendanceCategory.students, 'p5-blue'),
        isFalse,
      );
    });
  });

  group('Headteacher - entire institution', () {
    test('gets institution-wide access to every granted category', () async {
      final user = buildUser(id: 'ht-1', roles: [UserRole.headTeacher]);
      grantOnly(user, {
        Permission.attendanceClassScan,
        Permission.attendanceStaffScan,
        Permission.attendanceBoardingScan,
        Permission.attendanceGateScan,
      });
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.canViewAllForCategory(AttendanceCategory.students), isTrue);
      expect(access.canViewAllForCategory(AttendanceCategory.hostel), isTrue);
      // Any classId/dormitoryId is authorised, without needing a matching
      // assignment row - this is the admin bypass, not scope-derived access.
      expect(
        access.canActOnScope(AttendanceCategory.students, 'literally-any-class'),
        isTrue,
      );
      expect(
        access.canActOnScope(AttendanceCategory.hostel, 'literally-any-dorm'),
        isTrue,
      );
    });
  });

  group('Institution Administrator (schoolAdmin) - entire institution', () {
    test('gets institution-wide access same as headteacher', () async {
      final user = buildUser(id: 'admin-1', roles: [UserRole.schoolAdmin]);
      grantOnly(user, {Permission.attendanceClassScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.canViewAllForCategory(AttendanceCategory.students), isTrue);
    });
  });

  group('Bursar - no attendance assignment', () {
    test('has no attendance access at all, never falls back to all students', () async {
      final user = buildUser(id: 'bursar-1', roles: [UserRole.bursar]);
      grantOnly(user, {}); // Bursar's role defaults grant no attendance.*.
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(access.hasAnyAccess, isFalse);
      expect(access.allowedDomains, isEmpty);
      expect(
        access.canActOnScope(AttendanceCategory.students, 'any-class'),
        isFalse,
      );
    });
  });

  group('Multi-role user', () {
    test('unions Class Teacher and Subject Teacher scopes', () async {
      final user = buildUser(
        id: 'multi-1',
        roles: [UserRole.classTeacher, UserRole.subjectTeacher],
      );
      grantOnly(user, {
        Permission.attendanceClassScan,
        Permission.attendanceSubjectScan,
      });
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-ct',
            userId: user.id,
            roleType: StaffResponsibilityType.classTeacher,
            classId: 'p5-blue',
          ),
          buildAssignment(
            id: 'assign-st',
            userId: user.id,
            roleType: StaffResponsibilityType.subjectTeacher,
            subjectId: 'math',
            classId: 'p6-blue',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      // Both the class-teacher class AND the subject-teacher class are
      // visible - a narrower "currently selected workspace" would only
      // show one of these.
      expect(access.canAccessClass('p5-blue'), isTrue);
      expect(access.canAccessClass('p6-blue'), isTrue);
      expect(access.canAccessClass('p7-red'), isFalse);
    });
  });

  group('Suspended responsibility', () {
    test('a suspended assignment contributes no scope', () async {
      final user = buildUser(id: 'ct-2', roles: [UserRole.classTeacher]);
      grantOnly(user, {Permission.attendanceClassScan});
      // getValidAssignments is documented to already exclude non-active
      // assignments (suspended/expired) - the resolver trusts that filter
      // rather than re-checking status itself, so a suspended assignment
      // simply never appears in what this mock returns.
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      // The classTeacher role's default attendance.class.scan permission
      // still resolves (hasAnyAccess), but with the suspended assignment
      // absent from getValidAssignments, no class is actually reachable -
      // this is the "permission but no responsibility" empty-state case,
      // not full lockout.
      expect(access.canAccessClass('p5-blue'), isFalse);
      expect(access.allScopedClassIds, isEmpty);
      expect(
        access.canActOnScope(AttendanceCategory.students, 'p5-blue'),
        isFalse,
      );
    });
  });

  group('Wrong-scope access', () {
    test('Class Teacher cannot act on a class outside their assignment', () async {
      final user = buildUser(id: 'ct-3', roles: [UserRole.classTeacher]);
      grantOnly(user, {Permission.attendanceClassScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-1',
            userId: user.id,
            roleType: StaffResponsibilityType.classTeacher,
            classId: 'p5-blue',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(
        access.canActOnScope(AttendanceCategory.students, 'p6-blue'),
        isFalse,
      );
      expect(
        access.assignmentIdForScope(AttendanceCategory.students, 'p6-blue'),
        isNull,
      );
    });

    test('Matron cannot act on a dormitory outside their assignment', () async {
      final user = buildUser(id: 'mat-2', roles: [UserRole.boardingMatron]);
      grantOnly(user, {Permission.attendanceBoardingScan});
      when(
        () => assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: user.id,
          academicYearId: academicYearId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildAssignment(
            id: 'assign-hostel-b',
            userId: user.id,
            roleType: StaffResponsibilityType.matron,
            houseId: 'girls-hostel-b',
          ),
        ]),
      );

      final result = await resolver.resolve(user);
      final access = result.getOrElse(() => throw StateError('failed'));

      expect(
        access.canActOnScope(AttendanceCategory.hostel, 'boys-hostel-a'),
        isFalse,
      );
    });
  });

  test('resolve() surfaces a repository failure rather than granting access', () async {
    final user = buildUser(id: 'ct-4', roles: [UserRole.classTeacher]);
    when(
      () => assignmentRepository.getValidAssignments(
        schoolId: schoolId,
        userId: user.id,
        academicYearId: academicYearId,
      ),
    ).thenAnswer((_) async => Left(ServerFailure()));

    final result = await resolver.resolve(user);

    expect(result.isLeft(), isTrue);
  });
}
