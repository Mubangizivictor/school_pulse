import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/security_entities.dart';

abstract class SecurityRepository {
  // Gates
  Stream<List<Gate>> watchGates(String schoolId);
  Future<Either<Failure, void>> createGate(Gate gate);
  Future<Either<Failure, void>> updateGate(Gate gate);

  // Student Movement
  Future<Either<Failure, void>> recordStudentMovement(StudentMovement movement);
  Stream<List<StudentMovement>> watchStudentMovements(
    String schoolId, {
    DateTime? date,
    String? gateId,
    String? studentId,
  });

  // Staff Movement
  Future<Either<Failure, void>> recordStaffMovement(StaffMovement movement);
  Stream<List<StaffMovement>> watchStaffMovements(
    String schoolId, {
    DateTime? date,
    String? gateId,
  });

  // Pickup Management
  Future<Either<Failure, List<PickupAuthorization>>> getPickupAuthorizations(
    String schoolId,
    String studentId,
  );
  Future<Either<Failure, void>> addPickupAuthorization(
    PickupAuthorization authorization,
  );

  // Incidents
  Future<Either<Failure, void>> reportIncident(SecurityIncident incident);
  Stream<List<SecurityIncident>> watchIncidents(String schoolId);
  Future<Either<Failure, void>> updateIncidentStatus(
    String schoolId,
    String incidentId,
    String status,
    String resolution,
  );

  // Emergency
  Future<Either<Failure, void>> triggerEmergency(EmergencyEvent event);
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId);
  Future<Either<Failure, void>> resolveEmergency(
    String schoolId,
    String emergencyId,
    DateTime endTime,
    List<String> actions,
  );

  // Patrols
  Future<Either<Failure, void>> recordPatrol(SecurityPatrol patrol);
  Stream<List<SecurityPatrol>> watchPatrols(String schoolId);

  // Lost and Found
  Future<Either<Failure, void>> reportFoundItem(LostAndFoundItem item);
  Future<Either<Failure, void>> claimItem(
    String schoolId,
    String itemId,
    Map<String, dynamic> claimDetails,
  );
  Stream<List<LostAndFoundItem>> watchLostAndFound(String schoolId);

  // Dashboard Stats
  Future<Either<Failure, Map<String, dynamic>>> getSecurityDashboardStats(
    String schoolId,
  );

  // Sync
  Future<Either<Failure, void>> syncSecurityData();
}
