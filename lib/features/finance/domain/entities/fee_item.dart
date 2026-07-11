import 'package:equatable/equatable.dart';

enum FeeStatus { paid, due, overdue }

class FeeItem extends Equatable {
  final String id;
  final String studentId;
  final String category;
  final double amount;
  final FeeStatus status;
  final DateTime dueDate;

  const FeeItem({
    required this.id,
    required this.studentId,
    required this.category,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [id, studentId, category, amount, status, dueDate];
}
