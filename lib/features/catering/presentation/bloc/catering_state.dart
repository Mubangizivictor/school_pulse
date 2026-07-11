import 'package:equatable/equatable.dart';

abstract class CateringState extends Equatable {
  const CateringState();

  @override
  List<Object?> get props => [];
}

class CateringInitial extends CateringState {}

class CateringLoading extends CateringState {}

class CateringLoaded extends CateringState {
  final List<MealPlan> todayMeals;
  final int totalStudents;
  final int specialDiets;
  final double stockLevel; // 0.0 to 1.0

  const CateringLoaded({
    required this.todayMeals,
    required this.totalStudents,
    required this.specialDiets,
    required this.stockLevel,
  });

  @override
  List<Object?> get props => [todayMeals, totalStudents, specialDiets, stockLevel];
}

class MealPlan extends Equatable {
  final String mealType; // Breakfast, Lunch, Dinner
  final String menu;
  final String time;

  const MealPlan({required this.mealType, required this.menu, required this.time});

  @override
  List<Object?> get props => [mealType, menu, time];
}

class CateringError extends CateringState {
  final String message;
  const CateringError(this.message);

  @override
  List<Object?> get props => [message];
}
