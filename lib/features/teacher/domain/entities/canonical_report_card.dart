import 'package:equatable/equatable.dart';

/// The academic approval workflow status a canonical report card carries.
///
/// Mirrors ACADEMIC_STATUS in functions/report_card_engine.js exactly -
/// every transition is enforced server-side by the Cloud Functions in
/// functions/index.js (submitReportCardsToDean, signReportCardAsDean, ...),
/// never by this client. This enum exists so the UI can render the right
/// screen/action for a status, not to decide whether a transition is legal.
enum AcademicWorkflowStatus {
  draft,
  generated,
  classTeacherReview,
  submittedToDean,
  returnedByDean,
  deanSigned,
  submittedToHeadteacher,
  returnedByHeadteacher,
  academicallyFinalized,
  superseded;

  static AcademicWorkflowStatus fromId(String? id) {
    for (final s in AcademicWorkflowStatus.values) {
      if (s.name == id) return s;
    }
    return AcademicWorkflowStatus.draft;
  }
}

extension AcademicWorkflowStatusDisplay on AcademicWorkflowStatus {
  String get label => switch (this) {
    AcademicWorkflowStatus.draft => 'Draft',
    AcademicWorkflowStatus.generated => 'Generated',
    AcademicWorkflowStatus.classTeacherReview => 'Needs your review',
    AcademicWorkflowStatus.submittedToDean => 'Awaiting Dean',
    AcademicWorkflowStatus.returnedByDean => 'Returned by Dean',
    AcademicWorkflowStatus.deanSigned => 'Signed by Dean',
    AcademicWorkflowStatus.submittedToHeadteacher => 'Awaiting Headteacher',
    AcademicWorkflowStatus.returnedByHeadteacher => 'Returned by Headteacher',
    AcademicWorkflowStatus.academicallyFinalized => 'Finalized',
    AcademicWorkflowStatus.superseded => 'Superseded',
  };

  /// Whether the Class Teacher may still edit their own sections and
  /// resubmit. Deliberately excludes `generated` - a fresh compile still
  /// needs the teacher to move it into review before it can be submitted.
  bool get isEditableByClassTeacher =>
      this == AcademicWorkflowStatus.classTeacherReview ||
      this == AcademicWorkflowStatus.returnedByDean ||
      this == AcademicWorkflowStatus.returnedByHeadteacher;

  bool get isPendingDean => this == AcademicWorkflowStatus.submittedToDean;
  bool get isPendingHeadteacher =>
      this == AcademicWorkflowStatus.submittedToHeadteacher;
}

/// One append-only decision in a report card's approval history. Never
/// rewritten or reordered - see approvalHistory on [CanonicalReportCard].
class ApprovalHistoryEntry extends Equatable {
  final String action;
  final String actorUid;
  final String actorRole;
  final String actorDisplayName;
  final String? reason;
  final int reportVersion;
  final String sourceHashReviewed;
  final DateTime? timestamp;

  const ApprovalHistoryEntry({
    required this.action,
    required this.actorUid,
    required this.actorRole,
    required this.actorDisplayName,
    this.reason,
    required this.reportVersion,
    required this.sourceHashReviewed,
    this.timestamp,
  });

  @override
  List<Object?> get props => [
    action,
    actorUid,
    actorRole,
    actorDisplayName,
    reason,
    reportVersion,
    sourceHashReviewed,
    timestamp,
  ];
}

/// A Dean or Headteacher decision recorded directly on the report (the
/// "current" decision at that stage, as opposed to the full history log).
class StageDecision extends Equatable {
  final String decision; // 'signed' | 'returned'
  final String actorUid;
  final String actorDisplayName;
  final String? reason;
  final int reportVersion;
  final DateTime? decidedAt;

  const StageDecision({
    required this.decision,
    required this.actorUid,
    required this.actorDisplayName,
    this.reason,
    required this.reportVersion,
    this.decidedAt,
  });

  bool get isSigned => decision == 'signed';

  @override
  List<Object?> get props => [
    decision,
    actorUid,
    actorDisplayName,
    reason,
    reportVersion,
    decidedAt,
  ];
}

/// One subject's computed result within a report, as the Report Card Engine
/// wrote it - read-only from the client's perspective.
class SubjectResultSnapshot extends Equatable {
  final String subjectId;
  final bool isComplete;
  final String? incompleteReason;
  final double? average;
  final String? grade;
  final String? gradeLabel;
  final double? gradePoint;
  final bool? isPassing;

  const SubjectResultSnapshot({
    required this.subjectId,
    required this.isComplete,
    this.incompleteReason,
    this.average,
    this.grade,
    this.gradeLabel,
    this.gradePoint,
    this.isPassing,
  });

