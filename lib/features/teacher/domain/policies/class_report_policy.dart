import '../entities/class_report_entry.dart';

enum ReportRefusal {
  notEditable,
  sectionsIncomplete,
  marksNotApproved,
  commentTooShort,
  noStudentsSelected,
  studentNotInClass,
  generateNotPermitted,
  shareBeforePublication,
}

class ReportDecision {
  final bool isAllowed;
  final ReportRefusal? refusal;
  final String? message;

  /// The sections still missing, when that is why it was refused. Named so
  /// the screen can list them rather than saying "incomplete".
  final List<ReportSection> missingSections;

  /// Subjects whose marks are not yet approved. The class teacher cannot fix
  /// these themselves, so naming them tells them who to chase.
  final List<String> unapprovedSubjects;

  const ReportDecision.allowed()
    : isAllowed = true,
      refusal = null,
      message = null,
      missingSections = const [],
      unapprovedSubjects = const [];

  const ReportDecision.refused(
    this.refusal,
    this.message, {
    this.missingSections = const [],
    this.unapprovedSubjects = const [],
  }) : isAllowed = false;
}

/// What has to be true before a report leaves the class teacher's hands.
///
/// The Report Card Engine owns grades, totals, rankings and layout. What this
/// decides is narrower and entirely the teacher's: whether their own sections
/// are done, and whether the marks underneath them are settled enough for a
/// report to be worth generating.
class ClassReportPolicy {
  const ClassReportPolicy._();

  /// Sections still missing for one student, honouring what the school
  /// actually switched on.
  static List<ReportSection> missingSections({
    required ClassReportEntry entry,
    required ReportProfile profile,
  }) {
    return ReportSection.values
        .where(profile.isEnabled)
        .where(
          (section) => !entry.isSectionComplete(
            section,
            commentMinLength: profile.commentMinLength,
          ),
        )
        .toList();
  }

  /// Whether the teacher may still write to this entry.
  static ReportDecision canEdit({required ClassReportEntry entry}) {
    if (!entry.isEditable) {
      return ReportDecision.refused(
        ReportRefusal.notEditable,
        entry.status.isApprovedUpstream
            ? 'This report has been approved and can no longer be changed here.'
            : 'This report is with the academic office for review.',
      );
    }
    return const ReportDecision.allowed();
  }

  /// Whether the teacher may hand one student's report on for review.
  static ReportDecision canSubmit({
    required ClassReportEntry entry,
    required ReportProfile profile,
  }) {
    final editable = canEdit(entry: entry);
    if (!editable.isAllowed) return editable;

    final missing = missingSections(entry: entry, profile: profile);
    if (missing.isNotEmpty) {
      return ReportDecision.refused(
        ReportRefusal.sectionsIncomplete,
        missing.length == 1
            ? '${missing.first.label} is not finished.'
            : '${missing.length} sections are not finished.',
        missingSections: missing,
      );
    }

    return const ReportDecision.allowed();
  }

  /// Whether reports may be generated for a set of students.
  ///
  /// Two separate reasons this fails, and they need different actions from
  /// the teacher: their own sections are incomplete (they can fix that), or
  /// subject marks are unapproved (they cannot, and need to chase somebody).
  static ReportDecision canGenerate({
    required List<ClassReportEntry> entries,
    required ReportProfile profile,
    required List<String> unapprovedSubjects,
    required bool hasGeneratePermission,
  }) {
    if (!hasGeneratePermission) {
      return const ReportDecision.refused(
        ReportRefusal.generateNotPermitted,
        'You do not have permission to generate reports for your class.',
      );
    }

    if (entries.isEmpty) {
      return const ReportDecision.refused(
        ReportRefusal.noStudentsSelected,
        'Select at least one student.',
      );
    }

    if (unapprovedSubjects.isNotEmpty && profile.requiresCompleteness) {
      return ReportDecision.refused(
        ReportRefusal.marksNotApproved,
        unapprovedSubjects.length == 1
            ? 'Marks for ${unapprovedSubjects.first} have not been approved yet.'
            : '${unapprovedSubjects.length} subjects still have unapproved '
                  'marks.',
        unapprovedSubjects: unapprovedSubjects,
      );
    }

    final incomplete = <ReportSection>{};
    for (final entry in entries) {
      incomplete.addAll(missingSections(entry: entry, profile: profile));
    }

    // A school that allows draft reports with gaps gets them; one that does
    // not is stopped here rather than discovering it at the printer.
    if (incomplete.isNotEmpty && profile.requiresCompleteness) {
      return ReportDecision.refused(
        ReportRefusal.sectionsIncomplete,
        'Some reports are missing ${incomplete.map((s) => s.label).join(', ')}.',
        missingSections: incomplete.toList(),
      );
    }

    return const ReportDecision.allowed();
  }

  /// Whether a generated report may be sent to a parent.
  ///
  /// Publication is the school's decision, and fee-related holds belong to
  /// Finance. The class teacher generating a PDF does not make it shareable.
  static ReportDecision canShare({
    required ClassReportEntry entry,
    required bool hasSharePermission,
    required bool releaseAllowedByPolicy,
  }) {
    if (!hasSharePermission) {
      return const ReportDecision.refused(
        ReportRefusal.generateNotPermitted,
        'You do not have permission to share reports.',
      );
    }

    if (entry.status != ReportEntryStatus.published) {
      return const ReportDecision.refused(
        ReportRefusal.shareBeforePublication,
        'This report has not been published yet.',
      );
    }

    if (!releaseAllowedByPolicy) {
      return const ReportDecision.refused(
        ReportRefusal.shareBeforePublication,
        'The school has placed a hold on releasing this report.',
      );
    }

    return const ReportDecision.allowed();
  }

  /// Progress across a class, for the reports dashboard.
  static ReportProgress progressOf(
    List<ClassReportEntry> entries,
    ReportProfile profile,
  ) {
    var complete = 0;
    var returned = 0;
    var locked = 0;
    var published = 0;

    for (final entry in entries) {
      if (entry.status == ReportEntryStatus.published) published++;
      if (entry.status.isApprovedUpstream) locked++;
      if (entry.wasReturned) returned++;
      if (missingSections(entry: entry, profile: profile).isEmpty) complete++;
    }

    return ReportProgress(
      total: entries.length,
      complete: complete,
      returned: returned,
      locked: locked,
      published: published,
    );
  }
}

class ReportProgress {
  final int total;
  final int complete;
  final int returned;
  final int locked;
  final int published;

  const ReportProgress({
    this.total = 0,
    this.complete = 0,
    this.returned = 0,
    this.locked = 0,
    this.published = 0,
  });

  int get pending => total - complete;

  /// Null rather than zero for an empty class - "no reports started" and
  /// "nothing to report on" are different states.
  double? get completionRate {
    if (total == 0) return null;
    return (complete / total) * 100;
  }
}
