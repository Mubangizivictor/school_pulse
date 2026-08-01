import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';

StaffRoleAssignment _assignment({
  String id = 'a1',
  StaffResponsibilityType roleType = StaffResponsibilityType.subjectTeacher,
  AssignmentStatus status = AssignmentStatus.active,
  DateTime? startDate,
  DateTime? endDate,
  String subjectId = 'maths',
  String classId = 'g10',
  String? streamId = 'a',
  Set<String> permissions = const {},
}) {
  return StaffRoleAssignment(
    id: id,
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: roleType,
    academicYearId: '2026',
    subjectId: subjectId,
    subjectName: 'Mathematics',
    classId: classId,
    className: 'Grade 10',
    streamId: streamId,
    streamName: 'A',
    startDate: startDate ?? DateTime(2026, 1, 1),
    endDate: endDate,
    status: status,
    permissionScope: PermissionScope(
      permissions: permissions,
      subjectId: subjectId,
      classId: classId,
      streamId: streamId,
      academicYearId: '2026',
    ),
    assignedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('assignment validity', () {
    final today = DateTime(2026, 6, 1);

    test('an active assignment inside its dates grants access', () {
      expect(_assignment().isCurrentlyValid(asOf: today), isTrue);
    });

    test('a suspended assignment never grants access', () {
      expect(
        _assignment(status: AssignmentStatus.suspended).isCurrentlyValid(asOf: today),
        isFalse,
      );
    });

    test('a removed assignment never grants access', () {
      expect(
        _assignment(status: AssignmentStatus.removed).isCurrentlyValid(asOf: today),
        isFalse,
      );
    });

    test('a temporary assignment stops granting access after its end date', () {
      final temp = _assignment(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
      );
      expect(temp.isCurrentlyValid(asOf: DateTime(2026, 5, 15)), isTrue);
      expect(temp.isCurrentlyValid(asOf: today), isFalse);
    });

    test('an assignment that has not started yet grants nothing', () {
      final future = _assignment(startDate: DateTime(2026, 9, 1));
      expect(future.isCurrentlyValid(asOf: today), isFalse);
    });

    test('access lasts to the end of the final day, not midnight', () {
      final ending = _assignment(endDate: DateTime(2026, 6, 1));
      expect(ending.isCurrentlyValid(asOf: DateTime(2026, 6, 1, 16, 30)), isTrue);
    });
  });

  group('permission scope', () {
    const scope = PermissionScope(
      permissions: {Permission.subjectMarksEnter},
      subjectId: 'maths',
      classId: 'g10',
      streamId: 'a',
      academicYearId: '2026',
    );

    test('covers a record inside the same subject, class and stream', () {
      expect(
        scope.covers(subjectId: 'maths', classId: 'g10', streamId: 'a'),
        isTrue,
      );
    });

    test('rejects the same subject in a different class', () {
      expect(scope.covers(subjectId: 'maths', classId: 'g11'), isFalse);
    });

    test('rejects a different subject in the same class', () {
      expect(scope.covers(subjectId: 'ict', classId: 'g10'), isFalse);
    });

    test('rejects a different stream of the same class', () {
      expect(
        scope.covers(subjectId: 'maths', classId: 'g10', streamId: 'b'),
        isFalse,
      );
    });

    test('rejects another academic year', () {
      expect(scope.covers(subjectId: 'maths', academicYearId: '2025'), isFalse);
    });

    test('a term-limited scope rejects terms outside it', () {
      const termScoped = PermissionScope(
        permissions: {Permission.subjectMarksEnter},
        subjectId: 'maths',
        academicYearId: '2026',
        termIds: {'t2'},
      );
      expect(termScoped.covers(termId: 't2'), isTrue);
      expect(termScoped.covers(termId: 't3'), isFalse);
    });

    test('an unconstrained dimension does not narrow the scope', () {
      const wholeClass = PermissionScope(
        permissions: {Permission.subjectMarksEnter},
        subjectId: 'maths',
        classId: 'g10',
        academicYearId: '2026',
      );
      // No streamId on the scope means every stream of the class is in range.
      expect(wholeClass.covers(subjectId: 'maths', classId: 'g10', streamId: 'b'),
          isTrue);
    });
  });

  group('active responsibility context', () {
    ActiveResponsibilityContext contextFor(StaffRoleAssignment a) =>
        ActiveResponsibilityContext.fromAssignment(a, termId: 't2', termName: 'Term 2');

    test('grants a held permission inside its own scope', () {
      final ctx = contextFor(
        _assignment(permissions: {Permission.subjectMarksEnter}),
      );
      expect(
        ctx.can(Permission.subjectMarksEnter, subjectId: 'maths', classId: 'g10'),
        isTrue,
      );
    });

    test('refuses a permission it was never granted', () {
      final ctx = contextFor(_assignment(permissions: {Permission.subjectMarksView}));
      expect(ctx.can(Permission.subjectMarksEnter), isFalse);
    });

    test('refuses a held permission outside its scope', () {
      // The teacher may enter marks - but only for Maths in Grade 10A. This
      // is the check a "user is a teacher" test can never make.
      final ctx = contextFor(
        _assignment(permissions: {Permission.subjectMarksEnter}),
      );
      expect(
        ctx.can(Permission.subjectMarksEnter, subjectId: 'maths', classId: 'g11'),
        isFalse,
      );
    });

    test('refuses everything once the assignment is suspended', () {
      final ctx = contextFor(_assignment(
        permissions: {Permission.subjectMarksEnter},
        status: AssignmentStatus.suspended,
      ));
      expect(ctx.can(Permission.subjectMarksEnter, subjectId: 'maths'), isFalse);
    });

    test('carries the term through from the calendar', () {
      final ctx = contextFor(_assignment());
      expect(ctx.termId, 't2');
      expect(ctx.academicYearId, '2026');
    });
  });

  group('switcher labels', () {
    test('a subject assignment reads as subject then class', () {
      expect(_assignment().displayLabel, 'Mathematics - Grade 10 A');
    });

    test('a class teacher assignment is labelled by responsibility', () {
      expect(
        _assignment(roleType: StaffResponsibilityType.classTeacher).displayLabel,
        'Class Teacher - Grade 10 A',
      );
    });
  });
}
