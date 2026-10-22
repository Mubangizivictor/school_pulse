import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_performance_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_performance.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_attendance_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_student_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_work_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/class_teacher_assignment_service.dart';

class _MockRemote extends Mock implements ClassTeacherRemoteDataSource {}

class _MockLocal extends Mock implements ClassTeacherLocalDataSource {}

class _MockStudentRepo extends Mock implements ClassStudentRepository {}

class _MockAttendanceRepo extends Mock implements ClassAttendanceRepository {}

class _MockWorkRepo extends Mock implements ClassWorkRepository {}

class _MockAssignment extends Mock implements ClassTeacherAssignmentService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _FakeContext extends Fake implements ActiveResponsibilityContext {}

class _FakeSummary extends Fake implements ClassPerformanceSummary {}

ActiveResponsibilityContext _context() {
  return ActiveResponsibilityContext(
    schoolId: 'school1',
    campusId: 'main',
    academicYearId: '2026',
    termId: '2026-t2',
    staffId: 'staff1',
    userId: 'user1',
    roleAssignmentId: 'ct1',
    roleType: StaffResponsibilityType.classTeacher,
    classId: 'p7',
    className: 'Primary 7',
    permissionScope: const PermissionScope(
      permissions: {Permission.classPerformanceView},
      classId: 'p7',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockStudentRepo studentRepository;
  late _MockAttendanceRepo attendanceRepository;
  late _MockWorkRepo workRepository;
  late _MockAssignment assignmentService;
  late _MockNetwork network;
  late ClassPerformanceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeContext());
    registerFallbackValue(_FakeSummary());
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    studentRepository = _MockStudentRepo();
    attendanceRepository = _MockAttendanceRepo();
    workRepository = _MockWorkRepo();
    assignmentService = _MockAssignment();
    network = _MockNetwork();
    repository = ClassPerformanceRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      studentRepository: studentRepository,
      attendanceRepository: attendanceRepository,
      workRepository: workRepository,
      assignmentService: assignmentService,
      networkInfo: network,
    );

    when(
      () => assignmentService.authorize(
        any(),
        permission: any(named: 'permission'),
      ),
    ).thenAnswer((invocation) => Right(invocation.positionalArguments.first));
  });

  test('getPerformance reads the local cache while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    const summary = ClassPerformanceSummary(
      students: [StudentPerformanceSummary(studentId: 's1')],
    );
    when(
      () => local.getPerformance(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
        termId: any(named: 'termId'),
        streamId: any(named: 'streamId'),
      ),
    ).thenAnswer((_) async => summary);

    final result = await repository.getPerformance(context: _context());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected cached summary'), (s) {
      expect(s.students, hasLength(1));
    });
    verifyNever(
      () => remote.getApprovedClassMarks(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
        termId: any(named: 'termId'),
        streamId: any(named: 'streamId'),
      ),
    );
  });

  test(
    'getPerformance returns a failure while offline with no cache',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(
        () => local.getPerformance(
          schoolId: any(named: 'schoolId'),
          classId: any(named: 'classId'),
          academicYearId: any(named: 'academicYearId'),
          termId: any(named: 'termId'),
          streamId: any(named: 'streamId'),
        ),
      ).thenAnswer((_) async => null);

      final result = await repository.getPerformance(context: _context());

      expect(result.isLeft(), isTrue);
    },
  );

  test('getPerformance caches the computed summary once online', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => studentRepository.getClassStudents(context: any(named: 'context')),
    ).thenAnswer(
      (_) async => const Right([
        ClassStudentSummary(
          studentId: 's1',
          schoolId: 'school1',
          name: 'Jane Doe',
          classId: 'p7',
          academicYearId: '2026',
        ),
      ]),
    );
    when(
      () => remote.getApprovedClassMarks(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
        termId: any(named: 'termId'),
        streamId: any(named: 'streamId'),
      ),
    ).thenAnswer((_) async => const []);
    when(
      () => workRepository.getBehaviourRecords(context: any(named: 'context')),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => attendanceRepository.getHistory(
        context: any(named: 'context'),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => local.cachePerformance(
        any(),
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
        termId: any(named: 'termId'),
        streamId: any(named: 'streamId'),
      ),
    ).thenAnswer((_) async {});

    final result = await repository.getPerformance(context: _context());

    expect(result.isRight(), isTrue);
    verify(
      () => local.cachePerformance(
        any(),
        schoolId: 'school1',
        classId: 'p7',
        academicYearId: '2026',
        termId: '2026-t2',
        streamId: any(named: 'streamId'),
      ),
    ).called(1);
  });
}
