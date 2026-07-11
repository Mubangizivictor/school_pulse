import 'package:equatable/equatable.dart';

class HealthVisit extends Equatable {
  final String id;
  final String studentId;
  final DateTime date;
  final String reason;
  final String treatment;
  final String medication;

  const HealthVisit({
    required this.id,
    required this.studentId,
    required this.date,
    required this.reason,
    required this.treatment,
    required this.medication,
  });

  @override
  List<Object?> get props => [id, studentId, date, reason, treatment, medication];
}
