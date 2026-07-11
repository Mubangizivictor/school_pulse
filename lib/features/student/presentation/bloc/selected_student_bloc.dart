import 'package:flutter_bloc/flutter_bloc.dart';
import 'selected_student_event.dart';
import 'selected_student_state.dart';

class SelectedStudentBloc
    extends Bloc<SelectedStudentEvent, SelectedStudentState> {
  SelectedStudentBloc() : super(SelectedStudentInitial()) {
    on<SelectStudent>((event, emit) {
      emit(SelectedStudentLoaded(event.student));
    });
  }
}
