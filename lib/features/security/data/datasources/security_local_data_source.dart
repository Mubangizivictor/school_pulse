import 'package:isar/isar.dart';
import '../models/security_isar_models.dart';

abstract class SecurityLocalDataSource {
  // Gates
  Future<void> cacheGates(List<GateIsar> gates);
  Future<List<GateIsar>> getCachedGates();
  Stream<List<GateIsar>> watchCachedGates();

  // Student Movement
  Future<void> cacheStudentMovement(StudentMovementIsar movement);
  Future<List<StudentMovementIsar>> getUnsyncedStudentMovements();
  Future<void> markStudentMovementsAsSynced(List<String> movementIds);
  Stream<List<StudentMovementIsar>> watchCachedStudentMovements();

  // Incidents
  Future<void> cacheIncident(SecurityIncidentIsar incident);
  Future<List<SecurityIncidentIsar>> getUnsyncedIncidents();
  Future<void> markIncidentsAsSynced(List<String> incidentIds);
  Stream<List<SecurityIncidentIsar>> watchCachedIncidents();

  // Emergency
  Future<void> cacheEmergency(EmergencyEventIsar event);
  Future<List<EmergencyEventIsar>> getActiveEmergencies();
  Stream<List<EmergencyEventIsar>> watchActiveEmergencies();

  // Patrols
  Future<void> cachePatrol(SecurityPatrolIsar patrol);
  Future<List<SecurityPatrolIsar>> getUnsyncedPatrols();
  Future<void> markPatrolsAsSynced(List<String> patrolIds);
}

class SecurityLocalDataSourceImpl implements SecurityLocalDataSource {
  final Isar isar;

  SecurityLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheGates(List<GateIsar> gates) async {
    await isar.writeTxn(() async {
      await isar.gateIsars.clear();
      await isar.gateIsars.putAll(gates);
    });
  }

  @override
  Future<List<GateIsar>> getCachedGates() async {
    return await isar.gateIsars.where().findAll();
  }

  @override
  Stream<List<GateIsar>> watchCachedGates() {
    return isar.gateIsars.where().watch(fireImmediately: true);
  }

  @override
  Future<void> cacheStudentMovement(StudentMovementIsar movement) async {
    await isar.writeTxn(() async {
      await isar.studentMovementIsars.put(movement);
    });
  }

  @override
  Future<List<StudentMovementIsar>> getUnsyncedStudentMovements() async {
    return await isar.studentMovementIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markStudentMovementsAsSynced(List<String> movementIds) async {
    await isar.writeTxn(() async {
      for (final id in movementIds) {
        final movement = await isar.studentMovementIsars.filter().movementIdEqualTo(id).findFirst();
        if (movement != null) {
          movement.isSynced = true;
          await isar.studentMovementIsars.put(movement);
        }
      }
    });
  }

  @override
  Stream<List<StudentMovementIsar>> watchCachedStudentMovements() {
    return isar.studentMovementIsars.where().sortByTimestampDesc().watch(fireImmediately: true);
  }

  @override
  Future<void> cacheIncident(SecurityIncidentIsar incident) async {
    await isar.writeTxn(() async {
      await isar.securityIncidentIsars.put(incident);
    });
  }

  @override
  Future<List<SecurityIncidentIsar>> getUnsyncedIncidents() async {
    return await isar.securityIncidentIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markIncidentsAsSynced(List<String> incidentIds) async {
    await isar.writeTxn(() async {
      for (final id in incidentIds) {
        final incident = await isar.securityIncidentIsars.filter().incidentIdEqualTo(id).findFirst();
        if (incident != null) {
          incident.isSynced = true;
          await isar.securityIncidentIsars.put(incident);
        }
      }
    });
  }

  @override
  Stream<List<SecurityIncidentIsar>> watchCachedIncidents() {
    return isar.securityIncidentIsars.where().sortByTimestampDesc().watch(fireImmediately: true);
  }

  @override
  Future<void> cacheEmergency(EmergencyEventIsar event) async {
    await isar.writeTxn(() async {
      await isar.emergencyEventIsars.put(event);
    });
  }

  @override
  Future<List<EmergencyEventIsar>> getActiveEmergencies() async {
    return await isar.emergencyEventIsars.filter().statusEqualTo('Active').findAll();
  }

  @override
  Stream<List<EmergencyEventIsar>> watchActiveEmergencies() {
    return isar.emergencyEventIsars.filter().statusEqualTo('Active').watch(fireImmediately: true);
  }

  @override
  Future<void> cachePatrol(SecurityPatrolIsar patrol) async {
    await isar.writeTxn(() async {
      await isar.securityPatrolIsars.put(patrol);
    });
  }

  @override
  Future<List<SecurityPatrolIsar>> getUnsyncedPatrols() async {
    return await isar.securityPatrolIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markPatrolsAsSynced(List<String> patrolIds) async {
    await isar.writeTxn(() async {
      for (final id in patrolIds) {
        final patrol = await isar.securityPatrolIsars.filter().patrolIdEqualTo(id).findFirst();
        if (patrol != null) {
          patrol.isSynced = true;
          await isar.securityPatrolIsars.put(patrol);
        }
      }
    });
  }
}
