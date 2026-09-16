import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';

/// Read access to `staff_attendance`. Writes never go through here - a
/// clock-in path (later slice) and manual corrections both run server-side
/// via the `correctStaffAttendance` callable, and the Firestore rules deny
/// direct client writes.
///
/// Unrelated to `AdminAttendanceRepository` (`admin_attendance_repository_impl.dart`),
/// which reads `class_attendance_sessions` for *student* attendance stats on
/// the admin dashboard home screen. That is a different collection and a
/// different domain - not a duplicate of this repository.
abstract class StaffAttendanceRepository {
  /// Live stream of every staff attendance record whose `clockIn` falls on
  /// the calendar day of [day] (local time), optionally narrowed to one
  /// [campusId].
  Stream<List<StaffAttendanceRecord>> watchDay({
    required String schoolId,
    required DateTime day,
    String? campusId,
  });

  /// One-shot fetch across an inclusive date range - used to build a CSV
  /// export. [from] and [to] are treated as calendar days (local time).
  Future<List<StaffAttendanceRecord>> fetchRange({
    required String schoolId,
    required DateTime from,
    required DateTime to,
    String? campusId,
  });

  /// Deterministic doc id: `"{staffId}_{yyyy-mm-dd}"` - one record per staff
  /// per day. Kept in sync with the callable's id scheme.
  String docId(String staffId, DateTime day);
}
