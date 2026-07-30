import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_borrowing.dart';
import '../repositories/library_repository.dart';

class IssueBook {
  final LibraryRepository repository;

  IssueBook(this.repository);

  Future<Either<Failure, void>> call(LibraryBorrowing borrowing) async {
    try {
      await repository.issueResource(borrowing);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
