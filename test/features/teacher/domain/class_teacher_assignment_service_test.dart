import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/data/services/class_teacher_assignment_service_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';

class _MockAssignmentRepository extends Mock
    implements StaffAssignmentRepository {}

class _MockResponsibilityService extends Mock
    implements ActiveResponsibilityService {}

StaffRoleAssignment _classRow({
  String id = 'ct1',
  String staffId = 'staff1',
  String campusId = 'main',
  String academicYearId = '2026',
  String classId = 'p5',
  String? streamId = 'east',
  AssignmentStatus status = AssignmentStatus.active,
  DateTime? assignedAt,
  DateTime? startDate,
  DateTime? endDate,
  Set<String> permissions = const {},
}) {
  return StaffRoleAssignment(
    id: id,
    schoolId: 'school1',
    campusId: campusId,
    staffId: staffId,
    userId: 'user1',
    roleType: StaffResponsibilityType.classTeacher,
    academicYearId: academicYearId,
    classId: classId,
    className: 'P5',
    streamId: streamId,
    streamName: 'East',
    startDate: startDate ?? DateTime(2026, 1, 1),
    endDate: endDate,
    status: status,
    permissionScope: PermissionScope(
      permissions: permissions,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
    ),
    assignedAt: assignedAt ?? DateTime(2026, 1, 1),
  );
}

StaffRoleAssignment _subjectRow({
  String id = 'st1',
  String classId = 'p6',
  String subjectId = 'maths',
}) {
  return StaffRoleAssignment(
    id: id,
    schoolId: 'school1',
    campusId: 'main',
    staffId: 'staff1',
    userId: 'user1',
    roleType: StaffResponsibilityType.subjectTeacher,
    academicYearId: '2026',
    subjectId: subjectId,
    subjectName: 'Mathematics',
    classId: classId,
    className: 'P6',
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );
}

