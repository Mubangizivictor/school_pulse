import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/attendance_local_data_source.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/attendance_remote_data_source.dart';
import 'package:school_pulse/features/attendance_hub/data/models/attendance_record_model.dart';
import 'package:school_pulse/features/attendance_hub/data/repositories/attendance_repository_impl.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

class _MockAttendanceRemoteDataSource extends Mock
    implements AttendanceRemoteDataSource {}

class _MockAttendanceLocalDataSource extends Mock
    implements AttendanceLocalDataSource {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

class _MockStructureRepository extends Mock implements StructureRepository {}

class _MockStudentRepository extends Mock implements StudentRepository {}

class _MockGetStaffMembers extends Mock implements GetStaffMembers {}

void main() {
  late _MockAttendanceRemoteDataSource remote;
  late _MockAttendanceLocalDataSource local;
  late _MockNetworkInfo networkInfo;
  late AttendanceRepositoryImpl repository;

  final record = AttendanceRecord(
    id: '',
    schoolId: 'school-a',
    category: AttendanceCategory.students,
    scopeId: 'class-a',
    scopeName: 'P5 Red',
    date: DateTime(2026, 8, 16),
    personId: 'student-a',
    personName: 'Victor Mubangizi',
    status: AttendanceStatus.present,
    method: AttendanceMethod.nfc,
    markedBy: 'Teacher A',
    operatorId: 'staff-a',
    createdAt: DateTime(2026, 8, 16, 8, 4),
  );

  // Matches `record` above (personId student-a, classId class-a, active) so
  // _validateStudentPlacement - which markAttendance calls unconditionally on
  // every write - finds the record's student in the roster it expects.
  final rosterStudent = Student(
    id: 'student-a',
    schoolId: 'school-a',
    name: 'Victor Mubangizi',
    studentCode: 'S-A-0001',
    admissionNumber: 'A-0001',
    dateOfBirth: DateTime(2015, 1, 1),
    gender: Gender.male,
    classId: 'class-a',
    academicYearId: 'year-a',
    status: StudentStatus.active,
    level: EducationLevel.primary,
  );

  setUpAll(() {
    registerFallbackValue(
      AttendanceRecordModel.fromEntity(record).toFirestore(),
    );
    registerFallbackValue(record);
    registerFallbackValue(AttendanceRecordModel.fromEntity(record));
    registerFallbackValue(const Duration(days: 30));
  });

  setUp(() {
    remote = _MockAttendanceRemoteDataSource();
    local = _MockAttendanceLocalDataSource();
    networkInfo = _MockNetworkInfo();
    final studentRepository = _MockStudentRepository();
    // markAttendance always runs _validateStudentPlacement first, which
    // calls studentRepository.getAllStudents - without this stub, mocktail
    // returns null for the unstubbed call and every markAttendance test
    // fails with `type 'Null' is not a subtype of type
    // 'Future<Either<Failure, List<Student>>>'` before reaching the
    // behaviour actually under test.
    when(
      () => studentRepository.getAllStudents(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => Right([rosterStudent]));
    // Every syncPendingAttendance sweep evicts stale/blocked rows first and
    // marks a record syncing right before the push - stub both to no-ops by
    // default so existing tests that only assert on markSynced/push don't
    // also have to know about lifecycle bookkeeping they aren't testing.
    when(
      () => local.evictStale(retention: any(named: 'retention')),
    ).thenAnswer((_) async => 0);
    when(() => local.markSyncing(any())).thenAnswer((_) async {});
    when(
      () => local.markRetryableFailure(any(), error: any(named: 'error')),
    ).thenAnswer((_) async {});
    repository = AttendanceRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
      structureRepository: _MockStructureRepository(),
      studentRepository: studentRepository,
      getStaffMembers: _MockGetStaffMembers(),
    );
  });

  group('markAttendance - offline-first', () {
    test(
      'caches locally and does not touch the network while offline',
      () async {
        when(() => local.cacheIfAbsent(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as AttendanceRecord,
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.markAttendance(record);

        expect(result.isRight(), isTrue);
        final saved = result.getOrElse(() => throw StateError('expected'));
        expect(saved.syncStatus, AttendanceSyncStatus.pending);
        verifyNever(() => remote.markAttendance(any()));
      },
    );

    test('caches locally then pushes and marks synced while online', () async {
      when(() => local.cacheIfAbsent(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as AttendanceRecord,
      );
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.markAttendance(any()),
      ).thenAnswer((_) async => AttendanceRecordModel.fromEntity(record));
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      final result = await repository.markAttendance(record);

      expect(result.isRight(), isTrue);
      final saved = result.getOrElse(() => throw StateError('expected'));
      expect(saved.syncStatus, AttendanceSyncStatus.synced);
      verify(() => local.markSynced(any())).called(1);
    });

    test(
      'a duplicate already cached locally is rejected without any network call',
      () async {
        when(
          () => local.cacheIfAbsent(any()),
        ).thenThrow(LocalDuplicateAttendanceException(record));

        final result = await repository.markAttendance(record);

        expect(result.isLeft(), isTrue);
        final failure = result.fold((f) => f, (_) => null);
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).field, 'duplicate');
        verifyNever(() => networkInfo.isConnected);
        verifyNever(() => remote.markAttendance(any()));
      },
    );

    test(
      'a push failure leaves the record pending instead of surfacing an error',
      () async {
        when(() => local.cacheIfAbsent(any())).thenAnswer(
          (invocation) async =>
              (invocation.positionalArguments.first as AttendanceRecord)
                  .copyWith(syncStatus: AttendanceSyncStatus.pending),
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remote.markAttendance(any()),
        ).thenThrow(Exception('timeout'));

        final result = await repository.markAttendance(record);

        expect(result.isRight(), isTrue);
        final saved = result.getOrElse(() => throw StateError('expected'));
        expect(saved.syncStatus, AttendanceSyncStatus.pending);
        verifyNever(() => local.markSynced(any()));
      },
    );

    test(
      'a duplicate discovered only server-side (e.g. web, no local cache) is still rejected',
      () async {
        when(() => local.cacheIfAbsent(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as AttendanceRecord,
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remote.markAttendance(any()),
        ).thenThrow(DuplicateAttendanceException());

        final result = await repository.markAttendance(record);

        expect(result.isLeft(), isTrue);
        final failure = result.fold((f) => f, (_) => null);
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).field, 'duplicate');
      },
    );
  });

  group('syncPendingAttendance', () {
    test('does nothing while offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      await repository.syncPendingAttendance('school-a');

      verifyNever(() => local.getPending(any()));
    });

    test('pushes every pending record and marks each synced', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record, record.copyWith()]);
      when(
        () => remote.pushRecord(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      await repository.syncPendingAttendance('school-a');

      verify(() => remote.pushRecord(any(), any(), any())).called(2);
      verify(() => local.markSynced(any())).called(2);
    });

    test(
      'a push failure leaves that record pending for the next sweep',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => local.getPending('school-a'),
        ).thenAnswer((_) async => [record]);
        when(
          () => remote.pushRecord(any(), any(), any()),
        ).thenThrow(Exception('offline mid-sweep'));

        await repository.syncPendingAttendance('school-a');

        verifyNever(() => local.markSynced(any()));
      },
    );

    test('a fresh repository instance (simulating app restart) still finds '
        'and syncs records that were queued before the restart', () async {
      // The same Isar-backed local data source persists across restarts on
      // a real device - a brand-new AttendanceRepositoryImpl wired to it
      // (as happens when DI re-registers everything on next launch) must
      // still see and drain whatever was left pending, without any
      // in-memory state carried over from the previous repository
      // instance.
      final restartedRepository = AttendanceRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: networkInfo,
        structureRepository: _MockStructureRepository(),
        studentRepository: _MockStudentRepository(),
        getStaffMembers: _MockGetStaffMembers(),
      );
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      when(
        () => remote.pushRecord(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      await restartedRepository.syncPendingAttendance('school-a');

      verify(() => remote.pushRecord(any(), any(), any())).called(1);
      verify(() => local.markSynced(any())).called(1);
    });

    test('the same student marked present via QR then re-scanned via NFC in '
        'the same session produces one deterministic id, not two records - '
        'buildAttendanceRecordId never factors in method', () {
      final qrId = buildAttendanceRecordId(
        category: record.category,
        scopeId: record.scopeId,
        sessionType: 'daily',
        date: record.date,
        personId: record.personId,
      );
      final nfcId = buildAttendanceRecordId(
        category: record.category,
        scopeId: record.scopeId,
        sessionType: 'daily',
        date: record.date,
        personId: record.personId,
      );

      expect(qrId, equals(nfcId));
    });

    test(
      'a student already marked present via QR is rejected as a duplicate '
      'when the same person is then scanned via NFC in the same session',
      () async {
        final qrRecord = AttendanceRecord(
          id: record.id,
          schoolId: record.schoolId,
          category: record.category,
          scopeId: record.scopeId,
          scopeName: record.scopeName,
          date: record.date,
          personId: record.personId,
          personName: record.personName,
          status: record.status,
          method: AttendanceMethod.qr,
          markedBy: record.markedBy,
          operatorId: record.operatorId,
          createdAt: record.createdAt,
        );
        final nfcRecord = AttendanceRecord(
          id: record.id,
          schoolId: record.schoolId,
          category: record.category,
          scopeId: record.scopeId,
          scopeName: record.scopeName,
          date: record.date,
          personId: record.personId,
          personName: record.personName,
          status: record.status,
          method: AttendanceMethod.nfc,
          markedBy: record.markedBy,
          operatorId: record.operatorId,
          createdAt: record.createdAt,
        );

        when(() => local.cacheIfAbsent(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as AttendanceRecord,
        );
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        final firstResult = await repository.markAttendance(qrRecord);
        expect(firstResult.isRight(), isTrue);

        when(
          () => local.cacheIfAbsent(any()),
        ).thenThrow(LocalDuplicateAttendanceException(qrRecord));
        final secondResult = await repository.markAttendance(nfcRecord);

        expect(secondResult.isLeft(), isTrue);
        final failure = secondResult.fold((f) => f, (_) => null);
        expect((failure as ValidationFailure).field, 'duplicate');
      },
    );

    test('repeated sync sweeps are idempotent - a record already synced is not '
        'pushed again', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      // First sweep: one pending record.
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      when(
        () => remote.pushRecord(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});
      await repository.syncPendingAttendance('school-a');

      // Second sweep: getPending now returns nothing, mirroring
      // markSynced having flipped the row out of the pending filter -
      // the sweep must not re-push anything already accounted for.
      when(() => local.getPending('school-a')).thenAnswer((_) async => []);
      await repository.syncPendingAttendance('school-a');

      verify(() => remote.pushRecord(any(), any(), any())).called(1);
      verify(() => local.markSynced(any())).called(1);
    });
  });

  group('syncPendingAttendance - lifecycle (queued/syncing/completed/'
      'retryableFailure/permanentlyBlocked/evicted)', () {
    test('happy path: a pending record is marked syncing, then synced '
        '(completed) - never left silently in an ambiguous state', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      when(
        () => remote.pushRecord(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      await repository.syncPendingAttendance('school-a');

      verify(() => local.markSyncing(any())).called(1);
      verify(() => local.markSynced(any())).called(1);
      verifyNever(
        () => local.markRetryableFailure(any(), error: any(named: 'error')),
      );
      verifyNever(
        () =>
            local.markPermanentlyBlocked(any(), reason: any(named: 'reason')),
      );
    });

    test('a transient network failure marks the record retryableFailure and '
        'still retries on the next sweep - never blocked', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      when(
        () => remote.pushRecord(any(), any(), any()),
      ).thenThrow(Exception('SocketException: Network is unreachable'));

      await repository.syncPendingAttendance('school-a');

      verify(
        () => local.markRetryableFailure(any(), error: any(named: 'error')),
      ).called(1);
      verifyNever(
        () =>
            local.markPermanentlyBlocked(any(), reason: any(named: 'reason')),
      );
      verifyNever(() => local.markSynced(any()));
    });

    test('a permission-denied FirebaseException (access revoked) marks the '
        'record permanentlyBlocked, not retryableFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      when(() => remote.pushRecord(any(), any(), any())).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
      );

      await repository.syncPendingAttendance('school-a');

      verify(
        () =>
            local.markPermanentlyBlocked(any(), reason: any(named: 'reason')),
      ).called(1);
      verifyNever(
        () => local.markRetryableFailure(any(), error: any(named: 'error')),
      );
      verifyNever(() => local.markSynced(any()));
    });

    test('a not-found FirebaseException (target learner/scope removed) also '
        'marks the record permanentlyBlocked - a gone target is not '
        'retryable', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      when(() => remote.pushRecord(any(), any(), any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'not-found'),
      );

      await repository.syncPendingAttendance('school-a');

      verify(
        () =>
            local.markPermanentlyBlocked(any(), reason: any(named: 'reason')),
      ).called(1);
    });

    test('a record older than the retention window is permanently blocked '
        'as stale instead of being pushed - never retried forever', () async {
      final staleRecord = record.copyWith().let(
        (r) => AttendanceRecord(
          id: r.id,
          schoolId: r.schoolId,
          category: r.category,
          scopeId: r.scopeId,
          scopeName: r.scopeName,
          sessionType: r.sessionType,
          date: r.date,
          personId: r.personId,
          personName: r.personName,
          status: r.status,
          method: r.method,
          markedBy: r.markedBy,
          operatorId: r.operatorId,
          deviceId: r.deviceId,
          syncStatus: r.syncStatus,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      );
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [staleRecord]);
      when(
        () =>
            local.markPermanentlyBlocked(any(), reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      await repository.syncPendingAttendance('school-a');

      verify(
        () =>
            local.markPermanentlyBlocked(any(), reason: any(named: 'reason')),
      ).called(1);
      verifyNever(() => remote.pushRecord(any(), any(), any()));
    });

    test('every sweep evicts stale completed/blocked rows past the '
        'retention window, even while offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      await repository.syncPendingAttendance('school-a');

      verify(
        () => local.evictStale(retention: const Duration(days: 30)),
      ).called(1);
    });

    test('logout clears the entire local attendance queue via '
        'clearLocalQueue, regardless of school or user', () async {
      when(() => local.clearAll()).thenAnswer((_) async {});

      await repository.clearLocalQueue();

      verify(() => local.clearAll()).called(1);
    });

    test('an account switch on the same device (a second clearLocalQueue '
        'call, e.g. teacher B signing in after teacher A signed out) also '
        'wipes any residue rather than assuming it is already empty', () async {
      when(() => local.clearAll()).thenAnswer((_) async {});

      await repository.clearLocalQueue();
      await repository.clearLocalQueue();

      verify(() => local.clearAll()).called(2);
    });

    test('a retried push after a transient failure uses the same '
        'deterministic recordId, so a retry can never create a duplicate '
        'server-side document', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => local.getPending('school-a'),
      ).thenAnswer((_) async => [record]);
      final pushedIds = <String>[];
      when(() => remote.pushRecord(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        pushedIds.add(invocation.positionalArguments[1] as String);
      });
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      await repository.syncPendingAttendance('school-a');
      await repository.syncPendingAttendance('school-a');

      expect(pushedIds.length, 2);
      expect(pushedIds.toSet().length, 1, reason: 'same idempotent recordId');
    });
  });
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
