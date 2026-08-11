import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/emergency_event.dart';
import 'gate_ops_local_data_source.dart';

GateOpsLocalDataSource create({dynamic isar, dynamic remote}) =>
    _GateOpsLocalDataSourceStub();

class _GateOpsLocalDataSourceStub implements GateOpsLocalDataSource {
  @override
  Future<void> cacheGates(List<Gate> gates) => _unsupported();
  @override
  Future<void> cacheGate(Gate gate) => _unsupported();
  @override
  Stream<List<Gate>> watchCachedGates(String schoolId) =>
      _unsupportedStream();

  @override
  Future<void> cacheMovementEvent(MovementEvent event) => _unsupported();
  @override
  Stream<List<MovementEvent>> watchCachedMovementEvents(
    String schoolId, {
    String? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) => _unsupportedStream();
  @override
  Future<List<MovementEvent>> getUnsyncedMovementEvents() => _unsupported();
  @override
  Future<void> markMovementEventSynced(String eventId) => _unsupported();

  @override
  Future<void> cacheVisitor(Visitor visitor) => _unsupported();
  @override
  Stream<List<Visitor>> watchCachedVisitors(String schoolId) =>
      _unsupportedStream();
  @override
  Future<List<Visitor>> getCachedVisitorsOnce(String schoolId) =>
      _unsupported();
  @override
  Future<Visitor?> getCachedVisitor(String visitorId) => _unsupported();
  @override
  Future<List<Visitor>> getUnsyncedVisitors() => _unsupported();
  @override
  Future<void> markVisitorSynced(String visitorId) => _unsupported();

  @override
  Future<void> cacheIncident(SecurityIncident incident) => _unsupported();
  @override
  Future<List<SecurityIncident>> getUnsyncedIncidents() => _unsupported();
  @override
  Future<void> markIncidentSynced(String incidentId) => _unsupported();

  @override
  Future<void> cacheEmergency(EmergencyEvent emergency) => _unsupported();
  @override
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId) =>
      _unsupportedStream();
  @override
  Future<EmergencyEvent?> getEmergency(String emergencyId) => _unsupported();
  @override
  Future<List<EmergencyEvent>> getUnsyncedEmergencies() => _unsupported();
  @override
  Future<void> markEmergencySynced(String emergencyId) => _unsupported();

  Never _unsupported() =>
      throw UnimplementedError('No GateOpsLocalDataSource for this platform');
  Stream<Never> _unsupportedStream() =>
      Stream.error(UnimplementedError('No GateOpsLocalDataSource for this platform'));
}
