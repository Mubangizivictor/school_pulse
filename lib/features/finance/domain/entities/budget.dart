import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String schoolId;
  final String name; // Academics, Transport, Meals, etc.
  final String academicYear;
  final String term;
  final double allocatedAmount;
  final double spentAmount;
  final String? description;

  const Budget({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.academicYear,
    required this.term,
    required this.allocatedAmount,
    this.spentAmount = 0,
    this.description,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get utilizationPercentage => allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        schoolId,
        name,
        academicYear,
        term,
        allocatedAmount,
        spentAmount,
        description,
      ];
}
