import 'package:equatable/equatable.dart';

class AuditLog extends Equatable {
  final String id;
  final String ownerId;
  final String action;
  final String? schoolId;
  final String? affectedUserId;
  final DateTime timestamp;
  final String device;
  final String? reason;
  final Map<String, dynamic> metadata;

  const AuditLog({
    required this.id,
    required this.ownerId,
    required this.action,
    this.schoolId,
    this.affectedUserId,
    required this.timestamp,
    required this.device,
    this.reason,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        action,
        schoolId,
        affectedUserId,
        timestamp,
        device,
        reason,
        metadata,
      ];
}
