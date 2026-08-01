import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/lesson.dart';
import '../entities/lesson_attendance.dart';
import '../entities/subject_enrollment.dart';

/// The lesson register.
///
/// Every method takes the verified context, and the register is always built
/// from the subject's enrolled students - never from a class list, and never
/// from ids the caller supplies. A student who is not enrolled in this
/// subject has no row to mark.
abstract class LessonAttendanceRepository {
  /// Opens the register for a lesson: the existing draft if there is one,
  /// otherwise a fresh one seeded from the enrolled students.
  Future<Either<Failure, LessonAttendance>> openRegister({
    required ActiveResponsibilityContext context,
    required Lesson lesson,
    required List<SubjectStudentSummary> enrolledStudents,
  });

  /// Saves progress. Works offline - a register half-filled in a classroom
  /// with no signal is exactly the case this has to survive.
  Future<Either<Failure, LessonAttendance>> saveDraft({
    required ActiveResponsibilityContext context,
    required LessonAttendance attendance,
  });

  /// Submits the register. Refuses while any student is still unmarked, so an
  /// absence is never recorded by omission.
  Future<Either<Failure, LessonAttendance>> submit({
    required ActiveResponsibilityContext context,
    required LessonAttendance attendance,
  });

  /// Corrects a submitted register. Needs a reason and the edit permission,
  /// and writes both the old and new value to the audit trail.
  Future<Either<Failure, LessonAttendance>> correct({
    required ActiveResponsibilityContext context,
    required LessonAttendance attendance,
    required String studentId,
    required LessonAttendanceStatus newStatus,
    required String reason,
  });
}
