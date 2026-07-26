import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/library_book.dart';
import '../repositories/library_repository.dart';

class IssueBook {
  final LibraryRepository repository;

  IssueBook(this.repository);

  Future<Either<Failure, void>> call(LibraryBook book) async {
    return await repository.issueBook(book);
  }
}
