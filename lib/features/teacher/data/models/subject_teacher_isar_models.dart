import 'dart:convert';

import 'package:isar/isar.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/entities/subject_enrollment.dart';

part 'subject_teacher_isar_models.g.dart';

/// Locally cached responsibility rows.
///
/// Cached so the panel can restore the teacher's last assignment on a cold
/// start with no network, and so the switcher is populated offline. The cache
/// is never the authority on whether an assignment still grants access -
/// `isCurrentlyValid()` re-checks status and dates on read, and the server
/// rules re-check on every write.
@collection
class StaffRoleAssignmentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String assignmentId;

  @Index()
  late String schoolId;

  late String campusId;

  @Index()
  late String staffId;

  @Index()
  late String userId;

  late String roleDefinitionId;
  late bool isPrimary;
  late String roleType;

  @Index()
  late String academicYearId;

  String? termId;
  String? subjectId;
  String? subjectName;
  String? classId;
  String? className;
  String? streamId;
  String? streamName;
  String? departmentId;
  String? houseId;
  late DateTime startDate;
  DateTime? endDate;
  late String status;
  late List<String> permissions;
  late List<String> scopeTermIds;
  String? substituteForStaffId;
  late String assignedBy;
  late DateTime assignedAt;
  String? updatedBy;
  DateTime? updatedAt;

  /// When this row was last refreshed from the server, so a long-stale cache
  /// can be treated as suspect rather than trusted indefinitely.
  late DateTime cachedAt;

  StaffRoleAssignmentIsar();

  factory StaffRoleAssignmentIsar.fromEntity(StaffRoleAssignment e) {
    return StaffRoleAssignmentIsar()
      ..assignmentId = e.id
      ..schoolId = e.schoolId
      ..campusId = e.campusId
      ..staffId = e.staffId
      ..userId = e.userId
      ..roleDefinitionId = e.roleDefinitionId
      ..isPrimary = e.isPrimary
      ..roleType = e.roleType.name
      ..academicYearId = e.academicYearId
      ..termId = e.termId
      ..subjectId = e.subjectId
      ..subjectName = e.subjectName
      ..classId = e.classId
      ..className = e.className
      ..streamId = e.streamId
      ..streamName = e.streamName
      ..departmentId = e.departmentId
      ..houseId = e.houseId
      ..startDate = e.startDate
      ..endDate = e.endDate
      ..status = e.status.name
      ..permissions = e.permissionScope.permissions.toList()
      ..scopeTermIds = e.permissionScope.termIds.toList()
      ..substituteForStaffId = e.substituteForStaffId
      ..assignedBy = e.assignedBy
      ..assignedAt = e.assignedAt
      ..updatedBy = e.updatedBy
      ..updatedAt = e.updatedAt
      ..cachedAt = DateTime.now();
  }

  StaffRoleAssignment toEntity() {
    return StaffRoleAssignment(
      id: assignmentId,
      schoolId: schoolId,
      campusId: campusId,
      staffId: staffId,
      userId: userId,
      roleDefinitionId: roleDefinitionId,
      isPrimary: isPrimary,
      roleType: StaffResponsibilityType.fromId(roleType),
      academicYearId: academicYearId,
      termId: termId,
      subjectId: subjectId,
      subjectName: subjectName,
      classId: classId,
      className: className,
      streamId: streamId,
      streamName: streamName,
      departmentId: departmentId,
      houseId: houseId,
      startDate: startDate,
      endDate: endDate,
      status: AssignmentStatus.fromId(status),
      permissionScope: PermissionScope(
        permissions: permissions.toSet(),
        subjectId: subjectId,
        classId: classId,
        streamId: streamId,
        departmentId: departmentId,
        academicYearId: academicYearId,
        termIds: scopeTermIds.toSet(),
      ),
      substituteForStaffId: substituteForStaffId,
      assignedBy: assignedBy,
      assignedAt: assignedAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
    );
  }
}

