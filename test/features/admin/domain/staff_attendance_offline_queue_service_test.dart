import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/admin/data/datasources/staff_attendance_queue_data_source.dart';
import 'package:school_pulse/features/admin/domain/services/staff_attendance_offline_queue_service.dart';

class _MockQueueDataSource extends Mock
    implements StaffAttendanceQueueDataSource {}

void main() {
  const institutionId = 'school-1';
  const actorId = 'admin-1';

  late _MockQueueDataSource dataSource;
  late StaffAttendanceOfflineQueueService service;

  StaffAttendanceQueueItem item(
    String key, {
    StaffAttendanceQueueStatus status = StaffAttendanceQueueStatus.pending,
  }) => StaffAttendanceQueueItem(
    idempotencyKey: key,
    institutionId: institutionId,
    actorId: actorId,
    createdAt: DateTime(2026, 1, 1),
    actionType: StaffAttendanceQueueActionType.clockIn,
    payloadJson: '{}',
    status: status,
  );

  setUpAll(() {
    registerFallbackValue(StaffAttendanceQueueActionType.clockIn);
  });

  setUp(() {
    dataSource = _MockQueueDataSource();
    service = StaffAttendanceOfflineQueueService(dataSource: dataSource);
    when(() => dataSource.markSyncing(any())).thenAnswer((_) async {});
    when(() => dataSource.markDone(any())).thenAnswer((_) async {});
    when(() => dataSource.markFailed(any(), any())).thenAnswer((_) async {});
  });

  test('enqueue generates a fresh idempotency key each call', () async {
    when(
      () => dataSource.enqueue(
        idempotencyKey: any(named: 'idempotencyKey'),
        institutionId: any(named: 'institutionId'),
        actorId: any(named: 'actorId'),
        actionType: any(named: 'actionType'),
        payloadJson: any(named: 'payloadJson'),
      ),
    ).thenAnswer((_) async {});

    final keyA = await service.enqueue(
      institutionId: institutionId,
      actorId: actorId,
      actionType: StaffAttendanceQueueActionType.clockIn,
      payloadJson: '{}',
    );
    final keyB = await service.enqueue(
      institutionId: institutionId,
      actorId: actorId,
      actionType: StaffAttendanceQueueActionType.clockIn,
      payloadJson: '{}',
    );

    expect(keyA, isNotEmpty);
    expect(keyB, isNotEmpty);
    expect(keyA, isNot(keyB));
  });

  test(
    'syncPending sends every pending item in order and marks each done',
    () async {
      when(
        () =>
            dataSource.pending(institutionId: institutionId, actorId: actorId),
      ).thenAnswer((_) async => [item('a'), item('b'), item('c')]);

      final sent = <String>[];
      await service.syncPending(
        institutionId: institutionId,
        actorId: actorId,
        send: (item) async => sent.add(item.idempotencyKey),
      );

      expect(sent, ['a', 'b', 'c']);
      verify(() => dataSource.markSyncing('a')).called(1);
      verify(() => dataSource.markSyncing('b')).called(1);
      verify(() => dataSource.markSyncing('c')).called(1);
      verify(() => dataSource.markDone('a')).called(1);
      verify(() => dataSource.markDone('b')).called(1);
      verify(() => dataSource.markDone('c')).called(1);
    },
  );

  test(
    'a failure stops the sweep - later items never jump ahead of it',
    () async {
      when(
        () =>
            dataSource.pending(institutionId: institutionId, actorId: actorId),
      ).thenAnswer((_) async => [item('a'), item('b'), item('c')]);

      final sent = <String>[];
      await service.syncPending(
        institutionId: institutionId,
        actorId: actorId,
        send: (item) async {
          sent.add(item.idempotencyKey);
          if (item.idempotencyKey == 'b') throw Exception('network down');
        },
      );

      expect(sent, ['a', 'b']);
      verify(() => dataSource.markDone('a')).called(1);
      verify(() => dataSource.markFailed('b', any())).called(1);
      verifyNever(() => dataSource.markSyncing('c'));
      verifyNever(() => dataSource.markDone('c'));
    },
  );

  test('an empty queue calls send zero times and touches no marks', () async {
    when(
      () => dataSource.pending(institutionId: institutionId, actorId: actorId),
    ).thenAnswer((_) async => const []);

    var sendCalls = 0;
    await service.syncPending(
      institutionId: institutionId,
      actorId: actorId,
      send: (_) async => sendCalls++,
    );

    expect(sendCalls, 0);
    verifyNever(() => dataSource.markSyncing(any()));
  });

  test('retryNow re-marks a failed item as syncing', () async {
    await service.retryNow('failed-key');
    verify(() => dataSource.markSyncing('failed-key')).called(1);
  });

  test('discard removes an item from the queue', () async {
    when(() => dataSource.discard(any())).thenAnswer((_) async {});
    await service.discard('stale-key');
    verify(() => dataSource.discard('stale-key')).called(1);
  });
}
