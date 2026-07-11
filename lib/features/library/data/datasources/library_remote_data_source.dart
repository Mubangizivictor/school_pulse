import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/library_book_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryBookModel>> getBorrowedBooks(String studentId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final FirebaseFirestore firestore;

  LibraryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<LibraryBookModel>> getBorrowedBooks(String studentId) async {
    final snapshot = await firestore
        .collection('library_books')
        .where('studentId', isEqualTo: studentId)
        .orderBy('dueDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => LibraryBookModel.fromFirestore(doc)).toList();
  }
}
