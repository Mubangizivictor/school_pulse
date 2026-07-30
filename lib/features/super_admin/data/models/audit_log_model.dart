import '../../domain/entities/audit_log.dart';

class AuditLogModel extends AuditLog {
  const AuditLogModel({
    required super.id,
    required super.ownerId,
    required super.action,
    super.schoolId,
    super.affectedUserId,
    required super.timestamp,
    required super.device,
    super.reason,
    super.metadata,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      action: json['action'] ?? '',
      schoolId: json['schoolId'],
      affectedUserId: json['affectedUserId'],
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) 
          : DateTime.now(),
      device: json['device'] ?? '',
      reason: json['reason'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'action': action,
      'schoolId': schoolId,
      'affectedUserId': affectedUserId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'device': device,
      'reason': reason,
      'metadata': metadata,
    };
  }
}
