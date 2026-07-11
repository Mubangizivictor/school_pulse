import 'package:equatable/equatable.dart';

class PaymentRecord extends Equatable {
  final String id;
  final String studentId;
  final double amount;
  final DateTime date;
  final String method;
  final String reference;

  const PaymentRecord({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.date,
    required this.method,
    required this.reference,
  });

  @override
  List<Object?> get props => [id, studentId, amount, date, method, reference];
}
