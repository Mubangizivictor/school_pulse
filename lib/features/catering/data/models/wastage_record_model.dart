import '../../domain/entities/wastage_record.dart';

class WastageRecordModel extends WastageRecord {
  const WastageRecordModel({
    required super.id,
    required super.mealCategoryId,
    required super.mealCategoryName,
    required super.date,
    required super.quantityPrepared,
    required super.quantityServed,
    required super.quantityWasted,
    required super.unit,
    required super.reason,
    required super.costImpact,
  });

  factory WastageRecordModel.fromJson(Map<String, dynamic> json) {
    return WastageRecordModel(
      id: json['id'] ?? '',
      mealCategoryId: json['mealCategoryId'] ?? '',
      mealCategoryName: json['mealCategoryName'] ?? '',
      date: DateTime.parse(json['date']),
      quantityPrepared: (json['quantityPrepared'] ?? 0).toDouble(),
      quantityServed: (json['quantityServed'] ?? 0).toDouble(),
      quantityWasted: (json['quantityWasted'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      reason: json['reason'] ?? '',
      costImpact: (json['costImpact'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealCategoryId': mealCategoryId,
      'mealCategoryName': mealCategoryName,
      'date': date.toIso8601String(),
      'quantityPrepared': quantityPrepared,
      'quantityServed': quantityServed,
      'quantityWasted': quantityWasted,
      'unit': unit,
      'reason': reason,
      'costImpact': costImpact,
    };
  }
}
