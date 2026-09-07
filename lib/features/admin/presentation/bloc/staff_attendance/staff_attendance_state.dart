import 'package:equatable/equatable.dart';

import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';

enum StaffAttendanceFilter { all, present, late, notClockedIn, onLeave, absent }

/// One row in the attendance log: a staff member joined to their record for
/// the selected day (null when they have not clocked in / no record exists).
class StaffAttendanceRow extends Equatable {
  const StaffAttendanceRow({required this.staff, this.record});

  final UserEntity staff;
  final StaffAttendanceRecord? record;

  /// The status shown for this row - synthesised as [notClockedIn] when
  /// there is no record.
  StaffAttendanceStatus get status =>
      record?.status ?? StaffAttendanceStatus.notClockedIn;

  @override
  List<Object?> get props => [staff.id, record?.clockIn, record?.status];
}

class StaffAttendanceSummary extends Equatable {
  const StaffAttendanceSummary({
    required this.total,
    required this.present,
    required this.late,
    required this.notClockedIn,
    required this.onLeave,
    required this.absent,
    required this.avgClockInMinutes,
  });

  const StaffAttendanceSummary.empty()
    : total = 0,
      present = 0,
      late = 0,
      notClockedIn = 0,
      onLeave = 0,
      absent = 0,
      avgClockInMinutes = null;

  final int total;
  final int present;
  final int late;
  final int notClockedIn;
  final int onLeave;
  final int absent;

  /// Mean of clock-in times (minutes since midnight) across records that
  /// have a clock-in. Null when nobody has clocked in.
  final int? avgClockInMinutes;

  @override
  List<Object?> get props => [
    total,
    present,
    late,
    notClockedIn,
    onLeave,
    absent,
    avgClockInMinutes,
  ];
}

class StaffAttendanceState extends Equatable {
  const StaffAttendanceState({
    required this.day,
    this.campusId,
    this.campuses = const [],
    this.query = '',
    this.filter = StaffAttendanceFilter.all,
    this.page = 0,
    this.pageSize = 25,
    this.roster = const [],
    this.records = const [],
    this.isLoadingRoster = true,
    this.isLoadingRecords = true,
    this.isOffline = false,
    this.error,
  });

  final DateTime day;
  final String? campusId;
  final List<Campus> campuses;
  final String query;
  final StaffAttendanceFilter filter;
  final int page;
  final int pageSize;

  final List<UserEntity> roster;
  final List<StaffAttendanceRecord> records;

  final bool isLoadingRoster;
  final bool isLoadingRecords;
  final bool isOffline;
  final String? error;

  bool get isLoading => isLoadingRoster || isLoadingRecords;

  StaffAttendanceState copyWith({
    DateTime? day,
    Object? campusId = _noChange,
    List<Campus>? campuses,
    String? query,
    StaffAttendanceFilter? filter,
    int? page,
    int? pageSize,
    List<UserEntity>? roster,
    List<StaffAttendanceRecord>? records,
    bool? isLoadingRoster,
    bool? isLoadingRecords,
    bool? isOffline,
    Object? error = _noChange,
  }) {
    return StaffAttendanceState(
      day: day ?? this.day,
      campusId: campusId == _noChange ? this.campusId : campusId as String?,
      campuses: campuses ?? this.campuses,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      roster: roster ?? this.roster,
      records: records ?? this.records,
      isLoadingRoster: isLoadingRoster ?? this.isLoadingRoster,
      isLoadingRecords: isLoadingRecords ?? this.isLoadingRecords,
      isOffline: isOffline ?? this.isOffline,
      error: error == _noChange ? this.error : error as String?,
    );
  }

  // --- Derived data -------------------------------------------------------

  Map<String, StaffAttendanceRecord> get _recordsByStaff => {
    for (final r in records) r.staffId: r,
  };

