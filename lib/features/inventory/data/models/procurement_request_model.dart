import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/procurement_request.dart';

class ProcurementRequestModel extends ProcurementRequest {
  const ProcurementRequestModel({
    required super.id,
    required super.requesterId,
    required super.requesterName,
    required super.itemName,
    required super.quantity,
    required super.reason,
    required super.status,
    required super.date,
    super.directorNote,
  });

  factory ProcurementRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProcurementRequestModel(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      itemName: data['itemName'] ?? '',
      quantity: data['quantity'] ?? 0,
      reason: data['reason'] ?? '',
      status: ProcurementStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProcurementStatus.pending,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      directorNote: data['directorNote'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'itemName': itemName,
      'quantity': quantity,
      'reason': reason,
      'status': status.name,
      'date': Timestamp.fromDate(date),
      'directorNote': directorNote,
    };
  }

  factory ProcurementRequestModel.fromEntity(ProcurementRequest request) {
    return ProcurementRequestModel(
      id: request.id,
      requesterId: request.requesterId,
      requesterName: request.requesterName,
      itemName: request.itemName,
      quantity: request.quantity,
      reason: request.reason,
      status: request.status,
      date: request.date,
      directorNote: request.directorNote,
    );
  }
}
