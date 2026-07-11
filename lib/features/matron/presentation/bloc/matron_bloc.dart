import 'package:flutter_bloc/flutter_bloc.dart';
import 'matron_event.dart';
import 'matron_state.dart';

class MatronBloc extends Bloc<MatronEvent, MatronState> {
  MatronBloc() : super(MatronInitial()) {
    on<MatronDashboardRequested>(_onMatronDashboardRequested);
  }

  Future<void> _onMatronDashboardRequested(
    MatronDashboardRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const MatronLoaded(
        totalStudents: 320,
        studentsPresent: 315,
        studentsOnLeave: 5,
        dormitories: [
          DormitoryStatus(
            name: 'Nyerere House',
            capacity: 80,
            currentOccupants: 78,
            status: 'Normal',
          ),
          DormitoryStatus(
            name: 'Mandela House',
            capacity: 80,
            currentOccupants: 80,
            status: 'Full',
          ),
          DormitoryStatus(
            name: 'Lumumba House',
            capacity: 80,
            currentOccupants: 75,
            status: 'Normal',
          ),
          DormitoryStatus(
            name: 'Obote House',
            capacity: 80,
            currentOccupants: 82,
            status: 'Over Capacity',
          ),
        ],
      ));
    } catch (e) {
      emit(MatronError(e.toString()));
    }
  }
}
