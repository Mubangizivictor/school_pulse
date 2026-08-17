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

  Future<List<AttendanceRecord>> getPending(String schoolId);

  Future<void> markSynced(String recordId);

  Stream<List<AttendanceRecord>> watchRecords({
    required String schoolId,
    required String scopeId,
    required DateTime date,
    required String sessionType,
  });
}
