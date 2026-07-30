import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/usecases/security_usecases.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final WatchGates watchGates;
  final CreateGate createGate;
  final RecordStudentMovement recordStudentMovement;
  final WatchStudentMovements watchStudentMovements;
  final ReportIncident reportIncident;
  final WatchIncidents watchIncidents;
  final TriggerEmergency triggerEmergency;
  final WatchActiveEmergencies watchActiveEmergencies;
  final RecordPatrol recordPatrol;
  final GetSecurityDashboardStats getSecurityDashboardStats;
  final ReportFoundItem reportFoundItem;
  final WatchLostAndFound watchLostAndFound;

  StreamSubscription? _gatesSubscription;
  StreamSubscription? _movementsSubscription;
  StreamSubscription? _incidentsSubscription;
  StreamSubscription? _emergenciesSubscription;
  StreamSubscription? _lostAndFoundSubscription;

  SecurityBloc({
    required this.watchGates,
    required this.createGate,
    required this.recordStudentMovement,
    required this.watchStudentMovements,
    required this.reportIncident,
    required this.watchIncidents,
    required this.triggerEmergency,
    required this.watchActiveEmergencies,
    required this.recordPatrol,
    required this.getSecurityDashboardStats,
    required this.reportFoundItem,
    required this.watchLostAndFound,
  }) : super(SecurityInitial()) {
    on<LoadSecurityDashboard>(_onLoadDashboard);
    on<WatchGatesRequested>(_onWatchGates);
    on<CreateGateRequested>(_onCreateGate);
    on<RecordStudentMovementRequested>(_onRecordStudentMovement);
    on<WatchStudentMovementsRequested>(_onWatchStudentMovements);
    on<ReportIncidentRequested>(_onReportIncident);
    on<WatchIncidentsRequested>(_onWatchIncidents);
    on<TriggerEmergencyRequested>(_onTriggerEmergency);
    on<WatchActiveEmergenciesRequested>(_onWatchActiveEmergencies);
    on<RecordPatrolRequested>(_onRecordPatrol);
    on<ReportFoundItemRequested>(_onReportFoundItem);
    on<WatchLostAndFoundRequested>(_onWatchLostAndFound);

    // Internal event handlers
    on<_GatesUpdated>(_onGatesUpdated);
    on<_MovementsUpdated>(_onMovementsUpdated);
    on<_IncidentsUpdated>(_onIncidentsUpdated);
    on<_EmergenciesUpdated>(_onEmergenciesUpdated);
    on<_LostAndFoundUpdated>(_onLostAndFoundUpdated);
  }

  Future<void> _onLoadDashboard(LoadSecurityDashboard event, Emitter<SecurityState> emit) async {
    emit(SecurityLoading());
    
    // Start watching everything for a unified real-time dashboard
    add(WatchGatesRequested());
    add(WatchStudentMovementsRequested(date: DateTime.now()));
    add(WatchIncidentsRequested());
    add(WatchActiveEmergenciesRequested());

    final statsResult = await getSecurityDashboardStats();
    
    statsResult.fold(
      (failure) => emit(SecurityError(failure.message)),
      (stats) => emit(SecurityDashboardLoaded(
        stats: stats,
        gates: const [],
        recentMovements: const [],
        activeIncidents: const [],
        activeEmergencies: const [],
      )),
    );
  }

  Future<void> _onWatchGates(WatchGatesRequested event, Emitter<SecurityState> emit) async {
    await _gatesSubscription?.cancel();
    _gatesSubscription = watchGates().listen(
      (gates) => add(_GatesUpdated(gates)),
      onError: (error) => emit(SecurityError(error.toString())),
    );
  }

  void _onGatesUpdated(_GatesUpdated event, Emitter<SecurityState> emit) {
    emit(GatesLoaded(event.gates));
  }

  Future<void> _onCreateGate(CreateGateRequested event, Emitter<SecurityState> emit) async {
    final result = await createGate(event.gate);
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(const SecurityActionSuccess('Gate created successfully')),
    );
  }

  Future<void> _onRecordStudentMovement(RecordStudentMovementRequested event, Emitter<SecurityState> emit) async {
    final result = await recordStudentMovement(event.movement);
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(const SecurityActionSuccess('Movement recorded')),
    );
  }

  Future<void> _onWatchStudentMovements(WatchStudentMovementsRequested event, Emitter<SecurityState> emit) async {
    await _movementsSubscription?.cancel();
    _movementsSubscription = watchStudentMovements(date: event.date, gateId: event.gateId).listen(
      (movements) => add(_MovementsUpdated(movements)),
    );
  }

  void _onMovementsUpdated(_MovementsUpdated event, Emitter<SecurityState> emit) {
    emit(StudentMovementsLoaded(event.movements));
  }

  Future<void> _onReportIncident(ReportIncidentRequested event, Emitter<SecurityState> emit) async {
    final result = await reportIncident(event.incident);
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(const SecurityActionSuccess('Incident reported')),
    );
  }

  Future<void> _onWatchIncidents(WatchIncidentsRequested event, Emitter<SecurityState> emit) async {
    await _incidentsSubscription?.cancel();
    _incidentsSubscription = watchIncidents().listen(
      (incidents) => add(_IncidentsUpdated(incidents)),
    );
  }

  void _onIncidentsUpdated(_IncidentsUpdated event, Emitter<SecurityState> emit) {
    emit(IncidentsLoaded(event.incidents));
  }

  Future<void> _onTriggerEmergency(TriggerEmergencyRequested event, Emitter<SecurityState> emit) async {
    final result = await triggerEmergency(event.event);
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(const SecurityActionSuccess('Emergency triggered')),
    );
  }

  Future<void> _onWatchActiveEmergencies(WatchActiveEmergenciesRequested event, Emitter<SecurityState> emit) async {
    await _emergenciesSubscription?.cancel();
    _emergenciesSubscription = watchActiveEmergencies().listen(
      (emergencies) => add(_EmergenciesUpdated(emergencies)),
    );
  }

  void _onEmergenciesUpdated(_EmergenciesUpdated event, Emitter<SecurityState> emit) {
    emit(ActiveEmergenciesLoaded(event.emergencies));
  }

  Future<void> _onRecordPatrol(RecordPatrolRequested event, Emitter<SecurityState> emit) async {
    final result = await recordPatrol(event.patrol);
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(const SecurityActionSuccess('Patrol recorded')),
    );
  }

  Future<void> _onReportFoundItem(ReportFoundItemRequested event, Emitter<SecurityState> emit) async {
    final result = await reportFoundItem(event.item);
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(const SecurityActionSuccess('Found item reported')),
    );
  }

  Future<void> _onWatchLostAndFound(WatchLostAndFoundRequested event, Emitter<SecurityState> emit) async {
    await _lostAndFoundSubscription?.cancel();
    _lostAndFoundSubscription = watchLostAndFound().listen(
      (items) => add(_LostAndFoundUpdated(items)),
    );
  }

  void _onLostAndFoundUpdated(_LostAndFoundUpdated event, Emitter<SecurityState> emit) {
    emit(LostAndFoundLoaded(event.items));
  }

  @override
  Future<void> close() {
    _gatesSubscription?.cancel();
    _movementsSubscription?.cancel();
    _incidentsSubscription?.cancel();
    _emergenciesSubscription?.cancel();
    _lostAndFoundSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _GatesUpdated extends SecurityEvent {
  final List<Gate> gates;
  const _GatesUpdated(this.gates);
}

class _MovementsUpdated extends SecurityEvent {
  final List<StudentMovement> movements;
  const _MovementsUpdated(this.movements);
}

class _IncidentsUpdated extends SecurityEvent {
  final List<SecurityIncident> incidents;
  const _IncidentsUpdated(this.incidents);
}

class _EmergenciesUpdated extends SecurityEvent {
  final List<EmergencyEvent> emergencies;
  const _EmergenciesUpdated(this.emergencies);
}

class _LostAndFoundUpdated extends SecurityEvent {
  final List<LostAndFoundItem> items;
  const _LostAndFoundUpdated(this.items);
}
