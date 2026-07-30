import 'package:equatable/equatable.dart';

class FeeStructure extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String academicYear;
  final String term;
  final List<FeeStructureItem> items;
  final String? classId; // Optional: specific to a class
  final String? programId; // Optional: specific to a program
  final String studentCategory; // Day, Boarding, International, etc.

  const FeeStructure({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.academicYear,
    required this.term,
    required this.items,
    this.classId,
    this.programId,
    required this.studentCategory,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.amount);

  @override
  List<Object?> get props => [
        id,
        schoolId,
        name,
        academicYear,
        term,
        items,
        classId,
        programId,
        studentCategory,
      ];
}

class FeeStructureItem extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;

  const FeeStructureItem({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, amount];
}
