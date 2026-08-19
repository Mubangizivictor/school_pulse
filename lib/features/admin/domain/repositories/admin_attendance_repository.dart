import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';

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
}
