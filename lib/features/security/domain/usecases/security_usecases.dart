import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/security_entities.dart';
import '../repositories/security_repository.dart';

class WatchGates {
  final SecurityRepository repository;
  WatchGates(this.repository);
  Stream<List<Gate>> call(String schoolId) => repository.watchGates(schoolId);
}

class CreateGate {
  final SecurityRepository repository;
  CreateGate(this.repository);
  Future<Either<Failure, void>> call(Gate gate) => repository.createGate(gate);
}

class UpdateGate {
  final SecurityRepository repository;
  UpdateGate(this.repository);
  Future<Either<Failure, void>> call(Gate gate) => repository.updateGate(gate);
}

class RecordStudentMovement {
  final SecurityRepository repository;
  RecordStudentMovement(this.repository);
  Future<Either<Failure, void>> call(StudentMovement movement) =>
      repository.recordStudentMovement(movement);
}

class WatchStudentMovements {
  final SecurityRepository repository;
  WatchStudentMovements(this.repository);
  Stream<List<StudentMovement>> call(
    String schoolId, {
    DateTime? date,
    String? gateId,
    String? studentId,
  }) => repository.watchStudentMovements(
    schoolId,
    date: date,
    gateId: gateId,
    studentId: studentId,
  );
}

class RecordStaffMovement {
  final SecurityRepository repository;
  RecordStaffMovement(this.repository);
  Future<Either<Failure, void>> call(StaffMovement movement) =>
      repository.recordStaffMovement(movement);
}

class WatchStaffMovements {
  final SecurityRepository repository;
  WatchStaffMovements(this.repository);
  Stream<List<StaffMovement>> call(
    String schoolId, {
    DateTime? date,
    String? gateId,
  }) => repository.watchStaffMovements(schoolId, date: date, gateId: gateId);
}

class ReportIncident {
  final SecurityRepository repository;
  ReportIncident(this.repository);
  Future<Either<Failure, void>> call(SecurityIncident incident) =>
      repository.reportIncident(incident);
}

class WatchIncidents {
  final SecurityRepository repository;
  WatchIncidents(this.repository);
  Stream<List<SecurityIncident>> call(String schoolId) =>
      repository.watchIncidents(schoolId);
}

class UpdateIncidentStatus {
  final SecurityRepository repository;
  UpdateIncidentStatus(this.repository);
  Future<Either<Failure, void>> call(
    String schoolId,
    String incidentId,
    String status,
    String resolution,
  ) =>
      repository.updateIncidentStatus(schoolId, incidentId, status, resolution);
}

class TriggerEmergency {
  final SecurityRepository repository;
  TriggerEmergency(this.repository);
  Future<Either<Failure, void>> call(EmergencyEvent event) =>
      repository.triggerEmergency(event);
}

class WatchActiveEmergencies {
  final SecurityRepository repository;
  WatchActiveEmergencies(this.repository);
  Stream<List<EmergencyEvent>> call(String schoolId) =>
      repository.watchActiveEmergencies(schoolId);
}

class ResolveEmergency {
  final SecurityRepository repository;
  ResolveEmergency(this.repository);
  Future<Either<Failure, void>> call(
    String schoolId,
    String emergencyId,
    DateTime endTime,
    List<String> actions,
  ) => repository.resolveEmergency(schoolId, emergencyId, endTime, actions);
}

class RecordPatrol {
  final SecurityRepository repository;
  RecordPatrol(this.repository);
  Future<Either<Failure, void>> call(SecurityPatrol patrol) =>
      repository.recordPatrol(patrol);
}

class WatchPatrols {
  final SecurityRepository repository;
  WatchPatrols(this.repository);
  Stream<List<SecurityPatrol>> call(String schoolId) =>
      repository.watchPatrols(schoolId);
}

class GetSecurityDashboardStats {
  final SecurityRepository repository;
  GetSecurityDashboardStats(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call(String schoolId) =>
      repository.getSecurityDashboardStats(schoolId);
}

class GetPickupAuthorizations {
  final SecurityRepository repository;
  GetPickupAuthorizations(this.repository);
  Future<Either<Failure, List<PickupAuthorization>>> call(
    String schoolId,
    String studentId,
  ) => repository.getPickupAuthorizations(schoolId, studentId);
}

class AddPickupAuthorization {
  final SecurityRepository repository;
  AddPickupAuthorization(this.repository);
  Future<Either<Failure, void>> call(PickupAuthorization authorization) =>
      repository.addPickupAuthorization(authorization);
}

class ReportFoundItem {
  final SecurityRepository repository;
  ReportFoundItem(this.repository);
  Future<Either<Failure, void>> call(LostAndFoundItem item) =>
      repository.reportFoundItem(item);
}

class ClaimItem {
  final SecurityRepository repository;
  ClaimItem(this.repository);
  Future<Either<Failure, void>> call(
    String schoolId,
    String itemId,
    Map<String, dynamic> claimDetails,
  ) => repository.claimItem(schoolId, itemId, claimDetails);
}

class WatchLostAndFound {
  final SecurityRepository repository;
  WatchLostAndFound(this.repository);
  Stream<List<LostAndFoundItem>> call(String schoolId) =>
      repository.watchLostAndFound(schoolId);
}

class SyncSecurityData {
  final SecurityRepository repository;
  SyncSecurityData(this.repository);
  Future<Either<Failure, void>> call() => repository.syncSecurityData();
}
