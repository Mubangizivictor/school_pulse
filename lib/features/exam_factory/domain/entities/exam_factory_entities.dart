import 'package:equatable/equatable.dart';

/// Lifecycle is deliberately separate from the legacy assessment status.
/// Persist enum names, rather than display labels, in the backend.
enum ExamSeriesStatus {
  draft,
  collectingQuestions,
  moderating,
  buildingPapers,
  awaitingApproval,
  printing,
  scheduled,
  inProgress,
  marking,
  resultsReview,
  published,
  archived,
  cancelled,
}

enum ExamQuestionStatus {
  draft,
  submitted,
  underReview,
  changesRequested,
  resubmitted,
  approved,
  rejected,
  usedInPaper,
  archived,
}

enum ExamPaperStatus {
  draft,
  compiling,
  readyForModeration,
  changesRequested,
  readyForApproval,
  approved,
  locked,
  printReady,
  printed,
  administered,
  archived,
}

enum ExamQuestionType {
  multipleChoice,
  shortAnswer,
  structured,
  essay,
  calculation,
  practical,
  comprehension,
  matching,
  diagramLabelling,
}

enum ExamQuestionDifficulty { easy, medium, hard }

class ExamSeries extends Equatable {
  final String id, institutionId, name, academicYear, term, type;
  final DateTime startDate, endDate;
  final DateTime? questionDeadline,
      moderationDeadline,
      paperApprovalDeadline,
      printingDeadline,
      markingDeadline,
      resultPublicationDate;
  final ExamSeriesStatus status;
  final List<String> classIds, subjectIds;
  final String gradingScaleId, paperTemplateId;
  final DateTime? createdAt, updatedAt;
  final String createdBy;

  const ExamSeries({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.academicYear,
    required this.term,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.type = 'midterm',
    this.classIds = const [],
    this.subjectIds = const [],
    this.gradingScaleId = '',
    this.paperTemplateId = '',
    this.questionDeadline,
    this.moderationDeadline,
    this.paperApprovalDeadline,
    this.printingDeadline,
    this.markingDeadline,
    this.resultPublicationDate,
    this.createdAt,
    this.updatedAt,
    this.createdBy = '',
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    name,
    academicYear,
    term,
    type,
    startDate,
    endDate,
    status,
    classIds,
    subjectIds,
    gradingScaleId,
    paperTemplateId,
    questionDeadline,
    moderationDeadline,
    paperApprovalDeadline,
    printingDeadline,
    markingDeadline,
    resultPublicationDate,
    createdAt,
    updatedAt,
    createdBy,
  ];
}

class ExamQuestion extends Equatable {
  final String id,
      seriesId,
      institutionId,
      classId,
      subjectId,
      topic,
      creatorId,
      text,
      suggestedAnswer,
      markingGuide,
      teacherNotes,
      moderationComment,
      moderatedBy;
  final int marks, version;
  final ExamQuestionType type;
  final ExamQuestionStatus status;
  final ExamQuestionDifficulty difficulty;
  final List<String> attachmentUrls;
  final DateTime? createdAt, updatedAt, submittedAt, moderatedAt;

  const ExamQuestion({
    required this.id,
    required this.seriesId,
    required this.institutionId,
    required this.classId,
    required this.subjectId,
    required this.topic,
    required this.creatorId,
    required this.text,
    required this.marks,
    required this.version,
    required this.type,
    required this.status,
    this.difficulty = ExamQuestionDifficulty.medium,
    this.suggestedAnswer = '',
    this.markingGuide = '',
    this.teacherNotes = '',
    this.moderationComment = '',
    this.moderatedBy = '',
    this.attachmentUrls = const [],
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.moderatedAt,
  });

  bool get isEditable =>
      status == ExamQuestionStatus.draft ||
      status == ExamQuestionStatus.changesRequested;

  ExamQuestion copyWith({
    String? topic,
    String? text,
    String? suggestedAnswer,
    String? markingGuide,
    String? teacherNotes,
    int? marks,
    ExamQuestionType? type,
    ExamQuestionDifficulty? difficulty,
    String? classId,
    String? subjectId,
    String? seriesId,
    List<String>? attachmentUrls,
  }) => ExamQuestion(
    id: id,
    seriesId: seriesId ?? this.seriesId,
    institutionId: institutionId,
    classId: classId ?? this.classId,
    subjectId: subjectId ?? this.subjectId,
    topic: topic ?? this.topic,
    creatorId: creatorId,
    text: text ?? this.text,
    marks: marks ?? this.marks,
    version: version,
    type: type ?? this.type,
    status: status,
    difficulty: difficulty ?? this.difficulty,
    suggestedAnswer: suggestedAnswer ?? this.suggestedAnswer,
    markingGuide: markingGuide ?? this.markingGuide,
    teacherNotes: teacherNotes ?? this.teacherNotes,
    moderationComment: moderationComment,
    moderatedBy: moderatedBy,
    attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    createdAt: createdAt,
    updatedAt: updatedAt,
    submittedAt: submittedAt,
    moderatedAt: moderatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    seriesId,
    institutionId,
    classId,
    subjectId,
    topic,
    creatorId,
    text,
    marks,
    version,
    type,
    status,
    difficulty,
    suggestedAnswer,
    markingGuide,
    teacherNotes,
    moderationComment,
    moderatedBy,
    attachmentUrls,
    createdAt,
    updatedAt,
    submittedAt,
    moderatedAt,
  ];
}

class ExamPaper extends Equatable {
  final String id, seriesId, institutionId, classId, subjectId, title;
  final int targetMarks, totalMarks, version, durationMinutes;
  final ExamPaperStatus status;
  final List<String> questionIds;
  final DateTime? createdAt, updatedAt, lockedAt;
  final String lockedBy, questionPaperPath, markingGuidePath;
  final int generatedFilesVersion;

