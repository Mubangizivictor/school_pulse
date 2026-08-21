import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/services/subject_sync_service_impl.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_announcement.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_attendance.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_behaviour.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_homework.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_task.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/domain/entities/offline_operation.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';

class _MockRemote extends Mock implements SubjectTeacherRemoteDataSource {}

class _MockLocal extends Mock implements SubjectTeacherLocalDataSource {}

class _MockClassRemote extends Mock implements ClassTeacherRemoteDataSource {}

class _MockClassLocal extends Mock implements ClassTeacherLocalDataSource {}

class _MockAudit extends Mock implements SubjectAuditService {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _FakeAttendance extends Fake implements LessonAttendance {}

class _FakeClassAttendance extends Fake implements ClassAttendanceSession {}

class _FakeOperationIsar extends Fake implements OfflineOperation {}

class _FakeClassTask extends Fake implements ClassTask {}

class _FakeClassHomework extends Fake implements ClassHomework {}

class _FakeClassBehaviour extends Fake implements ClassBehaviourRecord {}

class _FakeClassAnnouncement extends Fake implements ClassAnnouncement {}

LessonAttendance _register({
  AttendanceRegisterStatus status = AttendanceRegisterStatus.submitted,
  DateTime? submittedAt,
}) {
  return LessonAttendance(
    id: 'att1',
    schoolId: 'school1',
    lessonId: 'l1',
    academicYearId: '2026',
    subjectId: 'maths',
    classId: 'g10a',
    staffId: 'staff1',
    roleAssignmentId: 'a1',
    entries: const [
      LessonAttendanceEntry(
        studentId: 's1',
        status: LessonAttendanceStatus.present,
      ),
    ],
    status: status,
    submittedAt: submittedAt,
    updatedAt: DateTime(2026, 6, 1, 10),
  );
}

OfflineOperation _queued({
  String type = OfflineOperationType.attendanceSubmit,
  String entityId = 'l1',
}) {
  return OfflineOperation(
    operationId: 'attendance_$entityId',
    entityType: type,
    entityId: entityId,
    action: type,
    createdAt: DateTime(2026, 6, 1, 10),
    schoolId: 'school1',
    userId: 'user1',
    roleAssignmentId: 'a1',
  );
}

ClassTask _task({ClassTaskStatus status = ClassTaskStatus.pending}) {
  return ClassTask(
    id: 'task1',
    schoolId: 'school1',
    academicYearId: '2026',
    title: 'Mark CA scripts',
    status: status,
    dueAt: DateTime(2026, 6, 5),
    ownerUserId: 'user1',
    createdAt: DateTime(2026, 6, 1, 10),
    roleAssignmentId: 'a1',
  );
}

ClassHomework _homework() {
  return ClassHomework(
    id: 'hw1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    title: 'Reading assignment',
    dueDate: DateTime(2026, 6, 20),
    createdAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'a1',
  );
}

ClassBehaviourRecord _behaviour() {
  return ClassBehaviourRecord(
    id: 'b1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    studentId: 's1',
    categoryCode: 'merit',
    recordedAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'a1',
  );
}

ClassAnnouncement _announcement() {
  return ClassAnnouncement(
    id: 'ann1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    title: 'Field trip',
    body: 'Bring a hat.',
    createdAt: DateTime(2026, 6, 1),
    roleAssignmentId: 'a1',
  );
}

ClassAttendanceSession _classSession({
  ClassAttendanceSessionStatus status = ClassAttendanceSessionStatus.draft,
}) {
  return ClassAttendanceSession(
    id: 'sess1',
    schoolId: 'school1',
    classId: 'g10a',
    academicYearId: '2026',
    date: DateTime(2026, 6, 1),
    status: status,
    roleAssignmentId: 'a1',
  );
}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockClassRemote classRemote;
  late _MockClassLocal classLocal;
  late _MockAudit audit;
  late _MockNetwork network;
  late SubjectSyncServiceImpl service;

