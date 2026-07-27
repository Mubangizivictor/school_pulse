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

class LoadLibraryBooks extends LibraryEvent {}

class IssueBookRequested extends LibraryEvent {
  final String studentId;
  final String title;
  final String author;
  final DateTime dueDate;

  const IssueBookRequested({
    required this.studentId,
    required this.title,
    required this.author,
    required this.dueDate,
  });

  @override
  List<Object> get props => [studentId, title, author, dueDate];
}

class ReturnBookRequested extends LibraryEvent {
  final String bookId;

  const ReturnBookRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}
