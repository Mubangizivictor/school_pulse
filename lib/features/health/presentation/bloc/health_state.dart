import 'package:equatable/equatable.dart';
import '../../../matron/domain/entities/boarding_entities.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/emergency_incident.dart';
import '../../domain/entities/medical_inventory.dart';
import '../../domain/entities/medical_supply_request.dart';
import '../../domain/entities/student_health_profile.dart';

abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthDashboardLoaded extends HealthState {
  final List<ClinicVisit> todayVisits;
  final List<EmergencyIncident> todayEmergencies;
  final List<MedicalInventoryItem> lowStockItems;
  final List<MedicalSupplyRequest> pendingRequests;
  final List<WelfareRecord> welfareRecords;
  final Map<String, dynamic> stats;
  final int chronicCaseCount;
  final int allergyCount;

  const HealthDashboardLoaded({
    required this.todayVisits,
    required this.todayEmergencies,
    required this.lowStockItems,
    required this.pendingRequests,
    required this.stats,
    this.welfareRecords = const [],
    this.chronicCaseCount = 0,
    this.allergyCount = 0,
  });

  @override
  List<Object?> get props => [
    todayVisits,
    todayEmergencies,
    lowStockItems,
    pendingRequests,
    stats,
    welfareRecords,
    chronicCaseCount,
    allergyCount,
  ];
}

class StudentHealthProfileLoaded extends HealthState {
  final StudentHealthProfile profile;
  final List<ClinicVisit> visitHistory;
  final List<EmergencyIncident> incidentHistory;

  const StudentHealthProfileLoaded({
    required this.profile,
    required this.visitHistory,
    required this.incidentHistory,
  });

  @override
  List<Object?> get props => [profile, visitHistory, incidentHistory];
}

class ClinicVisitsLoaded extends HealthState {
  final List<ClinicVisit> visits;
  final List<WelfareRecord> welfareRecords;
  const ClinicVisitsLoaded(this.visits, {this.welfareRecords = const []});

  @override
  List<Object?> get props => [visits, welfareRecords];
}

class EmergencyIncidentsLoaded extends HealthState {
  final List<EmergencyIncident> incidents;
  const EmergencyIncidentsLoaded(this.incidents);

  @override
  List<Object?> get props => [incidents];
}

typedef HealthLoaded = ClinicVisitsLoaded;

class InventoryLoaded extends HealthState {
  final List<MedicalInventoryItem> items;
  const InventoryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class SupplyRequestsLoaded extends HealthState {
  final List<MedicalSupplyRequest> requests;
  const SupplyRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class HealthActionSuccess extends HealthState {
  final String message;
  const HealthActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthError extends HealthState {
  final String message;
  const HealthError(this.message);

  @override
  List<Object?> get props => [message];
}
