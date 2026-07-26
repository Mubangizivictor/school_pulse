import 'package:equatable/equatable.dart';

abstract class ReceptionistEvent extends Equatable {
  const ReceptionistEvent();

  @override
  List<Object?> get props => [];
}

class ReceptionistDashboardRequested extends ReceptionistEvent {}

class ScheduleAppointmentRequested extends ReceptionistEvent {
  final String visitorName;
  final String purpose;
  final DateTime time;

  const ScheduleAppointmentRequested({
    required this.visitorName,
    required this.purpose,
    required this.time,
  });

  @override
  List<Object?> get props => [visitorName, purpose, time];
}
