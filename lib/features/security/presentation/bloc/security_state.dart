import 'package:equatable/equatable.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityLoaded extends SecurityState {
  final int guardsOnDuty;
  final int activeIncidents;
  final int visitorsIn;
  final List<SecurityAlert> recentAlerts;

  const SecurityLoaded({
    required this.guardsOnDuty,
    required this.activeIncidents,
    required this.visitorsIn,
    required this.recentAlerts,
  });

  @override
  List<Object?> get props => [guardsOnDuty, activeIncidents, visitorsIn, recentAlerts];
}

class SecurityError extends SecurityState {
  final String message;

  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}

class SecurityAlert extends Equatable {
  final String title;
  final String time;
  final String severity;

  const SecurityAlert({
    required this.title,
    required this.time,
    required this.severity,
  });

  @override
  List<Object?> get props => [title, time, severity];
}
