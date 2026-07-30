import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_category.dart';
import '../../domain/entities/meal_record.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/stock_request.dart';
import '../../domain/entities/wastage_record.dart';
import '../../domain/repositories/catering_repository.dart';
import '../datasources/catering_local_data_source.dart';
import '../datasources/catering_remote_data_source.dart';
import '../models/meal_category_model.dart';
import '../models/meal_record_model.dart';
import '../models/menu_item_model.dart';
import '../models/wastage_record_model.dart';

class CateringRepositoryImpl implements CateringRepository {
  final CateringRemoteDataSource remoteDataSource;
  final CateringLocalDataSource localDataSource;

  CateringRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCateringDashboardData() async {
    try {
      final data = await remoteDataSource.getCateringDashboardData();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealCategory>>> getMealCategories() async {
    try {
      final categories = await remoteDataSource.getMealCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMealCategory(MealCategory category) async {
    try {
      final model = MealCategoryModel(
        id: category.id,
        name: category.name,
        price: category.price,
        startTime: category.startTime,
        endTime: category.endTime,
        applicableTo: category.applicableTo,
      );
      await remoteDataSource.saveMealCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getWeeklyMenu(DateTime date) async {
    try {
      final menuItems = await remoteDataSource.getWeeklyMenu(date);
      return Right(menuItems);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMenuItem(MenuItem menuItem) async {
    try {
      final model = MenuItemModel(
        id: menuItem.id,
        mealCategoryId: menuItem.mealCategoryId,
        dayOfWeek: menuItem.dayOfWeek,
        date: menuItem.date,
        items: menuItem.items,
        description: menuItem.description,
      );
      await remoteDataSource.saveMenuItem(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyStudentMealEligibility(String studentId) async {
    try {
      final data = await remoteDataSource.verifyStudentMealEligibility(studentId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordMealServed(MealRecord record) async {
    try {
      final model = MealRecordModel(
        id: record.id,
        studentId: record.studentId,
        studentName: record.studentName,
        classId: record.classId,
        mealCategoryId: record.mealCategoryId,
        mealCategoryName: record.mealCategoryName,
        servedAt: record.servedAt,
        servedBy: record.servedBy,
        schoolId: record.schoolId,
        academicYear: record.academicYear,
        term: record.term,
      );
      
      // Always cache locally first for offline support
      await localDataSource.cacheMealRecord(model);
      
      // Try to sync to remote if possible
      try {
        await remoteDataSource.recordMealServed(model);
        // If successful, we could mark as synced immediately, 
        // but typically a background sync worker handles this.
      } catch (e) {
        // Silently fail remote record, it's cached locally
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getInventory() async {
    try {
      final inventory = await remoteDataSource.getInventory();
      return Right(inventory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createStockRequest(StockRequest request) async {
    try {
      final requestData = {
        'requestedBy': request.requestedBy,
        'requestedAt': request.requestedAt.toIso8601String(),
        'status': request.status.name,
        'items': request.items.map((item) => {
          'foodItemId': item.foodItemId,
          'foodItemName': item.foodItemName,
          'quantity': item.quantity,
          'unit': item.unit,
        }).toList(),
      };
      await remoteDataSource.createStockRequest(requestData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockRequest>>> getStockRequests() async {
    try {
      final rawRequests = await remoteDataSource.getStockRequests();
      final requests = rawRequests.map((data) => StockRequest(
        id: data['id'],
        requestedBy: data['requestedBy'],
        requestedAt: DateTime.parse(data['requestedAt']),
        status: StockRequestStatus.values.firstWhere((e) => e.name == data['status']),
        items: (data['items'] as List).map((item) => StockRequestItem(
          foodItemId: item['foodItemId'],
          foodItemName: item['foodItemName'],
          quantity: item['quantity'],
          unit: item['unit'],
        )).toList(),
        approvedBy: data['approvedBy'],
        approvedAt: data['approvedAt'] != null ? DateTime.parse(data['approvedAt']) : null,
        comments: data['comments'],
      )).toList();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealRecord>>> getMealAttendanceReport(DateTime start, DateTime end) async {
    try {
      final records = await remoteDataSource.getMealAttendanceReport(start, end);
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WastageRecord>>> getWastageRecords(DateTime start, DateTime end) async {
    try {
      final records = await remoteDataSource.getWastageRecords(start, end);
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveWastageRecord(WastageRecord record) async {
    try {
      final model = WastageRecordModel(
        id: record.id,
        mealCategoryId: record.mealCategoryId,
        mealCategoryName: record.mealCategoryName,
        date: record.date,
        quantityPrepared: record.quantityPrepared,
        quantityServed: record.quantityServed,
        quantityWasted: record.quantityWasted,
        unit: record.unit,
        reason: record.reason,
        costImpact: record.costImpact,
      );
      await remoteDataSource.saveWastageRecord(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCateringFinancialReport(DateTime start, DateTime end) async {
    try {
      final report = await remoteDataSource.getCateringFinancialReport(start, end);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
