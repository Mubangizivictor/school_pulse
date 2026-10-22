import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_communication_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_announcement.dart';
import 'package:school_pulse/features/teacher/domain/entities/offline_operation.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_student_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/class_teacher_assignment_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements ClassTeacherRemoteDataSource {}

class _MockLocal extends Mock implements ClassTeacherLocalDataSource {}

class _MockQueue extends Mock implements SubjectTeacherLocalDataSource {}

class _MockStudentRepo extends Mock implements ClassStudentRepository {}

class _MockAssignment extends Mock implements ClassTeacherAssignmentService {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _FakeAnnouncement extends Fake implements ClassAnnouncement {}

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
        Permission.classAnnouncementCreate,
        Permission.classAnnouncementPublish,
        Permission.classParentMessage,
      },
      classId: 'p7',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

ClassAnnouncement _announcement({String id = 'a1'}) {
  return ClassAnnouncement(
    id: id,
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    title: 'Field trip',
    body: 'Bring a hat.',
    createdAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'ct1',
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockQueue queue;
  late _MockStudentRepo studentRepository;
  late _MockAssignment assignmentService;
  late _MockAudit audit;
  late _MockNetwork network;
  late ClassCommunicationRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeAnnouncement());
    registerFallbackValue(_FakeOperation());
    registerFallbackValue(_FakeContext());
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    queue = _MockQueue();
    studentRepository = _MockStudentRepo();
    assignmentService = _MockAssignment();
    audit = _MockAudit();
    network = _MockNetwork();
    repository = ClassCommunicationRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      queueDataSource: queue,
      studentRepository: studentRepository,
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
    when(() => local.saveAnnouncementLocal(any())).thenAnswer((_) async {});
    when(() => queue.enqueueOperation(any())).thenAnswer((_) async {});
  });

  test('getAnnouncements reads the local cache while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(
      () => local.getAnnouncements(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
      ),
    ).thenAnswer((_) async => [_announcement()]);

    final result = await repository.getAnnouncements(context: _context());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected cached announcements'), (list) {
      expect(list, hasLength(1));
    });
    verifyNever(
      () => remote.getAnnouncements(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
        streamId: any(named: 'streamId'),
      ),
    );
  });

  test(
    'saveAnnouncement writes to Isar and queues the write while offline',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.saveAnnouncement(
        context: _context(),
        announcement: _announcement(id: ''),
      );

      expect(result.isRight(), isTrue);
      verify(() => local.saveAnnouncementLocal(any())).called(1);
      verify(() => queue.enqueueOperation(any())).called(1);
      verifyNever(() => remote.saveAnnouncement(any()));
    },
  );
}
