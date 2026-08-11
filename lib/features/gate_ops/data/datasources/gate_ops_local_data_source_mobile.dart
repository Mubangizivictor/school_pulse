import 'package:isar/isar.dart';
import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/emergency_event.dart';
import '../models/gate_ops_isar_models.dart';
import 'gate_ops_local_data_source.dart';

GateOpsLocalDataSource create({dynamic isar, dynamic remote}) =>
    GateOpsLocalDataSourceImpl(isar as Isar);

class GateOpsLocalDataSourceImpl implements GateOpsLocalDataSource {
  final Isar isar;

  GateOpsLocalDataSourceImpl(this.isar);

  // Gates

  @override
  Future<void> cacheGates(List<Gate> gates) async {
    await isar.writeTxn(() async {
      await isar.gateIsars.putAll(gates.map(GateIsar.fromEntity).toList());
    });
  }

  @override
  Future<void> cacheGate(Gate gate) async {
    await isar.writeTxn(() async {
      await isar.gateIsars.put(GateIsar.fromEntity(gate));
    });
  }

  @override
  Stream<List<Gate>> watchCachedGates(String schoolId) {
    return isar.gateIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .watch(fireImmediately: true)
        .map((cached) => cached.map((c) => c.toEntity()).toList());
  }

  // Movement events

  @override
  Future<void> cacheMovementEvent(MovementEvent event) async {
    await isar.writeTxn(() async {
      await isar.movementEventIsars.put(MovementEventIsar.fromEntity(event));
    });
  }

  @override
  Stream<List<MovementEvent>> watchCachedMovementEvents(
    String schoolId, {
    String? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) {
    var query = isar.movementEventIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .optional(personType != null, (q) => q.personTypeEqualTo(personType!))
        .optional(personId != null, (q) => q.personIdEqualTo(personId!))
        .optional(gateId != null, (q) => q.gateIdEqualTo(gateId!));

    Stream<List<MovementEventIsar>> stream;
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      stream = query
          .actionTimestampBetween(start, end)
          .sortByActionTimestampDesc()
          .watch(fireImmediately: true);
    } else {
      stream = query.sortByActionTimestampDesc().watch(fireImmediately: true);
    }
    return stream.map((cached) => cached.map((c) => c.toEntity()).toList());
  }

  @override
  Future<List<MovementEvent>> getUnsyncedMovementEvents() async {
    final cached = await isar.movementEventIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> markMovementEventSynced(String eventId) async {
    await isar.writeTxn(() async {
      final event = await isar.movementEventIsars
          .filter()
          .eventIdEqualTo(eventId)
          .findFirst();
      if (event != null) {
        event.syncStatus = 'synced';
        event.serverTimestamp = DateTime.now();
        await isar.movementEventIsars.put(event);
      }
    });
  }

  // Visitors

  @override
  Future<void> cacheVisitor(Visitor visitor) async {
    await isar.writeTxn(() async {
      await isar.visitorIsars.put(VisitorIsar.fromEntity(visitor));
    });
  }

  @override
  Stream<List<Visitor>> watchCachedVisitors(String schoolId) {
    return isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByArrivalTimeDesc()
        .watch(fireImmediately: true)
        .map((cached) => cached.map((c) => c.toEntity()).toList());
  }

  @override
  Future<List<Visitor>> getCachedVisitorsOnce(String schoolId) async {
    final cached = await isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<Visitor?> getCachedVisitor(String visitorId) async {
    final cached = await isar.visitorIsars
        .filter()
        .visitorIdEqualTo(visitorId)
        .findFirst();
    return cached?.toEntity();
  }

  @override
  Future<List<Visitor>> getUnsyncedVisitors() async {
    final cached = await isar.visitorIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> markVisitorSynced(String visitorId) async {
    await isar.writeTxn(() async {
      final visitor = await isar.visitorIsars
          .filter()
          .visitorIdEqualTo(visitorId)
          .findFirst();
      if (visitor != null) {
        visitor.syncStatus = 'synced';
        await isar.visitorIsars.put(visitor);
      }
    });
  }

  // Incidents

  @override
  Future<void> cacheIncident(SecurityIncident incident) async {
    await isar.writeTxn(() async {
      await isar.securityIncidentIsars.put(
        SecurityIncidentIsar.fromEntity(incident),
      );
    });
  }

  @override
  Future<List<SecurityIncident>> getUnsyncedIncidents() async {
    final cached = await isar.securityIncidentIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> markIncidentSynced(String incidentId) async {
    await isar.writeTxn(() async {
      final incident = await isar.securityIncidentIsars
          .filter()
          .incidentIdEqualTo(incidentId)
          .findFirst();
      if (incident != null) {
        incident.syncStatus = 'synced';
        await isar.securityIncidentIsars.put(incident);
      }
    });
  }

  // Emergencies

  @override
  Future<void> cacheEmergency(EmergencyEvent emergency) async {
    await isar.writeTxn(() async {
      await isar.emergencyEventIsars.put(
        EmergencyEventIsar.fromEntity(emergency),
      );
    });
  }

  @override
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId) {
    return isar.emergencyEventIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo('Active')
        .watch(fireImmediately: true)
        .map((cached) => cached.map((c) => c.toEntity()).toList());
  }

  @override
  Future<EmergencyEvent?> getEmergency(String emergencyId) async {
    final cached = await isar.emergencyEventIsars
        .filter()
        .eventIdEqualTo(emergencyId)
        .findFirst();
    return cached?.toEntity();
  }

  @override
  Future<List<EmergencyEvent>> getUnsyncedEmergencies() async {
    final cached = await isar.emergencyEventIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> markEmergencySynced(String emergencyId) async {
    await isar.writeTxn(() async {
      final emergency = await isar.emergencyEventIsars
          .filter()
          .eventIdEqualTo(emergencyId)
          .findFirst();
      if (emergency != null) {
        emergency.syncStatus = 'synced';
        await isar.emergencyEventIsars.put(emergency);
      }
    });
  }
}
