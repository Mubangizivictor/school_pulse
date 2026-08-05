import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_financial_account.dart';
import '../entities/payment_record.dart';
import '../repositories/finance_repository.dart';

class FinanceService {
  final FinanceRepository repository;

  FinanceService(this.repository);

  /// Checks if a student is eligible for a specific service based on financial status.
  Future<Either<Failure, bool>> checkEligibility({
    required String studentId,
    required String schoolId,
    required String serviceType, // e.g., "EXAM", "MEAL", "TRIP"
  }) async {
    final accountResult = await repository.getStudentFinancialAccount(
      studentId,
      schoolId,
    );

    return accountResult.fold((failure) => Left(failure), (account) {
      // Eligibility logic can be customized per school
      // For now, simple logic:
      // EXAM: Balance must be below 10% of total billed
      // MEAL: Balance must be zero or negative (overpaid)

      if (serviceType == 'EXAM') {
        final maxAllowedBalance = account.totalBilled * 0.1;
        return Right(account.balance <= maxAllowedBalance);
      }

      if (serviceType == 'MEAL') {
        return Right(account.isFullyPaid);
      }

      // Default: requires full payment
      return Right(account.isFullyPaid);
    });
  }

  /// Verifies a receipt by its ID and school ID.
  Future<Either<Failure, PaymentRecord>> verifyReceipt({
    required String paymentId,
    required String schoolId,
  }) async {
    final paymentsResult = await repository.getSchoolPayments(schoolId);

    return paymentsResult.fold((failure) => Left(failure), (payments) {
      try {
        final payment = payments.firstWhere((p) => p.id == paymentId);
        return Right(payment);
      } catch (e) {
        return Left(ServerFailure('Receipt not found.'));
      }
    });
  }

  /// Initializes a new financial account for a student upon enrollment.
  /// This should be called by the Enrollment flow.
  Future<Either<Failure, void>> initializeStudentAccount({
    required String studentId,
    required String schoolId,
    required String academicYear,
    required String term,
    required String feeStructureId,
    required double totalBilled,
  }) async {
    final account = StudentFinancialAccount(
      studentId: studentId,
      schoolId: schoolId,
      academicYear: academicYear,
      term: term,
      feeStructureId: feeStructureId,
      totalBilled: totalBilled,
      totalPaid: 0,
      paymentHistory: const [],
      applicableRestrictions: const [],
    );

    return await repository.updateStudentFinancialAccount(account);
  }
}
