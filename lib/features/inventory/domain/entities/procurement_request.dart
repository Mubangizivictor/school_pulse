enum ProcurementStatus { pending, approved, rejected, completed }

class ProcurementRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String itemName;
  final int quantity;
  final String reason;
  final ProcurementStatus status;
  final DateTime date;
  final String? directorNote;

  const ProcurementRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.itemName,
    required this.quantity,
    required this.reason,
    required this.status,
    required this.date,
    this.directorNote,
  });

  ProcurementRequest copyWith({
    ProcurementStatus? status,
    String? directorNote,
  }) {
    return ProcurementRequest(
      id: id,
      requesterId: requesterId,
      requesterName: requesterName,
      itemName: itemName,
      quantity: quantity,
      reason: reason,
      status: status ?? this.status,
      date: date,
      directorNote: directorNote ?? this.directorNote,
    );
  }
}
