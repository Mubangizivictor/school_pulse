import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/security_entities.dart';
import '../repositories/security_repository.dart';

class WatchGates {
  final SecurityRepository repository;
  WatchGates(this.repository);
  Stream<List<Gate>> call() => repository.watchGates();
}

class CreateGate {
  final SecurityRepository repository;
  CreateGate(this.repository);
  Future<Either<Failure, void>> call(Gate gate) => repository.createGate(gate);
}

class RecordStudentMovement {
  final SecurityRepository repository;
  RecordStudentMovement(this.repository);
  Future<Either<Failure, void>> call(StudentMovement movement) => repository.recordStudentMovement(movement);
}

class WatchStudentMovements {
  final SecurityRepository repository;
  WatchStudentMovements(this.repository);
  Stream<List<StudentMovement>> call({DateTime? date, String? gateId}) => repository.watchStudentMovements(date: date, gateId: gateId);
}

class ReportIncident {
  final SecurityRepository repository;
  ReportIncident(this.repository);
  Future<Either<Failure, void>> call(SecurityIncident incident) => repository.reportIncident(incident);
}

class WatchIncidents {
  final SecurityRepository repository;
  WatchIncidents(this.repository);
  Stream<List<SecurityIncident>> call() => repository.watchIncidents();
}

class TriggerEmergency {
  final SecurityRepository repository;
  TriggerEmergency(this.repository);
  Future<Either<Failure, void>> call(EmergencyEvent event) => repository.triggerEmergency(event);
}

class WatchActiveEmergencies {
  final SecurityRepository repository;
  WatchActiveEmergencies(this.repository);
  Stream<List<EmergencyEvent>> call() => repository.watchActiveEmergencies();
}

class RecordPatrol {
  final SecurityRepository repository;
  RecordPatrol(this.repository);
  Future<Either<Failure, void>> call(SecurityPatrol patrol) => repository.recordPatrol(patrol);
}

class GetSecurityDashboardStats {
  final SecurityRepository repository;
  GetSecurityDashboardStats(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call() => repository.getSecurityDashboardStats();
}

class GetPickupAuthorizations {
  final SecurityRepository repository;
  GetPickupAuthorizations(this.repository);
  Future<Either<Failure, List<PickupAuthorization>>> call(String studentId) => repository.getPickupAuthorizations(studentId);
}

class ReportFoundItem {
  final SecurityRepository repository;
  ReportFoundItem(this.repository);
  Future<Either<Failure, void>> call(LostAndFoundItem item) => repository.reportFoundItem(item);
}

class WatchLostAndFound {
  final SecurityRepository repository;
  WatchLostAndFound(this.repository);
  Stream<List<LostAndFoundItem>> call() => repository.watchLostAndFound();
}

class SyncSecurityData {
  final SecurityRepository repository;
  SyncSecurityData(this.repository);
  Future<Either<Failure, void>> call() => repository.syncSecurityData();
}
