import 'package:isar/isar.dart';
import '../models/security_isar_models.dart';

abstract class SecurityLocalDataSource {
  // Gates
  Future<void> cacheGates(List<GateIsar> gates);
  Future<void> cacheGate(GateIsar gate);
  Future<List<GateIsar>> getCachedGates(String schoolId);
  Stream<List<GateIsar>> watchCachedGates(String schoolId);
  Future<List<GateIsar>> getUnsyncedGates();
  Future<void> markGatesAsSynced(List<String> gateIds);

  // Student Movement
  Future<void> cacheStudentMovement(StudentMovementIsar movement);
  Future<List<StudentMovementIsar>> getUnsyncedStudentMovements();
  Future<void> markStudentMovementsAsSynced(List<String> movementIds);
  Stream<List<StudentMovementIsar>> watchCachedStudentMovements(
    String schoolId, {
    DateTime? date,
    String? gateId,
  });

  // Staff Movement
  Future<void> cacheStaffMovement(StaffMovementIsar movement);
  Future<List<StaffMovementIsar>> getUnsyncedStaffMovements();
  Future<void> markStaffMovementsAsSynced(List<String> movementIds);
  Stream<List<StaffMovementIsar>> watchCachedStaffMovements(
    String schoolId, {
    DateTime? date,
    String? gateId,
  });

  // Incidents
  Future<void> cacheIncident(SecurityIncidentIsar incident);
  Future<List<SecurityIncidentIsar>> getUnsyncedIncidents();
  Future<void> markIncidentsAsSynced(List<String> incidentIds);
  Stream<List<SecurityIncidentIsar>> watchCachedIncidents(String schoolId);

  // Emergency
  Future<void> cacheEmergency(EmergencyEventIsar event);
  Future<List<EmergencyEventIsar>> getActiveEmergencies(String schoolId);
  Stream<List<EmergencyEventIsar>> watchActiveEmergencies(String schoolId);
  Future<List<EmergencyEventIsar>> getUnsyncedEmergencies();
  Future<void> markEmergenciesAsSynced(List<String> eventIds);

  // Patrols
  Future<void> cachePatrol(SecurityPatrolIsar patrol);
  Future<List<SecurityPatrolIsar>> getUnsyncedPatrols();
  Future<void> markPatrolsAsSynced(List<String> patrolIds);
  Stream<List<SecurityPatrolIsar>> watchCachedPatrols(String schoolId);

  // Lost and Found
  Future<void> cacheLostAndFoundItem(LostAndFoundItemIsar item);
  Future<List<LostAndFoundItemIsar>> getUnsyncedLostAndFound();
  Future<void> markLostAndFoundAsSynced(List<String> itemIds);
  Stream<List<LostAndFoundItemIsar>> watchCachedLostAndFound(String schoolId);

  // Pickup Authorizations
  Future<void> cachePickupAuthorizations(
    String studentId,
    List<PickupAuthorizationIsar> authorizations,
  );
  Future<void> cachePickupAuthorization(PickupAuthorizationIsar authorization);
  Future<List<PickupAuthorizationIsar>> getCachedPickupAuthorizations(
    String studentId,
  );
  Future<List<PickupAuthorizationIsar>> getUnsyncedPickupAuthorizations();
  Future<void> markPickupAuthorizationsAsSynced(List<String> authorizationIds);
}

class SecurityLocalDataSourceImpl implements SecurityLocalDataSource {
  final Isar isar;

  SecurityLocalDataSourceImpl({required this.isar});

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
  Future<List<GateIsar>> getCachedGates(String schoolId) async {
    return await isar.gateIsars.filter().schoolIdEqualTo(schoolId).findAll();
  }

  @override
  Stream<List<GateIsar>> watchCachedGates(String schoolId) {
    return isar.gateIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .watch(fireImmediately: true);
  }

