import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/admin/data/datasources/staff_attendance_queue_data_source.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/admin/domain/services/staff_attendance_queue_replay.dart';

class _MockRepository extends Mock implements StaffAttendanceRepository {}

void main() {
  late _MockRepository repository;
  late StaffAttendanceQueueReplay replay;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = _MockRepository();
    replay = StaffAttendanceQueueReplay(repository: repository);
    when(
      () => repository.clockIn(
        schoolId: any(named: 'schoolId'),
        staffId: any(named: 'staffId'),
        day: any(named: 'day'),
        location: any(named: 'location'),
        operationId: any(named: 'operationId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => repository.correct(
        schoolId: any(named: 'schoolId'),
        staffId: any(named: 'staffId'),
        day: any(named: 'day'),
        reason: any(named: 'reason'),
        patch: any(named: 'patch'),
        operationId: any(named: 'operationId'),
      ),
    ).thenAnswer((_) async {});
  });

  test(
    'replays a clockIn item with its idempotencyKey as operationId',
    () async {
      final item = StaffAttendanceQueueItem(
        idempotencyKey: 'key-1',
        institutionId: 'school-a',
        actorId: 'admin-1',
        createdAt: DateTime(2026, 9, 1),
        actionType: StaffAttendanceQueueActionType.clockIn,
        payloadJson: jsonEncode({
          'staffId': 'staff-1',
          'day': DateTime(2026, 9, 1).toIso8601String(),
          'location': 'Main Gate',
        }),
      );

      await replay.replay(item);

      verify(
        () => repository.clockIn(
          schoolId: 'school-a',
          staffId: 'staff-1',
          day: DateTime(2026, 9, 1),
          location: 'Main Gate',
          operationId: 'key-1',
        ),
      ).called(1);
    },
  );

  test(
    'replays a correction item with its idempotencyKey as operationId',
    () async {
      final item = StaffAttendanceQueueItem(
        idempotencyKey: 'key-2',
        institutionId: 'school-a',
        actorId: 'admin-1',
        createdAt: DateTime(2026, 9, 1),
        actionType: StaffAttendanceQueueActionType.correction,
        payloadJson: jsonEncode({
          'staffId': 'staff-1',
          'day': DateTime(2026, 9, 1).toIso8601String(),
          'reason': 'Forgot to clock out',
          'patch': {'status': 'late'},
        }),
      );

      await replay.replay(item);

      verify(
        () => repository.correct(
          schoolId: 'school-a',
          staffId: 'staff-1',
          day: DateTime(2026, 9, 1),
          reason: 'Forgot to clock out',
          patch: {'status': 'late'},
          operationId: 'key-2',
        ),
      ).called(1);
    },
  );
}