  setUpAll(() {
    registerFallbackValue(_FakeAttendance());
    registerFallbackValue(_FakeClassAttendance());
    registerFallbackValue(_FakeOperationIsar());
    registerFallbackValue(_FakeClassTask());
    registerFallbackValue(_FakeClassHomework());
    registerFallbackValue(_FakeClassBehaviour());
    registerFallbackValue(_FakeClassAnnouncement());
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    classRemote = _MockClassRemote();
    classLocal = _MockClassLocal();
    audit = _MockAudit();
    network = _MockNetwork();
    service = SubjectSyncServiceImpl(
      remoteDataSource: remote,
      localDataSource: local,
      classRemoteDataSource: classRemote,
      classLocalDataSource: classLocal,
      auditService: audit,
      networkInfo: network,
    );

    when(() => network.isConnected).thenAnswer((_) async => true);
    when(() => audit.flushPending()).thenAnswer((_) async {});
    when(() => local.deleteOperation(any())).thenAnswer((_) async {});
    when(() => local.updateOperation(any())).thenAnswer((_) async {});
    when(() => remote.saveLessonAttendance(any())).thenAnswer((_) async {});
  });

  void queueContains(
    List<OfflineOperation> first, {
    List<OfflineOperation> then = const [],
  }) {
    var call = 0;
    when(
      () => local.getPendingOperations(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => call++ == 0 ? first : then);
  }

  test('does nothing but count while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(
      () => local.getPendingOperations(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => [_queued()]);

    final result = await service.drain();

    expect(result.remaining, 1);
    expect(result.synced, 0);
    verifyNever(() => remote.saveLessonAttendance(any()));
  });

