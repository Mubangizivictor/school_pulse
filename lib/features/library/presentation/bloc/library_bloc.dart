import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_borrowed_books.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetBorrowedBooks getBorrowedBooks;

  LibraryBloc({required this.getBorrowedBooks}) : super(LibraryInitial()) {
    on<FetchBorrowedBooks>(_onFetchBorrowedBooks);
  }

  Future<void> _onFetchBorrowedBooks(FetchBorrowedBooks event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    final result = await getBorrowedBooks(event.studentId);
    result.fold(
      (failure) => emit(const LibraryError('Server Failure')),
      (books) => emit(LibraryLoaded(books)),
    );
  }
}
