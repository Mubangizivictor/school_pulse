import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/fee_category.dart';
import '../../domain/entities/fee_item.dart';
import '../../domain/entities/fee_structure.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/student_financial_account.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_governance_remote_data_source.dart';
import '../datasources/finance_remote_data_source.dart';
import '../models/fee_category_model.dart';
import '../models/fee_structure_model.dart';
import '../models/payment_record_model.dart';
import '../models/student_financial_account_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  /// Callable-only path for expenditure requisitions/decisions and budget
  /// lines (audit area 2). Never null in production DI; kept optional so
  /// existing repository unit tests that only exercise read paths don't
  /// have to construct it.
  final FinanceGovernanceRemoteDataSource? governance;

  FinanceRepositoryImpl({required this.remoteDataSource, this.governance});

  FinanceGovernanceRemoteDataSource get _governance {
    final g = governance;
    if (g == null) {
      throw StateError(
        'FinanceGovernanceRemoteDataSource is required for finance writes',
      );
    }
    return g;
  }

  Failure _callableFailure(Object e) {
    if (e is StateError) {
      // Misconfiguration, not a user-facing failure — surface it loudly.
      throw e;
    }
    if (e is FirebaseFunctionsException) {
      final msg = e.message ?? 'The finance service rejected this request.';
      switch (e.code) {
        case 'permission-denied':
        case 'unauthenticated':
          return PermissionDeniedFailure(msg);
        case 'invalid-argument':
        case 'failed-precondition':
        case 'already-exists':
        case 'not-found':
          return ValidationFailure(msg);
        default:
          return ServerFailure(msg);
      }
    }
    return ServerFailure();
  }

  @override
  Future<Either<Failure, List<FeeCategory>>> getFeeCategories(
    String schoolId,
  ) async {
    try {
      final categories = await remoteDataSource.getFeeCategories(schoolId);
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveFeeCategory(FeeCategory category) async {
    try {
      final model = FeeCategoryModel(
        id: category.id,
        schoolId: category.schoolId,
        name: category.name,
        description: category.description,
        isMandatory: category.isMandatory,
        priority: category.priority,
      );
      await remoteDataSource.saveFeeCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FeeStructure>>> getFeeStructures(
    String schoolId,
  ) async {
    try {
      final structures = await remoteDataSource.getFeeStructures(schoolId);
      return Right(structures);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveFeeStructure(FeeStructure structure) async {
    try {
      final model = FeeStructureModel(
        id: structure.id,
        schoolId: structure.schoolId,
        name: structure.name,
        academicYear: structure.academicYear,
        term: structure.term,
        items: structure.items
            .map(
              (item) => FeeStructureItemModel(
                categoryId: item.categoryId,
                categoryName: item.categoryName,
                amount: item.amount,
              ),
            )
            .toList(),
        classId: structure.classId,
        programId: structure.programId,
        studentCategory: structure.studentCategory,
      );
      await remoteDataSource.saveFeeStructure(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, StudentFinancialAccount>> getStudentFinancialAccount(
    String studentId,
    String schoolId,
  ) async {
    try {
      final account = await remoteDataSource.getStudentFinancialAccount(
        studentId,
        schoolId,
      );
      return Right(account);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StudentFinancialAccount>>>
  getFinancialAccountsByClass(String schoolId, String classId) async {
    try {
      final accounts = await remoteDataSource.getFinancialAccountsByClass(
        schoolId,
        classId,
      );
      return Right(accounts);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentFinancialAccount(
    StudentFinancialAccount account,
  ) async {
    try {
      final model = StudentFinancialAccountModel(
        studentId: account.studentId,
        schoolId: account.schoolId,
        academicYear: account.academicYear,
        term: account.term,
        feeStructureId: account.feeStructureId,
        scholarshipAmount: account.scholarshipAmount,
        discountAmount: account.discountAmount,
        totalBilled: account.totalBilled,
        totalPaid: account.totalPaid,
        paymentHistory: account.paymentHistory
            .map(
              (p) => PaymentRecordModel(
                id: p.id,
                schoolId: p.schoolId,
                studentId: p.studentId,
                academicYear: p.academicYear,
                term: p.term,
                amount: p.amount,
                date: p.date,
                method: p.method,
                reference: p.reference,
                receiptNumber: p.receiptNumber,
                feeBreakdown: p.feeBreakdown,
                recordedBy: p.recordedBy,
                notes: p.notes,
              ),
            )
            .toList(),
        applicableRestrictions: account.applicableRestrictions,
      );
      await remoteDataSource.updateStudentFinancialAccount(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory(
    String studentId,
    String schoolId,
  ) async {
    try {
      final history = await remoteDataSource.getPaymentHistory(
        studentId,
        schoolId,
      );
      return Right(history);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getSchoolPayments(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final payments = await remoteDataSource.getSchoolPayments(
        schoolId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(payments);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> recordPayment(PaymentRecord payment) async {
    try {
      final model = PaymentRecordModel(
        id: payment.id,
        schoolId: payment.schoolId,
        studentId: payment.studentId,
        academicYear: payment.academicYear,
        term: payment.term,
        amount: payment.amount,
        date: payment.date,
        method: payment.method,
        reference: payment.reference,
        receiptNumber: payment.receiptNumber,
        feeBreakdown: payment.feeBreakdown,
        recordedBy: payment.recordedBy,
        notes: payment.notes,
      );
      final id = await remoteDataSource.recordPayment(model);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelPayment(
    String paymentId,
    String reason,
  ) async {
    try {
      await remoteDataSource.cancelPayment(paymentId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getAllPaymentHistory() async {
    try {
      final history = await remoteDataSource.getAllPaymentHistory();
      return Right(history);
    } catch (e, st) {
      debugPrint('FinanceRepositoryImpl.getAllPaymentHistory error: $e\n$st');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FeeItem>>> getFees(String studentId) async {
    try {
      final fees = await remoteDataSource.getFees(studentId);
      return Right(fees);
    } catch (e, st) {
      debugPrint('FinanceRepositoryImpl.getFees error: $e\n$st');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FeeItem>>> getAllFees() async {
    try {
      final fees = await remoteDataSource.getAllFees();
      return Right(fees);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Budget>>> getBudgets(
    String schoolId,
    String academicYear,
    String term,
  ) async {
    try {
      final budgets = await remoteDataSource.getBudgets(
        schoolId,
        academicYear,
        term,
      );
      return Right(budgets);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveBudget(Budget budget) async {
    // Callable-only (audit area 2): saveSchoolBudget enforces validation,
    // tenant/role checks, keeps `spentAmount` server-authoritative, and
    // writes an audit event. Direct Firestore writes are denied by rules.
    try {
      await _governance.saveSchoolBudget(budget);
      return const Right(null);
    } catch (e) {
      return Left(_callableFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ExpenditureRequest>>> getExpenditureRequests(
    String schoolId,
  ) async {
    try {
      final requests = await remoteDataSource.getExpenditureRequests(schoolId);
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createExpenditureRequest(
    ExpenditureRequest request,
  ) async {
    // Callable-only (audit area 2): submitExpenditure validates the amount
    // (positive whole UGX), enforces role/tenant, is idempotent, and audits.
    try {
      await _governance.submitExpenditure(request);
      return const Right(null);
    } catch (e) {
      return Left(_callableFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpenditureStatus(
    String schoolId,
    String requestId,
    ExpenditureStatus status,
    String approverId,
    String approverName,
    String approverRole,
    String? comment,
  ) async {
    // Callable-only (audit area 2): decideExpenditure enforces the
    // requester-can't-self-approve rule, records the approval step + audit
    // event in one transaction, and is idempotent on retry. The approver
    // identity is taken from the authenticated call, not these params.
    try {
      await _governance.decideExpenditure(
        schoolId: schoolId,
        expenditureId: requestId,
        decision: FinanceGovernanceRemoteDataSource.decisionFor(status),
        comment: comment,
      );
      return const Right(null);
    } catch (e) {
      return Left(_callableFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFinancialDashboardKPIs(
    String schoolId,
  ) async {
    try {
      final kpis = await remoteDataSource.getFinancialDashboardKPIs(schoolId);
      return Right(kpis);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCollectionReport(
    String schoolId,
    String academicYear,
    String term,
  ) async {
    // Implementation would go here
    return const Right([]);
  }
}
