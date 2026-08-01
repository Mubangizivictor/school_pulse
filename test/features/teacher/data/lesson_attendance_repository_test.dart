import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/models/subject_teacher_isar_models.dart';
import 'package:school_pulse/features/teacher/data/repositories/lesson_attendance_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_enrollment.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements SubjectTeacherRemoteDataSource {}

class _MockLocal extends Mock implements SubjectTeacherLocalDataSource {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDeviceId extends Mock implements DeviceIdService {}

class _FakeAttendanceIsar extends Fake implements LessonAttendanceIsar {}

class _FakeOperationIsar extends Fake
    implements SubjectTeacherOfflineOperationIsar {}

ActiveResponsibilityContext _context({
  Set<String> permissions = const {
    Permission.subjectAttendanceTake,
    Permission.subjectAttendanceEdit,
  },
}) {
  return ActiveResponsibilityContext(
    schoolId: 'school1',
    academicYearId: '2026',
    termId: 't2',
    staffId: 'staff1',
    userId: 'user1',
    roleAssignmentId: 'a1',
    roleType: StaffResponsibilityType.subjectTeacher,
    subjectId: 'maths',
    classId: 'g10a',
    permissionScope: PermissionScope(
      permissions: permissions,
      subjectId: 'maths',
      classId: 'g10a',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

final _lesson = Lesson(
  id: 'l1',
  schoolId: 'school1',
  academicYearId: '2026',
  termId: 't2',
  subjectId: 'maths',
  classId: 'g10a',
  teacherStaffId: 'staff1',
  scheduledStart: DateTime(2026, 6, 1, 10),
  scheduledEnd: DateTime(2026, 6, 1, 10, 45),
);

SubjectStudentSummary _student(String id) =>
    SubjectStudentSummary(studentId: id, name: 'Student $id');

LessonAttendance _register({
  List<LessonAttendanceEntry> entries = const [],
  AttendanceRegisterStatus status = AttendanceRegisterStatus.draft,
}) {
  return LessonAttendance(
    id: 'att1',
    schoolId: 'school1',
    lessonId: 'l1',
    academicYearId: '2026',
    termId: 't2',
    subjectId: 'maths',
    classId: 'g10a',
    staffId: 'staff1',
    roleAssignmentId: 'a1',
    entries: entries,
    status: status,
    updatedAt: DateTime(2026, 6, 1, 10),
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockAudit audit;
  late _MockNetwork network;
  late _MockDeviceId deviceId;
  late LessonAttendanceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_context());
    registerFallbackValue(_register());
    registerFallbackValue(_FakeAttendanceIsar());
    registerFallbackValue(_FakeOperationIsar());
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    audit = _MockAudit();
    network = _MockNetwork();
    deviceId = _MockDeviceId();
    repository = LessonAttendanceRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      auditService: audit,
      networkInfo: network,
      deviceIdService: deviceId,
    );

    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => deviceId.getDeviceId()).thenAnswer((_) async => 'device1');
    when(() => local.saveAttendance(any())).thenAnswer((_) async {});
    when(() => local.enqueueOperation(any())).thenAnswer((_) async {});
    when(() => remote.saveLessonAttendance(any())).thenAnswer((_) async {});
    when(() => audit.record(
          context: any(named: 'context'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          previousValue: any(named: 'previousValue'),
          newValue: any(named: 'newValue'),
          reason: any(named: 'reason'),
          offlineOperationId: any(named: 'offlineOperationId'),
        )).thenAnswer((_) async {});
  });

  group('opening the register', () {
    test('seeds a row per enrolled student and nobody else', () async {
      when(() => local.getAttendance(any())).thenAnswer((_) async => null);
      when(() => remote.getLessonAttendance(
            schoolId: any(named: 'schoolId'),
            lessonId: any(named: 'lessonId'),
          )).thenAnswer((_) async => null);

      final result = await repository.openRegister(
        context: _context(),
        lesson: _lesson,
        enrolledStudents: [_student('s1'), _student('s2')],
      );

      final register = result.getOrElse(() => _register());
      expect(register.entries.map((e) => e.studentId), ['s1', 's2']);
      expect(register.unmarkedCount, 2);
    });

    test('prefers the device draft over the server copy', () async {
      // Marks taken offline must not be thrown away by a re-open.
      final localDraft = _register(entries: [
        const LessonAttendanceEntry(
          studentId: 's1',
          status: LessonAttendanceStatus.present,
        ),
      ]);
      when(() => local.getAttendance(any()))
          .thenAnswer((_) async => LessonAttendanceIsar.fromEntity(localDraft));

      final result = await repository.openRegister(
        context: _context(),
        lesson: _lesson,
        enrolledStudents: [_student('s1')],
      );

      expect(
        result.getOrElse(() => _register()).entryFor('s1')?.status,
        LessonAttendanceStatus.present,
      );
      verifyNever(() => remote.getLessonAttendance(
            schoolId: any(named: 'schoolId'),
            lessonId: any(named: 'lessonId'),
          ));
    });

    test('adds a row for a student enrolled after the draft was started',
        () async {
      final localDraft = _register(entries: [
        const LessonAttendanceEntry(
          studentId: 's1',
          status: LessonAttendanceStatus.present,
        ),
      ]);
      when(() => local.getAttendance(any()))
          .thenAnswer((_) async => LessonAttendanceIsar.fromEntity(localDraft));

      final result = await repository.openRegister(
        context: _context(),
        lesson: _lesson,
        enrolledStudents: [_student('s1'), _student('s2')],
      );

      final register = result.getOrElse(() => _register());
      expect(register.entries, hasLength(2));
      expect(register.entryFor('s1')?.status, LessonAttendanceStatus.present);
      expect(register.entryFor('s2')?.status, LessonAttendanceStatus.notMarked);
    });

    test('refuses a lesson belonging to another teacher', () async {
      final othersLesson = Lesson(
        id: 'l2',
        schoolId: 'school1',
        academicYearId: '2026',
        subjectId: 'maths',
        classId: 'g10a',
        teacherStaffId: 'staff2',
        scheduledStart: DateTime(2026, 6, 1, 10),
        scheduledEnd: DateTime(2026, 6, 1, 10, 45),
      );

      final result = await repository.openRegister(
        context: _context(),
        lesson: othersLesson,
        enrolledStudents: [_student('s1')],
      );

      expect(result.isLeft(), isTrue);
    });

    test('refuses without the take-attendance permission', () async {
      final result = await repository.openRegister(
        context: _context(permissions: const {Permission.subjectLessonView}),
        lesson: _lesson,
        enrolledStudents: [_student('s1')],
      );

      result.fold(
        (f) => expect(f, isA<PermissionDeniedFailure>()),
        (_) => fail('should not open the register'),
      );
    });
  });

  group('saving a draft', () {
    test('writes to the device before touching the network', () async {
      await repository.saveDraft(context: _context(), attendance: _register());
      verify(() => local.saveAttendance(any())).called(1);
    });

    test('queues the draft when offline instead of losing it', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.saveDraft(
        context: _context(),
        attendance: _register(entries: [
          const LessonAttendanceEntry(
            studentId: 's1',
            status: LessonAttendanceStatus.present,
          ),
        ]),
      );

      expect(result.isRight(), isTrue);
      verify(() => local.enqueueOperation(any())).called(1);
      verifyNever(() => remote.saveLessonAttendance(any()));
    });

    test('keeps the register when the network write throws', () async {
      when(() => remote.saveLessonAttendance(any()))
          .thenThrow(Exception('connection reset'));

      final result = await repository.saveDraft(
        context: _context(),
        attendance: _register(),
      );

      // The teacher's marks are not lost to a flaky connection.
      expect(result.isRight(), isTrue);
      verify(() => local.enqueueOperation(any())).called(1);
    });

    test('refuses to overwrite a submitted register', () async {
      final result = await repository.saveDraft(
        context: _context(),
        attendance: _register(status: AttendanceRegisterStatus.submitted),
      );

      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('a submitted register is not a draft'),
      );
    });
  });

  group('submitting', () {
    test('refuses while any student is unmarked', () async {
      final result = await repository.submit(
        context: _context(),
        attendance: _register(entries: [
          const LessonAttendanceEntry(
            studentId: 's1',
            status: LessonAttendanceStatus.present,
          ),
          const LessonAttendanceEntry(studentId: 's2'),
        ]),
      );

      // Submitting with gaps would record an absence nobody marked.
      result.fold(
        (f) => expect(f.message, contains('1 student(s) are still unmarked')),
        (_) => fail('an incomplete register should not submit'),
      );
      verifyNever(() => remote.saveLessonAttendance(any()));
    });

    test('submits a complete register and audits it', () async {
      final result = await repository.submit(
        context: _context(),
        attendance: _register(entries: [
          const LessonAttendanceEntry(
            studentId: 's1',
            status: LessonAttendanceStatus.present,
          ),
          const LessonAttendanceEntry(
            studentId: 's2',
            status: LessonAttendanceStatus.absent,
          ),
        ]),
      );

      final submitted = result.getOrElse(() => _register());
      expect(submitted.status, AttendanceRegisterStatus.submitted);
      expect(submitted.presentCount, 1);
      expect(submitted.absentCount, 1);
      verify(() => remote.saveLessonAttendance(any())).called(1);
    });

    test('counts a late arrival as present', () async {
      final result = await repository.submit(
        context: _context(),
        attendance: _register(entries: [
          const LessonAttendanceEntry(
            studentId: 's1',
            status: LessonAttendanceStatus.late,
          ),
        ]),
      );

      expect(result.getOrElse(() => _register()).presentCount, 1);
    });

    test('queues an offline submission rather than blocking it', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.submit(
        context: _context(),
        attendance: _register(entries: [
          const LessonAttendanceEntry(
            studentId: 's1',
            status: LessonAttendanceStatus.present,
          ),
        ]),
      );

      expect(result.getOrElse(() => _register()).status,
          AttendanceRegisterStatus.submitted);
      verify(() => local.enqueueOperation(any())).called(1);
    });

    test('refuses a second submission', () async {
      final result = await repository.submit(
        context: _context(),
        attendance: _register(status: AttendanceRegisterStatus.submitted),
      );
      expect(result.isLeft(), isTrue);
    });

    test('refuses an empty register', () async {
      final result =
          await repository.submit(context: _context(), attendance: _register());
      result.fold(
        (f) => expect(f.message, contains('No students')),
        (_) => fail('an empty register should not submit'),
      );
    });
  });

  group('correcting a submitted register', () {
    final submitted = _register(
      status: AttendanceRegisterStatus.submitted,
      entries: [
        const LessonAttendanceEntry(
          studentId: 's1',
          status: LessonAttendanceStatus.absent,
        ),
      ],
    );

    test('requires a reason', () async {
      final result = await repository.correct(
        context: _context(),
        attendance: submitted,
        studentId: 's1',
        newStatus: LessonAttendanceStatus.present,
        reason: '  ',
      );

      result.fold(
        (f) => expect((f as ValidationFailure).field, 'reason'),
        (_) => fail('a correction needs a reason'),
      );
    });

    test('records both the old and the new mark', () async {
      await repository.correct(
        context: _context(),
        attendance: submitted,
        studentId: 's1',
        newStatus: LessonAttendanceStatus.present,
        reason: 'Arrived late, marked in error',
      );

      final captured = verify(() => audit.record(
            context: any(named: 'context'),
            action: any(named: 'action'),
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            previousValue: captureAny(named: 'previousValue'),
            newValue: captureAny(named: 'newValue'),
            reason: any(named: 'reason'),
            offlineOperationId: any(named: 'offlineOperationId'),
          )).captured;

      expect(captured[0], containsPair('status', 'absent'));
      expect(captured[1], containsPair('status', 'present'));
    });

    test('refuses without the edit permission', () async {
      final result = await repository.correct(
        context: _context(permissions: const {Permission.subjectAttendanceTake}),
        attendance: submitted,
        studentId: 's1',
        newStatus: LessonAttendanceStatus.present,
        reason: 'Marked in error',
      );

      expect(result.isLeft(), isTrue);
    });

    test('will not correct offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.correct(
        context: _context(),
        attendance: submitted,
        studentId: 's1',
        newStatus: LessonAttendanceStatus.present,
        reason: 'Marked in error',
      );

      // Replaying a correction against a register the office has since
      // changed is how history gets silently overwritten.
      result.fold(
        (f) => expect(f, isA<OfflineNotAllowedFailure>()),
        (_) => fail('corrections need connectivity'),
      );
    });

    test('needs the historical permission once the register is locked',
        () async {
      final result = await repository.correct(
        context: _context(),
        attendance: _register(
          status: AttendanceRegisterStatus.locked,
          entries: [
            const LessonAttendanceEntry(
              studentId: 's1',
              status: LessonAttendanceStatus.absent,
            ),
          ],
        ),
        studentId: 's1',
        newStatus: LessonAttendanceStatus.present,
        reason: 'Marked in error',
      );

      result.fold(
        (f) => expect(f.message, contains('locked')),
        (_) => fail('a locked register needs the academic office'),
      );
    });
  });
}