  test('pushes a queued register and clears it from the queue', () async {
    queueContains([_queued()]);
    when(() => local.getAttendance('l1')).thenAnswer((_) async => _register());
    when(
      () => remote.getLessonAttendance(
        schoolId: any(named: 'schoolId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer((_) async => null);

    final result = await service.drain();

    expect(result.synced, 1);
    expect(result.isClean, isTrue);
    verify(() => remote.saveLessonAttendance(any())).called(1);
    verify(() => local.deleteOperation('attendance_l1')).called(1);
  });

  test(
    'reads the newest local register rather than a queued snapshot',
    () async {
      // The queue holds only the lesson id on purpose, so marks added after
      // the operation was queued still go up.
      queueContains([_queued()]);
      when(
        () => local.getAttendance('l1'),
      ).thenAnswer((_) async => _register());
      when(
        () => remote.getLessonAttendance(
          schoolId: any(named: 'schoolId'),
          lessonId: any(named: 'lessonId'),
        ),
      ).thenAnswer((_) async => null);

      await service.drain();

      verify(() => local.getAttendance('l1')).called(1);
    },
  );

  test('refuses to overwrite a register the office has locked', () async {
    queueContains([_queued()]);
    when(() => local.getAttendance('l1')).thenAnswer((_) async => _register());
    when(
      () => remote.getLessonAttendance(
        schoolId: any(named: 'schoolId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer(
      (_) async => _register(status: AttendanceRegisterStatus.locked),
    );

    final result = await service.drain();

    expect(result.conflicted, 1);
    verifyNever(() => remote.saveLessonAttendance(any()));
    // The work stays on the device for review rather than being dropped.
    verifyNever(() => local.deleteOperation(any()));
    verify(() => local.updateOperation(any())).called(1);
  });

  test('will not let an offline draft undo a submitted register', () async {
    queueContains([_queued(type: OfflineOperationType.attendanceDraft)]);
    when(() => local.getAttendance('l1')).thenAnswer(
      (_) async => _register(status: AttendanceRegisterStatus.draft),
    );
    when(
      () => remote.getLessonAttendance(
        schoolId: any(named: 'schoolId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer(
      (_) async => _register(status: AttendanceRegisterStatus.submitted),
    );

    final result = await service.drain();

    expect(result.conflicted, 1);
    verifyNever(() => remote.saveLessonAttendance(any()));
  });

  test('flags two devices submitting the same register', () async {
    queueContains([_queued()]);
    when(() => local.getAttendance('l1')).thenAnswer(
      (_) async => _register(submittedAt: DateTime(2026, 6, 1, 10, 5)),
    );
    when(
      () => remote.getLessonAttendance(
        schoolId: any(named: 'schoolId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer((_) async => _register(submittedAt: DateTime(2026, 6, 1, 11)));

    final result = await service.drain();

    expect(result.conflicted, 1);
  });

  test('drops an operation whose record is gone', () async {
    // The lesson was cancelled while the teacher was offline. Retrying
    // forever would be worse than dropping it.
    queueContains([_queued()]);
    when(() => local.getAttendance('l1')).thenAnswer((_) async => null);

    final result = await service.drain();

    expect(result.synced, 1);
    verify(() => local.deleteOperation('attendance_l1')).called(1);
  });

  test('keeps a failed operation queued and counts the retry', () async {
    queueContains([_queued()]);
    when(() => local.getAttendance('l1')).thenAnswer((_) async => _register());
    when(
      () => remote.getLessonAttendance(
        schoolId: any(named: 'schoolId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => remote.saveLessonAttendance(any()),
    ).thenThrow(Exception('connection reset'));

    final result = await service.drain();

    expect(result.failed, 1);
    verifyNever(() => local.deleteOperation(any()));
    verify(() => local.updateOperation(any())).called(1);
  });

  test('replays audit rows only after the actions they describe', () async {
    queueContains([_queued()]);
    when(() => local.getAttendance('l1')).thenAnswer((_) async => _register());
    when(
      () => remote.getLessonAttendance(
        schoolId: any(named: 'schoolId'),
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer((_) async => null);

    await service.drain();

    verifyInOrder([
      () => remote.saveLessonAttendance(any()),
      () => audit.flushPending(),
    ]);
  });

  test('discards an operation type nothing knows how to replay', () async {
    // Otherwise it sits in the queue forever pretending it will sync.
    queueContains([_queued(type: 'something.unknown')]);

    final result = await service.drain();

    expect(result.synced, 1);
    verify(() => local.deleteOperation(any())).called(1);
  });

  test(
    'replays a queued class register instead of silently discarding it',
    () async {
      // Regression test: classAttendanceDraft/Submit used to fall into the
      // "unknown type" default branch and get deleted from the queue without
      // ever reaching Firestore, silently losing a class teacher's offline
      // roll call.
      queueContains([
        _queued(
          type: OfflineOperationType.classAttendanceSubmit,
          entityId: 'sess1',
        ),
      ]);
      when(
        () => classLocal.getAttendanceDraft(
          'sess1',
          schoolId: any(named: 'schoolId'),
        ),
      ).thenAnswer((_) async => _classSession());
      when(
        () => classRemote.getAttendanceSession(
          schoolId: any(named: 'schoolId'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => classRemote.saveAttendanceSession(any()),
      ).thenAnswer((_) async {});

      final result = await service.drain();

      expect(result.synced, 1);
      verify(() => classRemote.saveAttendanceSession(any())).called(1);
      verify(() => local.deleteOperation('attendance_sess1')).called(1);
    },
  );

  test(
    'replays a queued task save instead of silently discarding it',
    () async {
      // Regression test for the same class of bug as the class-register
      // one above: classTaskSave/complete used to fall into the "unknown
      // type" default branch and get dropped from the queue without ever
      // reaching Firestore.
      queueContains([
        _queued(type: OfflineOperationType.classTaskSave, entityId: 'task1'),
      ]);
      when(() => classLocal.getTask('task1')).thenAnswer((_) async => _task());
      when(() => classRemote.saveTask(any())).thenAnswer((_) async {});

      final result = await service.drain();

      expect(result.synced, 1);
      verify(() => classRemote.saveTask(any())).called(1);
      verify(() => local.deleteOperation('attendance_task1')).called(1);
    },
  );

  test('drops a queued task save whose record is gone', () async {
    queueContains([
      _queued(type: OfflineOperationType.classTaskSave, entityId: 'task1'),
    ]);
    when(() => classLocal.getTask('task1')).thenAnswer((_) async => null);

    final result = await service.drain();

    expect(result.synced, 1);
    verifyNever(() => classRemote.saveTask(any()));
    verify(() => local.deleteOperation('attendance_task1')).called(1);
  });

  test(
    'replays a queued task delete against the remote store',
    () async {
      queueContains([
        _queued(
          type: OfflineOperationType.classTaskDelete,
          entityId: 'task1',
        ),
      ]);
      when(
        () => classRemote.deleteTask(
          schoolId: any(named: 'schoolId'),
          taskId: any(named: 'taskId'),
        ),
      ).thenAnswer((_) async {});

      final result = await service.drain();

      expect(result.synced, 1);
      verify(
        () => classRemote.deleteTask(schoolId: 'school1', taskId: 'task1'),
      ).called(1);
      verify(() => local.deleteOperation('attendance_task1')).called(1);
    },
  );

  test(
    'replays a queued homework save instead of silently discarding it',
    () async {
      queueContains([
        _queued(type: OfflineOperationType.classHomeworkSave, entityId: 'hw1'),
      ]);
      when(
        () => classLocal.getHomeworkItem('hw1'),
      ).thenAnswer((_) async => _homework());
      when(() => classRemote.saveHomework(any())).thenAnswer((_) async {});

      final result = await service.drain();

      expect(result.synced, 1);
      verify(() => classRemote.saveHomework(any())).called(1);
      verify(() => local.deleteOperation('attendance_hw1')).called(1);
    },
  );

  test('drops a queued homework save whose record is gone', () async {
    queueContains([
      _queued(type: OfflineOperationType.classHomeworkPublish, entityId: 'hw1'),
    ]);
    when(() => classLocal.getHomeworkItem('hw1')).thenAnswer((_) async => null);

    final result = await service.drain();

    expect(result.synced, 1);
    verifyNever(() => classRemote.saveHomework(any()));
    verify(() => local.deleteOperation('attendance_hw1')).called(1);
  });

  test(
    'replays a queued behaviour record instead of silently discarding it',
    () async {
      queueContains([
        _queued(type: OfflineOperationType.classBehaviourRecord, entityId: 'b1'),
      ]);
      when(
        () => classLocal.getBehaviourRecord('b1'),
      ).thenAnswer((_) async => _behaviour());
      when(
        () => classRemote.saveBehaviourRecord(any()),
      ).thenAnswer((_) async {});

      final result = await service.drain();

      expect(result.synced, 1);
      verify(() => classRemote.saveBehaviourRecord(any())).called(1);
      verify(() => local.deleteOperation('attendance_b1')).called(1);
    },
  );

  test(
    'replays a queued announcement save instead of silently discarding it',
    () async {
      queueContains([
        _queued(
          type: OfflineOperationType.classAnnouncementSave,
          entityId: 'ann1',
        ),
      ]);
      when(
        () => classLocal.getAnnouncement('ann1'),
      ).thenAnswer((_) async => _announcement());
      when(
        () => classRemote.saveAnnouncement(any()),
      ).thenAnswer((_) async {});

      final result = await service.drain();

      expect(result.synced, 1);
      verify(() => classRemote.saveAnnouncement(any())).called(1);
      verify(() => local.deleteOperation('attendance_ann1')).called(1);
    },
  );

  test(
    'refuses to overwrite a class register the office has locked',
    () async {
      queueContains([
        _queued(
          type: OfflineOperationType.classAttendanceDraft,
          entityId: 'sess1',
        ),
      ]);
      when(
        () => classLocal.getAttendanceDraft(
          'sess1',
          schoolId: any(named: 'schoolId'),
        ),
      ).thenAnswer((_) async => _classSession());
      when(
        () => classRemote.getAttendanceSession(
          schoolId: any(named: 'schoolId'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenAnswer(
        (_) async =>
            _classSession(status: ClassAttendanceSessionStatus.locked),
      );

      final result = await service.drain();

      expect(result.conflicted, 1);
      verifyNever(() => classRemote.saveAttendanceSession(any()));
    },
  );
}
