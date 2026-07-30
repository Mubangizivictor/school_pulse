import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/library_repository.dart';
import '../entities/library_resource.dart';

class ReturnBook {
  final LibraryRepository repository;

  ReturnBook(this.repository);

  Future<Either<Failure, void>> call({
    required String schoolId,
    required String borrowingId,
    ResourceCondition? condition,
    double? fineAmount,
  }) async {
    try {
      await repository.returnResource(
        schoolId,
        borrowingId,
        condition: condition,
        fineAmount: fineAmount,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
