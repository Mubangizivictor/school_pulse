import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int lowStockThreshold;
  final int? maximumStock;
  final int? reorderLevel;
  final String? warehouseLocation;
  final String? storeLocation;
  final DateTime? expiryDate;

  const InventoryItem({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
    this.maximumStock,
    this.reorderLevel,
    this.warehouseLocation,
    this.storeLocation,
    this.expiryDate,
  });

  bool get isLowStock => quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity <= 0;
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  InventoryItem copyWith({
    int? quantity,
    int? lowStockThreshold,
    int? maximumStock,
    int? reorderLevel,
    String? warehouseLocation,
    String? storeLocation,
    DateTime? expiryDate,
  }) {
    return InventoryItem(
      id: id,
      schoolId: schoolId,
      name: name,
      category: category,
      quantity: quantity ?? this.quantity,
      unit: unit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      maximumStock: maximumStock ?? this.maximumStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      storeLocation: storeLocation ?? this.storeLocation,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        name,
        category,
        quantity,
        unit,
        lowStockThreshold,
        maximumStock,
        reorderLevel,
        warehouseLocation,
        storeLocation,
        expiryDate,
      ];
}
