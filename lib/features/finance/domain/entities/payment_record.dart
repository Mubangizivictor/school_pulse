import 'package:equatable/equatable.dart';

class PaymentRecord extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String academicYear;
  final String term;
  final double amount;
  final DateTime date;
  final String method; // Cash, Bank Deposit, Bank Transfer, Cheque, Mobile Money, Card, etc.
  final String reference;
  final String receiptNumber;
  final Map<String, double> feeBreakdown; // Map categoryId to amount
  final String recordedBy;
  final String? notes;

  const PaymentRecord({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.academicYear,
    required this.term,
    required this.amount,
    required this.date,
    required this.method,
    required this.reference,
    required this.receiptNumber,
    required this.feeBreakdown,
    required this.recordedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        studentId,
        academicYear,
        term,
        amount,
        date,
        method,
        reference,
        receiptNumber,
        feeBreakdown,
        recordedBy,
        notes,
      ];
}
