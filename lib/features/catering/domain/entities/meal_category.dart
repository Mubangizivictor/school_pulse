import 'package:equatable/equatable.dart';

class MealCategory extends Equatable {
  final String id;
  final String name; // Breakfast, Lunch, Supper, Tea Break, etc.
  final double price;
  final String startTime;
  final String endTime;
  final List<String> applicableTo; // Boarders, Day Scholars, All

  const MealCategory({
    required this.id,
    required this.name,
    required this.price,
    required this.startTime,
    required this.endTime,
    required this.applicableTo,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    startTime,
    endTime,
    applicableTo,
  ];
}