  factory SubjectResultSnapshot.fromMap(Map<String, dynamic> map) {
    return SubjectResultSnapshot(
      subjectId: map['subjectId'] as String? ?? '',
      isComplete: map['isComplete'] as bool? ?? false,
      incompleteReason: map['incompleteReason'] as String?,
      average: (map['average'] as num?)?.toDouble(),
      grade: map['grade'] as String?,
      gradeLabel: map['gradeLabel'] as String?,
      gradePoint: (map['gradePoint'] as num?)?.toDouble(),
      isPassing: map['isPassing'] as bool?,
    );
  }

  @override
  List<Object?> get props => [
    subjectId,
    isComplete,
    incompleteReason,
    average,
    grade,
    gradeLabel,
    gradePoint,
    isPassing,
  ];
}

/// The canonical, server-computed report-card snapshot - a read-only view
/// of `schools/{schoolId}/reportCards/{reportCardId}` for the Class
/// Teacher/Dean/Headteacher review surfaces. Every field here reflects what
/// the Report Card Engine actually wrote; nothing in this entity is
/// editable by the client, and no setter exists that would let the UI
/// pretend otherwise - actions are requested through the workflow
/// repository methods, which call the trusted Cloud Functions.
class CanonicalReportCard extends Equatable {
  final String reportCardId;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String academicYearId;
  final String termId;
  final String classId;
  final String? streamId;
  final List<SubjectResultSnapshot> subjectResults;
  final double? totalScore;
  final double? average;
  final String? overallGrade;
  final String? overallGradeLabel;
  final bool? isOverallPassing;
  final double? aggregatePoints;
  final int? position;
  final bool isRanked;
  final bool attendanceVerified;
  final String? overallConductCode;
  final String? classTeacherComment;
  final List<String> recommendations;
  final AcademicWorkflowStatus academicStatus;
  final String currentApprovalStage;
  final int version;
  final String sourceHash;
  final bool isFinalized;
  final StageDecision? deanDecision;
  final StageDecision? headteacherDecision;
  final DateTime? academicallyFinalizedAt;
  final String? academicallyFinalizedBy;
  final String? supersedesReportCardId;
  final String? supersededByReportCardId;
  final List<ApprovalHistoryEntry> approvalHistory;

  const CanonicalReportCard({
    required this.reportCardId,
    required this.schoolId,
    required this.studentId,
    this.studentName = '',
    required this.academicYearId,
    required this.termId,
    required this.classId,
    this.streamId,
    this.subjectResults = const [],
    this.totalScore,
    this.average,
    this.overallGrade,
    this.overallGradeLabel,
    this.isOverallPassing,
    this.aggregatePoints,
    this.position,
    this.isRanked = false,
    this.attendanceVerified = false,
    this.overallConductCode,
    this.classTeacherComment,
    this.recommendations = const [],
    this.academicStatus = AcademicWorkflowStatus.draft,
    this.currentApprovalStage = 'classTeacher',
    this.version = 1,
    this.sourceHash = '',
    this.isFinalized = false,
    this.deanDecision,
    this.headteacherDecision,
    this.academicallyFinalizedAt,
    this.academicallyFinalizedBy,
    this.supersedesReportCardId,
    this.supersededByReportCardId,
    this.approvalHistory = const [],
  });

  /// Every enabled section actually resolved to a complete subject result -
  /// the review-readiness signal the Class Teacher sees before submitting.
  bool get hasIncompleteSubjects =>
      subjectResults.any((s) => !s.isComplete);

  List<SubjectResultSnapshot> get incompleteSubjects =>
      subjectResults.where((s) => !s.isComplete).toList();

  @override
  List<Object?> get props => [
    reportCardId,
    schoolId,
    studentId,
    studentName,
    academicYearId,
    termId,
    classId,
    streamId,
    subjectResults,
    totalScore,
    average,
    overallGrade,
    overallGradeLabel,
    isOverallPassing,
    aggregatePoints,
    position,
    isRanked,
    attendanceVerified,
    overallConductCode,
    classTeacherComment,
    recommendations,
    academicStatus,
    currentApprovalStage,
    version,
    sourceHash,
    isFinalized,
    deanDecision,
    headteacherDecision,
    academicallyFinalizedAt,
    academicallyFinalizedBy,
    supersedesReportCardId,
    supersededByReportCardId,
    approvalHistory,
  ];
}

/// The outcome of a bulk report-card submission. Never silently drops a
/// learner - every id passed in ends up in exactly one of these lists.
class SubmitReportCardsResult extends Equatable {
  final List<String> submitted;
  final List<SubmitReportCardFailure> failed;

  const SubmitReportCardsResult({
    this.submitted = const [],
    this.failed = const [],
  });

  @override
  List<Object?> get props => [submitted, failed];
}

class SubmitReportCardFailure extends Equatable {
  final String reportCardId;
  final String reason;

  const SubmitReportCardFailure({
    required this.reportCardId,
    required this.reason,
  });

  @override
  List<Object?> get props => [reportCardId, reason];
}
