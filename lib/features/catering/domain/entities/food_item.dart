import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String unit; // kg, liters, pieces, etc.
  final double currentStock;
  final double reorderLevel;
  final String? category;
  final DateTime? expiryDate;

  const FoodItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.reorderLevel,
    this.category,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [id, name, unit, currentStock, reorderLevel, category, expiryDate];
}
