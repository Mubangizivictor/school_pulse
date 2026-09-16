import 'package:isar/isar.dart';

import 'package:school_pulse/features/admin/data/datasources/staff_attendance_queue_data_source.dart'
    show StaffAttendanceQueueActionType, StaffAttendanceQueueStatus;

part 'staff_attendance_queue_item_isar.g.dart';

/// One durable, offline-queued staff attendance action - mirrors
/// ExamFactoryQueueItemIsar's design.
///
/// [idempotencyKey] is generated once at enqueue time and passed unchanged
/// as `operationId` on every retry to `clockInStaff`/`correctStaffAttendance`,
/// so a flaky reconnect that retries a partially-acked write can never
/// duplicate a clock-in or correction server-side.
@collection
class StaffAttendanceQueueItemIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String idempotencyKey;

  @Index()
  late String institutionId;

  @Index()
  late String actorId;

  late DateTime createdAt;

  @enumerated
  late StaffAttendanceQueueActionType actionType;

  /// JSON payload for the target callable - a direct re-dispatch with no
  /// separate mapping layer at replay time.
  late String payloadJson;

  int retryCount = 0;

  @enumerated
  StaffAttendanceQueueStatus status = StaffAttendanceQueueStatus.pending;

  String? lastError;
}
