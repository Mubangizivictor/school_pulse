import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.mealCategoryId,
    required super.dayOfWeek,
    super.date,
    required super.items,
    super.description = '',
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? '',
      mealCategoryId: json['mealCategoryId'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      items: List<String>.from(json['items'] ?? []),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealCategoryId': mealCategoryId,
      'dayOfWeek': dayOfWeek,
      'date': date?.toIso8601String(),
      'items': items,
      'description': description,
    };
  }
}