  const ExamPaper({
    required this.id,
    required this.seriesId,
    required this.institutionId,
    required this.classId,
    required this.subjectId,
    required this.title,
    required this.targetMarks,
    required this.totalMarks,
    required this.version,
    required this.status,
    this.durationMinutes = 60,
    this.questionIds = const [],
    this.createdAt,
    this.updatedAt,
    this.lockedAt,
    this.lockedBy = '',
    this.questionPaperPath = '',
    this.markingGuidePath = '',
    this.generatedFilesVersion = 0,
  });

  bool get isMarksValid => targetMarks == totalMarks;
  bool get isLocked => const {
    ExamPaperStatus.locked,
    ExamPaperStatus.printReady,
    ExamPaperStatus.printed,
    ExamPaperStatus.administered,
  }.contains(status);
  bool get filesGenerated =>
      questionPaperPath.isNotEmpty &&
      markingGuidePath.isNotEmpty &&
      generatedFilesVersion == version;

  @override
  List<Object?> get props => [
    id,
    seriesId,
    institutionId,
    classId,
    subjectId,
    title,
    targetMarks,
    totalMarks,
    version,
    status,
    durationMinutes,
    questionIds,
    createdAt,
    updatedAt,
    lockedAt,
    lockedBy,
    questionPaperPath,
    markingGuidePath,
    generatedFilesVersion,
  ];
}

enum PrintJobStatus { started, completed }

enum ScriptStatus { distributed, collected, missing }

class ExamSeatAssignment extends Equatable {
  final String id, institutionId, sittingId, studentId, studentName, seatNumber;
  final DateTime? assignedAt;

  const ExamSeatAssignment({
    required this.id,
    required this.institutionId,
    required this.sittingId,
    required this.studentId,
    required this.seatNumber,
    this.studentName = '',
    this.assignedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    sittingId,
    studentId,
    studentName,
    seatNumber,
    assignedAt,
  ];
}

class ExamScriptRecord extends Equatable {
  final String id, institutionId, sittingId, studentId, studentName, note;
  final ScriptStatus status;
  final DateTime? recordedAt;

  const ExamScriptRecord({
    required this.id,
    required this.institutionId,
    required this.sittingId,
    required this.studentId,
    required this.status,
    this.studentName = '',
    this.note = '',
    this.recordedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    sittingId,
    studentId,
    studentName,
    status,
    note,
    recordedAt,
  ];
}

/// One entry from schools/{schoolId}/exam_factory_audit - read-only, never
/// written from the client (every write comes from a Cloud Function's own
/// audit() call). Used to render moderation/approval history.
class ExamAuditEntry extends Equatable {
  final String id, action, actorId, role;
  final DateTime? at;

  const ExamAuditEntry({
    required this.id,
    required this.action,
    this.actorId = '',
    this.role = '',
    this.at,
  });

  String get actionLabel => switch (action) {
    'series_saved' => 'Examination series saved',
    'question_draft_saved' => 'Draft saved',
    'question_submitted' => 'Submitted for review',
    'question_moderated' => 'Moderation decision recorded',
    'paper_saved' => 'Paper saved',
    'paper_approval_requested' => 'Sent for approval',
    'paper_approved' => 'Approved',
    'paper_locked' => 'Locked',
    'paper_files_generated' => 'Controlled PDF generated',
    'paper_file_downloaded' => 'File downloaded',
    'print_job_started' => 'Print job started',
    'print_job_completed' => 'Print job completed',
    'sitting_saved' => 'Sitting scheduled',
    'invigilator_assigned' => 'Invigilator assigned',
    'invigilator_removed' => 'Invigilator removed',
    'attendance_recorded' => 'Attendance recorded',
    'incident_reported' => 'Incident reported',
    'incident_resolved' => 'Incident resolved',
    'mark_saved' => 'Mark saved',
    'marks_submitted' => 'Marks submitted',
    'results_approved' => 'Results approved',
    'reminder_sent' => 'Reminder sent',
    'seat_assigned' => 'Seat assigned',
    'seat_removed' => 'Seat removed',
    'script_recorded' => 'Script recorded',
    _ => action,
  };

