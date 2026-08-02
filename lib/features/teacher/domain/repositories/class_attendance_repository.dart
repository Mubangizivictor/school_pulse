import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/lesson_attendance.dart';

/// The class register, as the Class Teacher panel reads and writes it.
///
/// The register itself belongs to the Attendance engine - this repository is
/// the class-scoped door onto it, not a second implementation of it. Marks
/// are keyed to the class and stream on the verified assignment, so a teacher
/// cannot open, mark or read the register of a class they were not given.
abstract class ClassAttendanceRepository {
  /// How each student on the roster was marked on [date], keyed by student id.
  ///
  /// A student missing from the map was never marked, which is deliberately
  /// distinct from being marked absent: defaulting the unmarked to absent
  /// would put an absence on a record no teacher actually recorded.
  Future<Either<Failure, Map<String, LessonAttendanceStatus>>> getStatusesForDate({
    required ActiveResponsibilityContext context,
    required DateTime date,
  });
}
