import 'package:equatable/equatable.dart';

/// Where an assessment is in the school's marking cycle.
///
/// The Assessment Engine owns these transitions; the panel reads them to
/// decide what a teacher may do. Nothing here is hardcoded to a school's
/// particular workflow - a school that skips moderation simply never uses
/// [returned].
enum AssessmentAvailability {
  draft,
  open,
  inProgress,
  submitted,
  returned,
  approved,
  locked,
  published,
  archived;

  static AssessmentAvailability fromId(String? id) {
    if (id == null) return AssessmentAvailability.draft;
    for (final s in AssessmentAvailability.values) {
      if (s.name == id) return s;
    }
    return AssessmentAvailability.draft;
  }

  /// Whether a teacher may still type marks into it. Approved and published
  /// marks feed report cards, so they are closed to ordinary entry.
  bool get acceptsEntry =>
      this == open || this == inProgress || this == returned;
}

extension AssessmentAvailabilityDisplay on AssessmentAvailability {
  String get label => switch (this) {
    AssessmentAvailability.draft => 'Draft',
    AssessmentAvailability.open => 'Open',
    AssessmentAvailability.inProgress => 'In progress',
    AssessmentAvailability.submitted => 'Submitted',
    AssessmentAvailability.returned => 'Returned for correction',
    AssessmentAvailability.approved => 'Approved',
    AssessmentAvailability.locked => 'Locked',
    AssessmentAvailability.published => 'Published',
    AssessmentAvailability.archived => 'Archived',
  };
}

/// One markable part of an assessment - Section A, Coursework, Practical.
///
/// The names and weights come from the school's configuration, never from a
/// list in this file: a school marking out of 40 for Paper 1 and 60 for
/// Paper 2 has to be able to say so.
class AssessmentComponent extends Equatable {
  final String id;
  final String assessmentId;
  final String name;
  final double maximumMark;
  final double weight;
  final bool isRequired;
  final AssessmentAvailability entryStatus;
  final DateTime? deadline;

  const AssessmentComponent({
    required this.id,
    required this.assessmentId,
    required this.name,
    required this.maximumMark,
    this.weight = 0,
    this.isRequired = true,
    this.entryStatus = AssessmentAvailability.open,
    this.deadline,
  });

  bool get isOverdue => deadline != null && DateTime.now().isAfter(deadline!);

  @override
  List<Object?> get props => [
    id,
    assessmentId,
    name,
    maximumMark,
    weight,
    isRequired,
    entryStatus,
    deadline,
  ];
}

/// An assessment as the Subject Teacher panel sees it: scoped to one subject
/// and class, with the components they have to fill in.
class SubjectAssessment extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String academicYearId;
  final String termId;
  final String subjectId;
  final String classId;
  final String? streamId;

  /// The school-configured type this came from (Test, Practical, Midterm...).
  /// An id, not an enum, because the list belongs to the school.
  final String assessmentTypeId;
  final String assessmentTypeName;

  final String title;
  final double maximumMark;
  final double? passMark;
  final String? gradingSystemId;
  final AssessmentAvailability status;
  final DateTime? assessmentDate;
  final DateTime? entryOpensAt;
  final DateTime? submissionDeadline;
  final List<AssessmentComponent> components;
  final bool requiresApproval;

  const SubjectAssessment({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.academicYearId,
    this.termId = '',
    required this.subjectId,
    required this.classId,
    this.streamId,
    this.assessmentTypeId = '',
    this.assessmentTypeName = '',
    this.title = '',
    this.maximumMark = 100,
    this.passMark,
    this.gradingSystemId,
    this.status = AssessmentAvailability.draft,
    this.assessmentDate,
    this.entryOpensAt,
    this.submissionDeadline,
    this.components = const [],
    this.requiresApproval = true,
  });

  /// Assessments without explicit components are marked as a single whole;
  /// this gives callers one code path either way.
  List<AssessmentComponent> get markableComponents => components.isNotEmpty
      ? components
      : [
          AssessmentComponent(
            id: id,
            assessmentId: id,
            name: title.isEmpty ? assessmentTypeName : title,
            maximumMark: maximumMark,
          ),
        ];

  bool get isOverdue =>
      submissionDeadline != null && DateTime.now().isAfter(submissionDeadline!);

  bool get hasOpened =>
      entryOpensAt == null || DateTime.now().isAfter(entryOpensAt!);

  AssessmentComponent? componentById(String componentId) =>
      markableComponents.where((c) => c.id == componentId).firstOrNull;

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    academicYearId,
    termId,
    subjectId,
    classId,
    streamId,
    assessmentTypeId,
    assessmentTypeName,
    title,
    maximumMark,
    passMark,
    gradingSystemId,
    status,
    assessmentDate,
    entryOpensAt,
    submissionDeadline,
    components,
    requiresApproval,
  ];
}

/// Why a student has no numeric mark.
///
/// A blank and a zero are not the same thing, and neither is an absence. A
/// student who did not sit the paper must not be averaged in as having
/// scored nothing.
enum MarkEntryStatus {
  notEntered,
  scored,
  absent,
  exempted,
  missing,
  notAssessed;

  static MarkEntryStatus fromId(String? id) {
    if (id == null) return MarkEntryStatus.notEntered;
    for (final s in MarkEntryStatus.values) {
      if (s.name == id) return s;
    }
    return MarkEntryStatus.notEntered;
  }

  /// Whether this row contributes to a class average.
  bool get countsTowardsAverage => this == scored;

  /// Whether the teacher has dealt with this student at all - a status is an
  /// answer even when there is no number.
  bool get isResolved => this != notEntered;
}

extension MarkEntryStatusDisplay on MarkEntryStatus {
  String get label => switch (this) {
    MarkEntryStatus.notEntered => 'Not entered',
    MarkEntryStatus.scored => 'Scored',
    MarkEntryStatus.absent => 'Absent',
    MarkEntryStatus.exempted => 'Exempted',
    MarkEntryStatus.missing => 'Missing',
    MarkEntryStatus.notAssessed => 'Not assessed',
  };
}

/// One student's mark for one component.
class StudentMarkEntry extends Equatable {
  final String studentId;
  final String componentId;
  final double? score;
  final MarkEntryStatus status;
  final String? remark;
  final DateTime? enteredAt;

  const StudentMarkEntry({
    required this.studentId,
    required this.componentId,
    this.score,
    this.status = MarkEntryStatus.notEntered,
    this.remark,
    this.enteredAt,
  });

  double? percentageOf(double maximumMark) {
    final value = score;
    if (value == null || !status.countsTowardsAverage || maximumMark <= 0) {
      return null;
    }
    return (value / maximumMark) * 100;
  }

  StudentMarkEntry copyWith({
    double? score,
    MarkEntryStatus? status,
    String? remark,
    DateTime? enteredAt,
    bool clearScore = false,
  }) {
    return StudentMarkEntry(
      studentId: studentId,
      componentId: componentId,
      score: clearScore ? null : (score ?? this.score),
      status: status ?? this.status,
      remark: remark ?? this.remark,
      enteredAt: enteredAt ?? this.enteredAt,
    );
  }

  @override
  List<Object?> get props => [
    studentId,
    componentId,
    score,
    status,
    remark,
    enteredAt,
  ];
}
