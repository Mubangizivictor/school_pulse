import '../../domain/entities/attendance_record.dart';
import 'attendance_local_data_source.dart';

AttendanceLocalDataSource create({dynamic isar}) =>
    const AttendanceLocalDataSourceWeb();

/// No local database on web - every write goes straight to Firestore via
/// AttendanceRepositoryImpl's network branch (WebNetworkInfo always reports
/// connected, so nothing is ever queued as pending here). cacheIfAbsent
/// never actually caches; its only remaining job on web is to preserve the
/// deterministic-id duplicate check by delegating to the caller's own
/// Firestore round trip, which AttendanceRepositoryImpl already performs.
class AttendanceLocalDataSourceWeb implements AttendanceLocalDataSource {
  const AttendanceLocalDataSourceWeb();

  @override
  Future<AttendanceRecord> cacheIfAbsent(AttendanceRecord record) async =>
      record;

  @override
  Future<List<AttendanceRecord>> getPending(String schoolId) async => [];

  @override
  Future<void> markSynced(String recordId) async {}

  @override
  Stream<List<AttendanceRecord>> watchRecords({
    required String schoolId,
    required String scopeId,
    required DateTime date,
    required String sessionType,
  }) => const Stream.empty();
}
