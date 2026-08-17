import 'package:isar/isar.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_isar.dart';
import 'attendance_local_data_source.dart';
import 'attendance_remote_data_source.dart' show buildAttendanceRecordId;

AttendanceLocalDataSource create({dynamic isar}) =>
    AttendanceLocalDataSourceImpl(isar: isar as Isar);

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final Isar isar;

  AttendanceLocalDataSourceImpl({required this.isar});

  @override
  Future<AttendanceRecord> cacheIfAbsent(AttendanceRecord record) async {
    final recordId = buildAttendanceRecordId(
      category: record.category,
      scopeId: record.scopeId,
      sessionType: record.sessionType,
      date: record.date,
      personId: record.personId,
    );

    final existing = await isar.attendanceRecordIsars
        .filter()
        .recordIdEqualTo(recordId)
        .findFirst();
    if (existing != null) {
      throw LocalDuplicateAttendanceException(existing.toEntity());
    }

    final isarRecord = AttendanceRecordIsar.fromEntity(record, recordId);
    await isar.writeTxn(() => isar.attendanceRecordIsars.put(isarRecord));
    return isarRecord.toEntity();
  }

  @override
  Future<List<AttendanceRecord>> getPending(String schoolId) async {
    final rows = await isar.attendanceRecordIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .syncStatusEqualTo(AttendanceSyncStatus.pending.name)
        .findAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> markSynced(String recordId) async {
    await isar.writeTxn(() async {
      final row = await isar.attendanceRecordIsars
          .filter()
          .recordIdEqualTo(recordId)
          .findFirst();
      if (row == null) return;
      row.syncStatus = AttendanceSyncStatus.synced.name;
      await isar.attendanceRecordIsars.put(row);
    });
  }

  @override
  Stream<List<AttendanceRecord>> watchRecords({
    required String schoolId,
    required String scopeId,
    required DateTime date,
    required String sessionType,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final query = isar.attendanceRecordIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .scopeIdEqualTo(scopeId)
        .sessionTypeEqualTo(sessionType)
        .dateBetween(dayStart, dayEnd)
        .build();
    return query
        .watch(fireImmediately: true)
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }
}
