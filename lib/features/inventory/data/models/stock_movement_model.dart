import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/stock_movement.dart';

class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.itemId,
    required super.itemName,
    required super.type,
    required super.quantity,
    required super.date,
    required super.note,
  });

  factory StockMovementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockMovementModel(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      type: StockMovementType.values.firstWhere(
        (t) => t.name == (data['type'] ?? 'restock'),
        orElse: () => StockMovementType.restock,
      ),
      quantity: (data['quantity'] ?? 0) as int,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'type': type.name,
      'quantity': quantity,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
