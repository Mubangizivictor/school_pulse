import 'package:equatable/equatable.dart';

import 'lesson_attendance.dart';

/// One attendance status a teacher can pick, as the school defined it.
///
/// The list is the school's - a school that adds "Sick Bay" or "Prayers" gets
/// those buttons without a code change. What the app supplies is the
/// [classification], because a colour and a name cannot tell a report whether
/// the student was in the room, and totals have to come from somewhere.
class ClassAttendanceOption extends Equatable {
  final String code;
  final String label;
  final String colorHex;
  final AttendanceClassification classification;

  const ClassAttendanceOption({
    required this.code,
    required this.label,
    this.colorHex = '',
    required this.classification,
  });

  bool get countsAsPresent =>
      classification == AttendanceClassification.present;

  bool get isAuthorisedAbsence =>
      classification == AttendanceClassification.authorisedAbsence;

  @override
  List<Object?> get props => [code, label, colorHex, classification];
}

/// What a status means for totals, independent of what the school called it.
enum AttendanceClassification {
  /// In the room. Lateness lives here - a late student attended.
  present,

  /// Away with permission: excused, medical, approved leave.
  authorisedAbsence,

  /// Away without explanation. The default for a status nobody has
  /// classified, because silently counting an unrecognised code as present
  /// would inflate every attendance rate in the school.
  unauthorisedAbsence,
}

/// Turns the school's configured status list into options the register can
/// use, and classifies each one.
///
/// Recognised codes classify from the shared [LessonAttendanceStatus] the
/// Subject Teacher panel already uses, so a school that has not customised
/// anything behaves identically across both panels. Custom codes fall back to
/// name matching, then to unauthorised absence.
class AttendanceStatusResolver {
  const AttendanceStatusResolver._();

  /// The statuses to offer when the school has configured none. Mirrors
  /// [LessonAttendanceStatus] so the two panels agree out of the box.
  static const List<ClassAttendanceOption> defaults = [
    ClassAttendanceOption(
      code: 'present',
      label: 'Present',
      classification: AttendanceClassification.present,
    ),
    ClassAttendanceOption(
      code: 'late',
      label: 'Late',
      classification: AttendanceClassification.present,
    ),
    ClassAttendanceOption(
      code: 'absent',
      label: 'Absent',
      classification: AttendanceClassification.unauthorisedAbsence,
    ),
    ClassAttendanceOption(
      code: 'excused',
      label: 'Excused',
      classification: AttendanceClassification.authorisedAbsence,
    ),
    ClassAttendanceOption(
      code: 'medical',
      label: 'Medical',
      classification: AttendanceClassification.authorisedAbsence,
    ),
    ClassAttendanceOption(
      code: 'approvedLeave',
      label: 'Approved leave',
      classification: AttendanceClassification.authorisedAbsence,
    ),
  ];

  /// Classifies one configured status. [code] is matched first because it is
  /// stable; [label] is a fallback for schools that gave a custom code a
  /// recognisable name.
  static AttendanceClassification classify(String code, String label) {
    final normalisedCode = _normalise(code);
    final known = LessonAttendanceStatus.values
        .where((s) => _normalise(s.name) == normalisedCode)
        .firstOrNull;
    if (known != null && known != LessonAttendanceStatus.notMarked) {
      if (known.countsAsPresent) return AttendanceClassification.present;
      if (known.isAuthorisedAbsence) {
        return AttendanceClassification.authorisedAbsence;
      }
      return AttendanceClassification.unauthorisedAbsence;
    }

    final text = '${_normalise(label)} $normalisedCode';
    if (text.contains('present') ||
        text.contains('late') ||
        text.contains('here')) {
      return AttendanceClassification.present;
    }
    if (text.contains('excus') ||
        text.contains('medical') ||
        text.contains('sick') ||
        text.contains('leave') ||
        text.contains('permission') ||
        text.contains('authorised') ||
        text.contains('authorized')) {
      return AttendanceClassification.authorisedAbsence;
    }

    // Deliberately the strictest reading: an unclassified status must not
    // quietly improve a student's attendance record.
    return AttendanceClassification.unauthorisedAbsence;
  }

