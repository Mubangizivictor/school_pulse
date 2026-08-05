import 'package:equatable/equatable.dart';

enum ClassTaskStatus {
  draft,
  pending,
  inProgress,
  completed,
  cancelled,
  archived;

  static ClassTaskStatus fromId(String? id) {
    if (id == null) return ClassTaskStatus.pending;
    final normalised = id.replaceAll('_', '').toLowerCase();
    for (final s in ClassTaskStatus.values) {
      if (s.name.toLowerCase() == normalised) return s;
    }
    return ClassTaskStatus.pending;
  }

  bool get isOpen => this == pending || this == inProgress;
}

enum ClassTaskPriority {
  low,
  medium,
  high;

  static ClassTaskPriority fromId(String? id) {
    if (id == null) return ClassTaskPriority.medium;
    for (final p in ClassTaskPriority.values) {
      if (p.name == id) return p;
    }
    return ClassTaskPriority.medium;
  }
}

/// How often a task repeats.
///
/// [endDate] and [maxOccurrences] both exist because a recurrence with
/// neither is the one that runs away: something has to stop generation, and a
/// school that genuinely wants an open-ended task should say so explicitly
/// through [neverEnds] rather than by omission.
class TaskRecurrence extends Equatable {
  final String frequency;
  final Set<int> weekdays;
  final DateTime? endDate;
  final int? maxOccurrences;
  final bool neverEnds;

  const TaskRecurrence({
    this.frequency = 'none',
    this.weekdays = const {},
    this.endDate,
    this.maxOccurrences,
    this.neverEnds = false,
  });

  static const none = TaskRecurrence();

  bool get repeats => frequency != 'none' && frequency.isNotEmpty;

  /// A repeating task has to terminate somehow, unless the school explicitly
  /// asked for one that does not.
  bool get isBounded =>
      !repeats || neverEnds || endDate != null || maxOccurrences != null;

  static TaskRecurrence fromMap(Map<String, dynamic>? data) {
    if (data == null) return none;
    return TaskRecurrence(
      frequency: data['frequency'] as String? ?? 'none',
      weekdays: ((data['weekdays'] as List?) ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toSet(),
      endDate: data['endDate'] is DateTime ? data['endDate'] as DateTime : null,
      maxOccurrences: (data['maxOccurrences'] as num?)?.toInt(),
      neverEnds: data['neverEnds'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'frequency': frequency,
    'weekdays': weekdays.toList(),
    'endDate': endDate,
    'maxOccurrences': maxOccurrences,
    'neverEnds': neverEnds,
  };

  @override
  List<Object?> get props => [
    frequency,
    weekdays,
    endDate,
    maxOccurrences,
    neverEnds,
  ];
}

class ClassTaskChecklistItem extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const ClassTaskChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  ClassTaskChecklistItem copyWith({bool? isCompleted}) {
    return ClassTaskChecklistItem(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

/// One item on the class teacher's working list.
///
/// Ownership rather than assignment scope is what governs a task: it is the
/// teacher's own list, and a colleague they invited may work it too. That is
/// why [ownerUserId] and [collaboratorUserIds] are here and no permission
/// scope is - the deployed rule tests the same two fields.
class ClassTask extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String? classId;
  final String academicYearId;
  final String? termId;

  final String title;
  final String description;
  final String category;
  final ClassTaskPriority priority;
  final ClassTaskStatus status;
  final DateTime dueAt;

  /// Set when the task is about one student, so opening it can go straight to
  /// their profile.
  final String? studentId;
  final String? subjectName;

  final List<ClassTaskChecklistItem> checklist;
  final List<String> attachments;
  final TaskRecurrence recurrence;
  final DateTime? remindAt;

  final String ownerUserId;
  final List<String> collaboratorUserIds;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? completedBy;
  final String roleAssignmentId;

  const ClassTask({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    this.classId,
    required this.academicYearId,
    this.termId,
    required this.title,
    this.description = '',
    this.category = 'Other',
    this.priority = ClassTaskPriority.medium,
    this.status = ClassTaskStatus.pending,
    required this.dueAt,
    this.studentId,
    this.subjectName,
    this.checklist = const [],
    this.attachments = const [],
    this.recurrence = TaskRecurrence.none,
    this.remindAt,
    this.ownerUserId = '',
    this.collaboratorUserIds = const [],
    required this.createdAt,
    this.completedAt,
    this.completedBy,
    this.roleAssignmentId = '',
  });

  bool get isComplete => status == ClassTaskStatus.completed;

  /// Overdue is derived, not stored - otherwise a task only becomes overdue
  /// when something happens to run and update it.
  bool isOverdue({DateTime? asOf}) {
    if (isComplete || status == ClassTaskStatus.cancelled) return false;
    return (asOf ?? DateTime.now()).isAfter(dueAt);
  }

  int get completedChecklistItems =>
      checklist.where((c) => c.isCompleted).length;

  double? get checklistProgress {
    if (checklist.isEmpty) return null;
    return completedChecklistItems / checklist.length;
  }

  ClassTask copyWith({
    String? title,
    String? description,
    String? category,
    ClassTaskPriority? priority,
    ClassTaskStatus? status,
    DateTime? dueAt,
    List<ClassTaskChecklistItem>? checklist,
    List<String>? attachments,
    TaskRecurrence? recurrence,
    DateTime? remindAt,
    List<String>? collaboratorUserIds,
    DateTime? completedAt,
    String? completedBy,
    String? roleAssignmentId,
  }) {
    return ClassTask(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      academicYearId: academicYearId,
      termId: termId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      studentId: studentId,
      subjectName: subjectName,
      checklist: checklist ?? this.checklist,
      attachments: attachments ?? this.attachments,
      recurrence: recurrence ?? this.recurrence,
      remindAt: remindAt ?? this.remindAt,
      ownerUserId: ownerUserId,
      collaboratorUserIds: collaboratorUserIds ?? this.collaboratorUserIds,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    classId,
    academicYearId,
    termId,
    title,
    description,
    category,
    priority,
    status,
    dueAt,
    studentId,
    subjectName,
    checklist,
    attachments,
    recurrence,
    remindAt,
    ownerUserId,
    collaboratorUserIds,
    createdAt,
    completedAt,
    completedBy,
    roleAssignmentId,
  ];
}

/// The task categories a school uses. Configurable, with a working default
/// set - a school that calls them something else should see its own words.
class TaskCategories {
  const TaskCategories._();

  static const List<String> defaults = [
    'Academic',
    'Lessons',
    'Homework',
    'Examinations',
    'Meetings',
    'Administration',
    'Other',
  ];

  static List<String> from(List<String> configured) =>
      configured.isEmpty ? defaults : configured;
}
