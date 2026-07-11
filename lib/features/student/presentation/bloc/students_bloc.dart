import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_students_by_ids.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final GetStudentsByIds getStudentsByIds;

  StudentsBloc({required this.getStudentsByIds}) : super(StudentsInitial()) {
    on<FetchStudents>(_onFetchStudents);
  }

  Future<void> _onFetchStudents(
    FetchStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    final result = await getStudentsByIds(event.studentIds);
    result.fold(
      (failure) => emit(const StudentsError('Server Failure')),
      (students) => emit(StudentsLoaded(students)),
    );
  }
}
