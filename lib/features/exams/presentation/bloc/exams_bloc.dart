import 'package:flutter_bloc/flutter_bloc.dart';
import 'exams_event.dart';
import 'exams_state.dart';

class ExamsBloc extends Bloc<ExamsEvent, ExamsState> {
  ExamsBloc() : super(ExamsInitial()) {
    on<ExamsDashboardRequested>((event, emit) async {
      emit(ExamsLoading());
      // Mocking delay and data
      await Future.delayed(const Duration(seconds: 1));
      emit(const ExamsLoaded(
        totalStudents: 850,
        pendingResults: 124,
        completionRate: 0.85,
        upcomingExams: [
          ExamSchedule(
            subject: 'Mathematics',
            className: 'Senior 4',
            date: 'Oct 30, 2023',
            session: 'Morning',
          ),
          ExamSchedule(
            subject: 'English Literature',
            className: 'Senior 6',
            date: 'Oct 31, 2023',
            session: 'Afternoon',
          ),
          ExamSchedule(
            subject: 'Physics Practical',
            className: 'Senior 4',
            date: 'Nov 02, 2023',
            session: 'Morning',
          ),
        ],
      ));
    });
  }
}
