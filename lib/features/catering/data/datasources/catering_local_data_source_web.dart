import '../../domain/entities/meal_record.dart';
import '../models/meal_record_model.dart';
import 'catering_local_data_source.dart';
import 'catering_remote_data_source.dart';

CateringLocalDataSource create({dynamic isar, dynamic remote}) =>
    CateringLocalDataSourceWeb(remote as CateringRemoteDataSource);

/// No local database and no offline dining-hall scanning use case on web -
/// writes go straight to Firestore via the existing remote datasource.
/// Nothing is ever pending, so getUnsyncedRecords/markAsSynced are
/// empty/no-op.
class CateringLocalDataSourceWeb implements CateringLocalDataSource {
  final CateringRemoteDataSource remote;

  CateringLocalDataSourceWeb(this.remote);

  @override
  Future<void> cacheMealRecord(MealRecord record) => remote.recordMealServed(
    MealRecordModel(
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
    ),
  );

  @override
  Future<List<MealRecord>> getUnsyncedRecords() async => [];

  @override
  Future<void> markAsSynced(List<String> ids) async {}
}
