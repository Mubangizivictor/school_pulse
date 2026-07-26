import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/library_book_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryBookModel>> getBorrowedBooks(String studentId);
  Future<List<LibraryBookModel>> getAllBorrowedBooks();
  Future<void> issueBook(LibraryBookModel book);
  Future<void> returnBook(String bookId);
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

  @override
  Future<List<LibraryBookModel>> getAllBorrowedBooks() async {
    final snapshot = await firestore
        .collection('library_books')
        .orderBy('dueDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => LibraryBookModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> issueBook(LibraryBookModel book) async {
    await firestore.collection('library_books').add(book.toFirestore());
  }

  @override
  Future<void> returnBook(String bookId) async {
    await firestore.collection('library_books').doc(bookId).update({'isReturned': true});
  }
}
