import 'package:isar/isar.dart';
import '../models/gate_ops_isar_models.dart';

abstract class GateOpsLocalDataSource {
  // Gates
  Future<void> cacheGates(List<GateIsar> gates);
  Future<void> cacheGate(GateIsar gate);
  Stream<List<GateIsar>> watchCachedGates(String schoolId);

  // Movement events
  Future<void> cacheMovementEvent(MovementEventIsar event);
  Stream<List<MovementEventIsar>> watchCachedMovementEvents(
    String schoolId, {
    String? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  });
  Future<List<MovementEventIsar>> getUnsyncedMovementEvents();
  Future<void> markMovementEventSynced(String eventId);

  // Visitors
  Future<void> cacheVisitor(VisitorIsar visitor);
  Stream<List<VisitorIsar>> watchCachedVisitors(String schoolId);
  Future<List<VisitorIsar>> getCachedVisitorsOnce(String schoolId);
  Future<VisitorIsar?> getCachedVisitor(String visitorId);
  Future<List<VisitorIsar>> getUnsyncedVisitors();
  Future<void> markVisitorSynced(String visitorId);

  // Incidents
  Future<void> cacheIncident(SecurityIncidentIsar incident);
  Future<List<SecurityIncidentIsar>> getUnsyncedIncidents();
  Future<void> markIncidentSynced(String incidentId);

  // Emergencies
  Future<void> cacheEmergency(EmergencyEventIsar emergency);
  Stream<List<EmergencyEventIsar>> watchActiveEmergencies(String schoolId);
  Future<EmergencyEventIsar?> getEmergency(String emergencyId);
  Future<List<EmergencyEventIsar>> getUnsyncedEmergencies();
  Future<void> markEmergencySynced(String emergencyId);
}

class GateOpsLocalDataSourceImpl implements GateOpsLocalDataSource {
  final Isar isar;

  GateOpsLocalDataSourceImpl(this.isar);

  // Gates

  @override
  Future<void> cacheGates(List<GateIsar> gates) async {
    await isar.writeTxn(() async {
      await isar.gateIsars.putAll(gates);
    });
  }

  @override
  Future<void> cacheGate(GateIsar gate) async {
    await isar.writeTxn(() async {
      await isar.gateIsars.put(gate);
    });
  }

  @override
  Stream<List<GateIsar>> watchCachedGates(String schoolId) {
    return isar.gateIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .watch(fireImmediately: true);
  }

  // Movement events

  @override
  Future<void> cacheMovementEvent(MovementEventIsar event) async {
    await isar.writeTxn(() async {
      await isar.movementEventIsars.put(event);
    });
  }

  @override
  Stream<List<MovementEventIsar>> watchCachedMovementEvents(
    String schoolId, {
    String? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) {
    var query = isar.movementEventIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .optional(
          personType != null,
          (q) => q.personTypeEqualTo(personType!),
        )
        .optional(personId != null, (q) => q.personIdEqualTo(personId!))
        .optional(gateId != null, (q) => q.gateIdEqualTo(gateId!));

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      return query
          .actionTimestampBetween(start, end)
          .sortByActionTimestampDesc()
          .watch(fireImmediately: true);
    }

    return query.sortByActionTimestampDesc().watch(fireImmediately: true);
  }

  @override
  Future<List<MovementEventIsar>> getUnsyncedMovementEvents() async {
    return isar.movementEventIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
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
  Future<void> cacheVisitor(VisitorIsar visitor) async {
    await isar.writeTxn(() async {
      await isar.visitorIsars.put(visitor);
    });
  }

  @override
  Stream<List<VisitorIsar>> watchCachedVisitors(String schoolId) {
    return isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByArrivalTimeDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<VisitorIsar>> getCachedVisitorsOnce(String schoolId) async {
    return isar.visitorIsars.filter().schoolIdEqualTo(schoolId).findAll();
  }

  @override
  Future<VisitorIsar?> getCachedVisitor(String visitorId) async {
    return isar.visitorIsars.filter().visitorIdEqualTo(visitorId).findFirst();
  }

  @override
  Future<List<VisitorIsar>> getUnsyncedVisitors() async {
    return isar.visitorIsars.filter().syncStatusEqualTo('pending').findAll();
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
  Future<void> cacheIncident(SecurityIncidentIsar incident) async {
    await isar.writeTxn(() async {
      await isar.securityIncidentIsars.put(incident);
    });
  }

  @override
  Future<List<SecurityIncidentIsar>> getUnsyncedIncidents() async {
    return isar.securityIncidentIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
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
  Future<void> cacheEmergency(EmergencyEventIsar emergency) async {
    await isar.writeTxn(() async {
      await isar.emergencyEventIsars.put(emergency);
    });
  }

  @override
  Stream<List<EmergencyEventIsar>> watchActiveEmergencies(String schoolId) {
    return isar.emergencyEventIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo('Active')
        .watch(fireImmediately: true);
  }

  @override
  Future<EmergencyEventIsar?> getEmergency(String emergencyId) async {
    return isar.emergencyEventIsars
        .filter()
        .eventIdEqualTo(emergencyId)
        .findFirst();
  }

  @override
  Future<List<EmergencyEventIsar>> getUnsyncedEmergencies() async {
    return isar.emergencyEventIsars
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
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
