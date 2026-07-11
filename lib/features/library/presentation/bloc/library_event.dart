import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

class FetchBorrowedBooks extends LibraryEvent {
  final String studentId;
  const FetchBorrowedBooks(this.studentId);

  @override
  List<Object> get props => [studentId];
}
