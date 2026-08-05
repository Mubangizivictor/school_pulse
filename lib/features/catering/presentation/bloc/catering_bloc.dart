import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catering_repository.dart';
import 'catering_event.dart';
import 'catering_state.dart';

class CateringBloc extends Bloc<CateringEvent, CateringState> {
  final CateringRepository repository;

  CateringBloc({required this.repository}) : super(CateringInitial()) {
    on<LoadCateringDashboard>(_onLoadDashboard);
    on<LoadMealCategories>(_onLoadMealCategories);
    on<SaveMealCategoryEvent>(_onSaveMealCategory);
    on<LoadWeeklyMenu>(_onLoadWeeklyMenu);
    on<SaveMenuItemEvent>(_onSaveMenuItem);
    on<VerifyStudentMeal>(_onVerifyStudentMeal);
    on<RecordMealServedEvent>(_onRecordMealServed);
    on<LoadInventoryEvent>(_onLoadInventory);
    on<CreateStockRequestEvent>(_onCreateStockRequest);
    on<LoadStockRequests>(_onLoadStockRequests);
    on<LoadMealAttendanceReport>(_onLoadMealAttendanceReport);
    on<LoadWastageRecords>(_onLoadWastageRecords);
    on<SaveWastageRecordEvent>(_onSaveWastageRecord);
    on<LoadFinancialReport>(_onLoadFinancialReport);
  }

  Future<void> _onLoadDashboard(
    LoadCateringDashboard event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getCateringDashboardData();
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (data) => emit(CateringDashboardLoaded(data)),
    );
  }

  Future<void> _onLoadMealCategories(
    LoadMealCategories event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getMealCategories();
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (categories) => emit(MealCategoriesLoaded(categories)),
    );
  }

  Future<void> _onSaveMealCategory(
    SaveMealCategoryEvent event,
    Emitter<CateringState> emit,
  ) async {
    final result = await repository.saveMealCategory(event.category);
    result.fold((failure) => emit(CateringError(failure.message)), (_) {
      emit(const CateringSuccess('Meal category saved successfully'));
      add(LoadMealCategories());
    });
  }

  Future<void> _onLoadWeeklyMenu(
    LoadWeeklyMenu event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getWeeklyMenu(event.date);
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (menuItems) => emit(WeeklyMenuLoaded(menuItems)),
    );
  }

  Future<void> _onSaveMenuItem(
    SaveMenuItemEvent event,
    Emitter<CateringState> emit,
  ) async {
    final result = await repository.saveMenuItem(event.menuItem);
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (_) => emit(const CateringSuccess('Menu item saved successfully')),
    );
  }

  Future<void> _onVerifyStudentMeal(
    VerifyStudentMeal event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.verifyStudentMealEligibility(
      event.studentId,
    );
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (data) => emit(MealEligibilityVerified(data)),
    );
  }

  Future<void> _onRecordMealServed(
    RecordMealServedEvent event,
    Emitter<CateringState> emit,
  ) async {
    final result = await repository.recordMealServed(event.record);
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (_) => emit(const CateringSuccess('Meal served recorded')),
    );
  }

  Future<void> _onLoadInventory(
    LoadInventoryEvent event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getInventory();
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (items) => emit(InventoryLoaded(items)),
    );
  }

  Future<void> _onCreateStockRequest(
    CreateStockRequestEvent event,
    Emitter<CateringState> emit,
  ) async {
    final result = await repository.createStockRequest(event.request);
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (_) => emit(const CateringSuccess('Stock request created')),
    );
  }

  Future<void> _onLoadStockRequests(
    LoadStockRequests event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getStockRequests();
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (requests) => emit(StockRequestsLoaded(requests)),
    );
  }

  Future<void> _onLoadMealAttendanceReport(
    LoadMealAttendanceReport event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getMealAttendanceReport(
      event.start,
      event.end,
    );
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (records) => emit(MealAttendanceReportLoaded(records)),
    );
  }

  Future<void> _onLoadWastageRecords(
    LoadWastageRecords event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getWastageRecords(event.start, event.end);
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (records) => emit(WastageRecordsLoaded(records)),
    );
  }

  Future<void> _onSaveWastageRecord(
    SaveWastageRecordEvent event,
    Emitter<CateringState> emit,
  ) async {
    final result = await repository.saveWastageRecord(event.record);
    result.fold((failure) => emit(CateringError(failure.message)), (_) {
      emit(const CateringSuccess('Wastage record saved successfully'));
      add(
        LoadWastageRecords(
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        ),
      );
    });
  }

  Future<void> _onLoadFinancialReport(
    LoadFinancialReport event,
    Emitter<CateringState> emit,
  ) async {
    emit(CateringLoading());
    final result = await repository.getCateringFinancialReport(
      event.start,
      event.end,
    );
    result.fold(
      (failure) => emit(CateringError(failure.message)),
      (report) => emit(FinancialReportLoaded(report)),
    );
  }
}
