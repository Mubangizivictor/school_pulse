import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/emergency_event.dart';
import 'gate_ops_local_data_source.dart';
import 'gate_ops_remote_data_source.dart';

GateOpsLocalDataSource create({dynamic isar, dynamic remote}) =>
    GateOpsLocalDataSourceWeb(remote as GateOpsRemoteDataSource);

/// No local database on web, no offline sync queue - watch* streams proxy
/// Firestore directly via the remote datasource, cache*/mark*Synced writes
/// go straight to Firestore (see GateOpsRepositoryImpl, which calls this
/// class's cache* methods then separately best-effort-pushes via
/// MovementSyncEngine on mobile - on web that push already happened
/// implicitly since watch* is live Firestore, so cache*/mark*Synced here
/// are no-ops), and getUnsynced* always returns empty since nothing is
/// ever queued on web.
class GateOpsLocalDataSourceWeb implements GateOpsLocalDataSource {
  final GateOpsRemoteDataSource remote;

  GateOpsLocalDataSourceWeb(this.remote);

  // Gates
  @override
  Future<void> cacheGates(List<Gate> gates) async {}
  @override
  Future<void> cacheGate(Gate gate) async {}
  @override
  Stream<List<Gate>> watchCachedGates(String schoolId) =>
      remote.watchGates(schoolId);

  // Movement events
  @override
  Future<void> cacheMovementEvent(MovementEvent event) async {}
  @override
  Stream<List<MovementEvent>> watchCachedMovementEvents(
    String schoolId, {
    String? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) {
    return remote.watchMovementEvents(
      schoolId,
      personType: personType == null
          ? null
          : PersonType.values.firstWhere((v) => v.name == personType),
      personId: personId,
      gateId: gateId,
      date: date,
    );
  }

  @override
  Future<List<MovementEvent>> getUnsyncedMovementEvents() async => [];
  @override
  Future<void> markMovementEventSynced(String eventId) async {}

  // Visitors
  @override
  Future<void> cacheVisitor(Visitor visitor) async {}
  @override
  Stream<List<Visitor>> watchCachedVisitors(String schoolId) =>
      remote.watchVisitors(schoolId);
  @override
  Future<List<Visitor>> getCachedVisitorsOnce(String schoolId) =>
      remote.getVisitorsOnce(schoolId);
  @override
  Future<Visitor?> getCachedVisitor(String visitorId) async => null;
  @override
  Future<List<Visitor>> getUnsyncedVisitors() async => [];
  @override
  Future<void> markVisitorSynced(String visitorId) async {}

  // Incidents
  @override
  Future<void> cacheIncident(SecurityIncident incident) async {}
  @override
  Future<List<SecurityIncident>> getUnsyncedIncidents() async => [];
  @override
  Future<void> markIncidentSynced(String incidentId) async {}

  // Emergencies
  @override
  Future<void> cacheEmergency(EmergencyEvent emergency) async {}
  @override
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId) =>
      remote.watchActiveEmergencies(schoolId);
  @override
  Future<EmergencyEvent?> getEmergency(String emergencyId) async => null;
  @override
  Future<List<EmergencyEvent>> getUnsyncedEmergencies() async => [];
  @override
  Future<void> markEmergencySynced(String emergencyId) async {}
}
