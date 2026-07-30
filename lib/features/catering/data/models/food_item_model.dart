import '../../domain/entities/food_item.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.currentStock,
    required super.reorderLevel,
    super.category,
    super.expiryDate,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      currentStock: (json['currentStock'] ?? 0.0).toDouble(),
      reorderLevel: (json['reorderLevel'] ?? 0.0).toDouble(),
      category: json['category'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'currentStock': currentStock,
      'reorderLevel': reorderLevel,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}
