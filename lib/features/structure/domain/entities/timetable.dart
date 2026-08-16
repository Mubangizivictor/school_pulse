import 'package:equatable/equatable.dart';

/// Lifecycle of a class/stream timetable. Only [active] is what students,
/// teachers, and printouts read; [draft] can be edited freely and validated
/// as many times as needed before publishing.
enum TimetableStatus {
  draft,
  active,
  archived;

  static TimetableStatus fromId(String? id) {
    if (id == null) return TimetableStatus.draft;
    for (final s in TimetableStatus.values) {
      if (s.name == id) return s;
    }
    return TimetableStatus.draft;
  }
}

extension TimetableStatusDisplay on TimetableStatus {
  String get label => switch (this) {
    TimetableStatus.draft => 'Draft',
    TimetableStatus.active => 'Active',
    TimetableStatus.archived => 'Archived',
  };
}

/// The timetable for one class, or one stream inside a class, for a single
/// academic year/term. This is the envelope; the actual scheduled lessons
/// live as [TimetableLesson] documents that reference [id] as
/// `timetableId`.
///
/// Uniqueness of the *active* timetable for a given
/// (academicYearId, termId, classId, streamId) target is enforced by the
/// repository/conflict layer, not by this entity - drafts and archived
/// versions of the same target are expected to coexist.
class Timetable extends Equatable {
  final String id;
  final String schoolId;
  final String academicYearId;

  /// Empty when the school's timetable is yearly rather than per-term.
  final String termId;
  final String classId;

  /// Empty when the timetable targets the class as a whole rather than one
  /// of its streams.
  final String streamId;
  final String name;
  final String description;
  final TimetableStatus status;

  /// Monotonically increasing per target; bumped whenever a draft that
  /// supersedes a previously active/archived timetable is published.
  final int version;

  /// Snapshot of the period/break structure this timetable was built
  /// against, so historical timetables stay readable even if the school's
  /// live TimetableConfig later changes. Empty means "use the school's
  /// current TimetableConfig" (older timetables created before this field
  /// existed).
  final String configSnapshotId;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? publishedAt;
  final String? publishedBy;
  final DateTime? archivedAt;
  final String? archivedBy;

  const Timetable({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    this.termId = '',
    required this.classId,
    this.streamId = '',
    required this.name,
    this.description = '',
    this.status = TimetableStatus.draft,
    this.version = 1,
    this.configSnapshotId = '',
    required this.createdAt,
    this.createdBy = '',
    this.updatedAt,
    this.updatedBy,
    this.publishedAt,
    this.publishedBy,
    this.archivedAt,
    this.archivedBy,
  });

  bool get hasStream => streamId.isNotEmpty;

  /// The identity of what this timetable schedules, ignoring version/status -
  /// two [Timetable] rows sharing this key are different versions of the
  /// same target.
  String get targetKey =>
      [academicYearId, termId, classId, streamId].join('::');

  Timetable copyWith({
    String? id,
    String? schoolId,
    String? academicYearId,
    String? termId,
    String? classId,
    String? streamId,
    String? name,
    String? description,
    TimetableStatus? status,
    int? version,
    String? configSnapshotId,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    DateTime? publishedAt,
    String? publishedBy,
    DateTime? archivedAt,
    String? archivedBy,
  }) {
    return Timetable(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      academicYearId: academicYearId ?? this.academicYearId,
      termId: termId ?? this.termId,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      version: version ?? this.version,
      configSnapshotId: configSnapshotId ?? this.configSnapshotId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      publishedAt: publishedAt ?? this.publishedAt,
      publishedBy: publishedBy ?? this.publishedBy,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedBy: archivedBy ?? this.archivedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    academicYearId,
    termId,
    classId,
    streamId,
    name,
    description,
    status,
    version,
    configSnapshotId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    publishedAt,
    publishedBy,
    archivedAt,
    archivedBy,
  ];
}

/// One consecutive block a lesson occupies within a slot when a school
/// supports double/triple periods. A single lesson always has at least one.
class TimetableLessonOccurrence extends Equatable {
  final String day;
  final String slotId;

  const TimetableLessonOccurrence({required this.day, required this.slotId});

  @override
  List<Object?> get props => [day, slotId];
}

/// One scheduled subject assignment inside a [Timetable]: a subject taught
/// by a teacher, on one or more day/slot occurrences (more than one only for
/// double/triple/consecutive-block lessons), optionally in a room and/or for
/// a sub-group of the class.
///
/// `occurrences.length > 1` is how a double lesson is represented - all
/// occurrences share the same subject/teacher/room/group and must be
/// scheduled or removed together.
class TimetableLesson extends Equatable {
  final String id;
  final String schoolId;
  final String timetableId;

  /// Denormalized from the parent [Timetable] so a school-wide conflict scan
  /// can query lessons directly by year/term without joining every
  /// timetable first.
  final String academicYearId;
  final String termId;
  final String classId;
  final String className;
  final String streamId;
  final String streamName;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final String? roomId;
  final String? roomName;
  final String? groupId;
  final String notes;
  final List<TimetableLessonOccurrence> occurrences;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const TimetableLesson({
    required this.id,
    required this.schoolId,
    required this.timetableId,
    this.academicYearId = '',
    this.termId = '',
    required this.classId,
    this.className = '',
    this.streamId = '',
    this.streamName = '',
    required this.subjectId,
    this.subjectName = '',
    required this.teacherId,
    this.teacherName = '',
    this.roomId,
    this.roomName,
    this.groupId,
    this.notes = '',
    required this.occurrences,
    required this.createdAt,
    this.createdBy = '',
    this.updatedAt,
    this.updatedBy,
  });

  bool get isDoubleOrMore => occurrences.length > 1;

  /// Human-readable "Class Stream" label, e.g. "P5 Blue" or "P5" when the
  /// timetable targets the whole class rather than one stream.
  String get classLabel =>
      [className, streamName].where((e) => e.isNotEmpty).join(' ');

  TimetableLesson copyWith({
    String? id,
    String? schoolId,
    String? timetableId,
    String? academicYearId,
    String? termId,
    String? classId,
    String? className,
    String? streamId,
    String? streamName,
    String? subjectId,
    String? subjectName,
    String? teacherId,
    String? teacherName,
    String? roomId,
    String? roomName,
    String? groupId,
    String? notes,
    List<TimetableLessonOccurrence>? occurrences,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return TimetableLesson(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      timetableId: timetableId ?? this.timetableId,
      academicYearId: academicYearId ?? this.academicYearId,
      termId: termId ?? this.termId,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      streamId: streamId ?? this.streamId,
      streamName: streamName ?? this.streamName,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      groupId: groupId ?? this.groupId,
      notes: notes ?? this.notes,
      occurrences: occurrences ?? this.occurrences,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    timetableId,
    academicYearId,
    termId,
    classId,
    className,
    streamId,
    streamName,
    subjectId,
    subjectName,
    teacherId,
    teacherName,
    roomId,
    roomName,
    groupId,
    notes,
    occurrences,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
  ];
}
