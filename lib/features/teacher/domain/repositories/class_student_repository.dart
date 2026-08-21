import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_student_summary.dart';
import '../entities/student_leave_application.dart';

/// Which students a Class Teacher may see, and nothing wider.
///
/// Every method takes the [ActiveResponsibilityContext] rather than loose ids,
/// for the same reason the Subject Teacher repositories do: the class and
/// stream come from the verified assignment, so a caller cannot ask for
/// "the students of P6 West" while holding the P5 East assignment. A screen
/// that passes its own `classId` gets a failure, not a wider result set.
abstract class ClassStudentRepository {
  /// The active roster of the assigned class and stream for the context's
  /// academic year. Never the whole school, and never another year unless
  /// historical access was granted.
  Future<Either<Failure, List<ClassStudentSummary>>> getClassStudents({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  });

  /// One student, refused unless they are on this teacher's roster. The
  /// membership check is the point - a student id is guessable, an assignment
  /// is not.
  Future<Either<Failure, ClassStudentSummary>> getClassStudent({
    required ActiveResponsibilityContext context,
    required String studentId,
  });

  /// Pushes roster changes - an admission mid-term, a transfer out - to an
  /// open panel, so the register a teacher is about to mark is the current one.
  Stream<List<ClassStudentSummary>> watchClassStudents({
    required ActiveResponsibilityContext context,
  });

  /// One student's leave applications, newest first, refused unless they are
  /// on this teacher's roster.
  ///
  /// Reads the boarding leave queue rather than a class-teacher copy of it,
  /// so the status a teacher sees is the one the patron is acting on.
  Future<Either<Failure, List<StudentLeaveApplication>>>
  getStudentLeaveApplications({
    required ActiveResponsibilityContext context,
    required String studentId,
  });

  /// Drops the cached roster on logout or school switch, so no student of one
  /// tenant survives into another.
  Future<Either<Failure, void>> clearCache({String? schoolId});
}
