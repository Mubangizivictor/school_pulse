import 'package:equatable/equatable.dart';

enum AdjustmentReason { correction, damage, loss, returnToSupplier, other }

class StockAdjustment extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final int quantityAdjusted; // Positive or negative
  final AdjustmentReason reason;
  final String notes;
  final DateTime date;
  final String adjustedBy;

  const StockAdjustment({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantityAdjusted,
    required this.reason,
    required this.notes,
    required this.date,
    required this.adjustedBy,
  });

  @override
  List<Object?> get props => [id, itemId, itemName, quantityAdjusted, reason, notes, date, adjustedBy];
}
