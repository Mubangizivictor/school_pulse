import 'package:isar/isar.dart';
import '../models/boarding_attendance_isar.dart';
import 'boarding_attendance_local_data_source.dart';

BoardingAttendanceLocalDataSource create({dynamic isar}) =>
    BoardingAttendanceLocalDataSourceImpl(isar: isar as Isar);

class BoardingAttendanceLocalDataSourceImpl
    implements BoardingAttendanceLocalDataSource {
  final Isar isar;

  BoardingAttendanceLocalDataSourceImpl({required this.isar});

  String _recordId(LocalBoardingAttendanceRecord r) =>
      buildBoardingAttendanceRecordId(
        schoolId: r.schoolId,
        dormitoryId: r.dormitoryId,
        type: r.type,
        date: r.date,
        studentId: r.studentId,
      );

  @override
  Future<void> cacheAll(List<LocalBoardingAttendanceRecord> records) async {
    final rows = records.map((r) {
      return BoardingAttendanceIsar()
        ..recordId = _recordId(r)
        ..schoolId = r.schoolId
        ..dormitoryId = r.dormitoryId
        ..studentId = r.studentId
        ..studentName = r.studentName
        ..type = r.type
        ..date = r.date
        ..status = r.status
        ..remarks = r.remarks
        ..recordedBy = r.recordedBy
        ..syncStatus = r.syncStatus
        ..createdAt = DateTime.now();
    }).toList();

    await isar.writeTxn(() => isar.boardingAttendanceIsars.putAll(rows));
  }

  @override
  Future<List<LocalBoardingAttendanceRecord>> getPending(
    String schoolId,
  ) async {
    final rows = await isar.boardingAttendanceIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .syncStatusEqualTo('pending')
        .findAll();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<void> markSynced({
    required String schoolId,
    required String dormitoryId,
    required String type,
    required DateTime date,
    required String studentId,
  }) async {
    final recordId = buildBoardingAttendanceRecordId(
      schoolId: schoolId,
      dormitoryId: dormitoryId,
      type: type,
      date: date,
      studentId: studentId,
    );
    await isar.writeTxn(() async {
      final row = await isar.boardingAttendanceIsars
          .filter()
          .recordIdEqualTo(recordId)
          .findFirst();
      if (row == null) return;
      row.syncStatus = 'synced';
      await isar.boardingAttendanceIsars.put(row);
    });
  }

  @override
  Stream<List<LocalBoardingAttendanceRecord>> watchRecords({
    required String schoolId,
    required DateTime date,
    String? dormitoryId,
    String? type,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    var builder = isar.boardingAttendanceIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .dateBetween(dayStart, dayEnd);

    final query =
        (dormitoryId != null
                ? builder.dormitoryIdEqualTo(dormitoryId)
                : builder)
            .optional(type != null, (q) => q.typeEqualTo(type!))
            .build();

    return query
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toRecord).toList());
  }

  LocalBoardingAttendanceRecord _toRecord(BoardingAttendanceIsar row) {
    return LocalBoardingAttendanceRecord(
      schoolId: row.schoolId,
      dormitoryId: row.dormitoryId,
      studentId: row.studentId,
      studentName: row.studentName,
      type: row.type,
      date: row.date,
      status: row.status,
      remarks: row.remarks,
      recordedBy: row.recordedBy,
      syncStatus: row.syncStatus,
    );
  }
}
