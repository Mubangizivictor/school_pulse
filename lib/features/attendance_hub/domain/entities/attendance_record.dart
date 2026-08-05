import 'package:equatable/equatable.dart';
import 'attendance_category.dart';

enum AttendanceStatus { present, absent, late, excused }

enum AttendanceMethod { nfc, qr, manual }

enum AttendanceSyncStatus { pending, synced, failed }

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
  });

  AttendanceRecord copyWith({
    AttendanceStatus? status,
    AttendanceSyncStatus? syncStatus,
    DateTime? correctedAt,
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
  ];
}
