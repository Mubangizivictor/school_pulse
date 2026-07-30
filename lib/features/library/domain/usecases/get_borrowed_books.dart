import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_borrowing.dart';
import '../repositories/library_repository.dart';

class GetBorrowedBooks {
  final LibraryRepository repository;

  GetBorrowedBooks(this.repository);

  Future<Either<Failure, List<LibraryBorrowing>>> call({
    required String schoolId,
    required String borrowerId,
  }) async {
    try {
      final borrowings = await repository
          .watchBorrowingHistory(schoolId, borrowerId: borrowerId)
          .first;
      return Right(borrowings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
