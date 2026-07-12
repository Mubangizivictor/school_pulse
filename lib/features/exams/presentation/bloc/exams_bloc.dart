import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/exams_repository.dart';
import 'exams_event.dart';
import 'exams_state.dart';

class ExamsBloc extends Bloc<ExamsEvent, ExamsState> {
  final ExamsRepository repository;

  ExamsBloc({required this.repository}) : super(ExamsInitial()) {
    on<ExamsDashboardRequested>((event, emit) async {
      emit(ExamsLoading());
      final result = await repository.getDashboardData();
      result.fold(
        (failure) => emit(ExamsError(failure.message)),
        (data) => emit(data),
      );
    });
  }
}
