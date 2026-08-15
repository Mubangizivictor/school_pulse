import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_homework_for_student.dart';
import 'student_homework_event.dart';
import 'student_homework_state.dart';

class StudentHomeworkBloc
    extends Bloc<StudentHomeworkEvent, StudentHomeworkState> {
  final GetHomeworkForStudent getHomeworkForStudent;

  StudentHomeworkBloc({required this.getHomeworkForStudent})
    : super(StudentHomeworkInitial()) {
    on<LoadStudentHomework>(_onLoadStudentHomework);
  }

  Future<void> _onLoadStudentHomework(
    LoadStudentHomework event,
    Emitter<StudentHomeworkState> emit,
  ) async {
    emit(StudentHomeworkLoading());
    final result = await getHomeworkForStudent(event.schoolId, event.className);
    result.fold(
      (failure) => emit(StudentHomeworkError(failure.message)),
      (homeworkList) => emit(StudentHomeworkLoaded(homeworkList)),
    );
  }
}
