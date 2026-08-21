import 'package:equatable/equatable.dart';

/// Where a queued write has got to.
enum OfflineSyncStatus {
  pending,
  inProgress,
  synced,
  failed,
  conflict;

  static OfflineSyncStatus fromId(String? id) {
    if (id == null) return OfflineSyncStatus.pending;
    for (final s in OfflineSyncStatus.values) {
      if (s.name == id) return s;
    }
    return OfflineSyncStatus.pending;
  }
}

/// The write actions the panel is allowed to queue while offline.
///
/// Deliberately narrow: drafts and teacher-owned content only. Approvals,
/// permission changes and anything that needs a server-side decision are
/// absent, because replaying those from a device that has been offline for a
/// week would let a revoked teacher act on stale authority.
class OfflineOperationType {
  const OfflineOperationType._();

  static const attendanceDraft = 'attendance.draft';
  static const attendanceSubmit = 'attendance.submit';

  /// The class register, distinct from the per-lesson one above: a class
  /// teacher's daily roll call and a subject teacher's lesson register are
  /// different records and must not replay into each other.
  static const classAttendanceDraft = 'class_attendance.draft';
  static const classAttendanceSubmit = 'class_attendance.submit';

  /// Correcting a register the teacher may no longer edit. Present here so
  /// the type is nameable, but deliberately absent from [offlineCreatable]:
  /// replaying an approval-bearing request from a device that has been away
  /// for a week would let a revoked teacher act on stale authority.
  static const classAttendanceCorrection = 'class_attendance.correction';

  static const lessonStart = 'lesson.start';
  static const lessonComplete = 'lesson.complete';
  static const lessonNoteSave = 'lesson_note.save';
  static const marksDraft = 'marks.draft';
  static const marksSubmit = 'marks.submit';
  static const subjectEnrollment = 'subject.enrollment';
  static const resourceMetadata = 'resource.metadata';
  static const auditLog = 'audit.log';

  /// Operations that may be created while offline. Anything not listed here
  /// is rejected at queue time rather than failing confusingly on replay.
  static const Set<String> offlineCreatable = {
    attendanceDraft,
    attendanceSubmit,
    classAttendanceDraft,
    classAttendanceSubmit,
    lessonStart,
    lessonComplete,
    lessonNoteSave,
    marksDraft,
    resourceMetadata,
    auditLog,
  };
}

/// One queued write waiting for connectivity.
class OfflineOperation extends Equatable {
  final String operationId;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final OfflineSyncStatus status;
  final String schoolId;
  final String userId;
  final String roleAssignmentId;
  final String deviceId;

  /// Earliest time this operation may be replayed again after a failure.
  /// Null means it has never failed, so it's eligible as soon as it's
  /// queued.
  final DateTime? nextRetryAt;

  const OfflineOperation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.payload = const {},
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.status = OfflineSyncStatus.pending,
    required this.schoolId,
    required this.userId,
    required this.roleAssignmentId,
    this.deviceId = '',
    this.nextRetryAt,
  });

  /// Retries back off and then stop. A permanently failing operation stays in
  /// the queue as [OfflineSyncStatus.failed] so the teacher's work is still
  /// on the device and visible, rather than being silently dropped.
  static const maxRetries = 5;

  bool get canRetry => retryCount < maxRetries;

  /// Exponential backoff after a failure: 1, 2, 4, 8, 16 minutes, doubling
  /// per attempt so a transient outage isn't hammered every poll cycle
  /// while a genuinely-fixed one still catches up within the minute.
  static Duration backoffFor(int retryCount) =>
      Duration(minutes: 1 << retryCount.clamp(0, 4));

  bool isDueFor(DateTime now) {
    final next = nextRetryAt;
    return next == null || !now.isBefore(next);
  }

  OfflineOperation copyWith({
    int? retryCount,
    String? lastError,
    OfflineSyncStatus? status,
    Map<String, dynamic>? payload,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
  }) {
    return OfflineOperation(
      operationId: operationId,
      entityType: entityType,
      entityId: entityId,
      action: action,
      payload: payload ?? this.payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      schoolId: schoolId,
      userId: userId,
      roleAssignmentId: roleAssignmentId,
      deviceId: deviceId,
      nextRetryAt: clearNextRetryAt ? null : (nextRetryAt ?? this.nextRetryAt),
    );
  }

  @override
  List<Object?> get props => [
    operationId,
    entityType,
    entityId,
    action,
    payload,
    createdAt,
    retryCount,
    lastError,
    status,
    schoolId,
    userId,
    roleAssignmentId,
    deviceId,
    nextRetryAt,
  ];
}
