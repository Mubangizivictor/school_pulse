import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_resource_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_resource_repository_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/services/class_teacher_assignment_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockLocal extends Mock implements ClassResourceLocalDataSource {}

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockAssignment extends Mock implements ClassTeacherAssignmentService {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _FakeResource extends Fake implements ClassResource {}

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

ClassResource _resource({String id = 'r1'}) {
  return ClassResource(
    id: id,
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    name: 'Notes.pdf',
    kind: ClassResourceKind.document,
    downloadUrl: 'https://example.com/notes.pdf',
    uploadedAt: DateTime(2026, 6, 1),
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockStorage storage;
  late _MockLocal local;
  late _MockAssignment assignmentService;
  late _MockAudit audit;
  late _MockNetwork network;
  late ClassResourceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeResource());
  });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    storage = _MockStorage();
    local = _MockLocal();
    assignmentService = _MockAssignment();
    audit = _MockAudit();
    network = _MockNetwork();
    repository = ClassResourceRepositoryImpl(
      firestore: firestore,
      storage: storage,
      localDataSource: local,
      assignmentService: assignmentService,
      auditService: audit,
      networkInfo: network,
    );

    when(
      () => assignmentService.authorize(
        any(),
        permission: any(named: 'permission'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
      ),
    ).thenAnswer((invocation) => Right(invocation.positionalArguments[0]));
    when(() => local.cacheResources(
      any(),
      schoolId: any(named: 'schoolId'),
      classId: any(named: 'classId'),
      academicYearId: any(named: 'academicYearId'),
    )).thenAnswer((_) async {});
    when(() => local.saveResourceLocal(any())).thenAnswer((_) async {});
  });

  test('getResources reads the local cache while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(
      () => local.getResources(
        schoolId: any(named: 'schoolId'),
        classId: any(named: 'classId'),
        academicYearId: any(named: 'academicYearId'),
      ),
    ).thenAnswer((_) async => [_resource()]);

    final result = await repository.getResources(context: _context());

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected cached resources'), (resources) {
      expect(resources, hasLength(1));
    });
  });

  test(
    'downloadForOffline refuses without a connection - nothing to fetch',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.downloadForOffline(
        context: _context(),
        resource: _resource(),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OfflineNotAllowedFailure>()),
        (_) => fail('expected a failure'),
      );
    },
  );

  test('isDownloaded reflects the local file path', () async {
    when(
      () => local.getLocalFilePath('r1'),
    ).thenAnswer((_) async => '/tmp/r1.pdf');

    expect(await repository.isDownloaded('r1'), isTrue);
  });

  test('removeDownload clears the on-device copy', () async {
    when(() => local.removeDownload('r1')).thenAnswer((_) async {});
    when(() => network.isConnected).thenAnswer((_) async => false);

    final result = await repository.removeDownload(
      context: _context(),
      resource: _resource(),
    );

    expect(result.isRight(), isTrue);
    verify(() => local.removeDownload('r1')).called(1);
  });
}
