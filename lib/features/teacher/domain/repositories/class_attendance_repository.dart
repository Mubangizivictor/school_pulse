import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_attendance.dart';
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

  /// The statuses this school offers, in the order the register should show
  /// them. Comes from the school's attendance configuration, falling back to
  /// a shared default set when nothing has been configured.
  Future<Either<Failure, List<ClassAttendanceOption>>> getStatusOptions({
    required ActiveResponsibilityContext context,
  });

  /// The register for [date], or a fresh empty one when it has not been
  /// started. Never null on success - "no register yet" is an empty draft the
  /// teacher can fill, not an error.
  Future<Either<Failure, ClassAttendanceSession>> resolveSession({
    required ActiveResponsibilityContext context,
    required DateTime date,
    String sessionType = 'daily',
  });

  /// Saves without submitting. Queued locally when offline, because a
  /// classroom with no signal is the single most common place a register is
  /// filled in.
  Future<Either<Failure, ClassAttendanceSession>> saveDraft({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
  });

  /// Submits the register. Refused while any student on [rosterStudentIds] is
  /// unmarked, so an absence is never recorded by omission.
  Future<Either<Failure, ClassAttendanceSession>> submit({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
    required List<String> rosterStudentIds,
  });

  /// Changes a submitted register inside the correction window. Requires a
  /// reason, and records the previous and new value against the teacher who
  /// made the change.
  Future<Either<Failure, ClassAttendanceSession>> correct({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
    required String studentId,
    required String newStatusCode,
    required String reason,
  });

  /// Asks the academic office to change a register the teacher may no longer
  /// edit. Never available offline: replaying an approval-bearing request
  /// from a device that has been away for a week would let a revoked teacher
  /// act on stale authority.
  Future<Either<Failure, void>> requestCorrection({
    required ActiveResponsibilityContext context,
    required ClassAttendanceSession session,
    required String studentId,
    required String requestedStatusCode,
    required String reason,
  });

  /// Submitted registers between two dates, newest first.
  Future<Either<Failure, List<ClassAttendanceSession>>> getHistory({
    required ActiveResponsibilityContext context,
    required DateTime from,
    required DateTime to,
  });
}
