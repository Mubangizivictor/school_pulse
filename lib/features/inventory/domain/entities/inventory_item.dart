import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int lowStockThreshold;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  InventoryItem copyWith({int? quantity}) {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity ?? this.quantity,
      unit: unit,
      lowStockThreshold: lowStockThreshold,
    );
  }

  @override
  List<Object?> get props => [id, name, category, quantity, unit, lowStockThreshold];
}
