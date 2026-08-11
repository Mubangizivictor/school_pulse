import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/emergency_event.dart';

/// No Isar/isar-model import here on purpose - see
/// gate_ops_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// gate_ops_local_data_source_factory.dart's conditional import.
///
/// Mobile is offline-first: every write lands here immediately (the sync
/// queue), then GateOpsRepositoryImpl best-effort-pushes to Firestore. Web
/// has no offline queue - writes go straight to Firestore via
/// GateOpsRemoteDataSource, and this web-side cache exists only to satisfy
/// the same interface: watch* streams proxy Firestore directly, and
/// getUnsynced*/mark*Synced are no-ops/empty since nothing is ever pending.
abstract class GateOpsLocalDataSource {
  // Gates
  Future<void> cacheGates(List<Gate> gates);
  Future<void> cacheGate(Gate gate);
  Stream<List<Gate>> watchCachedGates(String schoolId);

  // Movement events
  Future<void> cacheMovementEvent(MovementEvent event);
  Stream<List<MovementEvent>> watchCachedMovementEvents(
    String schoolId, {
    String? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  });
  Future<List<MovementEvent>> getUnsyncedMovementEvents();
  Future<void> markMovementEventSynced(String eventId);

  // Visitors
  Future<void> cacheVisitor(Visitor visitor);
  Stream<List<Visitor>> watchCachedVisitors(String schoolId);
  Future<List<Visitor>> getCachedVisitorsOnce(String schoolId);
  Future<Visitor?> getCachedVisitor(String visitorId);
  Future<List<Visitor>> getUnsyncedVisitors();
  Future<void> markVisitorSynced(String visitorId);

  // Incidents
  Future<void> cacheIncident(SecurityIncident incident);
  Future<List<SecurityIncident>> getUnsyncedIncidents();
  Future<void> markIncidentSynced(String incidentId);

  // Emergencies
  Future<void> cacheEmergency(EmergencyEvent emergency);
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId);
  Future<EmergencyEvent?> getEmergency(String emergencyId);
  Future<List<EmergencyEvent>> getUnsyncedEmergencies();
  Future<void> markEmergencySynced(String emergencyId);
}
