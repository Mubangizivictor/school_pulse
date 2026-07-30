import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_financial_account.dart';
import '../repositories/finance_repository.dart';

class InitializeStudentFinancials {
  final FinanceRepository repository;

  InitializeStudentFinancials(this.repository);

  Future<Either<Failure, void>> call({
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
