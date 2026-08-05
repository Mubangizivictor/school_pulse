import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meal_category.dart';
import '../entities/meal_record.dart';
import '../entities/menu_item.dart';
import '../entities/food_item.dart';
import '../entities/stock_request.dart';
import '../entities/wastage_record.dart';

abstract class CateringRepository {
  // Dashboard
  Future<Either<Failure, Map<String, dynamic>>> getCateringDashboardData();

  // Meal Management
  Future<Either<Failure, List<MealCategory>>> getMealCategories();
  Future<Either<Failure, void>> saveMealCategory(MealCategory category);

  // Menu Management
  Future<Either<Failure, List<MenuItem>>> getWeeklyMenu(DateTime date);
  Future<Either<Failure, void>> saveMenuItem(MenuItem menuItem);

  // Meal Verification
  Future<Either<Failure, Map<String, dynamic>>> verifyStudentMealEligibility(
    String studentId,
  );
  Future<Either<Failure, void>> recordMealServed(MealRecord record);

  // Inventory & Stock
  Future<Either<Failure, List<FoodItem>>> getInventory();
  Future<Either<Failure, void>> createStockRequest(StockRequest request);
  Future<Either<Failure, List<StockRequest>>> getStockRequests();

  // Reports
  Future<Either<Failure, List<MealRecord>>> getMealAttendanceReport(
    DateTime start,
    DateTime end,
  );

  // Wastage Tracking
  Future<Either<Failure, List<WastageRecord>>> getWastageRecords(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, void>> saveWastageRecord(WastageRecord record);

  // Financial Reporting
  Future<Either<Failure, Map<String, dynamic>>> getCateringFinancialReport(
    DateTime start,
    DateTime end,
  );
}
