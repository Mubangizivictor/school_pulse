import 'package:equatable/equatable.dart';

abstract class ReceptionistState extends Equatable {
  const ReceptionistState();

  @override
  List<Object?> get props => [];
}

class ReceptionistInitial extends ReceptionistState {}

class ReceptionistLoading extends ReceptionistState {}

class ReceptionistLoaded extends ReceptionistState {
  final int upcomingAppointments;
  final int totalVisitorsToday;
  final List<Appointment> appointments;

  const ReceptionistLoaded({
    required this.upcomingAppointments,
    required this.totalVisitorsToday,
    required this.appointments,
  });

  @override
  List<Object?> get props => [upcomingAppointments, totalVisitorsToday, appointments];
}

class Appointment extends Equatable {
  final String id;
  final String visitorName;
  final String purpose;
  final DateTime time;
  final String status;

  const Appointment({
    required this.id,
    required this.visitorName,
    required this.purpose,
    required this.time,
    required this.status,
  });

  @override
  List<Object?> get props => [id, visitorName, purpose, time, status];
}

class ReceptionistError extends ReceptionistState {
  final String message;

  const ReceptionistError(this.message);

  @override
  List<Object?> get props => [message];
}
