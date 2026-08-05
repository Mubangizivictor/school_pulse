import 'package:equatable/equatable.dart';

/// Where a lesson is in its life. The school's timetable produces
/// [scheduled] rows; everything after that is the teacher's doing, except
/// [substituted] and [rescheduled], which the academic office drives.
enum LessonStatus {
  draft,
  scheduled,
  ongoing,
  completed,
  missed,
  cancelled,
  substituted,
  rescheduled;

  static LessonStatus fromId(String? id) {
    if (id == null) return LessonStatus.scheduled;
    for (final s in LessonStatus.values) {
      if (s.name == id) return s;
    }
    return LessonStatus.scheduled;
  }

  bool get isFinished =>
      this == completed || this == cancelled || this == missed;
}

extension LessonStatusDisplay on LessonStatus {
  String get label => switch (this) {
    LessonStatus.draft => 'Draft',
    LessonStatus.scheduled => 'Scheduled',
    LessonStatus.ongoing => 'Ongoing',
    LessonStatus.completed => 'Completed',
    LessonStatus.missed => 'Missed',
    LessonStatus.cancelled => 'Cancelled',
    LessonStatus.substituted => 'Substituted',
    LessonStatus.rescheduled => 'Rescheduled',
  };
}

/// One period on the timetable, for one subject and class.
///
/// The lesson row is owned by the timetable; this panel reads it and records
/// what happened during it. That is why [teacherStaffId] and
/// [timetableSlotId] are here and are never written by the teacher - the
/// panel proves it is entitled to a lesson by matching them, it does not get
/// to assert them.
class Lesson extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String academicYearId;
  final String termId;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String? streamId;
  final String? streamName;
  final String timetableSlotId;

  /// The staff member the timetable assigned. A substitute does not replace
  /// this - they appear in [substituteStaffId] so the original teacher keeps
  /// their history.
  final String teacherStaffId;
  final String? substituteStaffId;

  final String title;
  final String? topic;
  final String? subtopic;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String? room;
  final LessonStatus status;
  final String? statusReason;
  final int enrolledCount;
  final bool attendanceSubmitted;
  final int lessonNoteCount;
  final int resourceCount;
  final String? relatedAssessmentId;

  const Lesson({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.academicYearId,
    this.termId = '',
    required this.subjectId,
    this.subjectName = '',
    required this.classId,
    this.className = '',
    this.streamId,
    this.streamName,
    this.timetableSlotId = '',
    required this.teacherStaffId,
    this.substituteStaffId,
    this.title = '',
    this.topic,
    this.subtopic,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.room,
    this.status = LessonStatus.scheduled,
    this.statusReason,
    this.enrolledCount = 0,
    this.attendanceSubmitted = false,
    this.lessonNoteCount = 0,
    this.resourceCount = 0,
    this.relatedAssessmentId,
  });

  bool get isToday {
    final now = DateTime.now();
    return scheduledStart.year == now.year &&
        scheduledStart.month == now.month &&
        scheduledStart.day == now.day;
  }

  bool get isUpcoming =>
      status == LessonStatus.scheduled &&
      scheduledStart.isAfter(DateTime.now());

  /// Whether [staffId] is entitled to act on this lesson: either the teacher
  /// the timetable assigned, or the substitute covering for them.
  bool isTaughtBy(String staffId) =>
      teacherStaffId == staffId || substituteStaffId == staffId;

  Lesson copyWith({
    LessonStatus? status,
    String? statusReason,
    DateTime? actualStart,
    DateTime? actualEnd,
    String? topic,
    String? subtopic,
    int? enrolledCount,
    bool? attendanceSubmitted,
    int? lessonNoteCount,
    int? resourceCount,
    String? substituteStaffId,
  }) {
    return Lesson(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      academicYearId: academicYearId,
      termId: termId,
      subjectId: subjectId,
      subjectName: subjectName,
      classId: classId,
      className: className,
      streamId: streamId,
      streamName: streamName,
      timetableSlotId: timetableSlotId,
      teacherStaffId: teacherStaffId,
      substituteStaffId: substituteStaffId ?? this.substituteStaffId,
      title: title,
      topic: topic ?? this.topic,
      subtopic: subtopic ?? this.subtopic,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      room: room,
      status: status ?? this.status,
      statusReason: statusReason ?? this.statusReason,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      attendanceSubmitted: attendanceSubmitted ?? this.attendanceSubmitted,
      lessonNoteCount: lessonNoteCount ?? this.lessonNoteCount,
      resourceCount: resourceCount ?? this.resourceCount,
      relatedAssessmentId: relatedAssessmentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    academicYearId,
    termId,
    subjectId,
    subjectName,
    classId,
    className,
    streamId,
    streamName,
    timetableSlotId,
    teacherStaffId,
    substituteStaffId,
    title,
    topic,
    subtopic,
    scheduledStart,
    scheduledEnd,
    actualStart,
    actualEnd,
    room,
    status,
    statusReason,
    enrolledCount,
    attendanceSubmitted,
    lessonNoteCount,
    resourceCount,
    relatedAssessmentId,
  ];
}

/// What the teacher recorded when they closed the lesson.
class LessonCompletion extends Equatable {
  final String? topicsCovered;
  final String? syllabusReference;
  final double? syllabusProgress;
  final String? outcome;
  final String? challenges;
  final bool followUpRequired;
  final String? homeworkAssigned;
  final String? teacherNote;

  const LessonCompletion({
    this.topicsCovered,
    this.syllabusReference,
    this.syllabusProgress,
    this.outcome,
    this.challenges,
    this.followUpRequired = false,
    this.homeworkAssigned,
    this.teacherNote,
  });

  @override
  List<Object?> get props => [
    topicsCovered,
    syllabusReference,
    syllabusProgress,
    outcome,
    challenges,
    followUpRequired,
    homeworkAssigned,
    teacherNote,
  ];
}
