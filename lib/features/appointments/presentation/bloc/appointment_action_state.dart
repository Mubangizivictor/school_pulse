import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment.dart';

abstract class AppointmentActionState extends Equatable {
  const AppointmentActionState();

  @override
  List<Object?> get props => [];
}

class AppointmentActionIdle extends AppointmentActionState {}

class AppointmentActionInProgress extends AppointmentActionState {}

class AppointmentActionSuccess extends AppointmentActionState {
  final String message;
  final Appointment? appointment;

  const AppointmentActionSuccess(this.message, {this.appointment});

  @override
  List<Object?> get props => [message, appointment];
}

class AppointmentActionFailure extends AppointmentActionState {
  final String message;
  const AppointmentActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
