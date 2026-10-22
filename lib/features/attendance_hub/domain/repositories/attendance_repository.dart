import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/attendance_access_context.dart';
import '../entities/attendance_category.dart';
import '../entities/attendance_record.dart';
import '../entities/attendance_scope.dart';

abstract class AttendanceRepository {
  /// Scopes returned are restricted to [access] - a Class Teacher only gets
  /// their assigned classes back for `students`, never every class in the
  /// school. See AttendanceParticipantResolver for how [access] is built.
  Future<Either<Failure, List<AttendanceScope>>> getScopes(
    String schoolId,
    AttendanceCategory category,
    AttendanceAccessContext access,
  );

  /// Throws no exception and returns no roster for a scopeId [access] does
  /// not authorise - callers must not pass an unresolved/unchecked scopeId.
  Future<Either<Failure, List<AttendancePerson>>> getRoster(
    String schoolId,
    AttendanceCategory category,
    String scopeId,
    AttendanceAccessContext access,
  );

  /// Marks one person. Local-first: the record lands in the on-device
  /// queue before any network call, so a scan is never lost to a dropped
  /// connection - the returned record's `syncStatus` reflects whether the
  /// immediate push succeeded (`synced`) or is queued (`pending`). Returns
  /// a ValidationFailure with a 'duplicate' message if a record already
  /// exists for this exact session/person/day, checked locally first so
  /// duplicates are caught even fully offline.
  Future<Either<Failure, AttendanceRecord>> markAttendance(
    AttendanceRecord record,
  );

  Future<Either<Failure, List<AttendanceRecord>>> markBatch(
    List<AttendanceRecord> records,
  );

  /// Pushes every locally-queued (`syncStatus == pending`) record for
  /// [schoolId] that a connection is now available for. Safe to call
  /// repeatedly (e.g. from a periodic timer or on reconnect) - already
  /// synced rows are skipped and a push failure just leaves a row pending
  /// for the next sweep rather than raising an error.
  Future<void> syncPendingAttendance(String schoolId);

  /// Clears every locally-queued attendance record on this device,
  /// regardless of school/user - called on logout and on account switch so
  /// the next person to sign in on this device never sees or resumes a
  /// previous operator's queued marks. A no-op on platforms with no local
  /// cache (web).
  Future<void> clearLocalQueue();

  /// Records returned are restricted to [access] - a Class Teacher only
  /// sees Previous Attendance sessions for their assigned classes, never the
  /// whole school's history.
  Future<Either<Failure, List<AttendanceRecord>>> getRecords({
    required String schoolId,
    required AttendanceAccessContext access,
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  });
}
