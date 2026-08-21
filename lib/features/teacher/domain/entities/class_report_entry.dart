import 'package:equatable/equatable.dart';

/// Where one student's report has got to.
///
/// The exact chain is the school's - some skip leadership approval, some add
/// steps - so this is the superset the panel understands, and the school's
/// configured workflow decides which of them are actually used.
enum ReportEntryStatus {
  draft,
  inProgress,
  submittedForReview,
  returnedForCorrection,
  classTeacherCompleted,
  academicOfficeApproved,
  leadershipApproved,
  published,
  archived;

  static ReportEntryStatus fromId(String? id) {
    if (id == null) return ReportEntryStatus.draft;
    final normalised = id.replaceAll('_', '').toLowerCase();
    for (final s in ReportEntryStatus.values) {
      if (s.name.toLowerCase() == normalised) return s;
    }
    return ReportEntryStatus.draft;
  }

  /// The states a class teacher may still write in. Past this the report
  /// belongs to the academic office, and the teacher's copy is read-only.
  bool get isTeacherEditable =>
      this == draft || this == inProgress || this == returnedForCorrection;

  bool get isApprovedUpstream =>
      this == academicOfficeApproved ||
      this == leadershipApproved ||
      this == published ||
      this == archived;
}

extension ReportEntryStatusDisplay on ReportEntryStatus {
  /// Stable persisted value used by Firestore and its security rules.
  /// Dart enum names are camelCase while the database contract is snake_case.
  String get storageId => switch (this) {
    ReportEntryStatus.draft => 'draft',
    ReportEntryStatus.inProgress => 'in_progress',
    ReportEntryStatus.submittedForReview => 'submitted_for_review',
    ReportEntryStatus.returnedForCorrection => 'returned_for_correction',
    ReportEntryStatus.classTeacherCompleted => 'class_teacher_completed',
    ReportEntryStatus.academicOfficeApproved => 'academic_office_approved',
    ReportEntryStatus.leadershipApproved => 'leadership_approved',
    ReportEntryStatus.published => 'published',
    ReportEntryStatus.archived => 'archived',
  };

  String get label => switch (this) {
    ReportEntryStatus.draft => 'Draft',
    ReportEntryStatus.inProgress => 'In progress',
    ReportEntryStatus.submittedForReview => 'Submitted for review',
    ReportEntryStatus.returnedForCorrection => 'Returned for correction',
    ReportEntryStatus.classTeacherCompleted => 'Completed',
    ReportEntryStatus.academicOfficeApproved => 'Approved',
    ReportEntryStatus.leadershipApproved => 'Leadership approved',
    ReportEntryStatus.published => 'Published',
    ReportEntryStatus.archived => 'Archived',
  };
}

/// A section of the report the class teacher fills in.
///
/// Which of these a school uses is configuration, not an assumption: a
/// competency-based curriculum may skip conduct ratings entirely, and a
/// school that does not do recommendations should not be told its reports are
/// incomplete.
enum ReportSection {
  competencies,
  conduct,
  teacherComment,
  recommendations,
  attendanceVerification;

  static ReportSection? fromId(String? id) {
    if (id == null) return null;
    final normalised = id.replaceAll('_', '').toLowerCase();
    for (final s in ReportSection.values) {
      if (s.name.toLowerCase() == normalised) return s;
    }
    return null;
  }

  String get label => switch (this) {
    ReportSection.competencies => 'Competencies',
    ReportSection.conduct => 'Conduct',
    ReportSection.teacherComment => 'Teacher comment',
    ReportSection.recommendations => 'Recommendations',
    ReportSection.attendanceVerification => 'Attendance',
  };
}

/// One competency rating against a school-defined domain and level.
///
/// Both the domain and the level come from the school's report configuration:
/// "Emerging / Developing / Achieved / Exceeding" is one school's scale, not
/// the app's.
class CompetencyEntry extends Equatable {
  final String domainId;
  final String domainLabel;
  final String? levelCode;
  final String? evidenceNote;

  const CompetencyEntry({
    required this.domainId,
    this.domainLabel = '',
    this.levelCode,
    this.evidenceNote,
  });

  bool get isRated => levelCode != null && levelCode!.isNotEmpty;

  CompetencyEntry copyWith({String? levelCode, String? evidenceNote}) {
    return CompetencyEntry(
      domainId: domainId,
      domainLabel: domainLabel,
      levelCode: levelCode ?? this.levelCode,
      evidenceNote: evidenceNote ?? this.evidenceNote,
    );
  }

  @override
  List<Object?> get props => [domainId, domainLabel, levelCode, evidenceNote];
}

/// One conduct rating against a school-defined criterion.
class ConductEntry extends Equatable {
  final String criterionId;
  final String criterionLabel;
  final String? ratingCode;

  const ConductEntry({
    required this.criterionId,
    this.criterionLabel = '',
    this.ratingCode,
  });

  bool get isRated => ratingCode != null && ratingCode!.isNotEmpty;

