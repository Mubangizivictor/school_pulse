import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/matron/domain/entities/boarding_entities.dart';
import '../../domain/usecases/health_usecases.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/medical_inventory.dart';
import '../../domain/entities/emergency_incident.dart';
import '../../domain/entities/medical_supply_request.dart';
import '../../domain/entities/student_health_profile.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final GetStudentHealthProfile getStudentHealthProfile;
  final UpdateStudentHealthProfile updateStudentHealthProfile;
  final GetAllHealthProfiles getAllHealthProfiles;
  final GetClinicVisits getClinicVisits;
  final RecordClinicVisit recordClinicVisit;
  final GetEmergencyIncidents getEmergencyIncidents;
  final RecordEmergencyIncident recordEmergencyIncident;
  final GetMedicalInventory getMedicalInventory;
  final UpdateInventoryItem updateInventoryItem;
  final DispenseMedicalItem dispenseMedicalItem;
  final GetMedicalSupplyRequests getMedicalSupplyRequests;
  final CreateSupplyRequest createSupplyRequest;
  final GetHealthAnalytics getHealthAnalytics;
  final StudentRepository studentRepository;

  HealthBloc({
    required this.getStudentHealthProfile,
    required this.updateStudentHealthProfile,
    required this.getAllHealthProfiles,
    required this.getClinicVisits,
    required this.recordClinicVisit,
    required this.getEmergencyIncidents,
    required this.recordEmergencyIncident,
    required this.getMedicalInventory,
    required this.updateInventoryItem,
    required this.dispenseMedicalItem,
    required this.getMedicalSupplyRequests,
    required this.createSupplyRequest,
    required this.getHealthAnalytics,
    required this.studentRepository,
  }) : super(HealthInitial()) {
    on<FetchHealthDashboardData>(_onFetchHealthDashboardData);
    on<FetchStudentHealthProfile>(_onFetchStudentHealthProfile);
    on<UpdateHealthProfile>(_onUpdateHealthProfile);
    on<FetchClinicVisits>(_onFetchClinicVisits);
    on<RecordNewClinicVisit>(_onRecordNewClinicVisit);
    on<FetchEmergencyIncidents>(_onFetchEmergencyIncidents);
    on<RecordNewEmergencyIncident>(_onRecordNewEmergencyIncident);
    on<FetchInventory>(_onFetchInventory);
    on<UpdateInventoryItemEvent>(_onUpdateInventoryItem);
    on<DispenseMedicalItemEvent>(_onDispenseMedicalItem);
    on<FetchSupplyRequests>(_onFetchSupplyRequests);
    on<CreateNewSupplyRequest>(_onCreateNewSupplyRequest);
  }

  Future<void> _onFetchHealthDashboardData(
    FetchHealthDashboardData event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final results = await Future.wait<dynamic>([
      getClinicVisits(schoolId: event.schoolId, startDate: startOfDay),
      getEmergencyIncidents(schoolId: event.schoolId),
      getMedicalInventory(event.schoolId),
      getMedicalSupplyRequests(event.schoolId),
      getHealthAnalytics(),
      studentRepository.getWelfareRecords(
        schoolId: event.schoolId,
        publicOnly: true,
      ),
      getAllHealthProfiles(event.schoolId),
    ]);
    final visitsResult = results[0];
    final incidentsResult = results[1];
    final inventoryResult = results[2];
    final requestsResult = results[3];
    final statsResult = results[4];
    final welfareResult = results[5];
    final profilesResult = results[6];

    if (visitsResult.isLeft()) {
      emit(const HealthError('Failed to fetch visits'));
      return;
    }
    if (inventoryResult.isLeft()) {
      emit(const HealthError('Failed to fetch inventory'));
      return;
    }
    if (incidentsResult.isLeft()) {
      emit(const HealthError('Failed to fetch emergencies'));
      return;
    }

    final visits = (visitsResult as Either<Failure, List<ClinicVisit>>).fold(
      (_) => <ClinicVisit>[],
      (value) => value,
    );
    final inventory =
        (inventoryResult as Either<Failure, List<MedicalInventoryItem>>).fold(
          (_) => <MedicalInventoryItem>[],
          (value) => value,
        );
    final incidents =
        (incidentsResult as Either<Failure, List<EmergencyIncident>>).fold(
          (_) => <EmergencyIncident>[],
          (value) => value,
        );
    final lowStock = inventory
        .where((item) => item.quantity <= item.reorderLevel)
        .toList();
    final todayEmergencies = incidents
        .where(
          (i) =>
              i.dateTime.year == today.year &&
              i.dateTime.month == today.month &&
              i.dateTime.day == today.day,
        )
        .toList();

    final welfareRecords = welfareResult.fold(
      (_) => <WelfareRecord>[],
      (records) => records.where((r) => !r.isPrivate).toList(),
    );
    final pendingRequests =
        (requestsResult as Either<Failure, List<MedicalSupplyRequest>>).fold(
          (_) => <MedicalSupplyRequest>[],
          (value) => value,
        );
    final stats = (statsResult as Either<Failure, Map<String, dynamic>>).fold(
      (_) => <String, dynamic>{},
      (value) => value,
    );
    final profiles =
        (profilesResult as Either<Failure, List<StudentHealthProfile>>).fold(
          (_) => <StudentHealthProfile>[],
          (value) => value,
        );
    final chronicCaseCount = profiles
        .where((p) => p.chronicIllnesses.isNotEmpty)
        .length;
    final allergyCount = profiles.where((p) => p.allergies.isNotEmpty).length;

    emit(
      HealthDashboardLoaded(
        todayVisits: visits,
        todayEmergencies: todayEmergencies,
        lowStockItems: lowStock,
        pendingRequests: pendingRequests,
        stats: stats,
        welfareRecords: welfareRecords,
        chronicCaseCount: chronicCaseCount,
        allergyCount: allergyCount,
      ),
    );
  }

  Future<void> _onFetchStudentHealthProfile(
    FetchStudentHealthProfile event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final profileResult = await getStudentHealthProfile(
      event.studentId,
      event.schoolId,
    );
    final visitsResult = await getClinicVisits(
      schoolId: event.schoolId,
      studentId: event.studentId,
    );
    final incidentsResult = await getEmergencyIncidents(
      schoolId: event.schoolId,
      studentId: event.studentId,
    );

    profileResult.fold(
      (failure) => emit(const HealthError('Failed to fetch profile')),
      (profile) {
        visitsResult.fold(
          (failure) => emit(const HealthError('Failed to fetch visit history')),
          (visits) {
            incidentsResult.fold(
              (failure) => emit(const HealthError('Failed to fetch incidents')),
              (incidents) => emit(
                StudentHealthProfileLoaded(
                  profile: profile,
                  visitHistory: visits,
                  incidentHistory: incidents,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onUpdateHealthProfile(
    UpdateHealthProfile event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await updateStudentHealthProfile(
      event.profile,
      event.schoolId,
    );
    result.fold(
      (failure) => emit(const HealthError('Failed to update profile')),
      (_) => add(
        FetchStudentHealthProfile(event.profile.studentId, event.schoolId),
      ),
    );
  }

  Future<void> _onFetchClinicVisits(
    FetchClinicVisits event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await getClinicVisits(
      schoolId: event.schoolId,
      studentId: event.studentId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    // Also fetch welfare records for parents/nurses to see dormitory health checks
    List<WelfareRecord> welfareRecords = [];
    if (event.studentId != null) {
      final welfareResult = await studentRepository.getWelfareRecords(
        schoolId: event.schoolId,
        studentId: event.studentId!,
        publicOnly: true,
      );
      welfareResult.fold(
        (_) => null,
        (records) =>
            welfareRecords = records.where((r) => !r.isPrivate).toList(),
      );
    }

    result.fold(
      (failure) => emit(const HealthError('Failed to fetch visits')),
      (visits) =>
          emit(ClinicVisitsLoaded(visits, welfareRecords: welfareRecords)),
    );
  }

  Future<void> _onRecordNewClinicVisit(
    RecordNewClinicVisit event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await recordClinicVisit(event.visit);

    result.fold(
      (failure) => emit(const HealthError('Failed to record visit')),
      (_) => emit(
        HealthActionSuccess(
          event.visit.outcome == VisitOutcome.sentHome
              ? 'Visit recorded. Student marked for health follow-up; enrollment was not changed.'
              : 'Visit recorded successfully',
        ),
      ),
    );
  }

  Future<void> _onFetchEmergencyIncidents(
    FetchEmergencyIncidents event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await getEmergencyIncidents(
      schoolId: event.schoolId,
      studentId: event.studentId,
    );
    result.fold(
      (failure) => emit(const HealthError('Failed to fetch incidents')),
      (incidents) => emit(EmergencyIncidentsLoaded(incidents)),
    );
  }

  Future<void> _onRecordNewEmergencyIncident(
    RecordNewEmergencyIncident event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await recordEmergencyIncident(event.incident);
    result.fold(
      (failure) => emit(const HealthError('Failed to record incident')),
      (_) => emit(const HealthActionSuccess('Incident recorded successfully')),
    );
  }

  Future<void> _onFetchInventory(
    FetchInventory event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await getMedicalInventory(event.schoolId);
    result.fold(
      (failure) => emit(const HealthError('Failed to fetch inventory')),
      (items) => emit(InventoryLoaded(items)),
    );
  }

  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItemEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await updateInventoryItem(event.item);
    result.fold(
      (failure) => emit(const HealthError('Failed to update item')),
      (_) => emit(const HealthActionSuccess('Inventory updated successfully')),
    );
  }

  Future<void> _onDispenseMedicalItem(
    DispenseMedicalItemEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await dispenseMedicalItem(
      itemId: event.itemId,
      visitId: event.visitId,
      studentId: event.studentId,
      quantity: event.quantity,
    );
    await result.fold((failure) async => emit(HealthError(failure.message)), (
      _,
    ) async {
      emit(const HealthActionSuccess('Item dispensed'));
      // Refresh stock so the nurse sees the decremented quantity.
      final refreshed = await getMedicalInventory(event.schoolId);
      refreshed.fold((_) {}, (items) => emit(InventoryLoaded(items)));
    });
  }

  Future<void> _onFetchSupplyRequests(
    FetchSupplyRequests event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await getMedicalSupplyRequests(event.schoolId);
    result.fold(
      (failure) => emit(const HealthError('Failed to fetch requests')),
      (requests) => emit(SupplyRequestsLoaded(requests)),
    );
  }

  Future<void> _onCreateNewSupplyRequest(
    CreateNewSupplyRequest event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());
    final result = await createSupplyRequest(event.request);
    result.fold(
      (failure) => emit(const HealthError('Failed to create request')),
      (_) => emit(const HealthActionSuccess('Request created successfully')),
    );
  }
}
