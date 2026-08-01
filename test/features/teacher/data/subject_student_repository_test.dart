import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/subject_student_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_enrollment.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements SubjectTeacherRemoteDataSource {}

class _MockLocal extends Mock implements SubjectTeacherLocalDataSource {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

ActiveResponsibilityContext _context({
  Set<String> permissions = const {
    Permission.subjectStudentsView,
    Permission.subjectStudentEnroll,
    Permission.subjectStudentRemove,
  },
  String subjectId = 'maths',
  String classId = 'g10a',
}) {
  return ActiveResponsibilityContext(
    schoolId: 'school1',
    academicYearId: '2026',
    termId: 't2',
    staffId: 'staff1',
    userId: 'user1',
    roleAssignmentId: 'a1',
    roleType: StaffResponsibilityType.subjectTeacher,
    subjectId: subjectId,
    subjectName: 'Mathematics',
    classId: classId,
    className: 'Grade 10',
    permissionScope: PermissionScope(
      permissions: permissions,
      subjectId: subjectId,
      classId: classId,
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

SubjectEnrollment _enrollment(
  String studentId, {
  SubjectEnrollmentStatus status = SubjectEnrollmentStatus.active,
  bool isMandatory = false,
}) {
  return SubjectEnrollment(
    id: '${studentId}_maths_2026',
    schoolId: 'school1',
    studentId: studentId,
    subjectId: 'maths',
    classId: 'g10a',
    academicYearId: '2026',
    status: status,
    isMandatory: isMandatory,
    enrolledAt: DateTime(2026, 1, 10),
  );
}

EligibleStudent _student(String id, String name) =>
    EligibleStudent(studentId: id, name: name, classId: 'g10a');

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockAudit audit;
  late _MockNetwork network;
  late SubjectStudentRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_context());
    registerFallbackValue(_enrollment('fallback'));
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    audit = _MockAudit();
    network = _MockNetwork();
    repository = SubjectStudentRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      auditService: audit,
      networkInfo: network,
    );

    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => local.cacheEnrollments(any())).thenAnswer((_) async {});
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

