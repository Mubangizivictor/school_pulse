import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';

abstract class AdminAttendanceRepository {
  /// Returns the school-wide average student attendance and a list of
  /// daily averages for the past week (usually last 5-7 school days).
  Future<Either<Failure, (double average, List<double> weekly)>>
  getStudentAttendanceStats(String schoolId);
}
