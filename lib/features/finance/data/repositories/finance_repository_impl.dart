import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/fee_item.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_data_source.dart';
import '../models/payment_record_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FeeItem>>> getFees(String studentId) async {
    try {
      final remoteFees = await remoteDataSource.getFees(studentId);
      return Right(remoteFees);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory(String studentId) async {
    try {
      final remoteHistory = await remoteDataSource.getPaymentHistory(studentId);
      return Right(remoteHistory);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> processPayment(PaymentRecord payment) async {
    try {
      final model = PaymentRecordModel(
        id: payment.id,
        studentId: payment.studentId,
        amount: payment.amount,
        date: payment.date,
        method: payment.method,
        reference: payment.reference,
      );
      await remoteDataSource.processPayment(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
