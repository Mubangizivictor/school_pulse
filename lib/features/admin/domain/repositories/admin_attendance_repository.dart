import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';

/// Raw present/late/absent/excused counts from submitted class attendance
/// sessions for a single day.
class AttendanceCounts extends Equatable {
  const AttendanceCounts({
    required this.present,
    required this.late,
    required this.absent,
    required this.excused,
  });

  const AttendanceCounts.zero()
    : present = 0,
      late = 0,
      absent = 0,
      excused = 0;

  final int present;
  final int late;
  final int absent;
  final int excused;

  int get total => present + late + absent + excused;

  double get presentPercent => total == 0 ? 0 : present / total;
  double get latePercent => total == 0 ? 0 : late / total;
  double get absentPercent => total == 0 ? 0 : absent / total;
  double get excusedPercent => total == 0 ? 0 : excused / total;

  @override
  List<Object?> get props => [present, late, absent, excused];
}

abstract class AdminAttendanceRepository {
  /// Returns the school-wide average student attendance and a list of
  /// daily averages. With no date range, this is the last 5-7 school days
  /// up to today. With [startDate]/[endDate] supplied (e.g. a past term's
  /// bounds), samples school days across that range instead - used for
  /// historical term switching on the admin dashboard.
  Future<Either<Failure, (double average, List<double> weekly)>>
  getStudentAttendanceStats(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Returns raw present/late/absent/excused counts from submitted class
  /// attendance sessions for today. Counts are all zero when no sessions
  /// have been submitted yet today.
  Future<Either<Failure, AttendanceCounts>> getTodayAttendanceCounts(
    String schoolId,
  );
}