  @override
  Future<List<GateIsar>> getUnsyncedGates() async {
    return await isar.gateIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markGatesAsSynced(List<String> gateIds) async {
    await isar.writeTxn(() async {
      for (final id in gateIds) {
        final gate = await isar.gateIsars
            .filter()
            .gateIdEqualTo(id)
            .findFirst();
        if (gate != null) {
          gate.isSynced = true;
          await isar.gateIsars.put(gate);
        }
      }
    });
  }

  @override
  Future<void> cacheStudentMovement(StudentMovementIsar movement) async {
    await isar.writeTxn(() async {
      await isar.studentMovementIsars.put(movement);
    });
  }

  @override
  Future<List<StudentMovementIsar>> getUnsyncedStudentMovements() async {
    return await isar.studentMovementIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markStudentMovementsAsSynced(List<String> movementIds) async {
    await isar.writeTxn(() async {
      for (final id in movementIds) {
        final movement = await isar.studentMovementIsars
            .filter()
            .movementIdEqualTo(id)
            .findFirst();
        if (movement != null) {
          movement.isSynced = true;
          await isar.studentMovementIsars.put(movement);
        }
      }
    });
  }

  @override
  Stream<List<StudentMovementIsar>> watchCachedStudentMovements(
    String schoolId, {
    DateTime? date,
    String? gateId,
  }) {
    var q = isar.studentMovementIsars.filter().schoolIdEqualTo(schoolId);
    QueryBuilder<
      StudentMovementIsar,
      StudentMovementIsar,
      QAfterFilterCondition
    >
    query = q;
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query.and().timestampBetween(start, end, includeUpper: false);
    }
    if (gateId != null) {
      query = query.and().gateIdEqualTo(gateId);
    }
    return query.sortByTimestampDesc().watch(fireImmediately: true);
  }

  @override
  Future<void> cacheStaffMovement(StaffMovementIsar movement) async {
    await isar.writeTxn(() async {
      await isar.staffMovementIsars.put(movement);
    });
  }

  @override
  Future<List<StaffMovementIsar>> getUnsyncedStaffMovements() async {
    return await isar.staffMovementIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markStaffMovementsAsSynced(List<String> movementIds) async {
    await isar.writeTxn(() async {
      for (final id in movementIds) {
        final movement = await isar.staffMovementIsars
            .filter()
            .movementIdEqualTo(id)
            .findFirst();
        if (movement != null) {
          movement.isSynced = true;
          await isar.staffMovementIsars.put(movement);
        }
      }
    });
  }

  @override
  Stream<List<StaffMovementIsar>> watchCachedStaffMovements(
    String schoolId, {
    DateTime? date,
    String? gateId,
  }) {
    var q = isar.staffMovementIsars.filter().schoolIdEqualTo(schoolId);
    QueryBuilder<StaffMovementIsar, StaffMovementIsar, QAfterFilterCondition>
    query = q;
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query.and().timestampBetween(start, end, includeUpper: false);
    }
    if (gateId != null) {
      query = query.and().gateIdEqualTo(gateId);
    }
    return query.sortByTimestampDesc().watch(fireImmediately: true);
  }

  @override
  Future<void> cacheIncident(SecurityIncidentIsar incident) async {
    await isar.writeTxn(() async {
      await isar.securityIncidentIsars.put(incident);
    });
  }

  @override
  Future<List<SecurityIncidentIsar>> getUnsyncedIncidents() async {
    return await isar.securityIncidentIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markIncidentsAsSynced(List<String> incidentIds) async {
    await isar.writeTxn(() async {
      for (final id in incidentIds) {
        final incident = await isar.securityIncidentIsars
            .filter()
            .incidentIdEqualTo(id)
            .findFirst();
        if (incident != null) {
          incident.isSynced = true;
          await isar.securityIncidentIsars.put(incident);
        }
      }
    });
  }

  @override
  Stream<List<SecurityIncidentIsar>> watchCachedIncidents(String schoolId) {
    return isar.securityIncidentIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> cacheEmergency(EmergencyEventIsar event) async {
    await isar.writeTxn(() async {
      await isar.emergencyEventIsars.put(event);
    });
  }

  @override
  Future<List<EmergencyEventIsar>> getActiveEmergencies(String schoolId) async {
    return await isar.emergencyEventIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .statusEqualTo('Active')
        .findAll();
  }

  @override
  Stream<List<EmergencyEventIsar>> watchActiveEmergencies(String schoolId) {
    return isar.emergencyEventIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .statusEqualTo('Active')
        .watch(fireImmediately: true);
  }

  @override
  Future<List<EmergencyEventIsar>> getUnsyncedEmergencies() async {
    return await isar.emergencyEventIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markEmergenciesAsSynced(List<String> eventIds) async {
    await isar.writeTxn(() async {
      for (final id in eventIds) {
        final event = await isar.emergencyEventIsars
            .filter()
            .eventIdEqualTo(id)
            .findFirst();
        if (event != null) {
          event.isSynced = true;
          await isar.emergencyEventIsars.put(event);
        }
      }
    });
  }

  @override
  Future<void> cachePatrol(SecurityPatrolIsar patrol) async {
    await isar.writeTxn(() async {
      await isar.securityPatrolIsars.put(patrol);
    });
  }

  @override
  Future<List<SecurityPatrolIsar>> getUnsyncedPatrols() async {
    return await isar.securityPatrolIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markPatrolsAsSynced(List<String> patrolIds) async {
    await isar.writeTxn(() async {
      for (final id in patrolIds) {
        final patrol = await isar.securityPatrolIsars
            .filter()
            .patrolIdEqualTo(id)
            .findFirst();
        if (patrol != null) {
          patrol.isSynced = true;
          await isar.securityPatrolIsars.put(patrol);
        }
      }
    });
  }

  @override
  Stream<List<SecurityPatrolIsar>> watchCachedPatrols(String schoolId) {
    return isar.securityPatrolIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> cacheLostAndFoundItem(LostAndFoundItemIsar item) async {
    await isar.writeTxn(() async {
      await isar.lostAndFoundItemIsars.put(item);
    });
  }

  @override
  Future<List<LostAndFoundItemIsar>> getUnsyncedLostAndFound() async {
    return await isar.lostAndFoundItemIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markLostAndFoundAsSynced(List<String> itemIds) async {
    await isar.writeTxn(() async {
      for (final id in itemIds) {
        final item = await isar.lostAndFoundItemIsars
            .filter()
            .itemIdEqualTo(id)
            .findFirst();
        if (item != null) {
          item.isSynced = true;
          await isar.lostAndFoundItemIsars.put(item);
        }
      }
    });
  }

  @override
  Stream<List<LostAndFoundItemIsar>> watchCachedLostAndFound(String schoolId) {
    return isar.lostAndFoundItemIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByDateFoundDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> cachePickupAuthorizations(
    String studentId,
    List<PickupAuthorizationIsar> authorizations,
  ) async {
    await isar.writeTxn(() async {
      final existing = await isar.pickupAuthorizationIsars
          .filter()
          .studentIdEqualTo(studentId)
          .findAll();
      await isar.pickupAuthorizationIsars.deleteAll(
        existing.map((e) => e.id).toList(),
      );
      await isar.pickupAuthorizationIsars.putAll(authorizations);
    });
  }

  @override
  Future<void> cachePickupAuthorization(
    PickupAuthorizationIsar authorization,
  ) async {
    await isar.writeTxn(() async {
      await isar.pickupAuthorizationIsars.put(authorization);
    });
  }

  @override
  Future<List<PickupAuthorizationIsar>> getCachedPickupAuthorizations(
    String studentId,
  ) async {
    return await isar.pickupAuthorizationIsars
        .filter()
        .studentIdEqualTo(studentId)
        .findAll();
  }

  @override
  Future<List<PickupAuthorizationIsar>>
  getUnsyncedPickupAuthorizations() async {
    return await isar.pickupAuthorizationIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markPickupAuthorizationsAsSynced(
    List<String> authorizationIds,
  ) async {
    await isar.writeTxn(() async {
      for (final id in authorizationIds) {
        final auth = await isar.pickupAuthorizationIsars
            .filter()
            .authorizationIdEqualTo(id)
            .findFirst();
        if (auth != null) {
          auth.isSynced = true;
          await isar.pickupAuthorizationIsars.put(auth);
        }
      }
    });
  }
}