/// Locally cached subject enrollment, so the Students tab and the attendance
/// register both work with no connectivity.
@collection
class SubjectEnrollmentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String enrollmentId;

  @Index()
  late String schoolId;

  late String campusId;

  @Index()
  late String studentId;

  @Index()
  late String subjectId;

  @Index()
  late String classId;

  String? streamId;

  @Index()
  late String academicYearId;

  late String status;
  late String roleAssignmentId;
  late bool isMandatory;
  late DateTime enrolledAt;
  late String enrolledBy;
  DateTime? removedAt;
  String? removedBy;
  String? removalReason;
  DateTime? effectiveFrom;
  DateTime? effectiveTo;

  SubjectEnrollmentIsar();

  factory SubjectEnrollmentIsar.fromEntity(SubjectEnrollment e) {
    return SubjectEnrollmentIsar()
      ..enrollmentId = e.id
      ..schoolId = e.schoolId
      ..campusId = e.campusId
      ..studentId = e.studentId
      ..subjectId = e.subjectId
      ..classId = e.classId
      ..streamId = e.streamId
      ..academicYearId = e.academicYearId
      ..status = e.status.name
      ..roleAssignmentId = e.roleAssignmentId
      ..isMandatory = e.isMandatory
      ..enrolledAt = e.enrolledAt
      ..enrolledBy = e.enrolledBy
      ..removedAt = e.removedAt
      ..removedBy = e.removedBy
      ..removalReason = e.removalReason
      ..effectiveFrom = e.effectiveFrom
      ..effectiveTo = e.effectiveTo;
  }

  SubjectEnrollment toEntity() {
    return SubjectEnrollment(
      id: enrollmentId,
      schoolId: schoolId,
      campusId: campusId,
      studentId: studentId,
      subjectId: subjectId,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      status: SubjectEnrollmentStatus.fromId(status),
      roleAssignmentId: roleAssignmentId,
      isMandatory: isMandatory,
      enrolledAt: enrolledAt,
      enrolledBy: enrolledBy,
      removedAt: removedAt,
      removedBy: removedBy,
      removalReason: removalReason,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
    );
  }
}

/// The synchronisation queue.
///
/// [payloadJson] holds the write body as JSON because Isar has no map type;
/// it is decoded back on replay. Operations survive app restarts, which is
/// the whole point - a register taken in a basement classroom must still be
/// there tomorrow morning.
@collection
class SubjectTeacherOfflineOperationIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String operationId;

  @Index()
  late String entityType;

  late String entityId;
  late String action;
  late String payloadJson;
  late DateTime createdAt;
  late int retryCount;
  String? lastError;

  @Index()
  late String status;

  @Index()
  late String schoolId;

  late String userId;
  late String roleAssignmentId;
  late String deviceId;

  DateTime? nextRetryAt;

  SubjectTeacherOfflineOperationIsar();

  factory SubjectTeacherOfflineOperationIsar.fromEntity(OfflineOperation e) {
    return SubjectTeacherOfflineOperationIsar()
      ..operationId = e.operationId
      ..entityType = e.entityType
      ..entityId = e.entityId
      ..action = e.action
      ..payloadJson = jsonEncode(e.payload)
      ..createdAt = e.createdAt
      ..retryCount = e.retryCount
      ..lastError = e.lastError
      ..status = e.status.name
      ..schoolId = e.schoolId
      ..userId = e.userId
      ..roleAssignmentId = e.roleAssignmentId
      ..deviceId = e.deviceId
      ..nextRetryAt = e.nextRetryAt;
  }

  OfflineOperation toEntity() {
    return OfflineOperation(
      operationId: operationId,
      entityType: entityType,
      entityId: entityId,
      action: action,
      payload: _decodePayload(),
      createdAt: createdAt,
      retryCount: retryCount,
      lastError: lastError,
      status: OfflineSyncStatus.fromId(status),
      schoolId: schoolId,
      userId: userId,
      roleAssignmentId: roleAssignmentId,
      deviceId: deviceId,
      nextRetryAt: nextRetryAt,
    );
  }

  Map<String, dynamic> _decodePayload() {
    try {
      final decoded = jsonDecode(payloadJson);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      // A corrupt payload must not take the whole queue down on drain -
      // the operation surfaces as failed instead.
      return <String, dynamic>{};
    }
  }
}

