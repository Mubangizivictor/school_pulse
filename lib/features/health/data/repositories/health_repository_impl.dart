import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/emergency_incident.dart';
import '../../domain/entities/medical_inventory.dart';
import '../../domain/entities/medical_supply_request.dart';
import '../../domain/entities/student_health_profile.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';
import '../models/clinic_visit_model.dart';
import '../models/emergency_incident_model.dart';
import '../models/medical_inventory_model.dart';
import '../models/medical_supply_request_model.dart';
import '../models/student_health_profile_model.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StudentHealthProfile>> getStudentHealthProfile(
    String studentId,
    String schoolId,
  ) async {
    try {
      final profile = await remoteDataSource.getStudentHealthProfile(
        studentId,
        schoolId,
      );
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentHealthProfile(
    StudentHealthProfile profile,
    String schoolId,
  ) async {
    try {
      final model = StudentHealthProfileModel(
        studentId: profile.studentId,
        schoolId: schoolId,
        bloodGroup: profile.bloodGroup,
        rhesusFactor: profile.rhesusFactor,
        height: profile.height,
        weight: profile.weight,
        bmi: profile.bmi,
        allergies: profile.allergies,
        chronicIllnesses: profile.chronicIllnesses,
        disabilities: profile.disabilities,
        specialMedicalNeeds: profile.specialMedicalNeeds,
        medicalNotes: profile.medicalNotes,
        currentMedications: profile.currentMedications,
        emergencyContactName: profile.emergencyContactName,
        emergencyContactPhone: profile.emergencyContactPhone,
        familyDoctorName: profile.familyDoctorName,
        familyDoctorPhone: profile.familyDoctorPhone,
        hospitalPreference: profile.hospitalPreference,
        insuranceInformation: profile.insuranceInformation,
        vaccinationHistory: profile.vaccinationHistory
            .map(
              (e) => VaccinationRecordModel(
                id: e.id,
                vaccineName: e.vaccineName,
                dateAdministered: e.dateAdministered,
                nextDueDate: e.nextDueDate,
                healthProvider: e.healthProvider,
                certificateUrl: e.certificateUrl,
              ),
            )
            .toList(),
        medicalRestrictions: profile.medicalRestrictions,
        dietaryRestrictions: profile.dietaryRestrictions,
        physicalActivityRestrictions: profile.physicalActivityRestrictions,
      );
      await remoteDataSource.updateStudentHealthProfile(model, schoolId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ClinicVisit>>> getClinicVisits({
    required String schoolId,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final visits = await remoteDataSource.getClinicVisits(
        schoolId: schoolId,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(visits);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> recordClinicVisit(ClinicVisit visit) async {
    try {
      final model = ClinicVisitModel(
        id: visit.id,
        studentId: visit.studentId,
        staffId: visit.staffId,
        dateTime: visit.dateTime,
        reason: visit.reason,
        symptoms: visit.symptoms,
        temperature: visit.temperature,
        bloodPressure: visit.bloodPressure,
        pulseRate: visit.pulseRate,
        oxygenSaturation: visit.oxygenSaturation,
        weight: visit.weight,
        diagnosis: visit.diagnosis,
        treatmentProvided: visit.treatmentProvided,
        medicationsGiven: visit.medicationsGiven
            .map(
              (e) => AdministeredMedicationModel(
                medicationId: e.medicationId,
                medicationName: e.medicationName,
                dosage: e.dosage,
                quantity: e.quantity,
                timeAdministered: e.timeAdministered,
                administeredBy: e.administeredBy,
                notes: e.notes,
              ),
            )
            .toList(),
        observationNotes: visit.observationNotes,
        followUpRequired: visit.followUpRequired,
        outcome: visit.outcome,
        recordedBy: visit.recordedBy,
        schoolId: visit.schoolId,
      );
      await remoteDataSource.recordClinicVisit(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<EmergencyIncident>>> getEmergencyIncidents({
    required String schoolId,
    String? studentId,
  }) async {
    try {
      final incidents = await remoteDataSource.getEmergencyIncidents(
        schoolId: schoolId,
        studentId: studentId,
      );
      return Right(incidents);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> recordEmergencyIncident(
    EmergencyIncident incident,
  ) async {
    try {
      final model = EmergencyIncidentModel(
        id: incident.id,
        studentId: incident.studentId,
        staffId: incident.staffId,
        dateTime: incident.dateTime,
        incidentDetails: incident.incidentDetails,
        firstAidGiven: incident.firstAidGiven,
        ambulanceRequired: incident.ambulanceRequired,
        hospitalReferral: incident.hospitalReferral,
        parentNotified: incident.parentNotified,
        staffInvolved: incident.staffInvolved,
        witnesses: incident.witnesses,
        outcome: incident.outcome,
        recordedBy: incident.recordedBy,
        schoolId: incident.schoolId,
      );
      await remoteDataSource.recordEmergencyIncident(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MedicalInventoryItem>>> getMedicalInventory(
    String schoolId,
  ) async {
    try {
      final items = await remoteDataSource.getMedicalInventory(schoolId);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateInventoryItem(
    MedicalInventoryItem item,
  ) async {
    try {
      final model = MedicalInventoryItemModel(
        id: item.id,
        name: item.name,
        type: item.type,
        category: item.category,
        quantity: item.quantity,
        unit: item.unit,
        reorderLevel: item.reorderLevel,
        supplier: item.supplier,
        purchaseDate: item.purchaseDate,
        expiryDate: item.expiryDate,
        batchNumber: item.batchNumber,
        schoolId: item.schoolId,
      );
      await remoteDataSource.updateInventoryItem(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MedicalSupplyRequest>>> getMedicalSupplyRequests(
    String schoolId,
  ) async {
    try {
      final requests = await remoteDataSource.getMedicalSupplyRequests(
        schoolId,
      );
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createSupplyRequest(
    MedicalSupplyRequest request,
  ) async {
    try {
      final model = MedicalSupplyRequestModel(
        id: request.id,
        itemName: request.itemName,
        quantity: request.quantity,
        unit: request.unit,
        requestedBy: request.requestedBy,
        requestDate: request.requestDate,
        status: request.status,
        bursaReviewNotes: request.bursaReviewNotes,
        rejectionReason: request.rejectionReason,
        schoolId: request.schoolId,
      );
      await remoteDataSource.createSupplyRequest(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplyRequestStatus(
    String requestId,
    String schoolId,
    SupplyRequestStatus status, {
    String? reviewNotes,
    String? rejectionReason,
  }) async {
    try {
      await remoteDataSource.updateSupplyRequestStatus(
        requestId,
        schoolId,
        status.toString(),
        reviewNotes: reviewNotes,
        rejectionReason: rejectionReason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHealthAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // This could be a specialized remote data source call or calculated here if we fetch all data
    try {
      // For now, let's just return a placeholder or implement basic analytics
      // In a real app, this would probably be a Cloud Function or a specific API endpoint
      return const Right({});
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
