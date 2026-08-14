import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fee_category.dart';
import '../entities/fee_item.dart';
import '../entities/fee_structure.dart';
import '../entities/student_financial_account.dart';
import '../entities/payment_record.dart';
import '../entities/budget.dart';
import '../entities/expenditure.dart';

abstract class FinanceRepository {
  // Fee Configuration (Admin)
  Future<Either<Failure, List<FeeCategory>>> getFeeCategories(String schoolId);
  Future<Either<Failure, void>> saveFeeCategory(FeeCategory category);

  Future<Either<Failure, List<FeeStructure>>> getFeeStructures(String schoolId);
  Future<Either<Failure, void>> saveFeeStructure(FeeStructure structure);

  // Student Financials
  Future<Either<Failure, StudentFinancialAccount>> getStudentFinancialAccount(
    String studentId,
    String schoolId,
  );
  Future<Either<Failure, List<StudentFinancialAccount>>>
  getFinancialAccountsByClass(String schoolId, String classId);
  Future<Either<Failure, void>> updateStudentFinancialAccount(
    StudentFinancialAccount account,
  );

  // Payments & Collections
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory(
    String studentId,
    String schoolId,
  );
  Future<Either<Failure, List<PaymentRecord>>> getSchoolPayments(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, String>> recordPayment(PaymentRecord payment);
  Future<Either<Failure, void>> cancelPayment(String paymentId, String reason);

  // Legacy/Missing Methods for Compatibility
  Future<Either<Failure, List<PaymentRecord>>> getAllPaymentHistory();
  Future<Either<Failure, List<FeeItem>>> getFees(String studentId);
  Future<Either<Failure, List<FeeItem>>> getAllFees();

  // Budgeting
  Future<Either<Failure, List<Budget>>> getBudgets(
    String schoolId,
    String academicYear,
    String term,
  );
  Future<Either<Failure, void>> saveBudget(Budget budget);

  // Expenditure & Procurement Workflow
  Future<Either<Failure, List<ExpenditureRequest>>> getExpenditureRequests(
    String schoolId,
  );
  Future<Either<Failure, void>> createExpenditureRequest(
    ExpenditureRequest request,
  );
  Future<Either<Failure, void>> updateExpenditureStatus(
    String schoolId,
    String requestId,
    ExpenditureStatus status,
    String approverId,
    String approverName,
    String approverRole,
    String? comment,
  );

  // Reporting & KPIs
  Future<Either<Failure, Map<String, dynamic>>> getFinancialDashboardKPIs(
    String schoolId,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getCollectionReport(
    String schoolId,
    String academicYear,
    String term,
  );
}
