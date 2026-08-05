import 'package:equatable/equatable.dart';

/// Where a piece of class work is in its life.
///
/// [dueSoon] and [overdue] are derived from the due date rather than stored,
/// so a published item cannot sit in the wrong state because nothing ran a
/// sweep overnight.
enum ClassHomeworkStatus {
  draft,
  published,
  active,
  dueSoon,
  overdue,
  completed,
  archived,
  cancelled;

  static ClassHomeworkStatus fromId(String? id) {
    if (id == null) return ClassHomeworkStatus.draft;
    final normalised = id.replaceAll('_', '').toLowerCase();
    for (final s in ClassHomeworkStatus.values) {
      if (s.name.toLowerCase() == normalised) return s;
    }
    return ClassHomeworkStatus.draft;
  }

  /// The statuses that have reached students and parents. Editing one of
  /// these is a change to work already set, not a draft revision.
  bool get isPublished =>
      this != ClassHomeworkStatus.draft &&
      this != ClassHomeworkStatus.cancelled;

  bool get isOpen =>
      this == ClassHomeworkStatus.published ||
      this == ClassHomeworkStatus.active ||
      this == ClassHomeworkStatus.dueSoon ||
      this == ClassHomeworkStatus.overdue;
}

extension ClassHomeworkStatusDisplay on ClassHomeworkStatus {
  String get label => switch (this) {
    ClassHomeworkStatus.draft => 'Draft',
    ClassHomeworkStatus.published => 'Published',
    ClassHomeworkStatus.active => 'Active',
    ClassHomeworkStatus.dueSoon => 'Due soon',
    ClassHomeworkStatus.overdue => 'Overdue',
    ClassHomeworkStatus.completed => 'Completed',
    ClassHomeworkStatus.archived => 'Archived',
    ClassHomeworkStatus.cancelled => 'Cancelled',
  };
}

enum ClassHomeworkPriority {
  normal,
  high;

  static ClassHomeworkPriority fromId(String? id) =>
      id == 'high' ? ClassHomeworkPriority.high : ClassHomeworkPriority.normal;
}

/// One piece of homework or class work set for the whole class.
///
/// Subject-specific work belongs to the Subject Teacher panel; what a Class
/// Teacher sets here is class-level, which is why [subjectName] is a free
/// label rather than a subject assignment - setting it does not make the
/// teacher that subject's teacher.
class ClassHomework extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String classId;
  final String className;
  final String? streamId;
  final String academicYearId;
  final String termId;

  final String title;
  final String description;
  final String? instructions;
  final String? subjectName;
  final DateTime dueDate;
  final ClassHomeworkStatus status;
  final ClassHomeworkPriority priority;
  final List<String> attachments;

  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final String roleAssignmentId;

  const ClassHomework({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.classId,
    this.className = '',
    this.streamId,
    required this.academicYearId,
    this.termId = '',
    required this.title,
    this.description = '',
    this.instructions,
    this.subjectName,
    required this.dueDate,
    this.status = ClassHomeworkStatus.draft,
    this.priority = ClassHomeworkPriority.normal,
    this.attachments = const [],
    this.createdBy = '',
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.publishedAt,
    this.roleAssignmentId = '',
  });

  bool get isDraft => status == ClassHomeworkStatus.draft;

  /// The status as it actually stands now, with the due date applied.
  ///
  /// Stored status says "published"; whether that is *active*, *due soon* or
  /// *overdue* depends on the clock, and deriving it means the list is never
  /// wrong just because no scheduled job ran.
  ClassHomeworkStatus effectiveStatus({DateTime? asOf}) {
    if (status != ClassHomeworkStatus.published &&
        status != ClassHomeworkStatus.active &&
        status != ClassHomeworkStatus.dueSoon &&
        status != ClassHomeworkStatus.overdue) {
      return status;
    }

    final now = asOf ?? DateTime.now();
    if (now.isAfter(dueDate)) return ClassHomeworkStatus.overdue;
    if (dueDate.difference(now) <= const Duration(days: 2)) {
      return ClassHomeworkStatus.dueSoon;
    }
    return ClassHomeworkStatus.active;
  }

  ClassHomework copyWith({
    String? title,
    String? description,
    String? instructions,
    String? subjectName,
    DateTime? dueDate,
    ClassHomeworkStatus? status,
    ClassHomeworkPriority? priority,
    List<String>? attachments,
    String? updatedBy,
    DateTime? updatedAt,
    DateTime? publishedAt,
    String? roleAssignmentId,
  }) {
    return ClassHomework(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      className: className,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      subjectName: subjectName ?? this.subjectName,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    classId,
    className,
    streamId,
    academicYearId,
    termId,
    title,
    description,
    instructions,
    subjectName,
    dueDate,
    status,
    priority,
    attachments,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    publishedAt,
    roleAssignmentId,
  ];
}
