import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/security_entities.dart';
import '../../domain/usecases/security_usecases.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final WatchGates watchGates;
  final CreateGate createGate;
  final UpdateGate updateGate;
  final RecordStudentMovement recordStudentMovement;
  final WatchStudentMovements watchStudentMovements;
  final RecordStaffMovement recordStaffMovement;
  final WatchStaffMovements watchStaffMovements;
  final ReportIncident reportIncident;
  final WatchIncidents watchIncidents;
  final UpdateIncidentStatus updateIncidentStatus;
  final TriggerEmergency triggerEmergency;
  final WatchActiveEmergencies watchActiveEmergencies;
  final ResolveEmergency resolveEmergency;
  final RecordPatrol recordPatrol;
  final WatchPatrols watchPatrols;
  final GetSecurityDashboardStats getSecurityDashboardStats;
  final ReportFoundItem reportFoundItem;
  final ClaimItem claimItem;
  final WatchLostAndFound watchLostAndFound;

  StreamSubscription? _gatesSubscription;
  StreamSubscription? _studentMovementsSubscription;
  StreamSubscription? _staffMovementsSubscription;
  StreamSubscription? _incidentsSubscription;
  StreamSubscription? _emergenciesSubscription;
  StreamSubscription? _patrolsSubscription;
  StreamSubscription? _lostAndFoundSubscription;

  SecurityBloc({
    required this.watchGates,
    required this.createGate,
    required this.updateGate,
    required this.recordStudentMovement,
    required this.watchStudentMovements,
    required this.recordStaffMovement,
    required this.watchStaffMovements,
    required this.reportIncident,
    required this.watchIncidents,
    required this.updateIncidentStatus,
    required this.triggerEmergency,
    required this.watchActiveEmergencies,
    required this.resolveEmergency,
    required this.recordPatrol,
    required this.watchPatrols,
    required this.getSecurityDashboardStats,
    required this.reportFoundItem,
    required this.claimItem,
    required this.watchLostAndFound,
  }) : super(const SecurityState()) {
    on<LoadSecurityDashboard>(_onLoadDashboard);
    on<WatchGatesRequested>(_onWatchGates);
    on<CreateGateRequested>(_onCreateGate);
    on<UpdateGateRequested>(_onUpdateGate);
    on<RecordStudentMovementRequested>(_onRecordStudentMovement);
    on<WatchStudentMovementsRequested>(_onWatchStudentMovements);
    on<RecordStaffMovementRequested>(_onRecordStaffMovement);
    on<WatchStaffMovementsRequested>(_onWatchStaffMovements);
    on<ReportIncidentRequested>(_onReportIncident);
    on<WatchIncidentsRequested>(_onWatchIncidents);
    on<UpdateIncidentStatusRequested>(_onUpdateIncidentStatus);
    on<TriggerEmergencyRequested>(_onTriggerEmergency);
    on<WatchActiveEmergenciesRequested>(_onWatchActiveEmergencies);
    on<ResolveEmergencyRequested>(_onResolveEmergency);
    on<RecordPatrolRequested>(_onRecordPatrol);
    on<WatchPatrolsRequested>(_onWatchPatrols);
    on<ReportFoundItemRequested>(_onReportFoundItem);
    on<ClaimItemRequested>(_onClaimItem);
    on<WatchLostAndFoundRequested>(_onWatchLostAndFound);

    // Internal event handlers - registered once here, never inside another
    // handler (Bloc throws on duplicate `on<Event>` registration).
    on<_GatesUpdated>((e, emit) => emit(state.copyWith(gates: e.gates)));
    on<_StudentMovementsUpdated>((e, emit) => emit(state.copyWith(studentMovements: e.movements)));
    on<_StaffMovementsUpdated>((e, emit) => emit(state.copyWith(staffMovements: e.movements)));
    on<_IncidentsUpdated>((e, emit) => emit(state.copyWith(incidents: e.incidents)));
    on<_EmergenciesUpdated>((e, emit) => emit(state.copyWith(activeEmergencies: e.emergencies)));
    on<_PatrolsUpdated>((e, emit) => emit(state.copyWith(patrols: e.patrols)));
    on<_LostAndFoundUpdated>((e, emit) => emit(state.copyWith(lostAndFound: e.items)));
  }

  Future<void> _onLoadDashboard(LoadSecurityDashboard event, Emitter<SecurityState> emit) async {
    emit(state.copyWith(status: SecurityStatus.loading));

    add(WatchGatesRequested(event.schoolId));
    add(WatchStudentMovementsRequested(event.schoolId, date: DateTime.now()));
    add(WatchIncidentsRequested(event.schoolId));
    add(WatchActiveEmergenciesRequested(event.schoolId));

    final statsResult = await getSecurityDashboardStats(event.schoolId);

    statsResult.fold(
      (failure) => emit(state.copyWith(status: SecurityStatus.error, errorMessage: failure.message)),
      (stats) => emit(state.copyWith(status: SecurityStatus.loaded, stats: stats)),
    );
  }

  Future<void> _onWatchGates(WatchGatesRequested event, Emitter<SecurityState> emit) async {
    await _gatesSubscription?.cancel();
    _gatesSubscription = watchGates(event.schoolId).listen(
      (gates) => add(_GatesUpdated(gates)),
    );
  }

  Future<void> _onCreateGate(CreateGateRequested event, Emitter<SecurityState> emit) async {
    final result = await createGate(event.gate);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) {
        emit(state.copyWith(feedback: SecurityFeedback('Gate created successfully')));
        di.sl<AuditRepository>().logAction(
              title: 'Gate created',
              description: '${event.gate.name} (${event.gate.type}) was added to the security structure.',
              iconName: 'door_front_door',
              colorHex: '#2196F3',
            );
      },
    );
  }

  Future<void> _onUpdateGate(UpdateGateRequested event, Emitter<SecurityState> emit) async {
    final result = await updateGate(event.gate);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) {
        emit(state.copyWith(feedback: SecurityFeedback('Gate updated successfully')));
        di.sl<AuditRepository>().logAction(
              title: 'Gate updated',
              description: '${event.gate.name} configuration was changed.',
              iconName: 'door_front_door',
              colorHex: '#2196F3',
            );
      },
    );
  }

  Future<void> _onRecordStudentMovement(RecordStudentMovementRequested event, Emitter<SecurityState> emit) async {
    final result = await recordStudentMovement(event.movement);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) => emit(state.copyWith(feedback: SecurityFeedback('Movement recorded'))),
    );
  }

  Future<void> _onWatchStudentMovements(WatchStudentMovementsRequested event, Emitter<SecurityState> emit) async {
    await _studentMovementsSubscription?.cancel();
    _studentMovementsSubscription = watchStudentMovements(event.schoolId, date: event.date, gateId: event.gateId, studentId: event.studentId).listen(
      (movements) => add(_StudentMovementsUpdated(movements)),
    );
  }

  Future<void> _onRecordStaffMovement(RecordStaffMovementRequested event, Emitter<SecurityState> emit) async {
    final result = await recordStaffMovement(event.movement);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) => emit(state.copyWith(feedback: SecurityFeedback('Staff movement recorded'))),
    );
  }

  Future<void> _onWatchStaffMovements(WatchStaffMovementsRequested event, Emitter<SecurityState> emit) async {
    await _staffMovementsSubscription?.cancel();
    _staffMovementsSubscription = watchStaffMovements(event.schoolId, date: event.date, gateId: event.gateId).listen(
      (movements) => add(_StaffMovementsUpdated(movements)),
    );
  }

  Future<void> _onReportIncident(ReportIncidentRequested event, Emitter<SecurityState> emit) async {
    final result = await reportIncident(event.incident);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) {
        emit(state.copyWith(feedback: SecurityFeedback('Incident reported')));
        di.sl<AuditRepository>().logAction(
              title: 'Security incident reported',
              description: '${event.incident.type} at ${event.incident.location}: ${event.incident.description}',
              iconName: 'gavel',
              colorHex: '#FF9800',
              userId: event.incident.reportedByOfficerId,
            );
      },
    );
  }

  Future<void> _onWatchIncidents(WatchIncidentsRequested event, Emitter<SecurityState> emit) async {
    await _incidentsSubscription?.cancel();
    _incidentsSubscription = watchIncidents(event.schoolId).listen(
      (incidents) => add(_IncidentsUpdated(incidents)),
    );
  }

  Future<void> _onUpdateIncidentStatus(UpdateIncidentStatusRequested event, Emitter<SecurityState> emit) async {
    final result = await updateIncidentStatus(event.schoolId, event.incidentId, event.status, event.resolution);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) => emit(state.copyWith(feedback: SecurityFeedback('Incident updated'))),
    );
  }

  Future<void> _onTriggerEmergency(TriggerEmergencyRequested event, Emitter<SecurityState> emit) async {
    final result = await triggerEmergency(event.event);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) {
        emit(state.copyWith(feedback: SecurityFeedback('Emergency triggered')));
        NotificationService().sendSecurityAlert(
          title: event.event.type,
          body: event.event.description.isNotEmpty ? event.event.description : 'Emergency alert triggered - respond immediately.',
        );
        di.sl<AuditRepository>().logAction(
              title: 'EMERGENCY: ${event.event.type}',
              description: event.event.description.isEmpty ? 'No description provided.' : event.event.description,
              iconName: 'emergency',
              colorHex: '#F44336',
            );
      },
    );
  }

  Future<void> _onWatchActiveEmergencies(WatchActiveEmergenciesRequested event, Emitter<SecurityState> emit) async {
    await _emergenciesSubscription?.cancel();
    _emergenciesSubscription = watchActiveEmergencies(event.schoolId).listen(
      (emergencies) => add(_EmergenciesUpdated(emergencies)),
    );
  }

  Future<void> _onResolveEmergency(ResolveEmergencyRequested event, Emitter<SecurityState> emit) async {
    final result = await resolveEmergency(event.schoolId, event.emergencyId, event.endTime, event.actions);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) {
        emit(state.copyWith(feedback: SecurityFeedback('Emergency resolved')));
        di.sl<AuditRepository>().logAction(
              title: 'Emergency resolved',
              description: 'Response actions: ${event.actions.isEmpty ? 'none recorded' : event.actions.join('; ')}',
              iconName: 'emergency',
              colorHex: '#4CAF50',
            );
      },
    );
  }

  Future<void> _onRecordPatrol(RecordPatrolRequested event, Emitter<SecurityState> emit) async {
    final result = await recordPatrol(event.patrol);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) => emit(state.copyWith(feedback: SecurityFeedback('Patrol recorded'))),
    );
  }

  Future<void> _onWatchPatrols(WatchPatrolsRequested event, Emitter<SecurityState> emit) async {
    await _patrolsSubscription?.cancel();
    _patrolsSubscription = watchPatrols(event.schoolId).listen(
      (patrols) => add(_PatrolsUpdated(patrols)),
    );
  }

  Future<void> _onReportFoundItem(ReportFoundItemRequested event, Emitter<SecurityState> emit) async {
    final result = await reportFoundItem(event.item);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) => emit(state.copyWith(feedback: SecurityFeedback('Found item reported'))),
    );
  }

  Future<void> _onClaimItem(ClaimItemRequested event, Emitter<SecurityState> emit) async {
    final result = await claimItem(event.schoolId, event.itemId, event.claimDetails);
    result.fold(
      (failure) => emit(state.copyWith(feedback: SecurityFeedback(failure.message, isError: true))),
      (_) => emit(state.copyWith(feedback: SecurityFeedback('Item claimed'))),
    );
  }

  Future<void> _onWatchLostAndFound(WatchLostAndFoundRequested event, Emitter<SecurityState> emit) async {
    await _lostAndFoundSubscription?.cancel();
    _lostAndFoundSubscription = watchLostAndFound(event.schoolId).listen(
      (items) => add(_LostAndFoundUpdated(items)),
    );
  }

  @override
  Future<void> close() {
    _gatesSubscription?.cancel();
    _studentMovementsSubscription?.cancel();
    _staffMovementsSubscription?.cancel();
    _incidentsSubscription?.cancel();
    _emergenciesSubscription?.cancel();
    _patrolsSubscription?.cancel();
    _lostAndFoundSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _GatesUpdated extends SecurityEvent {
  final List<Gate> gates;
  const _GatesUpdated(this.gates);
}

class _StudentMovementsUpdated extends SecurityEvent {
  final List<StudentMovement> movements;
  const _StudentMovementsUpdated(this.movements);
}

class _StaffMovementsUpdated extends SecurityEvent {
  final List<StaffMovement> movements;
  const _StaffMovementsUpdated(this.movements);
}

class _IncidentsUpdated extends SecurityEvent {
  final List<SecurityIncident> incidents;
  const _IncidentsUpdated(this.incidents);
}

class _EmergenciesUpdated extends SecurityEvent {
  final List<EmergencyEvent> emergencies;
  const _EmergenciesUpdated(this.emergencies);
}

class _PatrolsUpdated extends SecurityEvent {
  final List<SecurityPatrol> patrols;
  const _PatrolsUpdated(this.patrols);
}

class _LostAndFoundUpdated extends SecurityEvent {
  final List<LostAndFoundItem> items;
  const _LostAndFoundUpdated(this.items);
}
