import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String iconName;
  final String colorHex;
  final String? userId;

  /// Id of the record this entry is about (e.g. a role definition or role
  /// assignment id), so a details screen's History tab can filter without
  /// string-matching [description]. Optional and additive - entries written
  /// before this field existed simply have none.
  final String? relatedEntityId;

  AuditLog({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconName,
    required this.colorHex,
    this.userId,
    this.relatedEntityId,
  });

  factory AuditLog.fromMap(Map<String, dynamic> map, String id) {
    return AuditLog(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      iconName: map['iconName'] ?? 'info',
      colorHex: map['colorHex'] ?? 'FF000000',
      userId: map['userId'],
      relatedEntityId: map['relatedEntityId'],
    );
  }
}
