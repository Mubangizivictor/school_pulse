import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/policies/lesson_start_policy.dart';

final _scheduledStart = DateTime(2026, 6, 1, 10, 0);

Lesson _lesson({
  String teacherStaffId = 'staff1',
  String? substituteStaffId,
  String subjectId = 'maths',
  String classId = 'g10a',
  LessonStatus status = LessonStatus.scheduled,
  DateTime? actualStart,
}) {
  return Lesson(
    id: 'l1',
    schoolId: 'school1',
    academicYearId: '2026',
    termId: 't2',
    subjectId: subjectId,
    subjectName: 'Mathematics',
    classId: classId,
    className: 'Grade 10',
    teacherStaffId: teacherStaffId,
    substituteStaffId: substituteStaffId,
    scheduledStart: _scheduledStart,
    scheduledEnd: _scheduledStart.add(const Duration(minutes: 45)),
    status: status,
    actualStart: actualStart,
  );
}

ActiveResponsibilityContext _context({
  String staffId = 'staff1',
  Set<String> permissions = const {Permission.subjectLessonStart},
  String subjectId = 'maths',
  String classId = 'g10a',
}) {
  return ActiveResponsibilityContext(
    schoolId: 'school1',
    academicYearId: '2026',
    termId: 't2',
    staffId: staffId,
    userId: 'user1',
    roleAssignmentId: 'a1',
    roleType: StaffResponsibilityType.subjectTeacher,
    subjectId: subjectId,
    classId: classId,
    permissionScope: PermissionScope(
      permissions: permissions,
      subjectId: subjectId,
      classId: classId,
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

void main() {
  const policy = LessonStartPolicy();
  final onTime = _scheduledStart.add(const Duration(minutes: 2));

  test('the assigned teacher may start their own lesson on time', () {
    expect(
      policy.evaluate(lesson: _lesson(), context: _context(), now: onTime),
      isNull,
    );
  });

  test('another teacher may not start it, even holding the same subject', () {
    // Same subject, same class, correct permission - but the timetable named
    // somebody else.
    final refusal = policy.evaluate(
      lesson: _lesson(teacherStaffId: 'staff2'),
      context: _context(staffId: 'staff1'),
      now: onTime,
    );
    expect(refusal, LessonStartRefusal.notYourLesson);
  });

  test('an approved substitute may start the lesson they are covering', () {
    expect(
      policy.evaluate(
        lesson: _lesson(teacherStaffId: 'staff2', substituteStaffId: 'staff1'),
        context: _context(staffId: 'staff1'),
        now: onTime,
      ),
      isNull,
    );
  });

  test('refuses without the start-lesson permission', () {
    expect(
      policy.evaluate(
        lesson: _lesson(),
        context: _context(permissions: const {Permission.subjectLessonView}),
        now: onTime,
      ),
      LessonStartRefusal.noPermission,
    );
  });

  test('refuses a lesson outside the responsibility currently in effect', () {
    // The teacher owns this lesson, but is acting as the ICT teacher right
    // now - they have to switch back before starting a Maths period.
    expect(
      policy.evaluate(
        lesson: _lesson(subjectId: 'maths'),
        context: _context(subjectId: 'ict'),
        now: onTime,
      ),
      LessonStartRefusal.outsideAssignmentScope,
    );
  });

  test('refuses a second session for a lesson already under way', () {
    expect(
      policy.evaluate(
        lesson: _lesson(status: LessonStatus.ongoing),
        context: _context(),
        now: onTime,
      ),
      LessonStartRefusal.alreadyStarted,
    );
  });

  test('refuses to reopen a lesson that already recorded a start time', () {
    expect(
      policy.evaluate(
        lesson: _lesson(actualStart: _scheduledStart),
        context: _context(),
        now: onTime,
      ),
      LessonStartRefusal.alreadyStarted,
    );
  });

  test('refuses a completed lesson', () {
    expect(
      policy.evaluate(
        lesson: _lesson(status: LessonStatus.completed),
        context: _context(),
        now: onTime,
      ),
      LessonStartRefusal.alreadyFinished,
    );
  });

  test('refuses a cancelled lesson', () {
    expect(
      policy.evaluate(
        lesson: _lesson(status: LessonStatus.cancelled),
        context: _context(),
        now: onTime,
      ),
      LessonStartRefusal.cancelled,
    );
  });

  group('start window', () {
    test('allows opening shortly before the bell', () {
      expect(
        policy.evaluate(
          lesson: _lesson(),
          context: _context(),
          now: _scheduledStart.subtract(const Duration(minutes: 10)),
        ),
        isNull,
      );
    });

    test('refuses opening the night before', () {
      expect(
        policy.evaluate(
          lesson: _lesson(),
          context: _context(),
          now: _scheduledStart.subtract(const Duration(hours: 12)),
        ),
        LessonStartRefusal.tooEarly,
      );
    });

    test('refuses opening long after the period ended', () {
      // A register stamped at 20:00 for a 10:00 lesson is not a register.
      expect(
        policy.evaluate(
          lesson: _lesson(),
          context: _context(),
          now: _scheduledStart.add(const Duration(hours: 10)),
        ),
        LessonStartRefusal.tooLate,
      );
    });

    test('honours a school-configured window', () {
      const generous = LessonStartPolicy(
        window: LessonStartWindow(early: Duration(hours: 1), late: Duration(hours: 6)),
      );
      expect(
        generous.evaluate(
          lesson: _lesson(),
          context: _context(),
          now: _scheduledStart.subtract(const Duration(minutes: 45)),
        ),
        isNull,
      );
    });
  });

  test('a substituted lesson is startable by the cover teacher', () {
    expect(
      policy.evaluate(
        lesson: _lesson(
          teacherStaffId: 'staff2',
          substituteStaffId: 'staff1',
          status: LessonStatus.substituted,
        ),
        context: _context(staffId: 'staff1'),
        now: onTime,
      ),
      isNull,
    );
  });
}
