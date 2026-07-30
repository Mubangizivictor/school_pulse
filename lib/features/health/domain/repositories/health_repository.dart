import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_visit.dart';
import '../entities/student_health_profile.dart';
import '../entities/medical_inventory.dart';
import '../entities/emergency_incident.dart';
import '../entities/medical_supply_request.dart';

abstract class HealthRepository {
  // Student Health Profile
  Future<Either<Failure, StudentHealthProfile>> getStudentHealthProfile(
    String studentId,
    String schoolId,
  );
  Future<Either<Failure, void>> updateStudentHealthProfile(
    StudentHealthProfile profile,
    String schoolId,
  );

  // Clinic Visits
  Future<Either<Failure, List<ClinicVisit>>> getClinicVisits({
    required String schoolId,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, void>> recordClinicVisit(ClinicVisit visit);

  // Emergency Incidents
  Future<Either<Failure, List<EmergencyIncident>>> getEmergencyIncidents({
    required String schoolId,
    String? studentId,
  });
  Future<Either<Failure, void>> recordEmergencyIncident(
    EmergencyIncident incident,
  );

  // Medical Inventory
  Future<Either<Failure, List<MedicalInventoryItem>>> getMedicalInventory(
    String schoolId,
  );
  Future<Either<Failure, void>> updateInventoryItem(MedicalInventoryItem item);

  // Procurement / Supply Requests
  Future<Either<Failure, List<MedicalSupplyRequest>>> getMedicalSupplyRequests(
    String schoolId,
  );
  Future<Either<Failure, void>> createSupplyRequest(
    MedicalSupplyRequest request,
  );
  Future<Either<Failure, void>> updateSupplyRequestStatus(
    String requestId,
    String schoolId,
    SupplyRequestStatus status, {
    String? reviewNotes,
    String? rejectionReason,
  });

  // Stats & Analytics
  Future<Either<Failure, Map<String, dynamic>>> getHealthAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}
