import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/subject_assessment.dart';
import '../policies/marks_entry_policy.dart';

/// Marks for the active subject and class.
///
/// Assessments come from the Assessment Engine; this repository never
/// invents one, and never changes an assessment's status - opening,
/// approving and locking belong to the academic office.
abstract class MarksRepository {
  /// Assessments a teacher may work on for the active responsibility.
  Future<Either<Failure, List<SubjectAssessment>>> getAssessments({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  });

  /// Existing marks for one component, keyed by student.
  Future<Either<Failure, List<StudentMarkEntry>>> getMarks({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
  });

  /// Saves progress without submitting. Works offline.
  Future<Either<Failure, void>> saveDraft({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
  });

  /// The review summary the submit screen shows, and the decision on whether
  /// submission may proceed.
  Future<Either<Failure, MarksSubmissionReport>> review({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
  });

  /// Submits marks for review by the academic office. Refuses if the review
  /// says so, so submission cannot bypass the same validation the UI ran.
  Future<Either<Failure, void>> submit({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
  });

  /// Changes one already-submitted mark. Needs a reason, and records both
  /// the old and new value.
  Future<Either<Failure, StudentMarkEntry>> editMark({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required StudentMarkEntry entry,
    required String reason,
  });
}
