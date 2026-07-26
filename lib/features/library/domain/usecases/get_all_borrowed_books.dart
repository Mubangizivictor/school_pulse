import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_book.dart';
import '../repositories/library_repository.dart';

class GetAllBorrowedBooks {
  final LibraryRepository repository;

  GetAllBorrowedBooks(this.repository);

  Future<Either<Failure, List<LibraryBook>>> call() async {
    return await repository.getAllBorrowedBooks();
  }
}
