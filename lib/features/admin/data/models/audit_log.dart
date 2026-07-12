import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String iconName;
  final String colorHex;
  final String? userId;

  AuditLog({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconName,
    required this.colorHex,
    this.userId,
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
    );
  }
}