  /// The roster narrowed to the selected campus, joined to records, then
  /// filtered by search + status. Not paginated - see [pagedRows].
  List<StaffAttendanceRow> get filteredRows {
    final byStaff = _recordsByStaff;
    final q = query.trim().toLowerCase();
    var rows = roster
        .where((s) => campusId == null || s.campusId == campusId)
        .map((s) => StaffAttendanceRow(staff: s, record: byStaff[s.id]))
        .toList();
    if (q.isNotEmpty) {
      rows = rows
          .where(
            (r) =>
                r.staff.name.toLowerCase().contains(q) ||
                (r.staff.staffCode?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    rows = rows.where((r) => _matchesFilter(r.status)).toList();
    rows.sort(
      (a, b) =>
          a.staff.name.toLowerCase().compareTo(b.staff.name.toLowerCase()),
    );
    return rows;
  }

  bool _matchesFilter(StaffAttendanceStatus status) {
    switch (filter) {
      case StaffAttendanceFilter.all:
        return true;
      case StaffAttendanceFilter.present:
        return status == StaffAttendanceStatus.onTime ||
            status == StaffAttendanceStatus.late;
      case StaffAttendanceFilter.late:
        return status == StaffAttendanceStatus.late;
      case StaffAttendanceFilter.notClockedIn:
        return status == StaffAttendanceStatus.notClockedIn;
      case StaffAttendanceFilter.onLeave:
        return status == StaffAttendanceStatus.onLeave;
      case StaffAttendanceFilter.absent:
        return status == StaffAttendanceStatus.absent;
    }
  }

  int get filteredCount => filteredRows.length;

  int get pageCount =>
      filteredCount == 0 ? 1 : ((filteredCount - 1) ~/ pageSize) + 1;

  /// Clamped current page (defends against a filter change shrinking the
  /// list below the active page).
  int get safePage => page.clamp(0, pageCount - 1);

  List<StaffAttendanceRow> get pagedRows {
    final rows = filteredRows;
    final startIndex = safePage * pageSize;
    if (startIndex >= rows.length) return const [];
    return rows.sublist(
      startIndex,
      (startIndex + pageSize).clamp(0, rows.length),
    );
  }

  /// 1-based inclusive range of the current page, for a "Showing X–Y of N"
  /// footer. Returns (0, 0) when empty.
  (int, int) get pageRange {
    if (filteredCount == 0) return (0, 0);
    final start = safePage * pageSize + 1;
    final end = (start + pagedRows.length - 1).clamp(start, filteredCount);
    return (start, end);
  }

  /// Summary over the campus-scoped roster (NOT search/status filtered - the
  /// metric cards always describe the whole day for the selected campus).
  StaffAttendanceSummary get summary {
    final byStaff = _recordsByStaff;
    final scoped = roster
        .where((s) => campusId == null || s.campusId == campusId)
        .toList();
    var present = 0, late = 0, onLeave = 0, absent = 0;
    final clockInMinutes = <int>[];
    for (final s in scoped) {
      final rec = byStaff[s.id];
      switch (rec?.status ?? StaffAttendanceStatus.notClockedIn) {
        case StaffAttendanceStatus.onTime:
          present++;
          break;
        case StaffAttendanceStatus.late:
          present++;
          late++;
          break;
        case StaffAttendanceStatus.onLeave:
          onLeave++;
          break;
        case StaffAttendanceStatus.absent:
          absent++;
          break;
        case StaffAttendanceStatus.notClockedIn:
          break;
      }
      if (rec != null &&
          (rec.status == StaffAttendanceStatus.onTime ||
              rec.status == StaffAttendanceStatus.late)) {
        clockInMinutes.add(rec.clockIn.hour * 60 + rec.clockIn.minute);
      }
    }
    final notClockedIn = scoped.length - present - onLeave - absent;
    final avg = clockInMinutes.isEmpty
        ? null
        : clockInMinutes.reduce((a, b) => a + b) ~/ clockInMinutes.length;
    return StaffAttendanceSummary(
      total: scoped.length,
      present: present,
      late: late,
      notClockedIn: notClockedIn,
      onLeave: onLeave,
      absent: absent,
      avgClockInMinutes: avg,
    );
  }

  @override
  List<Object?> get props => [
    day,
    campusId,
    campuses,
    query,
    filter,
    page,
    pageSize,
    roster,
    records,
    isLoadingRoster,
    isLoadingRecords,
    isOffline,
    error,
  ];
}

const _noChange = Object();
