import 'package:equatable/equatable.dart';

enum SupplyRequestStatus { pending, approved, purchased, delivered, rejected }

class MedicalSupplyRequest extends Equatable {
  final String id;
  final String itemName;
  final int quantity;
  final String unit;
  final String requestedBy;
  final DateTime requestDate;
  final SupplyRequestStatus status;
  final String? bursaReviewNotes;
  final String? rejectionReason;
  final String? schoolId;

  const MedicalSupplyRequest({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.requestedBy,
    required this.requestDate,
    this.status = SupplyRequestStatus.pending,
    this.bursaReviewNotes,
    this.rejectionReason,
    this.schoolId,
  });

  MedicalSupplyRequest copyWith({
    SupplyRequestStatus? status,
    String? bursaReviewNotes,
    String? rejectionReason,
  }) {
    return MedicalSupplyRequest(
      id: id,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      requestedBy: requestedBy,
      requestDate: requestDate,
      status: status ?? this.status,
      bursaReviewNotes: bursaReviewNotes ?? this.bursaReviewNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      schoolId: schoolId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    itemName,
    quantity,
    unit,
    requestedBy,
    requestDate,
    status,
    bursaReviewNotes,
    rejectionReason,
    schoolId,
  ];
}
