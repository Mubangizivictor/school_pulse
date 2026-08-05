import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.schoolId,
    required super.category,
    required super.scopeId,
    super.scopeName,
    super.sessionType,
    required super.date,
    required super.personId,
    super.personName,
    required super.status,
    required super.method,
    super.markedBy,
    super.operatorId,
    super.deviceId,
    super.syncStatus,
    required super.createdAt,
    super.correctedAt,
    super.correctionOf,
  });

  factory AttendanceRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecordModel(
      id: doc.id,
      schoolId: data['schoolId'] as String? ?? '',
      category: AttendanceCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => AttendanceCategory.custom,
      ),
      scopeId: data['scopeId'] as String? ?? '',
      scopeName: data['scopeName'] as String? ?? '',
      sessionType: data['sessionType'] as String? ?? 'daily',
      date: (data['date'] as Timestamp).toDate(),
      personId: data['personId'] as String? ?? '',
      personName: data['personName'] as String? ?? '',
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AttendanceStatus.present,
      ),
      method: AttendanceMethod.values.firstWhere(
        (m) => m.name == data['method'],
        orElse: () => AttendanceMethod.manual,
      ),
      markedBy: data['markedBy'] as String? ?? '',
      operatorId: data['operatorId'] as String? ?? '',
      deviceId: data['deviceId'] as String? ?? '',
      syncStatus: AttendanceSyncStatus.values.firstWhere(
        (s) => s.name == data['syncStatus'],
        orElse: () => AttendanceSyncStatus.synced,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      correctedAt: (data['correctedAt'] as Timestamp?)?.toDate(),
      correctionOf: data['correctionOf'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'category': category.name,
      'scopeId': scopeId,
      'scopeName': scopeName,
      'sessionType': sessionType,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'personId': personId,
      'personName': personName,
      'status': status.name,
      'method': method.name,
      'markedBy': markedBy,
      'operatorId': operatorId,
      'deviceId': deviceId,
      'syncStatus': syncStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'correctedAt': correctedAt != null ? Timestamp.fromDate(correctedAt!) : null,
      'correctionOf': correctionOf,
    };
  }

  factory AttendanceRecordModel.fromEntity(AttendanceRecord r) {
    return AttendanceRecordModel(
      id: r.id,
      schoolId: r.schoolId,
      category: r.category,
      scopeId: r.scopeId,
      scopeName: r.scopeName,
      sessionType: r.sessionType,
      date: r.date,
      personId: r.personId,
      personName: r.personName,
      status: r.status,
      method: r.method,
      markedBy: r.markedBy,
      operatorId: r.operatorId,
      deviceId: r.deviceId,
      syncStatus: r.syncStatus,
      createdAt: r.createdAt,
      correctedAt: r.correctedAt,
      correctionOf: r.correctionOf,
    );
  }
}
