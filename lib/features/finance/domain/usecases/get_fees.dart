import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fee_item.dart';
import '../repositories/finance_repository.dart';

class GetFees {
  final FinanceRepository repository;

  GetFees(this.repository);

  Future<Either<Failure, List<FeeItem>>> call(String studentId) async {
    return await repository.getFees(studentId);
  }
}
