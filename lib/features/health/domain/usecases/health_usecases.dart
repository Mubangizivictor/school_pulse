import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_visit.dart';
import '../entities/emergency_incident.dart';
import '../entities/medical_inventory.dart';
import '../entities/medical_supply_request.dart';
import '../entities/student_health_profile.dart';
import '../repositories/health_repository.dart';

class GetStudentHealthProfile {
  final HealthRepository repository;
  GetStudentHealthProfile(this.repository);
  Future<Either<Failure, StudentHealthProfile>> call(
    String studentId,
    String schoolId,
  ) async {
    return await repository.getStudentHealthProfile(studentId, schoolId);
  }
}

class UpdateStudentHealthProfile {
  final HealthRepository repository;
  UpdateStudentHealthProfile(this.repository);
  Future<Either<Failure, void>> call(
    StudentHealthProfile profile,
    String schoolId,
  ) async {
    return await repository.updateStudentHealthProfile(profile, schoolId);
  }
}

class GetClinicVisits {
  final HealthRepository repository;
  GetClinicVisits(this.repository);
  Future<Either<Failure, List<ClinicVisit>>> call({
    required String schoolId,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getClinicVisits(
      schoolId: schoolId,
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class RecordClinicVisit {
  final HealthRepository repository;
  RecordClinicVisit(this.repository);
  Future<Either<Failure, void>> call(ClinicVisit visit) async {
    return await repository.recordClinicVisit(visit);
  }
}

class GetEmergencyIncidents {
  final HealthRepository repository;
  GetEmergencyIncidents(this.repository);
  Future<Either<Failure, List<EmergencyIncident>>> call({
    required String schoolId,
    String? studentId,
  }) async {
    return await repository.getEmergencyIncidents(
      schoolId: schoolId,
      studentId: studentId,
    );
  }
}

class RecordEmergencyIncident {
  final HealthRepository repository;
  RecordEmergencyIncident(this.repository);
  Future<Either<Failure, void>> call(EmergencyIncident incident) async {
    return await repository.recordEmergencyIncident(incident);
  }
}

class GetMedicalInventory {
  final HealthRepository repository;
  GetMedicalInventory(this.repository);
  Future<Either<Failure, List<MedicalInventoryItem>>> call(
    String schoolId,
  ) async {
    return await repository.getMedicalInventory(schoolId);
  }
}

class UpdateInventoryItem {
  final HealthRepository repository;
  UpdateInventoryItem(this.repository);
  Future<Either<Failure, void>> call(MedicalInventoryItem item) async {
    return await repository.updateInventoryItem(item);
  }
}

class GetMedicalSupplyRequests {
  final HealthRepository repository;
  GetMedicalSupplyRequests(this.repository);
  Future<Either<Failure, List<MedicalSupplyRequest>>> call(
    String schoolId,
  ) async {
    return await repository.getMedicalSupplyRequests(schoolId);
  }
}

class CreateSupplyRequest {
  final HealthRepository repository;
  CreateSupplyRequest(this.repository);
  Future<Either<Failure, void>> call(MedicalSupplyRequest request) async {
    return await repository.createSupplyRequest(request);
  }
}

class UpdateSupplyRequestStatus {
  final HealthRepository repository;
  UpdateSupplyRequestStatus(this.repository);

  Future<Either<Failure, void>> call(
    String requestId,
    String schoolId,
    SupplyRequestStatus status, {
    String? reviewNotes,
    String? rejectionReason,
  }) {
    return repository.updateSupplyRequestStatus(
      requestId,
      schoolId,
      status,
      reviewNotes: reviewNotes,
      rejectionReason: rejectionReason,
    );
  }
}

class GetHealthAnalytics {
  final HealthRepository repository;
  GetHealthAnalytics(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getHealthAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
