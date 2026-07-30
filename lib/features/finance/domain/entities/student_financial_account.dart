import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';

class StudentFinancialAccount extends Equatable {
  final String studentId;
  final String schoolId;
  final String academicYear;
  final String term;
  final String feeStructureId;
  final double scholarshipAmount;
  final double discountAmount;
  final double totalBilled;
  final double totalPaid;
  final List<PaymentRecord> paymentHistory;
  final List<String> applicableRestrictions;

  const StudentFinancialAccount({
    required this.studentId,
    required this.schoolId,
    required this.academicYear,
    required this.term,
    required this.feeStructureId,
    this.scholarshipAmount = 0,
    this.discountAmount = 0,
    required this.totalBilled,
    required this.totalPaid,
    required this.paymentHistory,
    this.applicableRestrictions = const [],
  });

  double get balance => totalBilled - totalPaid - scholarshipAmount - discountAmount;
  bool get isFullyPaid => balance <= 0;

  @override
  List<Object?> get props => [
        studentId,
        schoolId,
        academicYear,
        term,
        feeStructureId,
        scholarshipAmount,
        discountAmount,
        totalBilled,
        totalPaid,
        paymentHistory,
        applicableRestrictions,
      ];
}
