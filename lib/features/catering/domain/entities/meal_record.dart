import 'package:equatable/equatable.dart';

class MealRecord extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String mealCategoryId;
  final String mealCategoryName;
  final DateTime servedAt;
  final String servedBy;
  final String schoolId;
  final String academicYear;
  final String term;

  const MealRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.mealCategoryId,
    required this.mealCategoryName,
    required this.servedAt,
    required this.servedBy,
    required this.schoolId,
    required this.academicYear,
    required this.term,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    classId,
    mealCategoryId,
    mealCategoryName,
    servedAt,
    servedBy,
    schoolId,
    academicYear,
    term,
  ];
}
