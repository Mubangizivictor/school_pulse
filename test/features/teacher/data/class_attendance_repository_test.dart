import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_attendance_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/services/class_teacher_assignment_service_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_attendance.dart';
import 'package:school_pulse/features/teacher/domain/entities/offline_operation.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements ClassTeacherRemoteDataSource {}

class _MockLocal extends Mock implements ClassTeacherLocalDataSource {}

class _MockQueue extends Mock implements SubjectTeacherLocalDataSource {}

class _MockStructure extends Mock implements StructureRepository {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDeviceId extends Mock implements DeviceIdService {}

class _MockAssignmentRepo extends Mock implements StaffAssignmentRepository {}

class _MockResponsibility extends Mock implements ActiveResponsibilityService {}

ActiveResponsibilityContext _context({
  Set<String> permissions = const {
    Permission.classAttendanceTake,
    Permission.classAttendanceView,
    Permission.classAttendanceEdit,
  },
}) {
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
    permissionScope: PermissionScope(
      permissions: permissions,
      classId: 'p7',
      academicYearId: '2026',
    ),
    assignmentStartDate: DateTime(2026, 1, 1),
  );
}

ClassAttendanceSession _session({
  ClassAttendanceSessionStatus status = ClassAttendanceSessionStatus.draft,
  List<ClassAttendanceEntry> entries = const [],
  DateTime? submittedAt,
}) {
  return ClassAttendanceSession(
    id: 'p7_all_daily_2026-06-15',
    schoolId: 'school1',
    classId: 'p7',
    className: 'Primary 7',
    academicYearId: '2026',
    termId: '2026-t2',
    date: DateTime(2026, 6, 15),
    status: status,
    entries: entries,
    submittedAt: submittedAt,
    roleAssignmentId: 'ct1',
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockQueue queue;
  late _MockStructure structure;
  late _MockAudit audit;
  late _MockNetwork network;
  late _MockDeviceId deviceId;
  late _MockAssignmentRepo assignmentRepo;
  late _MockResponsibility responsibility;
  late ClassAttendanceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_session());
    registerFallbackValue(_context());
    registerFallbackValue(
      OfflineOperation(
        operationId: 'op1',
        entityType: OfflineOperationType.classAttendanceDraft,
        entityId: 'e1',
        action: 'a',
        createdAt: DateTime(2026, 6, 15),
        schoolId: 'school1',
        userId: 'user1',
        roleAssignmentId: 'ct1',
      ),
    );
    registerFallbackValue(
      AttendanceCorrectionRequest(
        id: 'x',
        schoolId: 'school1',
        sessionId: 's',
        classId: 'p7',
        academicYearId: '2026',
        studentId: 's1',
        previousStatusCode: 'present',
        requestedStatusCode: 'absent',
        reason: 'reason',
        requestedByUserId: 'user1',
        requestedAt: DateTime(2026, 6, 15),
      ),
    );
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    queue = _MockQueue();
    structure = _MockStructure();
    audit = _MockAudit();
    network = _MockNetwork();
    deviceId = _MockDeviceId();
    assignmentRepo = _MockAssignmentRepo();
    responsibility = _MockResponsibility();

    repository = ClassAttendanceRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      queueDataSource: queue,
      structureRepository: structure,
      assignmentService: ClassTeacherAssignmentServiceImpl(
        assignmentRepository: assignmentRepo,
        responsibilityService: responsibility,
      ),
      auditService: audit,
      networkInfo: network,
      deviceIdService: deviceId,
    );

    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => deviceId.getDeviceId()).thenAnswer((_) async => 'device1');
    when(() => local.saveAttendanceDraft(any())).thenAnswer((_) async {});
    when(() => local.getAttendanceDraft(any())).thenAnswer((_) async => null);
    when(() => remote.saveAttendanceSession(any())).thenAnswer((_) async {});
    when(() => queue.enqueueOperation(any())).thenAnswer((_) async {});
    when(
      () => audit.record(
        context: any(named: 'context'),
        action: any(named: 'action'),
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        previousValue: any(named: 'previousValue'),
        newValue: any(named: 'newValue'),
        reason: any(named: 'reason'),
        offlineOperationId: any(named: 'offlineOperationId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => responsibility.revalidate(),
    ).thenAnswer((_) async => Right(_context()));
  });

  group('status options', () {
    test('come from the school configuration', () async {
      when(() => structure.watchAttendanceTypes(any())).thenAnswer(
        (_) => Stream.value(const [
          AttendanceTypeDef(
            id: 'present',
            schoolId: 'school1',
            name: 'Present',
          ),
          AttendanceTypeDef(
            id: 'sickbay',
            schoolId: 'school1',
            name: 'Sick Bay',
          ),
        ]),
      );

      final result = await repository.getStatusOptions(context: _context());
      final options = result.getOrElse(() => const []);

      expect(options.map((o) => o.code), ['present', 'sickbay']);
      // Classified from the name, since the config carries no such flag.
      expect(
        options.last.classification,
        AttendanceClassification.authorisedAbsence,
      );
    });

    test(
      'fall back to the shared defaults when the config read fails',
      () async {
        when(
          () => structure.watchAttendanceTypes(any()),
        ).thenAnswer((_) => Stream.error(Exception('offline')));

        final result = await repository.getStatusOptions(context: _context());

        // A register with no buttons would be worse than an opinionated one.
        expect(result.getOrElse(() => const []), hasLength(6));
      },
    );
  });

  group('submitting', () {
    test('is refused while any student is unmarked', () async {
      final result = await repository.submit(
        context: _context(),
        session: _session(
          entries: [
            const ClassAttendanceEntry(studentId: 's1', statusCode: 'present'),
          ],
        ),
        rosterStudentIds: const ['s1', 's2'],
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => remote.saveAttendanceSession(any()));
    });

    test(
      're-verifies the assignment against the server before writing',
      () async {
        // An admin revoked the assignment while the register was open.
        when(
          () => responsibility.revalidate(),
        ).thenAnswer((_) async => const Left(AssignmentInvalidFailure()));

        final result = await repository.submit(
          context: _context(),
          session: _session(
            entries: [
              const ClassAttendanceEntry(
                studentId: 's1',
                statusCode: 'present',
              ),
            ],
          ),
          rosterStudentIds: const ['s1'],
        );

        expect(result.isLeft(), isTrue);
        verifyNever(() => remote.saveAttendanceSession(any()));
      },
    );

    test(
      'stamps the submission time rather than trusting the caller',
      () async {
        final result = await repository.submit(
          context: _context(),
          session: _session(
            entries: [
              const ClassAttendanceEntry(
                studentId: 's1',
                statusCode: 'present',
              ),
            ],
          ),
          rosterStudentIds: const ['s1'],
        );

        final submitted = result.getOrElse(() => _session());
        expect(submitted.status, ClassAttendanceSessionStatus.submitted);
        expect(submitted.submittedAt, isNotNull);
        expect(submitted.submittedBy, 'user1');
      },
    );

    test('audits the submission', () async {
      await repository.submit(
        context: _context(),
        session: _session(
          entries: [
            const ClassAttendanceEntry(studentId: 's1', statusCode: 'present'),
          ],
        ),
        rosterStudentIds: const ['s1'],
      );

      verify(
        () => audit.record(
          context: any(named: 'context'),
          action: 'attendance.submitted',
          entityType: 'class_attendance_session',
          entityId: any(named: 'entityId'),
          previousValue: any(named: 'previousValue'),
          newValue: any(named: 'newValue'),
          reason: any(named: 'reason'),
          offlineOperationId: any(named: 'offlineOperationId'),
        ),
      ).called(1);
    });

    test('queues the register when offline instead of losing it', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.submit(
        context: _context(),
        session: _session(
          entries: [
            const ClassAttendanceEntry(studentId: 's1', statusCode: 'present'),
          ],
        ),
        rosterStudentIds: const ['s1'],
      );

      expect(result.isRight(), isTrue);
      verify(() => queue.enqueueOperation(any())).called(1);
      verifyNever(() => remote.saveAttendanceSession(any()));
    });

    test('writes the register locally before attempting the network', () async {
      await repository.submit(
        context: _context(),
        session: _session(
          entries: [
            const ClassAttendanceEntry(studentId: 's1', statusCode: 'present'),
          ],
        ),
        rosterStudentIds: const ['s1'],
      );

      // Survives the app being killed between the last tap and finding signal.
      verify(() => local.saveAttendanceDraft(any())).called(1);
    });
  });

  group('correcting a submitted register', () {
    test('records both the previous and the new value', () async {
      final session = _session(
        status: ClassAttendanceSessionStatus.submitted,
        submittedAt: DateTime.now(),
        entries: [
          const ClassAttendanceEntry(studentId: 's1', statusCode: 'absent'),
        ],
      );

      await repository.correct(
        context: _context(),
        session: session,
        studentId: 's1',
        newStatusCode: 'present',
        reason: 'Arrived late, marked in error',
      );

      final captured = verify(
        () => audit.record(
          context: any(named: 'context'),
          action: 'attendance.edited',
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          previousValue: captureAny(named: 'previousValue'),
          newValue: captureAny(named: 'newValue'),
          reason: any(named: 'reason'),
          offlineOperationId: any(named: 'offlineOperationId'),
        ),
      ).captured;

      expect((captured[0] as Map)['status'], 'absent');
      expect((captured[1] as Map)['status'], 'present');
    });

    test('is refused without the edit permission', () async {
      final context = _context(
        permissions: const {
          Permission.classAttendanceTake,
          Permission.classAttendanceView,
        },
      );
      when(
        () => responsibility.revalidate(),
      ).thenAnswer((_) async => Right(context));

      final result = await repository.correct(
        context: context,
        session: _session(
          status: ClassAttendanceSessionStatus.submitted,
          submittedAt: DateTime.now(),
        ),
        studentId: 's1',
        newStatusCode: 'present',
        reason: 'Arrived late, marked in error',
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => remote.saveAttendanceSession(any()));
    });

    test('cannot be queued offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.correct(
        context: _context(),
        session: _session(
          status: ClassAttendanceSessionStatus.submitted,
          submittedAt: DateTime.now(),
        ),
        studentId: 's1',
        newStatusCode: 'present',
        reason: 'Arrived late, marked in error',
      );

      // Replaying a correction days later would overwrite whatever the
      // academic office decided in the meantime.
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<OfflineNotAllowedFailure>()),
        (_) => fail('expected a refusal'),
      );
      verifyNever(() => queue.enqueueOperation(any()));
    });
  });

  group('correction requests', () {
    test('are refused without a substantive reason', () async {
      final result = await repository.requestCorrection(
        context: _context(),
        session: _session(status: ClassAttendanceSessionStatus.submitted),
        studentId: 's1',
        requestedStatusCode: 'present',
        reason: 'no',
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => remote.createCorrectionRequest(any()));
    });

    test('are sent as pending for the academic office to decide', () async {
      when(
        () => remote.createCorrectionRequest(any()),
      ).thenAnswer((_) async {});

      final result = await repository.requestCorrection(
        context: _context(),
        session: _session(status: ClassAttendanceSessionStatus.submitted),
        studentId: 's1',
        requestedStatusCode: 'present',
        reason: 'Arrived late, marked in error',
      );

      expect(result.isRight(), isTrue);
      final captured = verify(
        () => remote.createCorrectionRequest(captureAny()),
      ).captured;
      expect(
        (captured.single as AttendanceCorrectionRequest).status,
        'pending',
      );
    });

    test('need a connection', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.requestCorrection(
        context: _context(),
        session: _session(status: ClassAttendanceSessionStatus.submitted),
        studentId: 's1',
        requestedStatusCode: 'present',
        reason: 'Arrived late, marked in error',
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('offline queueing', () {
    test('class registers use their own operation type', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      await repository.submit(
        context: _context(),
        session: _session(
          entries: [
            const ClassAttendanceEntry(studentId: 's1', statusCode: 'present'),
          ],
        ),
        rosterStudentIds: const ['s1'],
      );

      final captured = verify(
        () => queue.enqueueOperation(captureAny()),
      ).captured;
      // A class roll call and a subject lesson register are different records
      // and must not replay into each other.
      expect(
        (captured.single as dynamic).entityType,
        OfflineOperationType.classAttendanceSubmit,
      );
    });

    test('the class register types are creatable offline', () {
      expect(
        OfflineOperationType.offlineCreatable,
        containsAll([
          OfflineOperationType.classAttendanceDraft,
          OfflineOperationType.classAttendanceSubmit,
        ]),
      );
    });

    test('corrections are deliberately not creatable offline', () {
      expect(
        OfflineOperationType.offlineCreatable,
        isNot(contains(OfflineOperationType.classAttendanceCorrection)),
      );
    });
  });

  group('scope enforcement', () {
    test('a register for another class is refused', () async {
      final result = await repository.saveDraft(
        context: _context(),
        session: ClassAttendanceSession(
          id: 'p6_all_daily_2026-06-15',
          schoolId: 'school1',
          classId: 'p6',
          academicYearId: '2026',
          date: DateTime(2026, 6, 15),
        ),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => remote.saveAttendanceSession(any()));
    });
  });
}
