import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/fee_category.dart';
import '../../domain/entities/fee_structure.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

class FetchFees extends FinanceEvent {
  final String studentId;
  const FetchFees(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadFinanceDashboard extends FinanceEvent {
  final String schoolId;
  const LoadFinanceDashboard(this.schoolId);
}

class LoadStudentFinancialProfile extends FinanceEvent {
  final String studentId;
  final String schoolId;
  const LoadStudentFinancialProfile({
    required this.studentId,
    required this.schoolId,
  });
}

class RecordNewPayment extends FinanceEvent {
  final PaymentRecord payment;
  const RecordNewPayment(this.payment);
}

class PrintReceipt extends FinanceEvent {
  final PaymentRecord payment;
  final String studentName;
  final String className;

  const PrintReceipt({
    required this.payment,
    required this.studentName,
    required this.className,
  });

  @override
  List<Object?> get props => [payment, studentName, className];
}

class LoadExpenditureRequests extends FinanceEvent {
  final String schoolId;
  const LoadExpenditureRequests(this.schoolId);
}

class SubmitExpenditureRequest extends FinanceEvent {
  final ExpenditureRequest request;
  const SubmitExpenditureRequest(this.request);
}

class UpdateExpenditureApproval extends FinanceEvent {
  final String schoolId;
  final String requestId;
  final ExpenditureStatus status;
  final String approverId;
  final String approverName;
  final String approverRole;
  final String? comment;

  const UpdateExpenditureApproval({
    required this.schoolId,
    required this.requestId,
    required this.status,
    required this.approverId,
    required this.approverName,
    required this.approverRole,
    this.comment,
  });
}

class LoadBudgets extends FinanceEvent {
  final String schoolId;
  final String academicYear;
  final String term;
  const LoadBudgets({
    required this.schoolId,
    required this.academicYear,
    required this.term,
  });
}

class SaveSchoolBudget extends FinanceEvent {
  final Budget budget;
  const SaveSchoolBudget(this.budget);
}

class LoadFeeCategories extends FinanceEvent {
  final String schoolId;
  const LoadFeeCategories(this.schoolId);
}

class SaveSchoolFeeCategory extends FinanceEvent {
  final FeeCategory category;
  const SaveSchoolFeeCategory(this.category);
}

class LoadFeeStructures extends FinanceEvent {
  final String schoolId;
  const LoadFeeStructures(this.schoolId);
}

class SaveSchoolFeeStructure extends FinanceEvent {
  final FeeStructure structure;
  const SaveSchoolFeeStructure(this.structure);
}

class VerifyFinanceReceipt extends FinanceEvent {
  final String qrData;
  const VerifyFinanceReceipt(this.qrData);
}

class CheckStudentEligibility extends FinanceEvent {
  final String studentId;
  final String schoolId;
  final String serviceType;

  const CheckStudentEligibility({
    required this.studentId,
    required this.schoolId,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [studentId, schoolId, serviceType];
}
