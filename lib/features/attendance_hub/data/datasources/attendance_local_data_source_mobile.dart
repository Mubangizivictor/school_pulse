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
    final now = DateTime.now();
    final rows = await isar.attendanceRecordIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .group(
          (q) => q
              .syncStatusEqualTo(AttendanceSyncStatus.pending.name)
              .or()
              .syncStatusEqualTo(AttendanceSyncStatus.queued.name)
              .or()
              .syncStatusEqualTo(AttendanceSyncStatus.failed.name)
              .or()
              .syncStatusEqualTo(AttendanceSyncStatus.retryableFailure.name),
        )
        .findAll();
    // A row whose backoff window hasn't elapsed yet is excluded here rather
    // than in the Isar filter itself - Isar's query builder can't express
    // "nextRetryAt is null OR nextRetryAt <= now" alongside the syncStatus
    // OR-group above without a second, harder-to-read composite index.
    return rows
        .where((r) => r.nextRetryAt == null || !now.isBefore(r.nextRetryAt!))
        .map((r) => r.toEntity())
        .toList();
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
      row.nextRetryAt = null;
      row.lastError = null;
      await isar.attendanceRecordIsars.put(row);
    });
  }

  @override
  Future<void> markSyncing(String recordId) async {
    await isar.writeTxn(() async {
      final row = await isar.attendanceRecordIsars
          .filter()
          .recordIdEqualTo(recordId)
          .findFirst();
      if (row == null) return;
      row.syncStatus = AttendanceSyncStatus.syncing.name;
      await isar.attendanceRecordIsars.put(row);
    });
  }

  @override
  Future<void> markRetryableFailure(
    String recordId, {
    required String error,
  }) async {
    await isar.writeTxn(() async {
      final row = await isar.attendanceRecordIsars
          .filter()
          .recordIdEqualTo(recordId)
          .findFirst();
      if (row == null) return;
      row.retryCount += 1;
      row.lastError = error;
      row.syncStatus = AttendanceSyncStatus.retryableFailure.name;
      // Same bounded-exponential-backoff shape as
      // OfflineOperation.backoffFor: 1, 2, 4, 8, 16 minutes, doubling per
      // attempt.
      row.nextRetryAt = DateTime.now().add(
        Duration(minutes: 1 << (row.retryCount - 1).clamp(0, 4)),
      );
      await isar.attendanceRecordIsars.put(row);
    });
  }

  @override
  Future<void> markPermanentlyBlocked(
    String recordId, {
    required String reason,
  }) async {
    await isar.writeTxn(() async {
      final row = await isar.attendanceRecordIsars
          .filter()
          .recordIdEqualTo(recordId)
          .findFirst();
      if (row == null) return;
      row.syncStatus = AttendanceSyncStatus.permanentlyBlocked.name;
      row.blockedReason = reason;
      row.nextRetryAt = null;
      await isar.attendanceRecordIsars.put(row);
    });
  }

  @override
  Future<int> evictStale({required Duration retention}) async {
    final cutoff = DateTime.now().subtract(retention);
    final candidates = await isar.attendanceRecordIsars
        .filter()
        .group(
          (q) => q
              .syncStatusEqualTo(AttendanceSyncStatus.permanentlyBlocked.name)
              .or()
              .group(
                (q2) => q2
                    .group(
                      (q3) => q3
                          .syncStatusEqualTo(AttendanceSyncStatus.synced.name)
                          .or()
                          .syncStatusEqualTo(
                            AttendanceSyncStatus.completed.name,
                          ),
                    )
                    .and()
                    .createdAtLessThan(cutoff),
              ),
        )
        .findAll();
    if (candidates.isEmpty) return 0;
    await isar.writeTxn(
      () => isar.attendanceRecordIsars.deleteAll(
        candidates.map((r) => r.id).toList(),
      ),
    );
    return candidates.length;
  }

  @override
  Future<void> clearAll() async {
    await isar.writeTxn(() => isar.attendanceRecordIsars.clear());
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
