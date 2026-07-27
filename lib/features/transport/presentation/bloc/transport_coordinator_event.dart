import 'package:equatable/equatable.dart';

abstract class TransportCoordinatorEvent extends Equatable {
  const TransportCoordinatorEvent();

  @override
  List<Object?> get props => [];
}

class TransportCoordinatorDashboardRequested extends TransportCoordinatorEvent {}

class StartTripRequested extends TransportCoordinatorEvent {
  final String routeId;
  const StartTripRequested(this.routeId);

  @override
  List<Object?> get props => [routeId];
}

class EndTripRequested extends TransportCoordinatorEvent {
  final String routeId;
  const EndTripRequested(this.routeId);

  @override
  List<Object?> get props => [routeId];
}

class LogStudentPickupRequested extends TransportCoordinatorEvent {
  final String routeId;
  final String studentId;

  const LogStudentPickupRequested({required this.routeId, required this.studentId});

  @override
  List<Object?> get props => [routeId, studentId];
}