  @override
  List<Object?> get props => [id, action, actorId, role, at];
}

enum ExamAttendanceStatus { present, absent, late, extraTime }

enum ExamIncidentType {
  lateArrival,
  malpractice,
  illness,
  materialsIssue,
  disturbance,
  other,
}

enum ExamIncidentStatus { open, underReview, resolved }

enum InvigilatorRole { chief, assistant }

enum MarkEntryStatus { draft, submitted, verified, approved, published }

/// A scheduled, dated sitting of one paper - distinct from the recurring
/// weekly class timetable (Timetable/TimetableLesson), which has no
/// absolute date and is scoped to one class rather than an exam venue.
class ExamSitting extends Equatable {
  final String id, institutionId, seriesId, paperId, venueId, venueName;
  final DateTime startTime;
  final int durationMinutes;
  final DateTime? createdAt, updatedAt;

  const ExamSitting({
    required this.id,
    required this.institutionId,
    required this.seriesId,
    required this.paperId,
    required this.venueId,
    required this.startTime,
    required this.durationMinutes,
    this.venueName = '',
    this.createdAt,
    this.updatedAt,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  @override
  List<Object?> get props => [
    id,
    institutionId,
    seriesId,
    paperId,
    venueId,
    venueName,
    startTime,
    durationMinutes,
    createdAt,
    updatedAt,
  ];
}

class ExamInvigilatorAssignment extends Equatable {
  final String id, institutionId, sittingId, staffId, staffName;
  final InvigilatorRole role;
  final DateTime? assignedAt;

  const ExamInvigilatorAssignment({
    required this.id,
    required this.institutionId,
    required this.sittingId,
    required this.staffId,
    required this.role,
    this.staffName = '',
    this.assignedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    sittingId,
    staffId,
    staffName,
    role,
    assignedAt,
  ];
}

class ExamAttendanceRecord extends Equatable {
  final String id,
      institutionId,
      sittingId,
      studentId,
      studentName,
      recordedBy,
      note;
  final ExamAttendanceStatus status;
  final DateTime? recordedAt;

  const ExamAttendanceRecord({
    required this.id,
    required this.institutionId,
    required this.sittingId,
    required this.studentId,
    required this.status,
    this.studentName = '',
    this.recordedBy = '',
    this.note = '',
    this.recordedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    sittingId,
    studentId,
    studentName,
    status,
    recordedBy,
    note,
    recordedAt,
  ];
}

class ExamIncident extends Equatable {
  final String id, institutionId, sittingId, description, reportedBy;
  final List<String> studentIds;
  final ExamIncidentType type;
  final ExamIncidentStatus status;
  final String resolution;
  final DateTime? reportedAt, resolvedAt;

  const ExamIncident({
    required this.id,
    required this.institutionId,
    required this.sittingId,
    required this.type,
    required this.description,
    this.reportedBy = '',
    this.studentIds = const [],
    this.status = ExamIncidentStatus.open,
    this.resolution = '',
    this.reportedAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    sittingId,
    type,
    description,
    reportedBy,
    studentIds,
    status,
    resolution,
    reportedAt,
    resolvedAt,
  ];
}

/// One student's mark for one exam paper. Approval writes the equivalent
/// row into schools/{schoolId}/student_marks (+ a subject_assessments
/// component) so Performance and Report Cards see it with zero engine
/// changes - see ExamFactoryRepository.approveExamResults.
class ExamMarkEntry extends Equatable {
  final String id, institutionId, paperId, studentId, studentName, remark;
  final double? score;
  final double maximumMark;
  final MarkEntryStatus status;
  final bool isAbsent;
  final DateTime? enteredAt, updatedAt;

  const ExamMarkEntry({
    required this.id,
    required this.institutionId,
    required this.paperId,
    required this.studentId,
    required this.maximumMark,
    required this.status,
    this.score,
    this.studentName = '',
    this.remark = '',
    this.isAbsent = false,
    this.enteredAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    paperId,
    studentId,
    studentName,
    score,
    maximumMark,
    status,
    isAbsent,
    remark,
    enteredAt,
    updatedAt,
  ];
}

class ExamPrintJob extends Equatable {
  final String id,
      institutionId,
      paperId,
      seriesId,
      printer,
      paperSize,
      reprintReason;
  final int version, copies, extraCopies;
  final bool duplex, includeQuestionPaper, includeMarkingGuide, isReprint;
  final PrintJobStatus status;
  final String initiatedBy, completedBy;
  final DateTime? initiatedAt, completedAt;

  const ExamPrintJob({
    required this.id,
    required this.institutionId,
    required this.paperId,
    required this.seriesId,
    required this.version,
    required this.copies,
    required this.status,
    this.extraCopies = 0,
    this.printer = '',
    this.paperSize = 'A4',
    this.duplex = false,
    this.includeQuestionPaper = true,
    this.includeMarkingGuide = false,
    this.isReprint = false,
    this.reprintReason = '',
    this.initiatedBy = '',
    this.completedBy = '',
    this.initiatedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    paperId,
    seriesId,
    version,
    copies,
    extraCopies,
    printer,
    paperSize,
    duplex,
    includeQuestionPaper,
    includeMarkingGuide,
    isReprint,
    reprintReason,
    status,
    initiatedBy,
    completedBy,
    initiatedAt,
    completedAt,
  ];
}
