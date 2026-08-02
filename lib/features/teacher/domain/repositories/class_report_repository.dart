import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_report_entry.dart';

/// The class teacher's part of the report card, and nothing else.
///
/// Grades, totals, rankings, descriptors, layout and PDF rendering all stay
/// with the existing Report Card Engine. What this owns is the sections the
/// class teacher fills in and the readiness checks that decide when their
/// work may be handed on.
abstract class ClassReportRepository {
  /// The school's report configuration, falling back to a sensible profile
  /// when none is configured so the panel still works.
  Future<Either<Failure, ReportProfile>> getProfile({
    required ActiveResponsibilityContext context,
  });

  /// Entries for every student in the class, creating blank ones from the
  /// roster where none exist yet - so a teacher opening reports for the first
  /// time sees their class rather than an empty list.
  Future<Either<Failure, List<ClassReportEntry>>> getEntries({
    required ActiveResponsibilityContext context,
  });

  /// Saves the teacher's own sections. Refused once the report has moved past
  /// their part of the workflow.
  Future<Either<Failure, ClassReportEntry>> saveEntry({
    required ActiveResponsibilityContext context,
    required ClassReportEntry entry,
  });

  /// Hands one student's report to the academic office. Refused while any
  /// enabled section is unfinished.
  Future<Either<Failure, ClassReportEntry>> submitEntry({
    required ActiveResponsibilityContext context,
    required ClassReportEntry entry,
  });

  /// Subjects the class sits whose marks are not yet approved.
  ///
  /// The class teacher cannot fix these themselves, so they are named rather
  /// than folded into a generic "incomplete" - it tells them who to chase.
  Future<Either<Failure, List<String>>> unapprovedSubjects({
    required ActiveResponsibilityContext context,
  });

  /// Asks the Report Card Engine to produce reports for these students.
  ///
  /// Validates readiness first, then hands off - this never renders a PDF or
  /// computes a grade of its own.
  Future<Either<Failure, int>> generateReports({
    required ActiveResponsibilityContext context,
    required List<ClassReportEntry> entries,
  });
}
