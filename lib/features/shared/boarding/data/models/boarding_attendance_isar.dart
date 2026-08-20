import 'package:isar/isar.dart';

part 'boarding_attendance_isar.g.dart';

/// Deterministic offline-duplicate-detection id: one boarder can only have
/// one attendance record per (school, dormitory, session type, day) - the
/// same identity Firestore should enforce, mirroring
/// `attendance_hub`'s `buildAttendanceRecordId` pattern.
String buildBoardingAttendanceRecordId({
  required String schoolId,
  required String dormitoryId,
  required String type,
  required DateTime date,
  required String studentId,
}) {
  final day =
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return '$schoolId|$dormitoryId|$type|$day|$studentId';
}

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
