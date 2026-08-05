import 'package:equatable/equatable.dart';

import 'staff_role_assignment.dart';

/// Every auditable action the Subject Teacher panel can take. Kept as a
/// closed set so the audit trail stays queryable - free-text action strings
/// make a log impossible to report on later.
class SubjectAuditAction {
  const SubjectAuditAction._();

  static const roleSelected = 'role.selected';
  static const subjectSelected = 'subject.selected';
  static const classSelected = 'class.selected';

  static const studentAddedToSubject = 'subject.student.added';
  static const studentRemovalRequested = 'subject.student.removal_requested';
  static const studentRemoved = 'subject.student.removed';

  static const lessonStarted = 'lesson.started';
  static const lessonCompleted = 'lesson.completed';
  static const lessonCancelled = 'lesson.cancelled';
  static const lessonRescheduled = 'lesson.rescheduled';

  static const attendanceSaved = 'attendance.saved';
  static const attendanceSubmitted = 'attendance.submitted';
  static const attendanceEdited = 'attendance.edited';

  static const lessonNoteCreated = 'lesson_note.created';
  static const lessonNoteEdited = 'lesson_note.edited';

  static const resourceUploaded = 'resource.uploaded';
  static const resourceShared = 'resource.shared';

  static const assessmentCreated = 'assessment.created';
  static const marksDraftSaved = 'marks.draft_saved';
  static const marksSubmitted = 'marks.submitted';
  static const marksEdited = 'marks.edited';
  static const marksImported = 'marks.imported';

  static const reportGenerated = 'report.generated';
  static const messageSent = 'message.sent';
}

/// One immutable audit row. Teachers can write these (by acting) but the
/// security rules give them no update or delete path, so the trail is
/// append-only from the client's point of view.
class SubjectAuditLog extends Equatable {
  final String auditId;
  final String schoolId;
  final String campusId;
  final String userId;
  final String staffId;
  final String roleAssignmentId;
  final StaffResponsibilityType activeRole;
  final String? subjectId;
  final String? classId;
  final String? streamId;
  final String academicYearId;
  final String? termId;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? previousValue;
  final Map<String, dynamic>? newValue;
  final String? reason;
  final DateTime timestamp;
  final String deviceId;
  final String platform;

  /// Set when the action was performed offline and replayed later, so a
  /// reviewer can tell a delayed write from a backdated one.
  final String? offlineOperationId;

  const SubjectAuditLog({
    required this.auditId,
    required this.schoolId,
    this.campusId = '',
    required this.userId,
    required this.staffId,
    required this.roleAssignmentId,
    required this.activeRole,
    this.subjectId,
    this.classId,
    this.streamId,
    required this.academicYearId,
    this.termId,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.previousValue,
    this.newValue,
    this.reason,
    required this.timestamp,
    this.deviceId = '',
    this.platform = '',
    this.offlineOperationId,
  });

  @override
  List<Object?> get props => [
    auditId,
    schoolId,
    campusId,
    userId,
    staffId,
    roleAssignmentId,
    activeRole,
    subjectId,
    classId,
    streamId,
    academicYearId,
    termId,
    action,
    entityType,
    entityId,
    previousValue,
    newValue,
    reason,
    timestamp,
    deviceId,
    platform,
    offlineOperationId,
  ];
}
