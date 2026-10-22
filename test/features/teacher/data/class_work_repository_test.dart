import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_work_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_behaviour.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_homework.dart';
import 'package:school_pulse/features/teacher/domain/entities/offline_operation.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/services/class_teacher_assignment_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements ClassTeacherRemoteDataSource {}

class _MockLocal extends Mock implements ClassTeacherLocalDataSource {}

class _MockQueue extends Mock implements SubjectTeacherLocalDataSource {}

class _MockAssignment extends Mock implements ClassTeacherAssignmentService {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _FakeHomework extends Fake implements ClassHomework {}

class _FakeBehaviour extends Fake implements ClassBehaviourRecord {}

class _FakeOperation extends Fake implements OfflineOperation {}

class _FakeContext extends Fake implements ActiveResponsibilityContext {}

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
      permissions: {
        Permission.classHomeworkCreate,
        Permission.classHomeworkEdit,
        Permission.classHomeworkPublish,
        Permission.classBehaviourView,
        Permission.classBehaviourRecord,
        Permission.classAchievementRecord,
      },
      classId: 'p7',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

ClassHomework _homework({String id = 'hw1'}) {
  return ClassHomework(
    id: id,
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    title: 'Reading assignment',
    dueDate: DateTime.now().add(const Duration(days: 14)),
    createdAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'ct1',
  );
}

ClassBehaviourRecord _record({String id = 'b1'}) {
  return ClassBehaviourRecord(
    id: id,
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    studentId: 's1',
    categoryCode: 'merit',
    note: 'Helped a classmate with their homework.',
    recordedAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'ct1',
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockQueue queue;
  late _MockAssignment assignmentService;
  late _MockAudit audit;
  late _MockNetwork network;
  late ClassWorkRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeHomework());
    registerFallbackValue(_FakeBehaviour());
    registerFallbackValue(_FakeOperation());
    registerFallbackValue(_FakeContext());
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    queue = _MockQueue();
    assignmentService = _MockAssignment();
    audit = _MockAudit();
    network = _MockNetwork();
    repository = ClassWorkRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      queueDataSource: queue,
      assignmentService: assignmentService,
      auditService: audit,
      networkInfo: network,
      uuid: null,
    );

    when(
      () => assignmentService.authorize(
        any(),
        permission: any(named: 'permission'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
      ),
    ).thenAnswer((invocation) => Right(invocation.positionalArguments.first));
    when(
      () => audit.record(
        context: any(named: 'context'),
        action: any(named: 'action'),
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        newValue: any(named: 'newValue'),
        previousValue: any(named: 'previousValue'),
      ),
    ).thenAnswer((_) async {});
    when(() => local.saveHomeworkLocal(any())).thenAnswer((_) async {});
    when(() => local.saveBehaviourRecordLocal(any())).thenAnswer((_) async {});
    when(() => queue.enqueueOperation(any())).thenAnswer((_) async {});
  });

  test('getHomework reads the local cache while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(
      () => local.getHomework(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
      ),
    ).thenAnswer((_) async => [_homework()]);

    final result = await repository.getHomework(context: _context());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected cached homework'), (list) {
      expect(list, hasLength(1));
    });
    verifyNever(
      () => remote.getHomework(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
        streamId: any(named: 'streamId'),
      ),
    );
  });

  test(
    'saveHomework writes to Isar and queues the write while offline',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.saveHomework(
        context: _context(),
        homework: _homework(id: ''),
      );

      expect(result.isRight(), isTrue);
      verify(() => local.saveHomeworkLocal(any())).called(1);
      verify(() => queue.enqueueOperation(any())).called(1);
      verifyNever(() => remote.saveHomework(any()));
    },
  );

  test('getBehaviourRecords reads the local cache while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(
      () => local.getBehaviourRecords(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
      ),
    ).thenAnswer((_) async => [_record()]);

    final result = await repository.getBehaviourRecords(context: _context());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected cached records'), (list) {
      expect(list, hasLength(1));
    });
  });

  test(
    'recordBehaviour writes to Isar and queues the write while offline',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(
        () => remote.getBehaviourCategories(schoolId: any(named: 'schoolId')),
      ).thenAnswer((_) async => const []);

      final result = await repository.recordBehaviour(
        context: _context(),
        record: _record(id: ''),
        rosterStudentIds: const ['s1'],
      );

      expect(result.isRight(), isTrue);
      verify(() => local.saveBehaviourRecordLocal(any())).called(1);
      verify(() => queue.enqueueOperation(any())).called(1);
      verifyNever(() => remote.saveBehaviourRecord(any()));
    },
  );
}
