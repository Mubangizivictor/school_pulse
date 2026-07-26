import 'package:equatable/equatable.dart';

enum StockMovementType { restock, issue }

class StockMovement extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final StockMovementType type;
  final int quantity;
  final DateTime date;
  final String note;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.date,
    required this.note,
  });

  @override
  List<Object?> get props => [id, itemId, itemName, type, quantity, date, note];
}
