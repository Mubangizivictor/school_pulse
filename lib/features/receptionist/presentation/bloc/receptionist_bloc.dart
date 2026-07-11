import 'package:flutter_bloc/flutter_bloc.dart';
import 'receptionist_event.dart';
import 'receptionist_state.dart';

class ReceptionistBloc extends Bloc<ReceptionistEvent, ReceptionistState> {
  ReceptionistBloc() : super(ReceptionistInitial()) {
    on<ReceptionistDashboardRequested>(_onReceptionistDashboardRequested);
  }

  Future<void> _onReceptionistDashboardRequested(
    ReceptionistDashboardRequested event,
    Emitter<ReceptionistState> emit,
  ) async {
    emit(ReceptionistLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(ReceptionistLoaded(
        upcomingAppointments: 4,
        totalVisitorsToday: 12,
        appointments: [
          Appointment(
            id: '1',
            visitorName: 'Mr. John Musoke',
            purpose: 'Meeting with Head Teacher',
            time: DateTime.now().add(const Duration(hours: 1)),
            status: 'Scheduled',
          ),
          Appointment(
            id: '2',
            visitorName: 'Mrs. Sarah Nabirye',
            purpose: 'Document Pickup',
            time: DateTime.now().add(const Duration(minutes: 30)),
            status: 'Arriving Soon',
          ),
        ],
      ));
    } catch (e) {
      emit(ReceptionistError(e.toString()));
    }
  }
}
