import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/maintenance.dart';

class MaintenanceRecordModel extends MaintenanceRecord {
  const MaintenanceRecordModel({
    required super.id,
    required super.assetId,
    required super.assetName,
    required super.type,
    required super.description,
    required super.scheduledDate,
    super.completionDate,
    required super.status,
    super.performedBy,
    super.cost,
    super.notes,
  });

  factory MaintenanceRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceRecordModel(
      id: doc.id,
      assetId: data['assetId'] ?? '',
      assetName: data['assetName'] ?? '',
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MaintenanceType.routine,
      ),
      description: data['description'] ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      completionDate: data['completionDate'] != null
          ? (data['completionDate'] as Timestamp).toDate()
          : null,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MaintenanceStatus.scheduled,
      ),
      performedBy: data['performedBy'],
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assetId': assetId,
      'assetName': assetName,
      'type': type.name,
      'description': description,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'completionDate': completionDate != null
          ? Timestamp.fromDate(completionDate!)
          : null,
      'status': status.name,
      'performedBy': performedBy,
      'cost': cost,
      'notes': notes,
    };
  }

  factory MaintenanceRecordModel.fromEntity(MaintenanceRecord maintenance) {
    return MaintenanceRecordModel(
      id: maintenance.id,
      assetId: maintenance.assetId,
      assetName: maintenance.assetName,
      type: maintenance.type,
      description: maintenance.description,
      scheduledDate: maintenance.scheduledDate,
      completionDate: maintenance.completionDate,
      status: maintenance.status,
      performedBy: maintenance.performedBy,
      cost: maintenance.cost,
      notes: maintenance.notes,
    );
  }
}
