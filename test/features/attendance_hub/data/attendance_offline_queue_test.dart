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

  setUpAll(() {
    registerFallbackValue(
      AttendanceRecordModel.fromEntity(record).toFirestore(),
    );
    registerFallbackValue(record);
    registerFallbackValue(AttendanceRecordModel.fromEntity(record));
  });

  setUp(() {
    remote = _MockAttendanceRemoteDataSource();
    local = _MockAttendanceLocalDataSource();
    networkInfo = _MockNetworkInfo();
    repository = AttendanceRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
      structureRepository: _MockStructureRepository(),
      studentRepository: _MockStudentRepository(),
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
}
