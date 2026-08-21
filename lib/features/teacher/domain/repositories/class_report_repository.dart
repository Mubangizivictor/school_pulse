import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/canonical_report_card.dart';
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

  /// Submits one or more generated report cards to the Dean for review.
  ///
  /// This is the academic-submission step, distinct from [submitEntry]
  /// (which only hands the class teacher's own sections to the academic
  /// office pre-generation). The server re-validates readiness and the
  /// current source hash for every report before moving it - a report that
  /// has drifted stale is reported back as a per-item failure, never
  /// silently skipped or force-submitted.
  Future<Either<Failure, SubmitReportCardsResult>> submitReportCardsToDean({
    required ActiveResponsibilityContext context,
    required List<String> reportCardIds,
  });

  /// The canonical report-card snapshot for one report id - what the Class
  /// Teacher's "View Report" action actually opens. Visible at every
  /// workflow stage, unsigned reports included; the caller is responsible
  /// for showing the right watermark/status, never for hiding the report.
  Future<Either<Failure, CanonicalReportCard>> getReportCard({
    required ActiveResponsibilityContext context,
    required String reportCardId,
  });

  /// Requests a rendered PDF preview of the report at its current state -
  /// carries the DRAFT/AWAITING-SIGNATURES watermark until the report is
  /// academically finalized. Returns the PDF bytes directly rather than a
  /// Storage URL, since an unsigned preview is never persisted as if it
  /// were official.
  Future<Either<Failure, List<int>>> previewReportCardPdf({
    required String reportCardId,
  });

  /// Requests the official, immutable PDF's short-lived signed download URL
  /// - only valid once the report is academically finalized.
  Future<Either<Failure, String>> getOfficialReportCardPdfUrl({
    required String reportCardId,
  });
}
