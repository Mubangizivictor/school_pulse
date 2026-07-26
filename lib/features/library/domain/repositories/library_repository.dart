import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_book.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<LibraryBook>>> getBorrowedBooks(String studentId);
  Future<Either<Failure, List<LibraryBook>>> getAllBorrowedBooks();
  Future<Either<Failure, void>> issueBook(LibraryBook book);
  Future<Either<Failure, void>> returnBook(String bookId);
}
