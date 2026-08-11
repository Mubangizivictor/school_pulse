import 'package:isar/isar.dart';
import '../../domain/entities/meal_record.dart';
import '../models/meal_record_isar.dart';
import 'catering_local_data_source.dart';

CateringLocalDataSource create({dynamic isar, dynamic remote}) =>
    CateringLocalDataSourceImpl(isar: isar as Isar);

class CateringLocalDataSourceImpl implements CateringLocalDataSource {
  final Isar isar;

  CateringLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheMealRecord(MealRecord record) async {
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
  Future<List<MealRecord>> getUnsyncedRecords() async {
    final found = await isar.mealRecordIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return found
        .map(
          (r) => MealRecord(
            id: r.id.toString(),
            studentId: r.studentId,
            studentName: r.studentName,
            classId: r.classId,
            mealCategoryId: r.mealCategoryId,
            mealCategoryName: r.mealCategoryName,
            servedAt: r.servedAt,
            servedBy: r.servedBy,
            schoolId: r.schoolId,
            academicYear: r.academicYear,
            term: r.term,
          ),
        )
        .toList();
  }

  @override
  Future<void> markAsSynced(List<String> ids) async {
    await isar.writeTxn(() async {
      for (final id in ids) {
        final isarId = int.tryParse(id);
        if (isarId == null) continue;
        final record = await isar.mealRecordIsars.get(isarId);
        if (record != null) {
          record.isSynced = true;
          await isar.mealRecordIsars.put(record);
        }
      }
    });
  }
}
