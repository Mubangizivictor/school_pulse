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
import '../datasources/finance_remote_data_source.dart';
import '../models/budget_model.dart';
import '../models/expenditure_model.dart';
import '../models/fee_category_model.dart';
import '../models/fee_structure_model.dart';
import '../models/payment_record_model.dart';
import '../models/student_financial_account_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

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
    try {
      final model = BudgetModel(
        id: budget.id,
        schoolId: budget.schoolId,
        name: budget.name,
        academicYear: budget.academicYear,
        term: budget.term,
        allocatedAmount: budget.allocatedAmount,
        spentAmount: budget.spentAmount,
        description: budget.description,
      );
      await remoteDataSource.saveBudget(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
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
    try {
      final model = ExpenditureRequestModel(
        id: request.id,
        schoolId: request.schoolId,
        requesterId: request.requesterId,
        requesterName: request.requesterName,
        description: request.description,
        amount: request.amount,
        budgetCategoryId: request.budgetCategoryId,
        supplierId: request.supplierId,
        supplierName: request.supplierName,
        status: request.status,
        attachmentUrls: request.attachmentUrls,
        createdAt: request.createdAt,
        approvalHistory: request.approvalHistory
            .map(
              (s) => ApprovalStepModel(
                id: s.id,
                approverId: s.approverId,
                approverName: s.approverName,
                approverRole: s.approverRole,
                status: s.status,
                comment: s.comment,
                updatedAt: s.updatedAt,
              ),
            )
            .toList(),
      );
      await remoteDataSource.createExpenditureRequest(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
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
    try {
      await remoteDataSource.updateExpenditureStatus(
        schoolId,
        requestId,
        status,
        approverId,
        approverName,
        approverRole,
        comment,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
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
