import '../../domain/entities/meal_record.dart';

class MealRecordModel extends MealRecord {
  const MealRecordModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.classId,
    required super.mealCategoryId,
    required super.mealCategoryName,
    required super.servedAt,
    required super.servedBy,
    required super.schoolId,
    required super.academicYear,
    required super.term,
  });

  factory MealRecordModel.fromJson(Map<String, dynamic> json) {
    return MealRecordModel(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      classId: json['classId'] ?? '',
      mealCategoryId: json['mealCategoryId'] ?? '',
      mealCategoryName: json['mealCategoryName'] ?? '',
      servedAt: DateTime.parse(json['servedAt']),
      servedBy: json['servedBy'] ?? '',
      schoolId: json['schoolId'] ?? '',
      academicYear: json['academicYear'] ?? '',
      term: json['term'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'mealCategoryId': mealCategoryId,
      'mealCategoryName': mealCategoryName,
      'servedAt': servedAt.toIso8601String(),
      'servedBy': servedBy,
      'schoolId': schoolId,
      'academicYear': academicYear,
      'term': term,
    };
  }
}
