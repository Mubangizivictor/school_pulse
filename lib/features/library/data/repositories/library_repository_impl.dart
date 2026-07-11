import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_data_source.dart';

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
}
