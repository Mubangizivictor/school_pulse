import 'package:isar/isar.dart';

export 'boarding_attendance_record_id.dart' show buildBoardingAttendanceRecordId;

part 'boarding_attendance_isar.g.dart';

/// Local-first cache for Patron/Matron boarding roll-call marks: every Roll
/// Call save lands here immediately, then a push to `boarding_attendance` is
/// attempted, so a roll call is never lost to a dropped connection. Shared
/// by both roles (their entities are structurally identical) - see
/// `attendance_hub`'s `AttendanceRecordIsar` for the pattern this mirrors.
@collection
class BoardingAttendanceIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String recordId;

  @Index()
  late String schoolId;
  @Index()
  late String dormitoryId;
  late String studentId;
  late String studentName;
  @Index()
  late String type;
  @Index()
  late DateTime date;
  late String status;
  String? remarks;
  late String recordedBy;
  @Index()
  late String syncStatus; // 'pending' | 'synced'
  late DateTime createdAt;

  BoardingAttendanceIsar();
}
