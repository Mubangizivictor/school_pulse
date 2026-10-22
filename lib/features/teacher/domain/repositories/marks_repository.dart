import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_subject.dart';
import '../entities/subject_assessment.dart';
import '../policies/marks_entry_policy.dart';

/// Marks for the active subject and class.
///
/// Assessments come from the Assessment Engine. A teacher may create one
/// for their own subject and class via `createAssessment`, but this
/// repository otherwise never changes an assessment's status - approving
/// and locking belong to the academic office.
abstract class MarksRepository {
  /// Every subject the curriculum teaches in the context's class - what a
  /// Class Teacher picks from before entering marks for a subject that is
  /// not their own. A Subject Teacher's screen never calls this; its one
  /// subject already comes from the context.
  Future<Either<Failure, List<ClassSubject>>> getClassSubjects({
    required ActiveResponsibilityContext context,
  });

  /// Assessments a teacher may work on for the active responsibility.
  ///
  /// [subjectId] overrides `context.subjectId` - needed for a Class Teacher,
  /// whose context is not tied to one subject, so the screen must say which
  /// of the class's subjects it means. A Subject Teacher's context already
  /// names its one subject and never needs to pass this.
  Future<Either<Failure, List<SubjectAssessment>>> getAssessments({
    required ActiveResponsibilityContext context,
    String? subjectId,
    bool forceRefresh = false,
  });

  /// Creates a new assessment for the active responsibility's class, open
  /// for entry immediately so the teacher can start marking. Requires
  /// `subject.assessment.create`. See [getAssessments] for [subjectId].
  Future<Either<Failure, SubjectAssessment>> createAssessment({
    required ActiveResponsibilityContext context,
    String? subjectId,
    required String title,
    required String assessmentType,
    required double maximumMark,
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
