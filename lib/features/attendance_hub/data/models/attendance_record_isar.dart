import 'package:isar/isar.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';

part 'attendance_record_isar.g.dart';

/// Local-first cache for attendance_hub marks, mirroring the
/// `GateIsar`/`MovementEventIsar` Isar-first-write pattern (see
/// `MovementSyncEngine`, `GateOpsRepositoryImpl.recordMovementEvent`): every
/// NFC/QR/manual mark lands here immediately, then a push is attempted, so a
/// scan is never lost to a dropped connection. `recordId` mirrors
/// `buildAttendanceRecordId`'s deterministic id, giving offline duplicate
/// detection the same identity Firestore already enforces server-side.
@collection
class AttendanceRecordIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String recordId;

  @Index()
  late String schoolId;
  late String category;
  @Index()
  late String scopeId;
  late String scopeName;
  late String sessionType;
  @Index()
  late DateTime date;
  @Index()
  late String personId;
  late String personName;
  late String status;
  late String method;
  late String markedBy;
  late String operatorId;
  late String deviceId;
  @Index()
  late String syncStatus;
  late DateTime createdAt;
  DateTime? correctedAt;
  String? correctionOf;
  String? roleAssignmentId;

  AttendanceRecordIsar();

  factory AttendanceRecordIsar.fromEntity(
    AttendanceRecord entity,
    String recordId,
  ) {
    return AttendanceRecordIsar()
      ..recordId = recordId
      ..schoolId = entity.schoolId
      ..category = entity.category.name
      ..scopeId = entity.scopeId
      ..scopeName = entity.scopeName
      ..sessionType = entity.sessionType
      ..date = entity.date
      ..personId = entity.personId
      ..personName = entity.personName
      ..status = entity.status.name
      ..method = entity.method.name
      ..markedBy = entity.markedBy
      ..operatorId = entity.operatorId
      ..deviceId = entity.deviceId
      ..syncStatus = entity.syncStatus.name
      ..createdAt = entity.createdAt
      ..correctedAt = entity.correctedAt
      ..correctionOf = entity.correctionOf
      ..roleAssignmentId = entity.roleAssignmentId;
  }

  AttendanceRecord toEntity() {
    return AttendanceRecord(
      id: recordId,
      schoolId: schoolId,
      category: AttendanceCategory.values.firstWhere(
        (c) => c.name == category,
        orElse: () => AttendanceCategory.custom,
      ),
      scopeId: scopeId,
      scopeName: scopeName,
      sessionType: sessionType,
      date: date,
      personId: personId,
      personName: personName,
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => AttendanceStatus.present,
      ),
      method: AttendanceMethod.values.firstWhere(
        (m) => m.name == method,
        orElse: () => AttendanceMethod.manual,
      ),
      markedBy: markedBy,
      operatorId: operatorId,
      deviceId: deviceId,
      syncStatus: AttendanceSyncStatus.values.firstWhere(
        (s) => s.name == syncStatus,
        orElse: () => AttendanceSyncStatus.pending,
      ),
      createdAt: createdAt,
      correctedAt: correctedAt,
      correctionOf: correctionOf,
      roleAssignmentId: roleAssignmentId,
    );
  }
}
