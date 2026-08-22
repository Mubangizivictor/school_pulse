import 'dart:async';

import 'package:school_pulse/core/network/network_info.dart';

import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/services/subject_audit_service.dart';
import '../../domain/services/subject_sync_service.dart';
import '../datasources/class_teacher_local_data_source.dart';
import '../datasources/class_teacher_remote_data_source.dart';
import '../datasources/subject_teacher_local_data_source.dart';
import '../datasources/subject_teacher_remote_data_source.dart';

class SubjectSyncServiceImpl implements SubjectSyncService {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectTeacherLocalDataSource localDataSource;
  final ClassTeacherRemoteDataSource classRemoteDataSource;
  final ClassTeacherLocalDataSource classLocalDataSource;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;

  Timer? _poller;
  bool _draining = false;

  /// Connectivity is polled rather than subscribed to: this project's
  /// NetworkInfo exposes a one-shot check, and a minute's delay before
  /// replaying a register is not worth a new dependency.
  static const _pollInterval = Duration(minutes: 1);

  SubjectSyncServiceImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.classRemoteDataSource,
    required this.classLocalDataSource,
    required this.auditService,
    required this.networkInfo,
  });

  @override
  Future<SyncResult> drain({String? schoolId}) async {
    // One drain at a time. Two concurrent passes would both pick up the same
    // operation and race to delete it.
    if (_draining) return const SyncResult();
    if (!await networkInfo.isConnected) {
      final waiting = await localDataSource.getPendingOperations(
        schoolId: schoolId,
      );
      return SyncResult(remaining: waiting.length);
    }

    _draining = true;
    var synced = 0;
    var failed = 0;
    var conflicted = 0;

    try {
      // Oldest first, so a lesson start lands before the register that
      // belongs to it.
      final pending = await localDataSource.getPendingOperations(
        schoolId: schoolId,
      );

      for (final operation in pending) {
        try {
          final outcome = await _replay(operation);
          switch (outcome) {
            case _ReplayOutcome.done:
              await localDataSource.deleteOperation(operation.operationId);
              synced++;
            case _ReplayOutcome.conflict:
              await _mark(
                operation,
                OfflineSyncStatus.conflict,
                'Changed on the server while you were offline.',
              );
              conflicted++;
            case _ReplayOutcome.gone:
              // The record this operation targets no longer exists - the
              // lesson was cancelled, say. Dropping it is correct; retrying
              // forever is not.
              await localDataSource.deleteOperation(operation.operationId);
              synced++;
          }
        } catch (e) {
          await _recordFailure(operation, e);
          failed++;
        }
      }

      // Audit rows are replayed last so the actions they describe have
      // already landed.
      await auditService.flushPending();

      final left = await localDataSource.getPendingOperations(
        schoolId: schoolId,
      );
      return SyncResult(
        synced: synced,
        failed: failed,
        conflicted: conflicted,
        remaining: left.length,
      );
    } finally {
      _draining = false;
    }
  }

  Future<_ReplayOutcome> _replay(OfflineOperation operation) async {
    switch (operation.entityType) {
      case OfflineOperationType.attendanceDraft:
      case OfflineOperationType.attendanceSubmit:
        return _replayAttendance(operation);

      case OfflineOperationType.classAttendanceDraft:
      case OfflineOperationType.classAttendanceSubmit:
        return _replayClassAttendance(operation);

      case OfflineOperationType.classTaskSave:
      case OfflineOperationType.classTaskComplete:
        return _replayClassTaskSave(operation);

      case OfflineOperationType.classTaskDelete:
        return _replayClassTaskDelete(operation);

      case OfflineOperationType.classHomeworkSave:
      case OfflineOperationType.classHomeworkPublish:
      case OfflineOperationType.classHomeworkCancel:
        return _replayClassHomework(operation);

      case OfflineOperationType.classBehaviourRecord:
      case OfflineOperationType.classBehaviourUpdate:
        return _replayClassBehaviour(operation);

      case OfflineOperationType.classAnnouncementSave:
      case OfflineOperationType.classAnnouncementPublish:
      case OfflineOperationType.classAnnouncementArchive:
        return _replayClassAnnouncement(operation);

      case OfflineOperationType.auditLog:
        // Handled by the audit service's own flush, which knows the payload.
        return _ReplayOutcome.done;

      default:
        // An operation type nothing knows how to replay must not sit in the
        // queue forever pretending it will.
        return _ReplayOutcome.gone;
    }
  }

  Future<_ReplayOutcome> _replayAttendance(OfflineOperation operation) async {
    // The queue holds only the lesson id; the register itself is read back
    // from the device, so the replay always pushes the newest local state
    // rather than a snapshot taken when the operation was queued.
    final register = await localDataSource.getAttendance(operation.entityId);
    if (register == null) return _ReplayOutcome.gone;

    final server = await remoteDataSource.getLessonAttendance(
      schoolId: register.schoolId,
      lessonId: register.lessonId,
    );

    if (server != null) {
      // Server-approved data wins. A register the academic office has locked
      // or already submitted is not something a week-old offline draft gets
      // to overwrite.
      if (server.status == AttendanceRegisterStatus.locked) {
        return _ReplayOutcome.conflict;
      }
      if (server.status == AttendanceRegisterStatus.submitted &&
          register.status != AttendanceRegisterStatus.submitted) {
        return _ReplayOutcome.conflict;
      }
      // Both sides submitted: the later submission is a genuine conflict
      // rather than a safe overwrite, because two devices took the same
      // register.
      if (server.status == AttendanceRegisterStatus.submitted &&
          register.status == AttendanceRegisterStatus.submitted &&
          server.submittedAt != null &&
          register.submittedAt != null &&
          server.submittedAt!.isAfter(register.submittedAt!)) {
        return _ReplayOutcome.conflict;
      }
    }

    await remoteDataSource.saveLessonAttendance(register);
    return _ReplayOutcome.done;
  }

  Future<_ReplayOutcome> _replayClassAttendance(
    OfflineOperation operation,
  ) async {
    // Mirrors _replayAttendance: read the newest local register rather than
    // a snapshot taken when the operation was queued, and defer to the
    // server once it has moved past what this device knows about.
    final register = await classLocalDataSource.getAttendanceDraft(
      operation.entityId,
      schoolId: operation.schoolId,
    );
    if (register == null) return _ReplayOutcome.gone;

    final server = await classRemoteDataSource.getAttendanceSession(
      schoolId: operation.schoolId,
      sessionId: register.id,
    );

    if (server != null) {
      if (server.status == ClassAttendanceSessionStatus.locked) {
        return _ReplayOutcome.conflict;
      }
      if (server.status == ClassAttendanceSessionStatus.submitted &&
          register.status != ClassAttendanceSessionStatus.submitted) {
        return _ReplayOutcome.conflict;
      }
    }

    await classRemoteDataSource.saveAttendanceSession(register);
    return _ReplayOutcome.done;
  }

  Future<_ReplayOutcome> _replayClassTaskSave(
    OfflineOperation operation,
  ) async {
    // As with attendance, the queue holds only the task id - the task
    // itself is read back from the device so the replay pushes the newest
    // local state, not a snapshot taken when the operation was queued.
    final task = await classLocalDataSource.getTask(operation.entityId);
    if (task == null) return _ReplayOutcome.gone;

    await classRemoteDataSource.saveTask(task);
    return _ReplayOutcome.done;
  }

  Future<_ReplayOutcome> _replayClassTaskDelete(
    OfflineOperation operation,
  ) async {
    // Deletion already removed the local row, so there is nothing to read
    // back - the operation's own schoolId/entityId are enough to replay it.
    await classRemoteDataSource.deleteTask(
      schoolId: operation.schoolId,
      taskId: operation.entityId,
    );
    return _ReplayOutcome.done;
  }

  Future<_ReplayOutcome> _replayClassHomework(
    OfflineOperation operation,
  ) async {
    // Save/publish/cancel all end up as the same saved document - the queue
    // holds only the id, so the replay reads the newest local row and pushes
    // it whole, regardless of which of the three calls created the entry.
    final homework = await classLocalDataSource.getHomeworkItem(
      operation.entityId,
    );
    if (homework == null) return _ReplayOutcome.gone;

    await classRemoteDataSource.saveHomework(homework);
    return _ReplayOutcome.done;
  }

  Future<_ReplayOutcome> _replayClassBehaviour(
    OfflineOperation operation,
  ) async {
    final record = await classLocalDataSource.getBehaviourRecord(
      operation.entityId,
    );
    if (record == null) return _ReplayOutcome.gone;

    await classRemoteDataSource.saveBehaviourRecord(record);
    return _ReplayOutcome.done;
  }

  Future<_ReplayOutcome> _replayClassAnnouncement(
    OfflineOperation operation,
  ) async {
    final announcement = await classLocalDataSource.getAnnouncement(
      operation.entityId,
    );
    if (announcement == null) return _ReplayOutcome.gone;

    await classRemoteDataSource.saveAnnouncement(announcement);
    return _ReplayOutcome.done;
  }

  Future<void> _recordFailure(OfflineOperation operation, Object error) async {
    final nextRetryCount = operation.retryCount + 1;
    await _mark(
      operation,
      nextRetryCount >= OfflineOperation.maxRetries
          ? OfflineSyncStatus.failed
          : OfflineSyncStatus.pending,
      error.toString(),
      incrementRetry: true,
      // A permanent failure has no next attempt to wait for; a retryable one
      // backs off so the same transient error isn't replayed next poll.
      nextRetryAt: nextRetryCount >= OfflineOperation.maxRetries
          ? null
          : DateTime.now().add(
              OfflineOperation.backoffFor(operation.retryCount),
            ),
    );
  }

  Future<void> _mark(
    OfflineOperation operation,
    OfflineSyncStatus status,
    String message, {
    bool incrementRetry = false,
    DateTime? nextRetryAt,
  }) async {
    // The operation stays in the queue either way. A permanently failing
    // write is still the teacher's work and has to remain visible on the
    // device rather than disappearing.
    await localDataSource.updateOperation(
      operation.copyWith(
        status: status,
        lastError: message,
        retryCount: incrementRetry
            ? operation.retryCount + 1
            : operation.retryCount,
        nextRetryAt: nextRetryAt,
        clearNextRetryAt: nextRetryAt == null,
      ),
    );
  }

  @override
  Future<List<OfflineOperation>> pending({String? schoolId}) async {
    return localDataSource.getPendingOperations(schoolId: schoolId);
  }

  @override
  void startWatching({String? schoolId}) {
    _poller?.cancel();
    _poller = Timer.periodic(_pollInterval, (_) => drain(schoolId: schoolId));
    // Try immediately too, so returning to the app does not wait a minute.
    unawaited(drain(schoolId: schoolId));
  }

  @override
  void stopWatching() {
    _poller?.cancel();
    _poller = null;
  }
}

enum _ReplayOutcome { done, conflict, gone }
