import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/offline_operation.dart';
import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/subject_teacher_local_data_source.dart';
import '../datasources/subject_teacher_remote_data_source.dart';
import '../models/subject_teacher_isar_models.dart';

class SubjectAuditServiceImpl implements SubjectAuditService {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectTeacherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final DeviceIdService deviceIdService;
  final Uuid uuid;

  SubjectAuditServiceImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.deviceIdService,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<void> record({
    required ActiveResponsibilityContext context,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    String? reason,
    String? offlineOperationId,
  }) async {
    final log = SubjectAuditLog(
      auditId: uuid.v4(),
      schoolId: context.schoolId,
      campusId: context.campusId,
      userId: context.userId,
      staffId: context.staffId,
      roleAssignmentId: context.roleAssignmentId,
      activeRole: context.roleType,
      // Coordinates come from the verified context, not from the caller, so a
      // row cannot be filed against a scope the action did not happen in.
      subjectId: context.subjectId,
      classId: context.classId,
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      previousValue: previousValue,
      newValue: newValue,
      reason: reason,
      timestamp: DateTime.now(),
      deviceId: await _deviceId(),
      platform: _platform(),
      offlineOperationId: offlineOperationId,
    );

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.writeAuditLog(log);
        return;
      } catch (_) {
        // Fall through and queue. Losing the audit row is worse than a
        // delayed one, and the action itself has already happened.
      }
    }

    await _queue(log);
  }

  @override
  Future<void> flushPending() async {
    if (!await networkInfo.isConnected) return;

    final pending = await localDataSource.getPendingOperations();
    final auditOps =
        pending.where((op) => op.entityType == OfflineOperationType.auditLog).toList();

    for (final op in auditOps) {
      try {
        await remoteDataSource.writeAuditLog(_logFromPayload(op));
        await localDataSource.deleteOperation(op.operationId);
      } catch (e) {
        final entity = op.toEntity();
        await localDataSource.updateOperation(
          SubjectTeacherOfflineOperationIsar.fromEntity(
            entity.copyWith(
              retryCount: entity.retryCount + 1,
              lastError: e.toString(),
              status: entity.canRetry
                  ? OfflineSyncStatus.pending
                  : OfflineSyncStatus.failed,
            ),
          ),
        );
      }
    }
  }

  Future<void> _queue(SubjectAuditLog log) async {
    final operation = OfflineOperation(
      operationId: log.auditId,
      entityType: OfflineOperationType.auditLog,
      entityId: log.entityId,
      action: log.action,
      payload: _toPayload(log),
      createdAt: log.timestamp,
      schoolId: log.schoolId,
      userId: log.userId,
      roleAssignmentId: log.roleAssignmentId,
      deviceId: log.deviceId,
    );
    await localDataSource.enqueueOperation(
      SubjectTeacherOfflineOperationIsar.fromEntity(operation),
    );
  }

  Map<String, dynamic> _toPayload(SubjectAuditLog log) => {
        'auditId': log.auditId,
        'schoolId': log.schoolId,
        'campusId': log.campusId,
        'userId': log.userId,
        'staffId': log.staffId,
        'roleAssignmentId': log.roleAssignmentId,
        'activeRole': log.activeRole.name,
        'subjectId': log.subjectId,
        'classId': log.classId,
        'streamId': log.streamId,
        'academicYearId': log.academicYearId,
        'termId': log.termId,
        'action': log.action,
        'entityType': log.entityType,
        'entityId': log.entityId,
        'previousValue':
            log.previousValue == null ? null : jsonEncode(log.previousValue),
        'newValue': log.newValue == null ? null : jsonEncode(log.newValue),
        'reason': log.reason,
        'timestamp': log.timestamp.toIso8601String(),
        'deviceId': log.deviceId,
        'platform': log.platform,
      };

  SubjectAuditLog _logFromPayload(SubjectTeacherOfflineOperationIsar op) {
    final p = op.toEntity().payload;
    return SubjectAuditLog(
      auditId: p['auditId'] as String? ?? op.operationId,
      schoolId: p['schoolId'] as String? ?? op.schoolId,
      campusId: p['campusId'] as String? ?? '',
      userId: p['userId'] as String? ?? op.userId,
      staffId: p['staffId'] as String? ?? '',
      roleAssignmentId: p['roleAssignmentId'] as String? ?? op.roleAssignmentId,
      activeRole: StaffResponsibilityType.fromId(p['activeRole'] as String?),
      subjectId: p['subjectId'] as String?,
      classId: p['classId'] as String?,
      streamId: p['streamId'] as String?,
      academicYearId: p['academicYearId'] as String? ?? '',
      termId: p['termId'] as String?,
      action: p['action'] as String? ?? op.action,
      entityType: p['entityType'] as String? ?? '',
      entityId: p['entityId'] as String? ?? op.entityId,
      previousValue: _decodeMap(p['previousValue']),
      newValue: _decodeMap(p['newValue']),
      reason: p['reason'] as String?,
      timestamp: DateTime.tryParse(p['timestamp'] as String? ?? '') ?? op.createdAt,
      deviceId: p['deviceId'] as String? ?? op.deviceId,
      platform: p['platform'] as String? ?? '',
      // Marks the row as a replay, so a reviewer can tell a delayed write
      // from a backdated one.
      offlineOperationId: op.operationId,
    );
  }

  static Map<String, dynamic>? _decodeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  Future<String> _deviceId() async {
    try {
      return await deviceIdService.getDeviceId();
    } catch (_) {
      return '';
    }
  }

  String _platform() {
    if (kIsWeb) return 'web';
    try {
      return Platform.operatingSystem;
    } catch (_) {
      return 'unknown';
    }
  }
}
