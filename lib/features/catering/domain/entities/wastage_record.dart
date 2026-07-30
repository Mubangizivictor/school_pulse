import 'package:equatable/equatable.dart';

class WastageRecord extends Equatable {
  final String id;
  final String mealCategoryId;
  final String mealCategoryName;
  final DateTime date;
  final double quantityPrepared;
  final double quantityServed;
  final double quantityWasted;
  final String unit;
  final String reason;
  final double costImpact;

  const WastageRecord({
    required this.id,
    required this.mealCategoryId,
    required this.mealCategoryName,
    required this.date,
    required this.quantityPrepared,
    required this.quantityServed,
    required this.quantityWasted,
    required this.unit,
    required this.reason,
    required this.costImpact,
  });

  @override
  List<Object?> get props => [
        id,
        mealCategoryId,
        mealCategoryName,
        date,
        quantityPrepared,
        quantityServed,
        quantityWasted,
        unit,
        reason,
        costImpact,
      ];
}
