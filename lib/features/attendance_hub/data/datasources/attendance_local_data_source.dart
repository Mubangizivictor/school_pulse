import '../../domain/entities/attendance_record.dart';

/// Thrown when a record already exists locally for this
/// (category, scope, session, date, person) - the same identity
/// `buildAttendanceRecordId` gives the Firestore doc, checked here first so
/// a duplicate tap is caught even while fully offline.
class LocalDuplicateAttendanceException implements Exception {
  final AttendanceRecord existing;
  LocalDuplicateAttendanceException(this.existing);
}

abstract class AttendanceLocalDataSource {
  /// Caches [record] if no record with the same deterministic id already
  /// exists locally. Throws [LocalDuplicateAttendanceException] otherwise.
  Future<AttendanceRecord> cacheIfAbsent(AttendanceRecord record);

  /// Every record still eligible for a sync attempt: `pending`/`queued`, or
  /// `retryableFailure`/`failed` whose backoff window has elapsed. Excludes
  /// `permanentlyBlocked`/`evicted` items - those are never retried.
  Future<List<AttendanceRecord>> getPending(String schoolId);

  Future<void> markSynced(String recordId);

  /// Marks [recordId] as actively being pushed - set immediately before the
  /// network call so a crash mid-push leaves a visibly-in-flight row rather
  /// than a silently-stuck `pending` one.
  Future<void> markSyncing(String recordId);

  /// A transient failure (network/timeout/5xx-equivalent): increments
  /// [AttendanceRecord.retryCount], records [error], and schedules the next
  /// attempt via [nextRetryAt] using the same backoff shape as
  /// `OfflineOperation.backoffFor`.
  Future<void> markRetryableFailure(String recordId, {required String error});

  /// A terminal failure that must never be retried again: access revoked,
  /// the learner/school changed or was removed, the acting user changed, the
  /// item went stale past the retention threshold, or the server returned a
  /// permanent (403-equivalent) rejection. [reason] is shown to the user -
  /// the UI must never render a blocked item as a success.
  Future<void> markPermanentlyBlocked(String recordId, {required String reason});

  /// Removes every `completed`/`synced` record past the retention window and
  /// every `permanentlyBlocked` record, regardless of age - a blocked item
  /// has nothing further to wait for locally once its status has been
  /// surfaced. Returns the number of rows evicted.
  Future<int> evictStale({required Duration retention});

  /// Clears every locally-cached attendance record and queue item for this
  /// device, regardless of school/user - called on logout and on account
  /// switch so the next person to sign in on this device can never see or
  /// resume a previous operator's queued marks.
  Future<void> clearAll();

  Stream<List<AttendanceRecord>> watchRecords({
    required String schoolId,
    required String scopeId,
    required DateTime date,
    required String sessionType,
  });
}