  /// Builds the option list from the school's configured types, falling back
  /// to [defaults] when the school has configured none or deactivated them
  /// all - a register with no buttons would be worse than an opinionated one.
  static List<ClassAttendanceOption> optionsFrom(
    List<({String id, String name, String colorHex, bool isActive})> configured,
  ) {
    final active = configured.where((t) => t.isActive).toList();
    if (active.isEmpty) return defaults;

    return active
        .map(
          (t) => ClassAttendanceOption(
            code: t.id,
            label: t.name,
            colorHex: t.colorHex,
            classification: classify(t.id, t.name),
          ),
        )
        .toList();
  }

  static String _normalise(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

/// Where a class register is in its life.
enum ClassAttendanceSessionStatus {
  /// Being filled in. Editable freely, and the only state that may be
  /// created offline.
  draft,

  /// Submitted by the teacher. Locked to ordinary saves; correcting it needs
  /// the edit permission and leaves an audit trail.
  submitted,

  /// Closed by the academic office. No teacher path at all.
  locked;

  static ClassAttendanceSessionStatus fromId(String? id) {
    if (id == null) return ClassAttendanceSessionStatus.draft;
    for (final s in ClassAttendanceSessionStatus.values) {
      if (s.name == id) return s;
    }
    return ClassAttendanceSessionStatus.draft;
  }
}

/// One student's mark in a class register.
class ClassAttendanceEntry extends Equatable {
  final String studentId;

  /// The school's status code, not an app enum - see [ClassAttendanceOption].
  final String statusCode;
  final String? note;

  /// Stamped when the teacher taps, not when the register is submitted: a
  /// register filled at 08:05 and submitted at lunchtime should say 08:05.
  final DateTime? markedAt;

  const ClassAttendanceEntry({
    required this.studentId,
    required this.statusCode,
    this.note,
    this.markedAt,
  });

  bool get isMarked => statusCode.isNotEmpty && statusCode != 'notMarked';

  ClassAttendanceEntry copyWith({
    String? statusCode,
    String? note,
    DateTime? markedAt,
    bool clearNote = false,
  }) {
    return ClassAttendanceEntry(
      studentId: studentId,
      statusCode: statusCode ?? this.statusCode,
      note: clearNote ? null : (note ?? this.note),
      markedAt: markedAt ?? this.markedAt,
    );
  }

  @override
  List<Object?> get props => [studentId, statusCode, note, markedAt];
}

/// One class's register for one day and session.
///
/// The id is derived from class + stream + session type + date rather than
/// generated, so a second submission for the same class and day collides with
/// the first instead of creating a duplicate register. That is the whole
/// defence against a class being marked twice.
class ClassAttendanceSession extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String classId;
  final String className;
  final String? streamId;
  final String academicYearId;
  final String termId;

  /// Which of the school's configured sessions this is - daily register,
  /// afternoon roll call, and so on.
  final String sessionType;

  final DateTime date;
  final ClassAttendanceSessionStatus status;
  final List<ClassAttendanceEntry> entries;
  final DateTime? submittedAt;
  final String? submittedBy;
  final String roleAssignmentId;
  final String deviceId;

  /// Set once the register has been corrected after submission, so a reader
  /// can tell a first submission from an amended one without reading the
  /// audit trail.
  final DateTime? lastCorrectedAt;

  const ClassAttendanceSession({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.classId,
    this.className = '',
    this.streamId,
    required this.academicYearId,
    this.termId = '',
    this.sessionType = 'daily',
    required this.date,
    this.status = ClassAttendanceSessionStatus.draft,
    this.entries = const [],
    this.submittedAt,
    this.submittedBy,
    this.roleAssignmentId = '',
    this.deviceId = '',
    this.lastCorrectedAt,
  });

  bool get isSubmitted => status == ClassAttendanceSessionStatus.submitted;
  bool get isLocked => status == ClassAttendanceSessionStatus.locked;

  /// Editable without the correction permission only while still a draft.
  bool get isFreelyEditable => status == ClassAttendanceSessionStatus.draft;

  ClassAttendanceEntry? entryFor(String studentId) =>
      entries.where((e) => e.studentId == studentId).firstOrNull;

  String statusCodeFor(String studentId) =>
      entryFor(studentId)?.statusCode ?? '';

  /// Students on the roster nobody has marked yet. The review step names them
  /// rather than defaulting them, so an absence is never recorded by omission.
  List<String> unmarkedFrom(List<String> rosterStudentIds) => rosterStudentIds
      .where((id) => !(entryFor(id)?.isMarked ?? false))
      .toList();

  /// Totals by classification, for the summary and the dashboard tiles.
  Map<AttendanceClassification, int> countsBy(
    List<ClassAttendanceOption> options,
  ) {
    final byCode = {for (final o in options) o.code: o.classification};
    final counts = {for (final c in AttendanceClassification.values) c: 0};
    for (final entry in entries) {
      if (!entry.isMarked) continue;
      final classification = byCode[entry.statusCode];
      if (classification == null) continue;
      counts[classification] = (counts[classification] ?? 0) + 1;
    }
    return counts;
  }

  ClassAttendanceSession copyWith({
    ClassAttendanceSessionStatus? status,
    List<ClassAttendanceEntry>? entries,
    DateTime? submittedAt,
    String? submittedBy,
    String? roleAssignmentId,
    String? deviceId,
    DateTime? lastCorrectedAt,
  }) {
    return ClassAttendanceSession(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      className: className,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      sessionType: sessionType,
      date: date,
      status: status ?? this.status,
      entries: entries ?? this.entries,
      submittedAt: submittedAt ?? this.submittedAt,
      submittedBy: submittedBy ?? this.submittedBy,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      deviceId: deviceId ?? this.deviceId,
      lastCorrectedAt: lastCorrectedAt ?? this.lastCorrectedAt,
    );
  }

  /// Replaces one student's mark, adding the entry when it is their first.
  ClassAttendanceSession withMark(
    String studentId,
    String statusCode, {
    String? note,
    DateTime? markedAt,
  }) {
    final now = markedAt ?? DateTime.now();
    final existing = entryFor(studentId);
    final updated = existing == null
        ? [
            ...entries,
            ClassAttendanceEntry(
              studentId: studentId,
              statusCode: statusCode,
              note: note,
              markedAt: now,
            ),
          ]
        : entries
              .map(
                (e) => e.studentId == studentId
                    ? e.copyWith(
                        statusCode: statusCode,
                        note: note,
                        markedAt: now,
                      )
                    : e,
              )
              .toList();
    return copyWith(entries: updated);
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
    sessionType,
    date,
    status,
    entries,
    submittedAt,
    submittedBy,
    roleAssignmentId,
    deviceId,
    lastCorrectedAt,
  ];
}

/// A request to change a register the teacher may no longer edit directly.
///
/// Historical corrections are the academic office's decision, so this is a
/// request rather than a write - and it is never creatable offline, because
/// replaying one from a device that has been away for a week would let a
/// revoked teacher act on stale authority.
class AttendanceCorrectionRequest extends Equatable {
  final String id;
  final String schoolId;
  final String sessionId;
  final String classId;
  final String academicYearId;
  final String studentId;
  final String previousStatusCode;
  final String requestedStatusCode;
  final String reason;
  final String requestedByUserId;
  final String requestedByStaffId;
  final String roleAssignmentId;
  final DateTime requestedAt;
  final String status;
  final String? decidedByUserId;
  final DateTime? decidedAt;
  final String? decisionNote;

  const AttendanceCorrectionRequest({
    required this.id,
    required this.schoolId,
    required this.sessionId,
    required this.classId,
    required this.academicYearId,
    required this.studentId,
    required this.previousStatusCode,
    required this.requestedStatusCode,
    required this.reason,
    required this.requestedByUserId,
    this.requestedByStaffId = '',
    this.roleAssignmentId = '',
    required this.requestedAt,
    this.status = 'pending',
    this.decidedByUserId,
    this.decidedAt,
    this.decisionNote,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    sessionId,
    classId,
    academicYearId,
    studentId,
    previousStatusCode,
    requestedStatusCode,
    reason,
    requestedByUserId,
    requestedByStaffId,
    roleAssignmentId,
    requestedAt,
    status,
    decidedByUserId,
    decidedAt,
    decisionNote,
  ];
}
