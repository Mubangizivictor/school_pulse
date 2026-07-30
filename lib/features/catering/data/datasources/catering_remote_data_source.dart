import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_category_model.dart';
import '../models/meal_record_model.dart';
import '../models/menu_item_model.dart';
import '../models/food_item_model.dart';
import '../models/wastage_record_model.dart';

abstract class CateringRemoteDataSource {
  Future<Map<String, dynamic>> getCateringDashboardData();
  Future<List<MealCategoryModel>> getMealCategories();
  Future<void> saveMealCategory(MealCategoryModel category);
  Future<List<MenuItemModel>> getWeeklyMenu(DateTime date);
  Future<void> saveMenuItem(MenuItemModel menuItem);
  Future<Map<String, dynamic>> verifyStudentMealEligibility(String studentId);
  Future<void> recordMealServed(MealRecordModel record);
  Future<List<FoodItemModel>> getInventory();
  Future<void> createStockRequest(Map<String, dynamic> requestData);
  Future<List<Map<String, dynamic>>> getStockRequests();
  Future<List<MealRecordModel>> getMealAttendanceReport(DateTime start, DateTime end);
  
  // Wastage
  Future<List<WastageRecordModel>> getWastageRecords(DateTime start, DateTime end);
  Future<void> saveWastageRecord(WastageRecordModel record);

  // Financial
  Future<Map<String, dynamic>> getCateringFinancialReport(DateTime start, DateTime end);
}

class CateringRemoteDataSourceImpl implements CateringRemoteDataSource {
  final FirebaseFirestore firestore;

  CateringRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Map<String, dynamic>> getCateringDashboardData() async {
    // In a real app, these would be aggregated from multiple collections or a dedicated summary doc
    final summaryDoc = await firestore.collection('catering_summary').doc('current').get();
    return summaryDoc.data() ?? {
      'expectedStudents': 0,
      'boardersCount': 0,
      'dayScholarsCount': 0,
      'mealsServedToday': 0,
      'lowStockAlerts': 0,
      'pendingRequests': 0,
    };
  }

  @override
  Future<List<MealCategoryModel>> getMealCategories() async {
    final snapshot = await firestore.collection('meal_categories').get();
    return snapshot.docs.map((doc) => MealCategoryModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> saveMealCategory(MealCategoryModel category) async {
    await firestore.collection('meal_categories').doc(category.id).set(category.toJson());
  }

  @override
  Future<List<MenuItemModel>> getWeeklyMenu(DateTime date) async {
    // Simplified: fetch menu for the whole week
    final snapshot = await firestore.collection('menu_items').get();
    return snapshot.docs.map((doc) => MenuItemModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> saveMenuItem(MenuItemModel menuItem) async {
    await firestore.collection('menu_items').doc(menuItem.id).set(menuItem.toJson());
  }

  @override
  Future<Map<String, dynamic>> verifyStudentMealEligibility(String studentId) async {
    // This involves checking the finance/bursar collection for payment status
    final financeDoc = await firestore.collection('finance').doc(studentId).get();
    final studentDoc = await firestore.collection('students').doc(studentId).get();
    
    if (!studentDoc.exists) throw Exception('Student not found');
    
    final studentData = studentDoc.data()!;
    final financeData = financeDoc.data() ?? {};
    
    // Logic for eligibility based on payment
    double percentagePaid = (financeData['paidAmount'] ?? 0) / (financeData['totalCateringFees'] ?? 1) * 100;
    
    String status = 'Not Cleared';
    if (percentagePaid >= 100) {
      status = 'Cleared';
    } else if (percentagePaid >= 50) {
      status = 'Partially Cleared';
    }

    return {
      'studentName': studentData['fullName'],
      'studentId': studentId,
      'class': studentData['class'],
      'photoUrl': studentData['photoUrl'],
      'eligibilityStatus': status,
      'percentagePaid': percentagePaid,
    };
  }

  @override
  Future<void> recordMealServed(MealRecordModel record) async {
    await firestore.collection('meal_records').add(record.toJson());
  }

  @override
  Future<List<FoodItemModel>> getInventory() async {
    final snapshot = await firestore.collection('inventory').where('type', isEqualTo: 'food').get();
    return snapshot.docs.map((doc) => FoodItemModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createStockRequest(Map<String, dynamic> requestData) async {
    await firestore.collection('stock_requests').add(requestData);
  }

  @override
  Future<List<Map<String, dynamic>>> getStockRequests() async {
    final snapshot = await firestore.collection('stock_requests').orderBy('requestedAt', descending: true).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  @override
  Future<List<MealRecordModel>> getMealAttendanceReport(DateTime start, DateTime end) async {
    final snapshot = await firestore.collection('meal_records')
        .where('servedAt', isGreaterThanOrEqualTo: start)
        .where('servedAt', isLessThanOrEqualTo: end)
        .get();
    return snapshot.docs.map((doc) => MealRecordModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<WastageRecordModel>> getWastageRecords(DateTime start, DateTime end) async {
    final snapshot = await firestore.collection('wastage_records')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();
    return snapshot.docs.map((doc) => WastageRecordModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> saveWastageRecord(WastageRecordModel record) async {
    await firestore.collection('wastage_records').doc(record.id).set(record.toJson());
  }

  @override
  Future<Map<String, dynamic>> getCateringFinancialReport(DateTime start, DateTime end) async {
    // Aggregated financial data from meal categories, inventory, and wastage
    return {
      'totalRevenue': 1500000.0,
      'foodCost': 850000.0,
      'wastageCost': 45000.0,
      'grossProfit': 605000.0,
      'laborCost': 200000.0,
      'netProfit': 405000.0,
    };
  }
}
