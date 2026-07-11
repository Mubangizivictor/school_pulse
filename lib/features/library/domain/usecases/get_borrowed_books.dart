import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_book.dart';
import '../repositories/library_repository.dart';

class GetBorrowedBooks {
  final LibraryRepository repository;

  GetBorrowedBooks(this.repository);

  Future<Either<Failure, List<LibraryBook>>> call(String studentId) async {
    return await repository.getBorrowedBooks(studentId);
  }
}