  ConductEntry copyWith({String? ratingCode}) {
    return ConductEntry(
      criterionId: criterionId,
      criterionLabel: criterionLabel,
      ratingCode: ratingCode ?? this.ratingCode,
    );
  }

  @override
  List<Object?> get props => [criterionId, criterionLabel, ratingCode];
}

/// The class teacher's contribution to one student's report.
///
/// Deliberately holds none of what the Report Card Engine owns - no grades,
/// no totals, no rankings, no layout. Those are computed from approved subject
/// marks at generation time, and a copy held here would be a second source of
/// truth that could disagree.
class ClassReportEntry extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final String termId;

  final String studentId;
  final String studentName;
  final ReportEntryStatus status;

  final List<CompetencyEntry> competencies;
  final List<ConductEntry> conduct;
  final String? overallConductCode;
  final String? teacherComment;
  final List<String> recommendations;

  /// Set once the teacher has confirmed the attendance figures the Attendance
  /// engine produced. They verify; they never type the totals.
  final bool attendanceVerified;

  /// Why the academic office sent it back, when they did.
  final String? returnReason;

  final String? updatedBy;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final String roleAssignmentId;

  const ClassReportEntry({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.classId,
    this.streamId,
    required this.academicYearId,
    required this.termId,
    required this.studentId,
    this.studentName = '',
    this.status = ReportEntryStatus.draft,
    this.competencies = const [],
    this.conduct = const [],
    this.overallConductCode,
    this.teacherComment,
    this.recommendations = const [],
    this.attendanceVerified = false,
    this.returnReason,
    this.updatedBy,
    this.updatedAt,
    this.submittedAt,
    this.roleAssignmentId = '',
  });

  bool get isEditable => status.isTeacherEditable;

  bool get wasReturned => status == ReportEntryStatus.returnedForCorrection;

  /// Whether one section has everything it needs. Sections the school has
  /// switched off are the caller's to exclude - see [ClassReportPolicy].
  bool isSectionComplete(ReportSection section, {int commentMinLength = 20}) {
    return switch (section) {
      ReportSection.competencies =>
        competencies.isNotEmpty && competencies.every((c) => c.isRated),
      ReportSection.conduct =>
        conduct.isNotEmpty && conduct.every((c) => c.isRated),
      ReportSection.teacherComment =>
        (teacherComment?.trim().length ?? 0) >= commentMinLength,
      ReportSection.recommendations => recommendations.isNotEmpty,
      ReportSection.attendanceVerification => attendanceVerified,
    };
  }

  ClassReportEntry copyWith({
    ReportEntryStatus? status,
    List<CompetencyEntry>? competencies,
    List<ConductEntry>? conduct,
    String? overallConductCode,
    String? teacherComment,
    List<String>? recommendations,
    bool? attendanceVerified,
    String? returnReason,
    String? updatedBy,
    DateTime? updatedAt,
    DateTime? submittedAt,
    String? roleAssignmentId,
  }) {
    return ClassReportEntry(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      studentId: studentId,
      studentName: studentName,
      status: status ?? this.status,
      competencies: competencies ?? this.competencies,
      conduct: conduct ?? this.conduct,
      overallConductCode: overallConductCode ?? this.overallConductCode,
      teacherComment: teacherComment ?? this.teacherComment,
      recommendations: recommendations ?? this.recommendations,
      attendanceVerified: attendanceVerified ?? this.attendanceVerified,
      returnReason: returnReason ?? this.returnReason,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    classId,
    streamId,
    academicYearId,
    termId,
    studentId,
    studentName,
    status,
    competencies,
    conduct,
    overallConductCode,
    teacherComment,
    recommendations,
    attendanceVerified,
    returnReason,
    updatedBy,
    updatedAt,
    submittedAt,
    roleAssignmentId,
  ];
}

/// The school's report configuration - which sections apply, and what the
/// scales are called.
class ReportProfile extends Equatable {
  final String id;
  final String name;
  final Set<ReportSection> enabledSections;

  /// Competency domains, in the order the entry screen should show them.
  final List<({String id, String label})> competencyDomains;

  /// The levels a competency may be rated at, e.g. Emerging / Achieved.
  final List<({String code, String label})> competencyLevels;

  final List<({String id, String label})> conductCriteria;
  final List<({String code, String label})> conductRatings;

  /// Minimum comment length the school expects. A one-word comment on a
  /// report a parent keeps for years is not a comment.
  final int commentMinLength;

  /// Whether the school refuses to generate a report with sections missing.
  final bool requiresCompleteness;

  const ReportProfile({
    required this.id,
    this.name = '',
    this.enabledSections = const {},
    this.competencyDomains = const [],
    this.competencyLevels = const [],
    this.conductCriteria = const [],
    this.conductRatings = const [],
    this.commentMinLength = 20,
    this.requiresCompleteness = true,
  });

  bool isEnabled(ReportSection section) => enabledSections.contains(section);

  @override
  List<Object?> get props => [
    id,
    name,
    enabledSections,
    competencyDomains,
    competencyLevels,
    conductCriteria,
    conductRatings,
    commentMinLength,
    requiresCompleteness,
  ];
}
