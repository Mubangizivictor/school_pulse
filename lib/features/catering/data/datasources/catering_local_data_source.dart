import 'package:isar/isar.dart';
import '../models/meal_record_isar.dart';
import '../models/meal_record_model.dart';

abstract class CateringLocalDataSource {
  Future<void> cacheMealRecord(MealRecordModel record);
  Future<List<MealRecordIsar>> getUnsyncedRecords();
  Future<void> markAsSynced(List<int> ids);
}

class CateringLocalDataSourceImpl implements CateringLocalDataSource {
  final Isar isar;

  CateringLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheMealRecord(MealRecordModel record) async {
    final isarRecord = MealRecordIsar()
      ..studentId = record.studentId
      ..studentName = record.studentName
      ..classId = record.classId
      ..mealCategoryId = record.mealCategoryId
      ..mealCategoryName = record.mealCategoryName
      ..servedAt = record.servedAt
      ..servedBy = record.servedBy
      ..schoolId = record.schoolId
      ..academicYear = record.academicYear
      ..term = record.term
      ..isSynced = false;

    await isar.writeTxn(() async {
      await isar.mealRecordIsars.put(isarRecord);
    });
  }

  @override
  Future<List<MealRecordIsar>> getUnsyncedRecords() async {
    return await isar.mealRecordIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markAsSynced(List<int> ids) async {
    await isar.writeTxn(() async {
      for (final id in ids) {
        final record = await isar.mealRecordIsars.get(id);
        if (record != null) {
          record.isSynced = true;
          await isar.mealRecordIsars.put(record);
        }
      }
    });
  }
}
