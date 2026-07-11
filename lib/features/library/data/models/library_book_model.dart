import '../../domain/entities/library_book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryBookModel extends LibraryBook {
  const LibraryBookModel({
    required super.id,
    required super.studentId,
    required super.title,
    required super.author,
    required super.dueDate,
    super.isReturned,
  });

  factory LibraryBookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LibraryBookModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isReturned: data['isReturned'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'title': title,
      'author': author,
      'dueDate': Timestamp.fromDate(dueDate),
      'isReturned': isReturned,
    };
  }
}
