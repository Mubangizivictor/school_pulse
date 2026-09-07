import 'package:cloud_firestore/cloud_firestore.dart';

/// The lifecycle states an admin sees for a staff member on a given day.
///
/// [notClockedIn] is never persisted - it's synthesised by the view model
/// for staff who have no `staff_attendance` doc for the day. The other four
/// are written by the `correctStaffAttendance` callable (or, in a later
/// slice, a real clock-in path).
enum StaffAttendanceStatus {
  onTime,
  late,
  notClockedIn,
  onLeave,
  absent;

  /// Wire value stored in Firestore. Kept snake_case for back-compat with
  /// the original free-string field (`'on_time'` / `'late'`).
  String get wire => switch (this) {
    StaffAttendanceStatus.onTime => 'on_time',
    StaffAttendanceStatus.late => 'late',
    StaffAttendanceStatus.notClockedIn => 'not_clocked_in',
    StaffAttendanceStatus.onLeave => 'on_leave',
    StaffAttendanceStatus.absent => 'absent',
  };

  /// Tolerant parse: legacy/unknown values fall back to [onTime] so a
  /// malformed doc never crashes the dashboard.
  static StaffAttendanceStatus fromWire(Object? value) {
    switch (value) {
      case 'late':
        return StaffAttendanceStatus.late;
      case 'not_clocked_in':
        return StaffAttendanceStatus.notClockedIn;
      case 'on_leave':
        return StaffAttendanceStatus.onLeave;
      case 'absent':
        return StaffAttendanceStatus.absent;
      case 'on_time':
      default:
        return StaffAttendanceStatus.onTime;
    }
  }

  /// The set an admin may set via a manual correction ([notClockedIn] is not
  /// a settable state - it just means "no record").
  static const Set<StaffAttendanceStatus> correctable = {
    StaffAttendanceStatus.onTime,
    StaffAttendanceStatus.late,
    StaffAttendanceStatus.onLeave,
    StaffAttendanceStatus.absent,
  };
}

class StaffAttendanceRecord {
  final String schoolId;
  final String staffId;

  /// The campus this record is scoped to. Null for single-site schools or
  /// records written before campuses existed.
  final String? campusId;

  final DateTime clockIn;
  final DateTime? clockOut;
  final StaffAttendanceStatus status;
  final String location;

  /// Set by the correction callable. Display-only - never trusted for auth.
  final DateTime? lastCorrectionAt;
  final String? lastCorrectedBy;

  StaffAttendanceRecord({
    required this.schoolId,
    required this.staffId,
    required this.clockIn,
    required this.status,
    required this.location,
    this.campusId,
    this.clockOut,
    this.lastCorrectionAt,
    this.lastCorrectedBy,
  });

  bool get wasCorrected => lastCorrectionAt != null;

  factory StaffAttendanceRecord.fromMap(Map<String, dynamic> map) =>
      StaffAttendanceRecord(
        schoolId: (map['schoolId'] as String?) ?? '',
        staffId: (map['staffId'] as String?) ?? '',
        campusId: map['campusId'] as String?,
        clockIn:
            _toDate(map['clockIn']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        clockOut: _toDate(map['clockOut']),
        status: StaffAttendanceStatus.fromWire(map['status']),
        location: (map['location'] as String?) ?? 'Main Gate',
        lastCorrectionAt: _toDate(map['lastCorrectionAt']),
        lastCorrectedBy: map['lastCorrectedBy'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'schoolId': schoolId,
    'staffId': staffId,
    'campusId': campusId,
    'clockIn': Timestamp.fromDate(clockIn),
    'clockOut': clockOut != null ? Timestamp.fromDate(clockOut!) : null,
    'status': status.wire,
    'location': location,
    if (lastCorrectionAt != null)
      'lastCorrectionAt': Timestamp.fromDate(lastCorrectionAt!),
    if (lastCorrectedBy != null) 'lastCorrectedBy': lastCorrectedBy,
  };

  static DateTime? _toDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
