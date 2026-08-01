import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/subject_enrollment.dart';

/// The students of one subject-class assignment.
///
/// Every method takes the [ActiveResponsibilityContext] rather than loose
/// ids. That is the enforcement point: a caller cannot ask for "the students
/// of Grade 10B" while acting as the Grade 10A teacher, because the scope
/// comes from the verified assignment and not from the arguments.
abstract class SubjectStudentRepository {
  /// Students holding an active enrollment in the context's subject, class
  /// and academic year. This is what the Students tab lists - never the whole
  /// school, and not even the whole class when some of it takes a different
  /// elective.
  Future<Either<Failure, List<SubjectStudentSummary>>> getSubjectStudents({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  });

  /// Students of the class who could still be added to the subject: active,
  /// in the permitted cohort, and not already enrolled.
  Future<Either<Failure, List<EligibleStudent>>> getEligibleStudents({
    required ActiveResponsibilityContext context,
  });

  /// Adds existing students to the subject. Never creates a student record -
  /// that belongs to Admissions, and this panel has no path to it.
  Future<Either<Failure, void>> enrollStudents({
    required ActiveResponsibilityContext context,
    required List<String> studentIds,
  });

  /// Removes a student from the subject, or raises a removal request when the
  /// school requires approval. Historical marks are preserved either way.
  Future<Either<Failure, SubjectEnrollmentStatus>> removeStudent({
    required ActiveResponsibilityContext context,
    required String studentId,
    required String reason,
    required bool requiresApproval,
  });

  /// The enrollment row for one student, used to decide whether a removal is
  /// even permitted before offering it.
  Future<Either<Failure, SubjectEnrollment?>> getEnrollment({
    required ActiveResponsibilityContext context,
    required String studentId,
  });
}
