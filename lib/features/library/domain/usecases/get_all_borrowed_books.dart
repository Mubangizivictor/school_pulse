import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_borrowing.dart';
import '../repositories/library_repository.dart';

class GetAllBorrowedBooks {
  final LibraryRepository repository;

  GetAllBorrowedBooks(this.repository);

  Future<Either<Failure, List<LibraryBorrowing>>> call(String schoolId) async {
    try {
      final borrowings = await repository.watchBorrowingHistory(schoolId).first;
      return Right(borrowings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
