import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/school_directory_repository.dart';
import 'school_directory_event.dart';
import 'school_directory_state.dart';

class SchoolDirectoryBloc
    extends Bloc<SchoolDirectoryEvent, SchoolDirectoryState> {
  final SchoolDirectoryRepository repository;

  SchoolDirectoryBloc({required this.repository})
    : super(SchoolDirectoryInitial()) {
    on<LoadDirectoryRequested>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDirectoryRequested event,
    Emitter<SchoolDirectoryState> emit,
  ) async {
    emit(SchoolDirectoryLoading());

    final result = await repository.getContacts(event.schoolId);
    result.fold(
      (failure) => emit(SchoolDirectoryError(failure.message)),
      (contacts) => emit(SchoolDirectoryLoaded(contacts: contacts)),
    );
  }
}