ActiveResponsibilityContext _context({
  StaffResponsibilityType roleType = StaffResponsibilityType.classTeacher,
  AssignmentStatus status = AssignmentStatus.active,
  String? classId = 'p5',
  String? streamId = 'east',
  Set<String> permissions = const {Permission.classStudentsView},
}) {
  return ActiveResponsibilityContext(
    schoolId: 'school1',
    campusId: 'main',
    academicYearId: '2026',
    termId: 't2',
    staffId: 'staff1',
    userId: 'user1',
    roleAssignmentId: 'ct1',
    roleType: roleType,
    classId: classId,
    className: 'P5',
    streamId: streamId,
    streamName: 'East',
    permissionScope: PermissionScope(
      permissions: permissions,
      classId: classId,
      streamId: streamId,
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
    assignmentStatus: status,
  );
}

void main() {
  late _MockAssignmentRepository repository;
  late _MockResponsibilityService responsibilityService;
  late ClassTeacherAssignmentServiceImpl service;

  setUp(() {
    repository = _MockAssignmentRepository();
    responsibilityService = _MockResponsibilityService();
    service = ClassTeacherAssignmentServiceImpl(
      assignmentRepository: repository,
      responsibilityService: responsibilityService,
    );
  });

  void stubAssignments(List<StaffRoleAssignment> rows) {
    when(
      () => repository.getAssignments(
        schoolId: any(named: 'schoolId'),
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(rows));
  }

  void stubValidAssignments(List<StaffRoleAssignment> rows) {
    when(
      () => repository.getValidAssignments(
        schoolId: any(named: 'schoolId'),
        userId: any(named: 'userId'),
        academicYearId: any(named: 'academicYearId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(rows));
  }

  Future<dynamic> validate({
    bool overrideRequested = false,
    String? overrideReason,
    Set<String> assignerPermissions = const {},
    String academicYearId = '2026',
    String campusId = 'main',
    String? excludeAssignmentId,
  }) {
    return service.validateAssignable(
      schoolId: 'school1',
      campusId: campusId,
      staffId: 'staff1',
      userId: 'user1',
      academicYearId: academicYearId,
      excludeAssignmentId: excludeAssignmentId,
      overrideRequested: overrideRequested,
      overrideReason: overrideReason,
      assignerPermissions: assignerPermissions,
    );
  }

  group('one Class Teacher assignment per year and campus', () {
    test('a staff member with no class yet may be given one', () async {
      stubAssignments([_subjectRow()]);

      final result = await validate();

      expect(result.getOrElse(() => throw 'unexpected').isAllowed, isTrue);
    });

    test(
      'a second class in the same year and campus is refused by default',
      () async {
        stubAssignments([_classRow()]);

        final assignability = (await validate()).getOrElse(
          () => throw 'unexpected',
        );

        expect(assignability.isAllowed, isFalse);
        expect(assignability.overrideWouldAllow, isTrue);
        expect(assignability.conflicting.single.id, 'ct1');
      },
    );

    test('subject assignments never count towards the limit', () async {
      // Six subjects across four classes plus no class row at all: the rule
      // restricts class teaching only, never teaching load.
      stubAssignments([
        _subjectRow(id: 's1', classId: 'p5', subjectId: 'maths'),
        _subjectRow(id: 's2', classId: 'p6', subjectId: 'maths'),
        _subjectRow(id: 's3', classId: 'p5', subjectId: 'ict'),
        _subjectRow(id: 's4', classId: 'p7', subjectId: 'ict'),
      ]);

      final assignability = (await validate()).getOrElse(
        () => throw 'unexpected',
      );

      expect(assignability.isAllowed, isTrue);
    });

    test('a class in a different academic year does not conflict', () async {
      stubAssignments([_classRow(academicYearId: '2025')]);

      final assignability = (await validate()).getOrElse(
        () => throw 'unexpected',
      );

      expect(assignability.isAllowed, isTrue);
    });

    test('a class on a different campus does not conflict', () async {
      stubAssignments([_classRow(campusId: 'annex')]);

      final assignability = (await validate()).getOrElse(
        () => throw 'unexpected',
      );

      expect(assignability.isAllowed, isTrue);
    });

    test('a suspended class row does not hold the slot', () async {
      stubAssignments([_classRow(status: AssignmentStatus.suspended)]);

      final assignability = (await validate()).getOrElse(
        () => throw 'unexpected',
      );

      expect(assignability.isAllowed, isTrue);
    });

    test('editing the same assignment does not conflict with itself', () async {
      stubAssignments([_classRow(id: 'ct1')]);

      final assignability = (await validate(
        excludeAssignmentId: 'ct1',
      )).getOrElse(() => throw 'unexpected');

      expect(assignability.isAllowed, isTrue);
    });

    test('an assignment with no academic year is rejected outright', () async {
      stubAssignments([]);

      final result = await validate(academicYearId: '');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected a validation failure'),
      );
    });
  });

  group('multi-class override', () {
    test(
      'is refused when the assigning admin lacks the override permission',
      () async {
        stubAssignments([_classRow()]);

        final assignability = (await validate(
          overrideRequested: true,
          overrideReason: 'Covering a long-term vacancy in P6 West.',
        )).getOrElse(() => throw 'unexpected');

        expect(assignability.isAllowed, isFalse);
        expect(assignability.reason, contains('override permission'));
      },
    );

    test('is refused without a substantive reason', () async {
      stubAssignments([_classRow()]);

      final assignability = (await validate(
        overrideRequested: true,
        overrideReason: 'because',
        assignerPermissions: {Permission.classTeacherMultiAssignOverride},
      )).getOrElse(() => throw 'unexpected');

      expect(assignability.isAllowed, isFalse);
      expect(assignability.reason, contains('reason'));
    });

    test('is allowed with the permission and a reason', () async {
      stubAssignments([_classRow()]);

      final assignability = (await validate(
        overrideRequested: true,
        overrideReason: 'Covering a long-term vacancy in P6 West.',
        assignerPermissions: {Permission.classTeacherMultiAssignOverride},
      )).getOrElse(() => throw 'unexpected');

      expect(assignability.isAllowed, isTrue);
      expect(assignability.conflicting, hasLength(1));
    });
  });

  group('resolveActiveAssignment', () {
    test('returns null when the teacher holds no class row', () async {
      stubValidAssignments([_subjectRow()]);

      final result = await service.resolveActiveAssignment(
        schoolId: 'school1',
        userId: 'user1',
      );

      expect(result.getOrElse(() => throw 'unexpected'), isNull);
    });

    test('ignores a class row that is past its end date', () async {
      stubValidAssignments([
        _classRow(
          endDate: DateTime(2026, 1, 2),
          startDate: DateTime(2026, 1, 1),
        ),
      ]);

      final result = await service.resolveActiveAssignment(
        schoolId: 'school1',
        userId: 'user1',
      );

      expect(result.getOrElse(() => throw 'unexpected'), isNull);
    });

    test(
      'prefers the most recently assigned class when a school allows two',
      () async {
        stubValidAssignments([
          _classRow(id: 'old', assignedAt: DateTime(2026, 1, 1)),
          _classRow(id: 'new', assignedAt: DateTime(2026, 5, 1)),
        ]);

        final result = await service.resolveActiveAssignment(
          schoolId: 'school1',
          userId: 'user1',
        );

        expect(result.getOrElse(() => throw 'unexpected')?.id, 'new');
      },
    );
  });

  group('authorize', () {
    test('refuses when no responsibility is active', () {
      final result = service.authorize(
        null,
        permission: Permission.classStudentsView,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AssignmentInvalidFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('refuses when the active responsibility is not the class one', () {
      final result = service.authorize(
        _context(roleType: StaffResponsibilityType.subjectTeacher),
        permission: Permission.classStudentsView,
      );

      expect(result.isLeft(), isTrue);
    });

    test('refuses when the assignment has been suspended', () {
      final result = service.authorize(
        _context(status: AssignmentStatus.suspended),
        permission: Permission.classStudentsView,
      );

      expect(result.isLeft(), isTrue);
    });

    test(
      'refuses a class the teacher was not given, even with the permission',
      () {
        // The scope check is the point: holding `class.students.view` says
        // nothing about *which* class it may be spent on.
        final result = service.authorize(
          _context(),
          permission: Permission.classStudentsView,
          classId: 'p6',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<PermissionDeniedFailure>()),
          (_) => fail('expected a permission failure'),
        );
      },
    );

    test('refuses another stream of the same class', () {
      final result = service.authorize(
        _context(),
        permission: Permission.classStudentsView,
        streamId: 'west',
      );

      expect(result.isLeft(), isTrue);
    });

    test('refuses a permission the assignment does not grant', () {
      final result = service.authorize(
        _context(permissions: const {Permission.classStudentsView}),
        permission: Permission.classAttendanceTake,
      );

      expect(result.isLeft(), isTrue);
    });

    test('allows the granted permission inside the assigned class', () {
      final result = service.authorize(
        _context(),
        permission: Permission.classStudentsView,
        classId: 'p5',
        streamId: 'east',
      );

      expect(result.isRight(), isTrue);
    });
  });

  group('authorizeFresh', () {
    test(
      'refuses when revalidation fails, without consulting the stale context',
      () async {
        when(
          () => responsibilityService.revalidate(),
        ).thenAnswer((_) async => const Left(AssignmentInvalidFailure()));

        final result = await service.authorizeFresh(
          permission: Permission.classAttendanceTake,
        );

        expect(result.isLeft(), isTrue);
      },
    );

    test(
      're-applies the scope check against the freshly read context',
      () async {
        // An admin narrowed the scope while the screen was open: the server now
        // says P5 East only, and the write aimed at P6 must not land.
        when(() => responsibilityService.revalidate()).thenAnswer(
          (_) async => Right(
            _context(permissions: const {Permission.classAttendanceTake}),
          ),
        );

        final result = await service.authorizeFresh(
          permission: Permission.classAttendanceTake,
          classId: 'p6',
        );

        expect(result.isLeft(), isTrue);
      },
    );
  });
}
