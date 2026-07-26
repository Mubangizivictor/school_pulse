import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/library_repository.dart';

class ReturnBook {
  final LibraryRepository repository;

  ReturnBook(this.repository);

  Future<Either<Failure, void>> call(String bookId) async {
    return await repository.returnBook(bookId);
  }
}
