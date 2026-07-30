import 'package:equatable/equatable.dart';

class StockIssue extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final String issuedToId;
  final String issuedToName;
  final String department;
  final String purpose;
  final int quantity;
  final DateTime date;
  final String approvedBy;
  final bool returned;
  final DateTime? returnDate;

  const StockIssue({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.issuedToId,
    required this.issuedToName,
    required this.department,
    required this.purpose,
    required this.quantity,
    required this.date,
    required this.approvedBy,
    this.returned = false,
    this.returnDate,
  });

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        issuedToId,
        issuedToName,
        department,
        purpose,
        quantity,
        date,
        approvedBy,
        returned,
        returnDate,
      ];
}
