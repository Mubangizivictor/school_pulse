import 'package:cloud_firestore/cloud_firestore.dart';
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
      timestamp: _parseDate(json['timestamp']) ?? DateTime.now(),
      device: json['device'] ?? '',
      reason: json['reason'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
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
