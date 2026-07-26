import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_record.dart';
import '../repositories/finance_repository.dart';

class GetAllPaymentHistory {
  final FinanceRepository repository;

  GetAllPaymentHistory(this.repository);

  Future<Either<Failure, List<PaymentRecord>>> call() async {
    return await repository.getAllPaymentHistory();
  }
}
