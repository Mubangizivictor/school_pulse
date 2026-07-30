import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/medical_supply_request.dart';

DateTime _readRequestDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class MedicalSupplyRequestModel extends MedicalSupplyRequest {
  const MedicalSupplyRequestModel({
    required super.id,
    required super.itemName,
    required super.quantity,
    required super.unit,
    required super.requestedBy,
    required super.requestDate,
    super.status,
    super.bursaReviewNotes,
    super.rejectionReason,
    super.schoolId,
  });

  factory MedicalSupplyRequestModel.fromJson(Map<String, dynamic> json) {
    return MedicalSupplyRequestModel(
      id: json['id'] as String? ?? '',
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String,
      requestedBy: json['requestedBy'] as String,
      requestDate: _readRequestDate(json['requestDate']),
      status: SupplyRequestStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SupplyRequestStatus.pending,
      ),
      bursaReviewNotes: json['bursaReviewNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      schoolId: json['schoolId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'requestedBy': requestedBy,
      'requestDate': Timestamp.fromDate(requestDate),
      'status': status.toString(),
      'bursaReviewNotes': bursaReviewNotes,
      'rejectionReason': rejectionReason,
      'schoolId': schoolId,
    };
  }
}
