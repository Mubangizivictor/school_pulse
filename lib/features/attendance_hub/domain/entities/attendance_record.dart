import 'package:equatable/equatable.dart';
import 'attendance_category.dart';

enum AttendanceStatus { present, absent, late, excused }

enum AttendanceMethod { nfc, qr, manual }

/// The full offline-queue-item lifecycle for one locally-cached attendance
/// mark. `pending`/`synced`/`failed` are the original three states this app
/// shipped with; the rest close the Day 3 release-gate gap that there was no
/// stale/revoked-queue-entry handling anywhere in attendance_hub.
///
///  queued -> syncing -> completed              (happy path)
///                     -> retryableFailure -> syncing (backoff retry loop)
///                     -> permanentlyBlocked     (revoked/stale/gone/403)
///  completed | permanentlyBlocked -> evicted    (past the retention window)
///
/// `pending`/`synced`/`failed` are kept as aliases of `queued`/`completed`/
/// `retryableFailure` respectively (see the `.legacy`/`.isPending` etc.
/// helpers below) so every existing call site and persisted Isar row -
/// `syncStatus` is stored by `.name` - keeps working unchanged.
enum AttendanceSyncStatus {
  pending,
  synced,
  failed,
  queued,
  syncing,
  completed,
  retryableFailure,
  permanentlyBlocked,
  evicted;

  /// True for any state that has not yet reached a terminal outcome and is
  /// still eligible to be picked up by a sync sweep.
  bool get isPending =>
      this == pending || this == queued || this == retryableFailure;

  bool get isSyncing => this == syncing;

  bool get isSuccessful => this == synced || this == completed;

  /// A queue item that will never be retried again - the sync sweep must
  /// skip these, and the UI must never render them as if they succeeded.
  bool get isBlocked => this == permanentlyBlocked;

  bool get isEvicted => this == evicted;
}

/// One person's attendance mark for one session on one day. `id` is always
/// deterministic - see AttendanceRemoteDataSource.buildRecordId - so a
/// second mark attempt for the same (category, scope, session, date,
/// person) collides with the first write instead of creating a duplicate.
class AttendanceRecord extends Equatable {
  final String id;
  final String schoolId;
  final AttendanceCategory category;
  final String scopeId;
  final String scopeName;
  final String sessionType;
  final DateTime date;
  final String personId;
  final String personName;
  final AttendanceStatus status;
  final AttendanceMethod method;
  final String markedBy;
  final String operatorId;
  final String deviceId;
  final AttendanceSyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime? correctedAt;
  final String? correctionOf;

  /// The staff_role_assignments doc this write is claimed under - null for
  /// an institution-wide operator (schoolAdmin/director/headTeacher/
  /// deputyHead, or anyone holding attendance.override) who has no single
  /// assignment to name. Firestore rules verify this specific assignment
  /// both belongs to the writer and covers [scopeId] before allowing the
  /// write - the same holdsAssignment() pattern already used by
  /// lesson_attendance/class_attendance_sessions/subject_enrollments.
  final String? roleAssignmentId;

  /// Offline-queue lifecycle bookkeeping. `retryCount`/`nextRetryAt` drive
  /// the same bounded-exponential-backoff shape as
  /// `OfflineOperation.backoffFor` (teacher/domain/entities/offline_operation
  /// .dart) - reused here rather than reinvented. `blockedReason` is set the
  /// moment a record transitions to `permanentlyBlocked`, so the UI has a
  /// human-readable explanation rather than a bare enum value.
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  final String? blockedReason;

  const AttendanceRecord({
    required this.id,
    required this.schoolId,
    required this.category,
    required this.scopeId,
    this.scopeName = '',
    this.sessionType = 'daily',
    required this.date,
    required this.personId,
    this.personName = '',
    required this.status,
    required this.method,
    this.markedBy = '',
    this.operatorId = '',
    this.deviceId = '',
    this.syncStatus = AttendanceSyncStatus.synced,
    required this.createdAt,
    this.correctedAt,
    this.correctionOf,
    this.roleAssignmentId,
    this.retryCount = 0,
    this.nextRetryAt,
    this.lastError,
    this.blockedReason,
  });

  AttendanceRecord copyWith({
    AttendanceStatus? status,
    AttendanceSyncStatus? syncStatus,
    DateTime? correctedAt,
    String? roleAssignmentId,
    int? retryCount,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
    String? lastError,
    String? blockedReason,
  }) {
    return AttendanceRecord(
      id: id,
      schoolId: schoolId,
      category: category,
      scopeId: scopeId,
      scopeName: scopeName,
      sessionType: sessionType,
      date: date,
      personId: personId,
      personName: personName,
      status: status ?? this.status,
      method: method,
      markedBy: markedBy,
      operatorId: operatorId,
      deviceId: deviceId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      correctedAt: correctedAt ?? this.correctedAt,
      correctionOf: correctionOf,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: clearNextRetryAt ? null : (nextRetryAt ?? this.nextRetryAt),
      lastError: lastError ?? this.lastError,
      blockedReason: blockedReason ?? this.blockedReason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    category,
    scopeId,
    scopeName,
    sessionType,
    date,
    personId,
    personName,
    status,
    method,
    markedBy,
    operatorId,
    deviceId,
    syncStatus,
    createdAt,
    correctedAt,
    correctionOf,
    roleAssignmentId,
    retryCount,
    nextRetryAt,
    lastError,
    blockedReason,
  ];
}
