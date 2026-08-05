import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String mealCategoryId;
  final String dayOfWeek; // Monday, Tuesday, etc. or specific date
  final DateTime? date;
  final List<String> items; // e.g., ["Rice", "Beans", "Beef"]
  final String description;

  const MenuItem({
    required this.id,
    required this.mealCategoryId,
    required this.dayOfWeek,
    this.date,
    required this.items,
    this.description = '',
  });

  @override
  List<Object?> get props => [
    id,
    mealCategoryId,
    dayOfWeek,
    date,
    items,
    description,
  ];
}
