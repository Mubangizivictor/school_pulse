import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/security_entities.dart';

abstract class SecurityRepository {
  // Gates
  Stream<List<Gate>> watchGates();
  Future<Either<Failure, void>> createGate(Gate gate);
  Future<Either<Failure, void>> updateGate(Gate gate);

  // Student Movement
  Future<Either<Failure, void>> recordStudentMovement(StudentMovement movement);
  Stream<List<StudentMovement>> watchStudentMovements({DateTime? date, String? gateId});
  
  // Staff Movement
  Future<Either<Failure, void>> recordStaffMovement(StaffMovement movement);
  Stream<List<StaffMovement>> watchStaffMovements({DateTime? date, String? gateId});

  // Pickup Management
  Future<Either<Failure, List<PickupAuthorization>>> getPickupAuthorizations(String studentId);
  Future<Either<Failure, void>> addPickupAuthorization(PickupAuthorization authorization);

  // Incidents
  Future<Either<Failure, void>> reportIncident(SecurityIncident incident);
  Stream<List<SecurityIncident>> watchIncidents();
  Future<Either<Failure, void>> updateIncidentStatus(String incidentId, String status, String resolution);

  // Emergency
  Future<Either<Failure, void>> triggerEmergency(EmergencyEvent event);
  Stream<List<EmergencyEvent>> watchActiveEmergencies();
  Future<Either<Failure, void>> resolveEmergency(String emergencyId, DateTime endTime, List<String> actions);

  // Patrols
  Future<Either<Failure, void>> recordPatrol(SecurityPatrol patrol);
  Stream<List<SecurityPatrol>> watchPatrols();

  // Lost and Found
  Future<Either<Failure, void>> reportFoundItem(LostAndFoundItem item);
  Future<Either<Failure, void>> claimItem(String itemId, Map<String, dynamic> claimDetails);
  Stream<List<LostAndFoundItem>> watchLostAndFound();

  // Dashboard Stats
  Future<Either<Failure, Map<String, dynamic>>> getSecurityDashboardStats();

  // Sync
  Future<Either<Failure, void>> syncSecurityData();
}
