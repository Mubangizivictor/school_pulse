import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/student_financial_account.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/fee_category.dart';
import '../../domain/entities/fee_item.dart';
import '../../domain/entities/fee_structure.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<FeeItem> fees;
  final List<PaymentRecord> paymentHistory;

  const FinanceLoaded({required this.fees, required this.paymentHistory});

  @override
  List<Object?> get props => [fees, paymentHistory];
}

class FinanceDashboardLoaded extends FinanceState {
  final Map<String, dynamic> kpis;
  final List<PaymentRecord> recentTransactions;
  final List<ExpenditureRequest> pendingApprovals;

  const FinanceDashboardLoaded({
    required this.kpis,
    required this.recentTransactions,
    required this.pendingApprovals,
  });

  @override
  List<Object?> get props => [kpis, recentTransactions, pendingApprovals];
}

class StudentFinancialProfileLoaded extends FinanceState {
  final StudentFinancialAccount account;
  final List<PaymentRecord> paymentHistory;

  const StudentFinancialProfileLoaded({
    required this.account,
    required this.paymentHistory,
  });

  @override
  List<Object?> get props => [account, paymentHistory];
}

class ExpendituresLoaded extends FinanceState {
  final List<ExpenditureRequest> requests;
  const ExpendituresLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class BudgetsLoaded extends FinanceState {
  final List<Budget> budgets;
  const BudgetsLoaded(this.budgets);

  @override
  List<Object?> get props => [budgets];
}

class FeeConfigurationLoaded extends FinanceState {
  final List<FeeCategory> categories;
  final List<FeeStructure> structures;

  const FeeConfigurationLoaded({
    required this.categories,
    required this.structures,
  });

  @override
  List<Object?> get props => [categories, structures];
}

class FinanceActionSuccess extends FinanceState {
  final String message;
  const FinanceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FinanceError extends FinanceState {
  final String message;
  const FinanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReceiptVerified extends FinanceState {
  final PaymentRecord payment;
  const ReceiptVerified(this.payment);

  @override
  List<Object?> get props => [payment];
}

class EligibilityChecked extends FinanceState {
  final bool isEligible;
  final String serviceType;
  final String? reason;

  const EligibilityChecked({
    required this.isEligible,
    required this.serviceType,
    this.reason,
  });

  @override
  List<Object?> get props => [isEligible, serviceType, reason];
}
