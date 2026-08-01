import 'package:school_pulse/core/permissions/permission.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/subject_assessment.dart';

/// Why one mark was rejected.
enum MarkRejection {
  belowZero,
  aboveMaximum,
  notANumber,
  scoreWithoutStatus,
  statusWithScore,
  studentNotEnrolled,
}

extension MarkRejectionMessage on MarkRejection {
  String messageFor(double maximumMark) => switch (this) {
        MarkRejection.belowZero => 'A mark cannot be negative.',
        MarkRejection.aboveMaximum =>
          'A mark cannot be more than ${_trim(maximumMark)}.',
        MarkRejection.notANumber => 'Enter a number.',
        MarkRejection.scoreWithoutStatus =>
          'Give this student a mark or mark them absent, exempted or missing.',
        MarkRejection.statusWithScore =>
          'A student marked absent or exempted cannot also have a score.',
        MarkRejection.studentNotEnrolled =>
          'That student is not enrolled in this subject.',
      };

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toString();
}

/// Why a whole submission was refused.
enum SubmissionRefusal {
  noPermission,
  outsideScope,
  assessmentNotOpen,
  assessmentLocked,
  entryNotOpenYet,
  missingMarks,
  invalidMarks,
  noStudents,
}

/// What a review screen needs to show before the teacher commits.
class MarksSubmissionReport {
  final int totalStudents;
  final int entered;
  final int pending;
  final int absent;
  final int exempted;
  final int invalid;
  final SubmissionRefusal? refusal;

  const MarksSubmissionReport({
    required this.totalStudents,
    required this.entered,
    required this.pending,
    required this.absent,
    required this.exempted,
    required this.invalid,
    this.refusal,
  });

  bool get canSubmit => refusal == null;
}

/// Validates marks before they reach a repository.
///
/// Pure, like the lesson-start rule: the same numbers are rejected offline
/// and online, and a CSV import runs through exactly this code rather than a
/// looser second copy of it. That is what stops an import being the way round
/// the rules.
class MarksEntryPolicy {
  const MarksEntryPolicy();

  /// Checks one entry against its component. Returns null when it is valid.
  MarkRejection? validateEntry({
    required StudentMarkEntry entry,
    required AssessmentComponent component,
    Set<String>? enrolledStudentIds,
  }) {
    if (enrolledStudentIds != null &&
        !enrolledStudentIds.contains(entry.studentId)) {
      return MarkRejection.studentNotEnrolled;
    }

    final score = entry.score;

    switch (entry.status) {
      case MarkEntryStatus.scored:
        if (score == null) return MarkRejection.scoreWithoutStatus;
        if (score.isNaN || score.isInfinite) return MarkRejection.notANumber;
        if (score < 0) return MarkRejection.belowZero;
        if (score > component.maximumMark) return MarkRejection.aboveMaximum;
        return null;

      case MarkEntryStatus.absent:
      case MarkEntryStatus.exempted:
      case MarkEntryStatus.missing:
      case MarkEntryStatus.notAssessed:
        // These are answers in their own right, but they exclude a number -
        // an "absent" with 45 next to it is ambiguous and would be averaged
        // inconsistently by whoever reads it next.
        if (score != null) return MarkRejection.statusWithScore;
        return null;

      case MarkEntryStatus.notEntered:
        // A bare number with no status is a half-finished row, not a mark.
        if (score != null) return MarkRejection.scoreWithoutStatus;
        return null;
    }
  }

  /// Parses typed text into a mark. Returns null for blank input, which is
  /// how a teacher clears a cell.
  double? parseScore(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  /// Builds the review summary and decides whether submission may proceed.
  MarksSubmissionReport review({
    required ActiveResponsibilityContext context,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
    required Set<String> enrolledStudentIds,
  }) {
    SubmissionRefusal? refusal;

    if (!context.can(Permission.subjectMarksSubmit)) {
      refusal = SubmissionRefusal.noPermission;
    } else if (!context.permissionScope.covers(
      subjectId: assessment.subjectId,
      classId: assessment.classId,
      streamId: assessment.streamId,
      academicYearId: assessment.academicYearId,
      termId: assessment.termId,
    )) {
      refusal = SubmissionRefusal.outsideScope;
    } else if (assessment.status == AssessmentAvailability.locked ||
        assessment.status == AssessmentAvailability.approved ||
        assessment.status == AssessmentAvailability.published) {
      refusal = SubmissionRefusal.assessmentLocked;
    } else if (!assessment.status.acceptsEntry) {
      refusal = SubmissionRefusal.assessmentNotOpen;
    } else if (!assessment.hasOpened) {
      refusal = SubmissionRefusal.entryNotOpenYet;
    }

    final relevant =
        entries.where((e) => enrolledStudentIds.contains(e.studentId)).toList();

    var entered = 0;
    var absent = 0;
    var exempted = 0;
    var invalid = 0;

    for (final entry in relevant) {
      if (validateEntry(
            entry: entry,
            component: component,
            enrolledStudentIds: enrolledStudentIds,
          ) !=
          null) {
        invalid++;
        continue;
      }
      switch (entry.status) {
        case MarkEntryStatus.scored:
          entered++;
        case MarkEntryStatus.absent:
          absent++;
        case MarkEntryStatus.exempted:
          exempted++;
        case MarkEntryStatus.missing:
        case MarkEntryStatus.notAssessed:
        case MarkEntryStatus.notEntered:
          break;
      }
    }

    // Every enrolled student needs an answer, even if that answer is
    // "absent". Anything left over is a gap, including a student with no row
    // at all.
    final resolvedIds = relevant
        .where((e) => e.status.isResolved)
        .map((e) => e.studentId)
        .toSet();
    final pending = enrolledStudentIds.difference(resolvedIds).length;

    if (refusal == null) {
      if (enrolledStudentIds.isEmpty) {
        refusal = SubmissionRefusal.noStudents;
      } else if (invalid > 0) {
        refusal = SubmissionRefusal.invalidMarks;
      } else if (pending > 0) {
        refusal = SubmissionRefusal.missingMarks;
      }
    }

    return MarksSubmissionReport(
      totalStudents: enrolledStudentIds.length,
      entered: entered,
      pending: pending,
      absent: absent,
      exempted: exempted,
      invalid: invalid,
      refusal: refusal,
    );
  }

  /// Whether an already-submitted mark may be edited at all, and if so
  /// whether a reason is required.
  bool requiresReasonToEdit(AssessmentAvailability status) =>
      status != AssessmentAvailability.open &&
      status != AssessmentAvailability.inProgress;

  bool canEdit({
    required ActiveResponsibilityContext context,
    required AssessmentAvailability status,
  }) {
    if (status == AssessmentAvailability.locked ||
        status == AssessmentAvailability.approved ||
        status == AssessmentAvailability.published) {
      // Approved marks feed report cards. Changing one is a correction
      // request, not an edit.
      return false;
    }
    if (requiresReasonToEdit(status)) {
      return context.can(Permission.subjectMarksEditSubmitted);
    }
    return context.can(Permission.subjectMarksEdit);
  }
}
