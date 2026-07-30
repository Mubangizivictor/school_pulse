import 'package:isar/isar.dart';

part 'attendance_log_isar.g.dart';

@collection
class AttendanceLogIsar {
  Id id = Isar.autoIncrement;

  late String studentUniqueId;
  late String studentName;
  late String className;
  late String status; // Present, Late, Absent, Excused
  late DateTime timestamp;
  late String scannedBy;
  late String schoolId;
  late String module; // ATTENDANCE, LIBRARY, SECURITY, etc.
  
  @Index()
  bool isSynced = false;
}
