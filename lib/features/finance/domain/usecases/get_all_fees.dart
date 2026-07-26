import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fee_item.dart';
import '../repositories/finance_repository.dart';

class GetAllFees {
  final FinanceRepository repository;

  GetAllFees(this.repository);

  Future<Either<Failure, List<FeeItem>>> call() async {
    return await repository.getAllFees();
  }
}
