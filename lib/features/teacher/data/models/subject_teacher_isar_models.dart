import 'dart:convert';

import 'package:isar/isar.dart';

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
      ..deviceId = e.deviceId;
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
