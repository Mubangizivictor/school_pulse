import '../../domain/entities/meal_category.dart';

class MealCategoryModel extends MealCategory {
  const MealCategoryModel({
    required super.id,
    required super.name,
    required super.price,
    required super.startTime,
    required super.endTime,
    required super.applicableTo,
  });

  factory MealCategoryModel.fromJson(Map<String, dynamic> json) {
    return MealCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      applicableTo: List<String>.from(json['applicableTo'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'startTime': startTime,
      'endTime': endTime,
      'applicableTo': applicableTo,
    };
  }
}