  group('subject student list', () {
    test('lists only the class members enrolled in this subject', () async {
      // Four students sit in Grade 10A; two of them take Mathematics.
      when(() => remote.getEnrollments(
            schoolId: any(named: 'schoolId'),
            subjectId: any(named: 'subjectId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async => [_enrollment('s1'), _enrollment('s3')]);
      when(() => remote.getClassRoster(
            schoolId: any(named: 'schoolId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async => [
            _student('s1', 'Amina'),
            _student('s2', 'Brian'),
            _student('s3', 'Chloe'),
            _student('s4', 'Daniel'),
          ]);

      final result = await repository.getSubjectStudents(context: _context());

      final students = result.getOrElse(() => []);
      expect(students.map((s) => s.studentId), ['s1', 's3']);
    });

    test('excludes students whose enrollment was removed', () async {
      when(() => remote.getEnrollments(
            schoolId: any(named: 'schoolId'),
            subjectId: any(named: 'subjectId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async => [
            _enrollment('s1'),
            _enrollment('s2', status: SubjectEnrollmentStatus.removed),
          ]);
      when(() => remote.getClassRoster(
            schoolId: any(named: 'schoolId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async =>
              [_student('s1', 'Amina'), _student('s2', 'Brian')]);

      final result = await repository.getSubjectStudents(context: _context());

      expect(result.getOrElse(() => []).map((s) => s.studentId), ['s1']);
    });

    test('refuses to list students without the view permission', () async {
      final result = await repository.getSubjectStudents(
        context: _context(permissions: const {}),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<PermissionDeniedFailure>()),
        (_) => fail('should not return students'),
      );
      verifyNever(() => remote.getEnrollments(
            schoolId: any(named: 'schoolId'),
            subjectId: any(named: 'subjectId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          ));
    });

    test('reads the cache when offline instead of failing', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(() => local.getEnrollments(
            schoolId: any(named: 'schoolId'),
            subjectId: any(named: 'subjectId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async => []);

      final result = await repository.getSubjectStudents(context: _context());

      expect(result.isRight(), isTrue);
      verify(() => local.getEnrollments(
            schoolId: any(named: 'schoolId'),
            subjectId: any(named: 'subjectId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).called(1);
    });
  });

  group('adding students to a subject', () {
    test('offers only class members who are not already enrolled', () async {
      when(() => remote.getClassRoster(
            schoolId: any(named: 'schoolId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async =>
              [_student('s1', 'Amina'), _student('s2', 'Brian')]);
      when(() => remote.getEnrollments(
            schoolId: any(named: 'schoolId'),
            subjectId: any(named: 'subjectId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            streamId: any(named: 'streamId'),
          )).thenAnswer((_) async => [_enrollment('s1')]);

      final result = await repository.getEligibleStudents(context: _context());

      expect(result.getOrElse(() => []).map((s) => s.studentId), ['s2']);
    });

    test('refuses without the enroll permission', () async {
      final result = await repository.getEligibleStudents(
        context: _context(permissions: const {Permission.subjectStudentsView}),
      );
      expect(result.isLeft(), isTrue);
    });

    test('will not enroll from a stale roster while offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.enrollStudents(
        context: _context(),
        studentIds: ['s2'],
      );

      result.fold(
        (f) => expect(f, isA<OfflineNotAllowedFailure>()),
        (_) => fail('offline enrollment should be refused'),
      );
    });

    test('writes an enrollment and an audit row per student', () async {
      when(() => remote.createEnrollments(any())).thenAnswer((_) async {});

      final result = await repository.enrollStudents(
        context: _context(),
        studentIds: ['s2', 's4'],
      );

      expect(result.isRight(), isTrue);
      verify(() => remote.createEnrollments(any())).called(1);
      verify(() => audit.record(
            context: any(named: 'context'),
            action: any(named: 'action'),
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            previousValue: any(named: 'previousValue'),
            newValue: any(named: 'newValue'),
            reason: any(named: 'reason'),
            offlineOperationId: any(named: 'offlineOperationId'),
          )).called(2);
    });
  });

  group('removing a student from a subject', () {
    setUp(() {
      when(() => remote.updateEnrollment(any())).thenAnswer((_) async {});
    });

    test('requires a reason', () async {
      final result = await repository.removeStudent(
        context: _context(),
        studentId: 's1',
        reason: '   ',
        requiresApproval: false,
      );

      result.fold(
        (f) => expect((f as ValidationFailure).field, 'reason'),
        (_) => fail('a blank reason should be refused'),
      );
    });

    test('will not let a teacher drop a mandatory subject outright', () async {
      when(() => remote.getEnrollmentsForStudent(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            academicYearId: any(named: 'academicYearId'),
          )).thenAnswer((_) async => [_enrollment('s1', isMandatory: true)]);

      final result = await repository.removeStudent(
        context: _context(),
        studentId: 's1',
        reason: 'Moved to another elective',
        requiresApproval: false,
      );

      result.fold(
        (f) => expect(f.message, contains('mandatory')),
        (_) => fail('a mandatory subject is not the teacher\'s to drop'),
      );
      verifyNever(() => remote.updateEnrollment(any()));
    });

    test('closes the enrollment rather than deleting the record', () async {
      when(() => remote.getEnrollmentsForStudent(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            academicYearId: any(named: 'academicYearId'),
          )).thenAnswer((_) async => [_enrollment('s1')]);

      final result = await repository.removeStudent(
        context: _context(),
        studentId: 's1',
        reason: 'Switched to Fine Art',
        requiresApproval: false,
      );

      expect(result.getOrElse(() => SubjectEnrollmentStatus.active),
          SubjectEnrollmentStatus.removed);

      // The row is updated, never deleted - the marks already recorded
      // against it have to survive.
      final captured = verify(() => remote.updateEnrollment(captureAny()))
          .captured
          .single as SubjectEnrollment;
      expect(captured.status, SubjectEnrollmentStatus.removed);
      expect(captured.effectiveTo, isNotNull);
      expect(captured.removalReason, 'Switched to Fine Art');
    });

    test('holds the enrollment open when approval is required', () async {
      when(() => remote.getEnrollmentsForStudent(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            academicYearId: any(named: 'academicYearId'),
          )).thenAnswer((_) async => [_enrollment('s1')]);

      final result = await repository.removeStudent(
        context: _context(),
        studentId: 's1',
        reason: 'Parent request',
        requiresApproval: true,
      );

      expect(result.getOrElse(() => SubjectEnrollmentStatus.active),
          SubjectEnrollmentStatus.pendingRemoval);

      final captured = verify(() => remote.updateEnrollment(captureAny()))
          .captured
          .single as SubjectEnrollment;
      // Still in force until somebody approves it.
      expect(captured.removedAt, isNull);
      expect(captured.effectiveTo, isNull);
    });
  });
}