/// Locally cached timetable lessons, so the Lessons tab and the register
/// both open with no connectivity.
@collection
class LessonIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String lessonId;

  @Index()
  late String schoolId;

  late String campusId;
  late String academicYearId;
  late String termId;

  @Index()
  late String subjectId;

  late String subjectName;

  @Index()
  late String classId;

  late String className;
  String? streamId;
  String? streamName;
  late String timetableSlotId;

  @Index()
  late String teacherStaffId;

  String? substituteStaffId;
  late String title;
  String? topic;
  String? subtopic;

  @Index()
  late DateTime scheduledStart;

  late DateTime scheduledEnd;
  DateTime? actualStart;
  DateTime? actualEnd;
  String? room;
  late String status;
  String? statusReason;
  late int enrolledCount;
  late bool attendanceSubmitted;
  late int lessonNoteCount;
  late int resourceCount;
  String? relatedAssessmentId;

  LessonIsar();

  factory LessonIsar.fromEntity(Lesson e) {
    return LessonIsar()
      ..lessonId = e.id
      ..schoolId = e.schoolId
      ..campusId = e.campusId
      ..academicYearId = e.academicYearId
      ..termId = e.termId
      ..subjectId = e.subjectId
      ..subjectName = e.subjectName
      ..classId = e.classId
      ..className = e.className
      ..streamId = e.streamId
      ..streamName = e.streamName
      ..timetableSlotId = e.timetableSlotId
      ..teacherStaffId = e.teacherStaffId
      ..substituteStaffId = e.substituteStaffId
      ..title = e.title
      ..topic = e.topic
      ..subtopic = e.subtopic
      ..scheduledStart = e.scheduledStart
      ..scheduledEnd = e.scheduledEnd
      ..actualStart = e.actualStart
      ..actualEnd = e.actualEnd
      ..room = e.room
      ..status = e.status.name
      ..statusReason = e.statusReason
      ..enrolledCount = e.enrolledCount
      ..attendanceSubmitted = e.attendanceSubmitted
      ..lessonNoteCount = e.lessonNoteCount
      ..resourceCount = e.resourceCount
      ..relatedAssessmentId = e.relatedAssessmentId;
  }

  Lesson toEntity() {
    return Lesson(
      id: lessonId,
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
      substituteStaffId: substituteStaffId,
      title: title,
      topic: topic,
      subtopic: subtopic,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      actualStart: actualStart,
      actualEnd: actualEnd,
      room: room,
      status: LessonStatus.fromId(status),
      statusReason: statusReason,
      enrolledCount: enrolledCount,
      attendanceSubmitted: attendanceSubmitted,
      lessonNoteCount: lessonNoteCount,
      resourceCount: resourceCount,
      relatedAssessmentId: relatedAssessmentId,
    );
  }
}

/// One student's row in a locally held register. Stored as an embedded
/// object so a register round-trips as a unit and a half-written draft can
/// never lose some of its marks.
@embedded
class LessonAttendanceEntryIsar {
  String? studentId;
  String? status;
  String? note;
  DateTime? markedAt;
}

/// A register held on the device - a draft in progress, or a submitted one
/// waiting for the sync queue to drain.
@collection
class LessonAttendanceIsar {
  Id id = Isar.autoIncrement;

  /// Keyed on the lesson, not on a generated id: one register per lesson is
  /// what makes a double submit or an offline replay overwrite instead of
  /// creating a second register for the same period.
  @Index(unique: true, replace: true)
  late String lessonId;

  late String attendanceId;

  @Index()
  late String schoolId;

  late String campusId;
  late String academicYearId;
  late String termId;

  @Index()
  late String subjectId;

  late String classId;
  String? streamId;
  late String staffId;
  late String roleAssignmentId;
  late List<LessonAttendanceEntryIsar> entries;

  @Index()
  late String status;

  DateTime? submittedAt;
  String? deviceId;
  late DateTime updatedAt;

  LessonAttendanceIsar();

  factory LessonAttendanceIsar.fromEntity(LessonAttendance e) {
    return LessonAttendanceIsar()
      ..lessonId = e.lessonId
      ..attendanceId = e.id
      ..schoolId = e.schoolId
      ..campusId = e.campusId
      ..academicYearId = e.academicYearId
      ..termId = e.termId
      ..subjectId = e.subjectId
      ..classId = e.classId
      ..streamId = e.streamId
      ..staffId = e.staffId
      ..roleAssignmentId = e.roleAssignmentId
      ..entries = e.entries
          .map(
            (entry) => LessonAttendanceEntryIsar()
              ..studentId = entry.studentId
              ..status = entry.status.name
              ..note = entry.note
              ..markedAt = entry.markedAt,
          )
          .toList()
      ..status = e.status.name
      ..submittedAt = e.submittedAt
      ..deviceId = e.deviceId
      ..updatedAt = e.updatedAt;
  }

  LessonAttendance toEntity() {
    return LessonAttendance(
      id: attendanceId,
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
      entries: entries
          .map(
            (entry) => LessonAttendanceEntry(
              studentId: entry.studentId ?? '',
              status: LessonAttendanceStatus.fromId(entry.status),
              note: entry.note,
              markedAt: entry.markedAt,
            ),
          )
          .toList(),
      status: AttendanceRegisterStatus.fromId(status),
      submittedAt: submittedAt,
      deviceId: deviceId,
      updatedAt: updatedAt,
    );
  }
}
