import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/receptionist_repository.dart';
import 'receptionist_event.dart';
import 'receptionist_state.dart';

class ReceptionistBloc extends Bloc<ReceptionistEvent, ReceptionistState> {
  final ReceptionistRepository repository;

  ReceptionistBloc({required this.repository}) : super(ReceptionistInitial()) {
    on<ReceptionistDashboardRequested>(_onReceptionistDashboardRequested);
    on<ScheduleAppointmentRequested>(_onScheduleAppointmentRequested);
  }

  Future<void> _onReceptionistDashboardRequested(
    ReceptionistDashboardRequested event,
    Emitter<ReceptionistState> emit,
  ) async {
    emit(ReceptionistLoading());
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(ReceptionistError(failure.message)),
      (data) => emit(data),
    );
  }

  Future<void> _onScheduleAppointmentRequested(
    ScheduleAppointmentRequested event,
    Emitter<ReceptionistState> emit,
  ) async {
    final appointment = Appointment(
      id: '',
      visitorName: event.visitorName,
      purpose: event.purpose,
      time: event.time,
      status: 'Scheduled',
    );
    final result = await repository.scheduleAppointment(appointment);
    await result.fold(
      (failure) async => emit(ReceptionistError(failure.message)),
      (_) async => _onReceptionistDashboardRequested(ReceptionistDashboardRequested(), emit),
    );
  }
}
