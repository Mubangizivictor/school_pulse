import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/repair.dart';

class RepairRecordModel extends RepairRecord {
  const RepairRecordModel({
    required super.id,
    required super.assetId,
    required super.assetName,
    required super.description,
    super.technicianName,
    super.estimatedCost,
    super.actualCost,
    required super.status,
    super.partsUsed,
    required super.requestDate,
    super.completionDate,
    super.notes,
    super.beforePhotoUrl,
    super.afterPhotoUrl,
  });

  factory RepairRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RepairRecordModel(
      id: doc.id,
      assetId: data['assetId'] ?? '',
      assetName: data['assetName'] ?? '',
      description: data['description'] ?? '',
      technicianName: data['technicianName'],
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      actualCost: (data['actualCost'] as num?)?.toDouble() ?? 0.0,
      status: RepairStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RepairStatus.pending,
      ),
      partsUsed: List<String>.from(data['partsUsed'] ?? []),
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      completionDate: data['completionDate'] != null
          ? (data['completionDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      beforePhotoUrl: data['beforePhotoUrl'],
      afterPhotoUrl: data['afterPhotoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assetId': assetId,
      'assetName': assetName,
      'description': description,
      'technicianName': technicianName,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'status': status.name,
      'partsUsed': partsUsed,
      'requestDate': Timestamp.fromDate(requestDate),
      'completionDate': completionDate != null ? Timestamp.fromDate(completionDate!) : null,
      'notes': notes,
      'beforePhotoUrl': beforePhotoUrl,
      'afterPhotoUrl': afterPhotoUrl,
    };
  }

  factory RepairRecordModel.fromEntity(RepairRecord repair) {
    return RepairRecordModel(
      id: repair.id,
      assetId: repair.assetId,
      assetName: repair.assetName,
      description: repair.description,
      technicianName: repair.technicianName,
      estimatedCost: repair.estimatedCost,
      actualCost: repair.actualCost,
      status: repair.status,
      partsUsed: repair.partsUsed,
      requestDate: repair.requestDate,
      completionDate: repair.completionDate,
      notes: repair.notes,
      beforePhotoUrl: repair.beforePhotoUrl,
      afterPhotoUrl: repair.afterPhotoUrl,
    );
  }
}
