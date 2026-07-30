import 'package:equatable/equatable.dart';
import '../../domain/entities/security_entities.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityDashboardLoaded extends SecurityState {
  final Map<String, dynamic> stats;
  final List<Gate> gates;
  final List<StudentMovement> recentMovements;
  final List<SecurityIncident> activeIncidents;
  final List<EmergencyEvent> activeEmergencies;

  const SecurityDashboardLoaded({
    required this.stats,
    required this.gates,
    required this.recentMovements,
    required this.activeIncidents,
    required this.activeEmergencies,
  });

  @override
  List<Object?> get props => [stats, gates, recentMovements, activeIncidents, activeEmergencies];
}

class GatesLoaded extends SecurityState {
  final List<Gate> gates;
  const GatesLoaded(this.gates);
  @override
  List<Object?> get props => [gates];
}

class StudentMovementsLoaded extends SecurityState {
  final List<StudentMovement> movements;
  const StudentMovementsLoaded(this.movements);
  @override
  List<Object?> get props => [movements];
}

class IncidentsLoaded extends SecurityState {
  final List<SecurityIncident> incidents;
  const IncidentsLoaded(this.incidents);
  @override
  List<Object?> get props => [incidents];
}

class ActiveEmergenciesLoaded extends SecurityState {
  final List<EmergencyEvent> emergencies;
  const ActiveEmergenciesLoaded(this.emergencies);
  @override
  List<Object?> get props => [emergencies];
}

class LostAndFoundLoaded extends SecurityState {
  final List<LostAndFoundItem> items;
  const LostAndFoundLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class SecurityError extends SecurityState {
  final String message;
  const SecurityError(this.message);
  @override
  List<Object?> get props => [message];
}

class SecurityActionSuccess extends SecurityState {
  final String message;
  const SecurityActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
