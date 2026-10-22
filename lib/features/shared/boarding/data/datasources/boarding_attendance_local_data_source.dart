/// Plain, role-agnostic record shape used by the local cache - deliberately
/// not the Patron/Matron `BoardingAttendance` entity, so this file never
/// imports either role's domain layer.
class LocalBoardingAttendanceRecord {
  final String schoolId;
  final String dormitoryId;
  final String studentId;
  final String studentName;
  final String type;
  final DateTime date;
  final String status;
  final String? remarks;
  final String recordedBy;
  final String syncStatus; // 'pending' | 'synced'

  const LocalBoardingAttendanceRecord({
    required this.schoolId,
    required this.dormitoryId,
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.date,
    required this.status,
    this.remarks,
    required this.recordedBy,
    this.syncStatus = 'pending',
  });

  LocalBoardingAttendanceRecord copyWith({String? syncStatus}) {
    return LocalBoardingAttendanceRecord(
      schoolId: schoolId,
      dormitoryId: dormitoryId,
      studentId: studentId,
      studentName: studentName,
      type: type,
      date: date,
      status: status,
      remarks: remarks,
      recordedBy: recordedBy,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

abstract class BoardingAttendanceLocalDataSource {
  /// Caches every record in [records], replacing any existing local record
  /// with the same deterministic id (a re-save of the same roll call
  /// overwrites, it does not duplicate).
  Future<void> cacheAll(List<LocalBoardingAttendanceRecord> records);

  Future<List<LocalBoardingAttendanceRecord>> getPending(String schoolId);

  Future<void> markSynced({
    required String schoolId,
    required String dormitoryId,
    required String type,
    required DateTime date,
    required String studentId,
  });

  Stream<List<LocalBoardingAttendanceRecord>> watchRecords({
    required String schoolId,
    required DateTime date,
    String? dormitoryId,
    String? type,
  });
}
