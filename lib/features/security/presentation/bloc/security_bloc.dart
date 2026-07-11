import 'package:flutter_bloc/flutter_bloc.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  SecurityBloc() : super(SecurityInitial()) {
    on<SecurityDashboardRequested>((event, emit) async {
      emit(SecurityLoading());
      // Mocking delay and data
      await Future.delayed(const Duration(seconds: 1));
      emit(const SecurityLoaded(
        guardsOnDuty: 8,
        activeIncidents: 0,
        visitorsIn: 5,
        recentAlerts: [
          SecurityAlert(title: 'Gate 2 Opened', time: '10 mins ago', severity: 'low'),
          SecurityAlert(title: 'Main Entrance Sensor Triggered', time: '45 mins ago', severity: 'medium'),
          SecurityAlert(title: 'Perimeter Check Completed', time: '1 hour ago', severity: 'low'),
        ],
      ));
    });
  }
}
