import 'package:equatable/equatable.dart';

abstract class GatekeeperState extends Equatable {
  const GatekeeperState();

  @override
  List<Object?> get props => [];
}

class GatekeeperInitial extends GatekeeperState {}

class GatekeeperLoading extends GatekeeperState {}

class GatekeeperLoaded extends GatekeeperState {
  final List<VisitorLog> recentVisitors;
  final int studentsIn;
  final int studentsOut;
  final int activeVisitors;

  const GatekeeperLoaded({
    required this.recentVisitors,
    required this.studentsIn,
    required this.studentsOut,
    required this.activeVisitors,
  });

  @override
  List<Object?> get props => [recentVisitors, studentsIn, studentsOut, activeVisitors];
}

class VisitorLog extends Equatable {
  final String id;
  final String name;
  final String purpose;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String status;

  const VisitorLog({
    required this.id,
    required this.name,
    required this.purpose,
    required this.entryTime,
    this.exitTime,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, purpose, entryTime, exitTime, status];
}

class GatekeeperError extends GatekeeperState {
  final String message;

  const GatekeeperError(this.message);

  @override
  List<Object?> get props => [message];
}
