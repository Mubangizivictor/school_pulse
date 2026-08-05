import 'package:school_pulse/core/permissions/permission.dart';
import 'attendance_category.dart';

/// Maps each attendance category to the permission that gates marking
/// attendance for it, so a bloc/screen can resolve the right check with one
/// call instead of hand-writing a switch at every call site.
String permissionForCategory(AttendanceCategory category) {
  switch (category) {
    case AttendanceCategory.students:
      return Permission.attendanceClassScan;
    case AttendanceCategory.staff:
      return Permission.attendanceStaffScan;
    case AttendanceCategory.gate:
      return Permission.attendanceGateScan;
    case AttendanceCategory.meals:
      return Permission.attendanceMealsScan;
    case AttendanceCategory.library:
      return Permission.attendanceLibraryScan;
    case AttendanceCategory.transport:
      return Permission.attendanceTransportScan;
    case AttendanceCategory.visitors:
      return Permission.attendanceVisitorsScan;
    case AttendanceCategory.hostel:
      return Permission.attendanceBoardingScan;
    case AttendanceCategory.custom:
      return Permission.attendanceCustomScan;
  }
}
