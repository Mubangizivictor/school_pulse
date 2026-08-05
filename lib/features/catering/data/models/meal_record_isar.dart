import 'package:isar/isar.dart';

part 'meal_record_isar.g.dart';

@collection
class MealRecordIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late String studentId;

  late String studentName;
  late String classId;
  late String mealCategoryId;
  late String mealCategoryName;

  @Index()
  late DateTime servedAt;

  late String servedBy;
  late String schoolId;
  late String academicYear;
  late String term;

  @Index()
  bool isSynced = false;
}
