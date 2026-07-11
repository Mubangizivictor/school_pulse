import 'package:flutter_bloc/flutter_bloc.dart';
import 'catering_event.dart';
import 'catering_state.dart';

class CateringBloc extends Bloc<CateringEvent, CateringState> {
  CateringBloc() : super(CateringInitial()) {
    on<CateringDashboardRequested>((event, emit) async {
      emit(CateringLoading());
      // Mocking delay and data
      await Future.delayed(const Duration(seconds: 1));
      emit(const CateringLoaded(
        todayMeals: [
          MealPlan(mealType: 'Breakfast', menu: 'Porridge & Bananas', time: '7:30 AM'),
          MealPlan(mealType: 'Lunch', menu: 'Posho, Beans & Cabbage', time: '1:00 PM'),
          MealPlan(mealType: 'Dinner', menu: 'Rice & Beef Stew', time: '6:30 PM'),
        ],
        totalStudents: 450,
        specialDiets: 12,
        stockLevel: 0.75,
      ));
    });
  }
}
