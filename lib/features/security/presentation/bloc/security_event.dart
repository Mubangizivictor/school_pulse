import 'package:equatable/equatable.dart';
import '../../domain/entities/security_entities.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class LoadSecurityDashboard extends SecurityEvent {
  final String schoolId;
  const LoadSecurityDashboard(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

// Gates
class WatchGatesRequested extends SecurityEvent {
  final String schoolId;
  const WatchGatesRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class CreateGateRequested extends SecurityEvent {
  final Gate gate;
  const CreateGateRequested(this.gate);
  @override
  List<Object?> get props => [gate];
}

class UpdateGateRequested extends SecurityEvent {
  final Gate gate;
  const UpdateGateRequested(this.gate);
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
  final String schoolId;
  final DateTime? date;
  final String? gateId;
  final String? studentId;
  const WatchStudentMovementsRequested(
    this.schoolId, {
    this.date,
    this.gateId,
    this.studentId,
  });
  @override
  List<Object?> get props => [schoolId, date, gateId, studentId];
}

// Staff Movement
class RecordStaffMovementRequested extends SecurityEvent {
  final StaffMovement movement;
  const RecordStaffMovementRequested(this.movement);
  @override
  List<Object?> get props => [movement];
}

class WatchStaffMovementsRequested extends SecurityEvent {
  final String schoolId;
  final DateTime? date;
  final String? gateId;
  const WatchStaffMovementsRequested(this.schoolId, {this.date, this.gateId});
  @override
  List<Object?> get props => [schoolId, date, gateId];
}

// Incidents
class ReportIncidentRequested extends SecurityEvent {
  final SecurityIncident incident;
  const ReportIncidentRequested(this.incident);
  @override
  List<Object?> get props => [incident];
}

class WatchIncidentsRequested extends SecurityEvent {
  final String schoolId;
  const WatchIncidentsRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class UpdateIncidentStatusRequested extends SecurityEvent {
  final String schoolId;
  final String incidentId;
  final String status;
  final String resolution;
  const UpdateIncidentStatusRequested(
    this.schoolId,
    this.incidentId,
    this.status,
    this.resolution,
  );
  @override
  List<Object?> get props => [schoolId, incidentId, status, resolution];
}

// Emergency
class TriggerEmergencyRequested extends SecurityEvent {
  final EmergencyEvent event;
  const TriggerEmergencyRequested(this.event);
  @override
  List<Object?> get props => [event];
}

class WatchActiveEmergenciesRequested extends SecurityEvent {
  final String schoolId;
  const WatchActiveEmergenciesRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class ResolveEmergencyRequested extends SecurityEvent {
  final String schoolId;
  final String emergencyId;
  final DateTime endTime;
  final List<String> actions;
  const ResolveEmergencyRequested(
    this.schoolId,
    this.emergencyId,
    this.endTime,
    this.actions,
  );
  @override
  List<Object?> get props => [schoolId, emergencyId, endTime, actions];
}

// Patrols
class RecordPatrolRequested extends SecurityEvent {
  final SecurityPatrol patrol;
  const RecordPatrolRequested(this.patrol);
  @override
  List<Object?> get props => [patrol];
}

class WatchPatrolsRequested extends SecurityEvent {
  final String schoolId;
  const WatchPatrolsRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

// Lost and Found
class ReportFoundItemRequested extends SecurityEvent {
  final LostAndFoundItem item;
  const ReportFoundItemRequested(this.item);
  @override
  List<Object?> get props => [item];
}

class ClaimItemRequested extends SecurityEvent {
  final String schoolId;
  final String itemId;
  final Map<String, dynamic> claimDetails;
  const ClaimItemRequested(this.schoolId, this.itemId, this.claimDetails);
  @override
  List<Object?> get props => [schoolId, itemId, claimDetails];
}

class WatchLostAndFoundRequested extends SecurityEvent {
  final String schoolId;
  const WatchLostAndFoundRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}
