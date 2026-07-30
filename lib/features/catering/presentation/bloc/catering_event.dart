import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/meal_record.dart';
import '../../domain/entities/stock_request.dart';
import '../../domain/entities/wastage_record.dart';

abstract class CateringEvent extends Equatable {
  const CateringEvent();

  @override
  List<Object?> get props => [];
}

class LoadCateringDashboard extends CateringEvent {}

class LoadMealCategories extends CateringEvent {}

class SaveMealCategoryEvent extends CateringEvent {
  final MealCategory category;
  const SaveMealCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadWeeklyMenu extends CateringEvent {
  final DateTime date;
  const LoadWeeklyMenu(this.date);

  @override
  List<Object?> get props => [date];
}

class SaveMenuItemEvent extends CateringEvent {
  final MenuItem menuItem;
  const SaveMenuItemEvent(this.menuItem);

  @override
  List<Object?> get props => [menuItem];
}

class VerifyStudentMeal extends CateringEvent {
  final String studentId;
  const VerifyStudentMeal(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class RecordMealServedEvent extends CateringEvent {
  final MealRecord record;
  const RecordMealServedEvent(this.record);

  @override
  List<Object?> get props => [record];
}

class LoadInventoryEvent extends CateringEvent {}

class CreateStockRequestEvent extends CateringEvent {
  final StockRequest request;
  const CreateStockRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class LoadStockRequests extends CateringEvent {}

class LoadMealAttendanceReport extends CateringEvent {
  final DateTime start;
  final DateTime end;
  const LoadMealAttendanceReport(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class LoadWastageRecords extends CateringEvent {
  final DateTime start;
  final DateTime end;
  const LoadWastageRecords(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class SaveWastageRecordEvent extends CateringEvent {
  final WastageRecord record;
  const SaveWastageRecordEvent(this.record);

  @override
  List<Object?> get props => [record];
}

class LoadFinancialReport extends CateringEvent {
  final DateTime start;
  final DateTime end;
  const LoadFinancialReport(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}
