import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/meal_record.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/stock_request.dart';
import '../../domain/entities/wastage_record.dart';

abstract class CateringState extends Equatable {
  const CateringState();

  @override
  List<Object?> get props => [];
}

class CateringInitial extends CateringState {}

class CateringLoading extends CateringState {}

class CateringDashboardLoaded extends CateringState {
  final Map<String, dynamic> dashboardData;
  const CateringDashboardLoaded(this.dashboardData);

  @override
  List<Object?> get props => [dashboardData];
}

class MealCategoriesLoaded extends CateringState {
  final List<MealCategory> categories;
  const MealCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class WeeklyMenuLoaded extends CateringState {
  final List<MenuItem> menuItems;
  const WeeklyMenuLoaded(this.menuItems);

  @override
  List<Object?> get props => [menuItems];
}

class MealEligibilityVerified extends CateringState {
  final Map<String, dynamic> eligibilityData;
  const MealEligibilityVerified(this.eligibilityData);

  @override
  List<Object?> get props => [eligibilityData];
}

class InventoryLoaded extends CateringState {
  final List<FoodItem> items;
  const InventoryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class StockRequestsLoaded extends CateringState {
  final List<StockRequest> requests;
  const StockRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class MealAttendanceReportLoaded extends CateringState {
  final List<MealRecord> records;
  const MealAttendanceReportLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class WastageRecordsLoaded extends CateringState {
  final List<WastageRecord> records;
  const WastageRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class FinancialReportLoaded extends CateringState {
  final Map<String, dynamic> report;
  const FinancialReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class CateringSuccess extends CateringState {
  final String message;
  const CateringSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CateringError extends CateringState {
  final String message;
  const CateringError(this.message);

  @override
  List<Object?> get props => [message];
}
