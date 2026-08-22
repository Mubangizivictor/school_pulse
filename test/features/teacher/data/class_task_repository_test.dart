import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_task_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_task.dart';
import 'package:school_pulse/features/teacher/domain/entities/offline_operation.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements ClassTeacherRemoteDataSource {}

class _MockLocal extends Mock implements ClassTeacherLocalDataSource {}

class _MockQueue extends Mock implements SubjectTeacherLocalDataSource {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _FakeTask extends Fake implements ClassTask {}

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
      permissions: {},
      classId: 'p7',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

ClassTask _task({String id = 'task1', String ownerUserId = 'user1'}) {
  return ClassTask(
    id: id,
    schoolId: 'school1',
    academicYearId: '2026',
    title: 'Mark CA scripts',
    dueAt: DateTime(2026, 6, 10),
    ownerUserId: ownerUserId,
    createdAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'ct1',
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockQueue queue;
  late _MockAudit audit;
  late _MockNetwork network;
  late ClassTaskRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeTask());
    registerFallbackValue(_FakeOperation());
    registerFallbackValue(_FakeContext());
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    queue = _MockQueue();
    audit = _MockAudit();
    network = _MockNetwork();
    repository = ClassTaskRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      queueDataSource: queue,
      auditService: audit,
      networkInfo: network,
      uuid: null,
    );

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
    when(() => local.saveTaskLocal(any())).thenAnswer((_) async {});
    when(() => local.deleteTaskLocal(any())).thenAnswer((_) async {});
    when(() => queue.enqueueOperation(any())).thenAnswer((_) async {});
  });

  test('getTasks reads the local cache while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(
      () => local.getTasks(
        schoolId: any(named: 'schoolId'),
        ownerUserId: any(named: 'ownerUserId'),
      ),
    ).thenAnswer((_) async => [_task()]);

    final result = await repository.getTasks(context: _context());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected cached tasks'), (tasks) {
      expect(tasks, hasLength(1));
    });
    verifyNever(
      () => remote.getTasks(
        schoolId: any(named: 'schoolId'),
        ownerUserId: any(named: 'ownerUserId'),
      ),
    );
  });

  test('getTasks caches the remote result once online', () async {
    when(() => network.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.getTasks(
        schoolId: any(named: 'schoolId'),
        ownerUserId: any(named: 'ownerUserId'),
      ),
    ).thenAnswer((_) async => [_task()]);
    when(
      () => local.cacheTasks(
        any(),
        schoolId: any(named: 'schoolId'),
        ownerUserId: any(named: 'ownerUserId'),
      ),
    ).thenAnswer((_) async {});

    final result = await repository.getTasks(context: _context());

    expect(result.isRight(), isTrue);
    verify(
      () => local.cacheTasks(any(), schoolId: 'school1', ownerUserId: 'user1'),
    ).called(1);
  });

  test('saveTask writes to Isar and queues the write while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    final result = await repository.saveTask(
      context: _context(),
      task: _task(id: ''),
    );

    expect(result.isRight(), isTrue);
    verify(() => local.saveTaskLocal(any())).called(1);
    verify(() => queue.enqueueOperation(any())).called(1);
    verifyNever(() => remote.saveTask(any()));
  });

  test('deleteTask removes the local row and queues while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);

    final result = await repository.deleteTask(
      context: _context(),
      task: _task(),
    );

    expect(result.isRight(), isTrue);
    verify(() => local.deleteTaskLocal('task1')).called(1);
    verify(() => queue.enqueueOperation(any())).called(1);
    verifyNever(
      () => remote.deleteTask(
        schoolId: any(named: 'schoolId'),
        taskId: any(named: 'taskId'),
      ),
    );
  });
}
