import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fee_item.dart';
import '../entities/payment_record.dart';

abstract class FinanceRepository {
  Future<Either<Failure, List<FeeItem>>> getFees(String studentId);
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory(String studentId);
  Future<Either<Failure, void>> processPayment(PaymentRecord payment);
}
