import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_record.dart';
import '../repositories/finance_repository.dart';

class ProcessPayment {
  final FinanceRepository repository;

  ProcessPayment(this.repository);

  Future<Either<Failure, String>> call(PaymentRecord payment) async {
    return await repository.recordPayment(payment);
  }
}
