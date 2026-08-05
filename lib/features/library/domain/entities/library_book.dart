import 'package:equatable/equatable.dart';

class LibraryBook extends Equatable {
  final String id;
  final String studentId;
  final String title;
  final String author;
  final DateTime dueDate;
  final bool isReturned;

  const LibraryBook({
    required this.id,
    required this.studentId,
    required this.title,
    required this.author,
    required this.dueDate,
    this.isReturned = false,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    title,
    author,
    dueDate,
    isReturned,
  ];
}
