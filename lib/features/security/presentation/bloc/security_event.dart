import 'package:equatable/equatable.dart';
import '../../domain/entities/security_entities.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class LoadSecurityDashboard extends SecurityEvent {}

// Gates
class WatchGatesRequested extends SecurityEvent {}

class CreateGateRequested extends SecurityEvent {
  final Gate gate;
  const CreateGateRequested(this.gate);
  @override
  List<Object?> get props => [gate];
}

// Student Movement
class RecordStudentMovementRequested extends SecurityEvent {
  final StudentMovement movement;
  const RecordStudentMovementRequested(this.movement);
  @override
  List<Object?> get props => [movement];
}

class WatchStudentMovementsRequested extends SecurityEvent {
  final DateTime? date;
  final String? gateId;
  const WatchStudentMovementsRequested({this.date, this.gateId});
  @override
  List<Object?> get props => [date, gateId];
}

// Incidents
class ReportIncidentRequested extends SecurityEvent {
  final SecurityIncident incident;
  const ReportIncidentRequested(this.incident);
  @override
  List<Object?> get props => [incident];
}

class WatchIncidentsRequested extends SecurityEvent {}

// Emergency
class TriggerEmergencyRequested extends SecurityEvent {
  final EmergencyEvent event;
  const TriggerEmergencyRequested(this.event);
  @override
  List<Object?> get props => [event];
}

class WatchActiveEmergenciesRequested extends SecurityEvent {}

// Patrols
class RecordPatrolRequested extends SecurityEvent {
  final SecurityPatrol patrol;
  const RecordPatrolRequested(this.patrol);
  @override
  List<Object?> get props => [patrol];
}

// Lost and Found
class ReportFoundItemRequested extends SecurityEvent {
  final LostAndFoundItem item;
  const ReportFoundItemRequested(this.item);
  @override
  List<Object?> get props => [item];
}

class WatchLostAndFoundRequested extends SecurityEvent {}
