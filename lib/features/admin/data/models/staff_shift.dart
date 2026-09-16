import 'package:cloud_firestore/cloud_firestore.dart';

/// One staff member's recurring weekly roster, as set by the `setStaffShift`
/// callable. `scheduledStart`/`scheduledEnd` are time-of-day strings
/// (`"08:00"`), not specific-day timestamps - a shift is a recurring
/// pattern, not a single day's schedule.
class StaffShift {
  final String staffId;
  final String? campusId;
  final String scheduledStart;
  final String scheduledEnd;

  /// 1 (Monday) through 7 (Sunday).
  final List<int> daysOfWeek;

  /// Minutes of grace before a clock-in after [scheduledStart] counts as
  /// late.
  final int graceMinutes;

  const StaffShift({
    required this.staffId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.daysOfWeek,
    this.campusId,
    this.graceMinutes = 0,
  });

  bool coversDay(DateTime day) => daysOfWeek.contains(day.weekday);

  factory StaffShift.fromMap(String staffId, Map<String, dynamic> map) =>
      StaffShift(
        staffId: staffId,
        campusId: map['campusId'] as String?,
        scheduledStart: (map['scheduledStart'] as String?) ?? '',
        scheduledEnd: (map['scheduledEnd'] as String?) ?? '',
        daysOfWeek:
            (map['daysOfWeek'] as List?)?.map((e) => e as int).toList() ??
            const [],
        graceMinutes: (map['graceMinutes'] as num?)?.toInt() ?? 0,
      );
}

/// Parsed from `map['clockIn']`/`toDate()` upstream - see
/// [StaffAttendanceRecord].
extension StaffShiftTimeOfDay on StaffShift {
  /// The scheduled start as (hour, minute) on the given [day]'s calendar
  /// date, or null if [scheduledStart] is malformed.
  DateTime? scheduledStartOn(DateTime day) {
    final parts = scheduledStart.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(day.year, day.month, day.day, h, m);
  }
}

DateTime? _toDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

/// Approved/pending/rejected leave for one staff member, feeding the
/// dashboard's `on_leave` status derivation.
class StaffLeaveRequest {
  final String id;
  final String staffId;
  final String startDate;
  final String endDate;
  final String status;
  final String reason;
  final String? approvedBy;
  final DateTime? approvedAt;

  const StaffLeaveRequest({
    required this.id,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.reason,
    this.approvedBy,
    this.approvedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';

  bool coversDay(DateTime day) {
    final key =
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    return key.compareTo(startDate) >= 0 && key.compareTo(endDate) <= 0;
  }

  factory StaffLeaveRequest.fromMap(String id, Map<String, dynamic> map) =>
      StaffLeaveRequest(
        id: id,
        staffId: (map['staffId'] as String?) ?? '',
        startDate: (map['startDate'] as String?) ?? '',
        endDate: (map['endDate'] as String?) ?? '',
        status: (map['status'] as String?) ?? 'pending',
        reason: (map['reason'] as String?) ?? '',
        approvedBy: map['approvedBy'] as String?,
        approvedAt: _toDate(map['approvedAt']),
      );
}
