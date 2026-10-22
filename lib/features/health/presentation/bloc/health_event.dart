import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/emergency_incident.dart';
import '../../domain/entities/medical_inventory.dart';
import '../../domain/entities/medical_supply_request.dart';
import '../../domain/entities/student_health_profile.dart';

abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

class FetchHealthDashboardData extends HealthEvent {
  final String schoolId;
  const FetchHealthDashboardData(this.schoolId);

  @override
  List<Object> get props => [schoolId];
}

class FetchStudentHealthProfile extends HealthEvent {
  final String studentId;
  final String schoolId;
  const FetchStudentHealthProfile(this.studentId, this.schoolId);

  @override
  List<Object> get props => [studentId, schoolId];
}

class UpdateHealthProfile extends HealthEvent {
  final StudentHealthProfile profile;
  final String schoolId;
  const UpdateHealthProfile(this.profile, this.schoolId);

  @override
  List<Object> get props => [profile, schoolId];
}

class FetchClinicVisits extends HealthEvent {
  final String schoolId;
  final String? studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchClinicVisits({
    required this.schoolId,
    this.studentId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [schoolId, studentId, startDate, endDate];
}

class RecordNewClinicVisit extends HealthEvent {
  final ClinicVisit visit;
  const RecordNewClinicVisit(this.visit);

  @override
  List<Object> get props => [visit];
}

class FetchEmergencyIncidents extends HealthEvent {
  final String schoolId;
  final String? studentId;
  const FetchEmergencyIncidents({required this.schoolId, this.studentId});

  @override
  List<Object?> get props => [schoolId, studentId];
}

class RecordNewEmergencyIncident extends HealthEvent {
  final EmergencyIncident incident;
  const RecordNewEmergencyIncident(this.incident);

  @override
  List<Object> get props => [incident];
}

class FetchInventory extends HealthEvent {
  final String schoolId;
  const FetchInventory(this.schoolId);

  @override
  List<Object> get props => [schoolId];
}

class UpdateInventoryItemEvent extends HealthEvent {
  final MedicalInventoryItem item;
  const UpdateInventoryItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class DispenseMedicalItemEvent extends HealthEvent {
  final String itemId;
  final String visitId;
  final String studentId;
  final int quantity;
  final String schoolId;
  const DispenseMedicalItemEvent({
    required this.itemId,
    required this.visitId,
    required this.studentId,
    required this.quantity,
    required this.schoolId,
  });

  @override
  List<Object> get props => [itemId, visitId, studentId, quantity, schoolId];
}

class FetchSupplyRequests extends HealthEvent {
  final String schoolId;
  const FetchSupplyRequests(this.schoolId);

  @override
  List<Object> get props => [schoolId];
}

class CreateNewSupplyRequest extends HealthEvent {
  final MedicalSupplyRequest request;
  const CreateNewSupplyRequest(this.request);

  @override
  List<Object> get props => [request];
}
