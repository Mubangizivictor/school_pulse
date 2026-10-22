import 'dart:convert';

import 'package:school_pulse/features/admin/data/datasources/staff_attendance_queue_data_source.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';

/// Deserializes one queued [StaffAttendanceQueueItem] and re-dispatches it
/// to the matching [StaffAttendanceRepository] method with its original
/// `operationId`, so the target callable's own idempotency guard
/// (deterministic doc id for clock-in, operationId-matched trail doc for
/// corrections) makes a retried replay a no-op rather than a duplicate.
/// Mirrors ExamFactoryQueueReplay.
class StaffAttendanceQueueReplay {
  final StaffAttendanceRepository repository;

  const StaffAttendanceQueueReplay({required this.repository});

  Future<void> replay(StaffAttendanceQueueItem item) async {
    final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
    final operationId = item.idempotencyKey;

    switch (item.actionType) {
      case StaffAttendanceQueueActionType.clockIn:
        await repository.clockIn(
          schoolId: item.institutionId,
          staffId: payload['staffId'] as String,
          day: DateTime.parse(payload['day'] as String),
          location: payload['location'] as String?,
          operationId: operationId,
        );
        return;

      case StaffAttendanceQueueActionType.correction:
        await repository.correct(
          schoolId: item.institutionId,
          staffId: payload['staffId'] as String,
          day: DateTime.parse(payload['day'] as String),
          reason: payload['reason'] as String,
          patch: (payload['patch'] as Map).cast<String, dynamic>(),
          operationId: operationId,
        );
        return;
    }
  }
}
