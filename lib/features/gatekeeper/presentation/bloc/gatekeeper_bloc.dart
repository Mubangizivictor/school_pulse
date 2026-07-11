import 'package:flutter_bloc/flutter_bloc.dart';
import 'gatekeeper_event.dart';
import 'gatekeeper_state.dart';

class GatekeeperBloc extends Bloc<GatekeeperEvent, GatekeeperState> {
  GatekeeperBloc() : super(GatekeeperInitial()) {
    on<GatekeeperDashboardRequested>(_onGatekeeperDashboardRequested);
  }

  Future<void> _onGatekeeperDashboardRequested(
    GatekeeperDashboardRequested event,
    Emitter<GatekeeperState> emit,
  ) async {
    emit(GatekeeperLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(GatekeeperLoaded(
        studentsIn: 450,
        studentsOut: 12,
        activeVisitors: 5,
        recentVisitors: [
          VisitorLog(
            id: '1',
            name: 'Mr. Kato Joseph',
            purpose: 'Student Pickup',
            entryTime: DateTime.now().subtract(const Duration(minutes: 30)),
            status: 'Checked In',
          ),
          VisitorLog(
            id: '2',
            name: 'Mrs. Namuli Sarah',
            purpose: 'Consultation',
            entryTime: DateTime.now().subtract(const Duration(hours: 1)),
            status: 'Checked In',
          ),
        ],
      ));
    } catch (e) {
      emit(GatekeeperError(e.toString()));
    }
  }
}
