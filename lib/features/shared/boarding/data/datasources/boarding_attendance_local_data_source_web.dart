import 'boarding_attendance_local_data_source.dart';

BoardingAttendanceLocalDataSource create({dynamic isar}) =>
    const BoardingAttendanceLocalDataSourceWeb();

/// No local database on web - every write goes straight to Firestore via
/// the boarding repository's network branch, same rationale as
/// `attendance_hub`'s `AttendanceLocalDataSourceWeb`.
class BoardingAttendanceLocalDataSourceWeb
    implements BoardingAttendanceLocalDataSource {
  const BoardingAttendanceLocalDataSourceWeb();

  @override
  Future<void> cacheAll(List<LocalBoardingAttendanceRecord> records) async {}

  @override
  Future<List<LocalBoardingAttendanceRecord>> getPending(
    String schoolId,
  ) async => [];

  @override
  Future<void> markSynced({
    required String schoolId,
    required String dormitoryId,
    required String type,
    required DateTime date,
    required String studentId,
  }) async {}

  @override
  Stream<List<LocalBoardingAttendanceRecord>> watchRecords({
    required String schoolId,
    required DateTime date,
    String? dormitoryId,
    String? type,
  }) => const Stream.empty();
}
