import 'package:school_pulse/features/biometrics/domain/entities/biometric_audit_log.dart';

class BiometricAuditLogModel extends BiometricAuditLog {
  BiometricAuditLogModel({
    required super.id,
    required super.schoolId,
    super.personId,
    super.personName,
    super.personType,
    required super.deviceId,
    super.operatorId,
    required super.eventType,
    required super.timestamp,
    super.result,
    super.failureReason,
    super.location,
  });

  factory BiometricAuditLogModel.fromEntity(BiometricAuditLog entity) {
    return BiometricAuditLogModel(
      id: entity.id,
      schoolId: entity.schoolId,
      personId: entity.personId,
      personName: entity.personName,
      personType: entity.personType,
      deviceId: entity.deviceId,
      operatorId: entity.operatorId,
      eventType: entity.eventType,
      timestamp: entity.timestamp,
      result: entity.result,
      failureReason: entity.failureReason,
      location: entity.location,
    );
  }

  factory BiometricAuditLogModel.fromMap(Map<String, dynamic> map) {
    return BiometricAuditLogModel(
      id: map['id'] ?? '',
      schoolId: map['schoolId'] ?? '',
      personId: map['personId'],
      personName: map['personName'],
      personType: map['personType'],
      deviceId: map['deviceId'] ?? '',
      operatorId: map['operatorId'],
      eventType: BiometricEventType.values.firstWhere(
        (e) => e.name == map['eventType'],
        orElse: () => BiometricEventType.verificationFailed,
      ),
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      result: map['result'],
      failureReason: map['failureReason'],
      location: map['location'],
    );
  }
}
