import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/data/models/staff_shift.dart';

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

  /// Live stream of every staff member's current shift/roster doc for the
  /// tenant. Read-only - writes go through the `setStaffShift` callable.
  Stream<List<StaffShift>> watchShifts({required String schoolId});

  /// Live stream of leave requests whose date range could plausibly cover
  /// [day] (server-side query is by date range, not exact-day match, so the
  /// caller still needs [StaffLeaveRequest.coversDay]).
  Stream<List<StaffLeaveRequest>> watchLeaveForDay({
    required String schoolId,
    required DateTime day,
  });

  /// Authorised "Mark staff attendance" - creates or upserts today's clock-in
  /// via the `clockInStaff` callable. Never called for a past day; corrections
  /// to an existing day go through [correct] instead.
  Future<void> clockIn({
    required String schoolId,
    required String staffId,
    required DateTime day,
    String? location,
    String? operationId,
  });

  /// Authorised manual correction via the `correctStaffAttendance` callable.
  /// [patch] mirrors the callable's wire shape (status/clockIn/clockOut/
  /// location, ISO8601 strings for the time fields) - see
  /// StaffAttendanceCorrectionSheet for the caller that builds it.
  Future<void> correct({
    required String schoolId,
    required String staffId,
    required DateTime day,
    required String reason,
    required Map<String, dynamic> patch,
    String? operationId,
  });
}
