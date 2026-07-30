import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_students_by_ids.dart';
import '../../domain/usecases/get_all_students.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final GetStudentsByIds getStudentsByIds;
  final GetAllStudents getAllStudents;

  StudentsBloc({
    required this.getStudentsByIds,
    required this.getAllStudents,
  }) : super(StudentsInitial()) {
    on<FetchStudents>(_onFetchStudents);
    on<SearchStudents>(_onSearchStudents);
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

  Future<void> _onSearchStudents(
    SearchStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    final result = await getAllStudents();
    result.fold(
      (failure) => emit(const StudentsError('Server Failure')),
      (students) {
        final filtered = students.where((s) {
          final query = event.query.toLowerCase();
          return s.name.toLowerCase().contains(query) ||
              s.studentId.toLowerCase().contains(query);
        }).toList();
        emit(StudentsLoaded(filtered));
      },
    );
  }
}
