import 'package:equatable/equatable.dart';

/// How a student was marked for one lesson.
///
/// [notMarked] is a real value, not a null stand-in: it is what lets the
/// review step say "four students still unmarked" instead of quietly
/// defaulting them to absent, which would put an absence on a record nobody
/// actually recorded.
enum LessonAttendanceStatus {
  notMarked,
  present,
  absent,
  late,
  excused,
  medical,
  approvedLeave;

  static LessonAttendanceStatus fromId(String? id) {
    if (id == null) return LessonAttendanceStatus.notMarked;
    for (final s in LessonAttendanceStatus.values) {
      if (s.name == id) return s;
    }
    return LessonAttendanceStatus.notMarked;
  }

  /// Whether the student was in the room. Late counts - they attended.
  bool get countsAsPresent => this == present || this == late;

  /// Whether the absence was authorised, which reports separate from
  /// unexplained absence.
  bool get isAuthorisedAbsence =>
      this == excused || this == medical || this == approvedLeave;
}

extension LessonAttendanceStatusDisplay on LessonAttendanceStatus {
  String get label => switch (this) {
    LessonAttendanceStatus.notMarked => 'Not marked',
    LessonAttendanceStatus.present => 'Present',
    LessonAttendanceStatus.absent => 'Absent',
    LessonAttendanceStatus.late => 'Late',
    LessonAttendanceStatus.excused => 'Excused',
    LessonAttendanceStatus.medical => 'Medical',
    LessonAttendanceStatus.approvedLeave => 'Approved leave',
  };
}

/// One student's mark for one lesson.
class LessonAttendanceEntry extends Equatable {
  final String studentId;
  final LessonAttendanceStatus status;
  final String? note;

  /// Stamped by the device when the teacher taps, not when the register is
  /// submitted - a register filled at 08:05 and submitted at lunchtime should
  /// say 08:05.
  final DateTime? markedAt;

  const LessonAttendanceEntry({
    required this.studentId,
    this.status = LessonAttendanceStatus.notMarked,
    this.note,
    this.markedAt,
  });

  bool get isMarked => status != LessonAttendanceStatus.notMarked;

  LessonAttendanceEntry copyWith({
    LessonAttendanceStatus? status,
    String? note,
    DateTime? markedAt,
  }) {
    return LessonAttendanceEntry(
      studentId: studentId,
      status: status ?? this.status,
      note: note ?? this.note,
      markedAt: markedAt ?? this.markedAt,
    );
  }

  @override
  List<Object?> get props => [studentId, status, note, markedAt];
}

/// Where a register has got to.
enum AttendanceRegisterStatus {
  draft,
  submitted,
  locked,
  returnedForCorrection;

  static AttendanceRegisterStatus fromId(String? id) {
    if (id == null) return AttendanceRegisterStatus.draft;
    for (final s in AttendanceRegisterStatus.values) {
      if (s.name == id) return s;
    }
    return AttendanceRegisterStatus.draft;
  }
}

/// The register for one lesson.
///
/// One register per lesson, keyed on the lesson id, which is what makes a
/// double submission or an offline replay overwrite rather than duplicate.
class LessonAttendance extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String lessonId;
  final String academicYearId;
  final String termId;
  final String subjectId;
  final String classId;
  final String? streamId;
  final String staffId;
  final String roleAssignmentId;
  final List<LessonAttendanceEntry> entries;
  final AttendanceRegisterStatus status;
  final DateTime? submittedAt;
  final String? deviceId;
  final DateTime updatedAt;

  const LessonAttendance({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.lessonId,
    required this.academicYearId,
    this.termId = '',
    required this.subjectId,
    required this.classId,
    this.streamId,
    required this.staffId,
    required this.roleAssignmentId,
    this.entries = const [],
    this.status = AttendanceRegisterStatus.draft,
    this.submittedAt,
    this.deviceId,
    required this.updatedAt,
  });

  int get presentCount => entries.where((e) => e.status.countsAsPresent).length;

  int get absentCount => entries
      .where(
        (e) =>
            e.status == LessonAttendanceStatus.absent ||
            e.status.isAuthorisedAbsence,
      )
      .length;

  int get unmarkedCount => entries.where((e) => !e.isMarked).length;

  bool get isComplete => entries.isNotEmpty && unmarkedCount == 0;

  /// Submitted registers are locked by default; editing needs a correction
  /// path with a reason, not a plain save.
  bool get isEditable =>
      status == AttendanceRegisterStatus.draft ||
      status == AttendanceRegisterStatus.returnedForCorrection;

  LessonAttendanceEntry? entryFor(String studentId) =>
      entries.where((e) => e.studentId == studentId).firstOrNull;

  LessonAttendance copyWith({
    List<LessonAttendanceEntry>? entries,
    AttendanceRegisterStatus? status,
    DateTime? submittedAt,
    DateTime? updatedAt,
  }) {
    return LessonAttendance(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      lessonId: lessonId,
      academicYearId: academicYearId,
      termId: termId,
      subjectId: subjectId,
      classId: classId,
      streamId: streamId,
      staffId: staffId,
      roleAssignmentId: roleAssignmentId,
      entries: entries ?? this.entries,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      deviceId: deviceId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    lessonId,
    academicYearId,
    termId,
    subjectId,
    classId,
    streamId,
    staffId,
    roleAssignmentId,
    entries,
    status,
    submittedAt,
    deviceId,
    updatedAt,
  ];
}
