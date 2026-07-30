import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_record.dart';
import '../repositories/finance_repository.dart';

class GetPaymentHistory {
  final FinanceRepository repository;

  GetPaymentHistory(this.repository);

  Future<Either<Failure, List<PaymentRecord>>> call(String studentId, String schoolId) async {
    return await repository.getPaymentHistory(studentId, schoolId);
  }
}
