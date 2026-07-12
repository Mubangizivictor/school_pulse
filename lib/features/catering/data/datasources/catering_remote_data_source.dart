import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/catering_state.dart';

abstract class CateringRemoteDataSource {
  Future<List<MealPlan>> getTodayMeals();
  Future<Map<String, dynamic>> getCateringStats();
}

class CateringRemoteDataSourceImpl implements CateringRemoteDataSource {
  final FirebaseFirestore firestore;

  CateringRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<MealPlan>> getTodayMeals() async {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    
    final doc = await firestore.collection('meal_plans').doc(dayName.toLowerCase()).get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>? ?? [];
    
    return meals.map((m) => MealPlan(
      mealType: m['mealType'] ?? '',
      menu: m['menu'] ?? '',
      time: m['time'] ?? '',
    )).toList();
  }

  @override
  Future<Map<String, dynamic>> getCateringStats() async {
    final doc = await firestore.collection('stats').doc('catering_summary').get();
    return doc.data() ?? {};
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
