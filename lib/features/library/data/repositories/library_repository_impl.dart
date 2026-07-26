import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_data_source.dart';
import '../models/library_book_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LibraryBook>>> getBorrowedBooks(String studentId) async {
    try {
      final remoteBooks = await remoteDataSource.getBorrowedBooks(studentId);
      return Right(remoteBooks);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LibraryBook>>> getAllBorrowedBooks() async {
    try {
      final remoteBooks = await remoteDataSource.getAllBorrowedBooks();
      return Right(remoteBooks);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> issueBook(LibraryBook book) async {
    try {
      final model = LibraryBookModel(
        id: book.id,
        studentId: book.studentId,
        title: book.title,
        author: book.author,
        dueDate: book.dueDate,
        isReturned: book.isReturned,
      );
      await remoteDataSource.issueBook(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> returnBook(String bookId) async {
    try {
      await remoteDataSource.returnBook(bookId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
