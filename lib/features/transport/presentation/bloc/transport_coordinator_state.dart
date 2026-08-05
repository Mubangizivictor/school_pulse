import 'package:equatable/equatable.dart';

abstract class TransportCoordinatorState extends Equatable {
  const TransportCoordinatorState();

  @override
  List<Object?> get props => [];
}

class TransportCoordinatorInitial extends TransportCoordinatorState {}

class TransportCoordinatorLoading extends TransportCoordinatorState {}

class TransportCoordinatorLoaded extends TransportCoordinatorState {
  final int activeBuses;
  final int totalStudents;
  final int studentsInTransit;
  final List<BusRoute> routes;

  const TransportCoordinatorLoaded({
    required this.activeBuses,
    required this.totalStudents,
    required this.studentsInTransit,
    required this.routes,
  });

  @override
  List<Object?> get props => [
    activeBuses,
    totalStudents,
    studentsInTransit,
    routes,
  ];
}

class TransportCoordinatorError extends TransportCoordinatorState {
  final String message;

  const TransportCoordinatorError(this.message);

  @override
  List<Object?> get props => [message];
}

class BusRoute extends Equatable {
  final String id;
  final String name;
  final String busNumber;
  final String driver;
  final int studentCount;
  final String status;

  const BusRoute({
    required this.id,
    required this.name,
    required this.busNumber,
    required this.driver,
    required this.studentCount,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    busNumber,
    driver,
    studentCount,
    status,
  ];
}

class TripActionSuccess extends TransportCoordinatorState {
  final String message;
  const TripActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
