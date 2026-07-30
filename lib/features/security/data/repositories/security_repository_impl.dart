import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_local_data_source.dart';
import '../datasources/security_remote_data_source.dart';
import '../models/security_isar_models.dart';
import '../models/security_models.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityRemoteDataSource remoteDataSource;
  final SecurityLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SecurityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Stream<List<Gate>> watchGates(String schoolId) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchGates(schoolId).listen((gates) async {
          final isarGates = gates.map((g) => GateIsar.fromEntity(g)).toList();
          await localDataSource.cacheGates(isarGates);
        });
      }
    });

    return localDataSource.watchCachedGates(schoolId).map(
          (isarGates) => isarGates.map((g) => g.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> createGate(Gate gate) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarGate = GateIsar.fromEntity(gate, isSynced: isConnected);
      await localDataSource.cacheGate(isarGate);

      if (isConnected) {
        await remoteDataSource.createGate(gate as GateModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGate(Gate gate) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarGate = GateIsar.fromEntity(gate, isSynced: isConnected);
      await localDataSource.cacheGate(isarGate);

      if (isConnected) {
        await remoteDataSource.updateGate(gate as GateModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordStudentMovement(StudentMovement movement) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarMovement = StudentMovementIsar.fromEntity(movement, isSynced: isConnected);
      await localDataSource.cacheStudentMovement(isarMovement);

      if (isConnected) {
        await remoteDataSource.recordStudentMovement(movement as StudentMovementModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<StudentMovement>> watchStudentMovements(String schoolId, {DateTime? date, String? gateId, String? studentId}) {
    if (studentId == null) {
      networkInfo.isConnected.then((isConnected) {
        if (isConnected) {
          remoteDataSource.watchStudentMovements(schoolId, date: date, gateId: gateId).listen((movements) async {
            for (final movement in movements) {
              await localDataSource.cacheStudentMovement(StudentMovementIsar.fromEntity(movement));
            }
          });
        }
      });

      return localDataSource.watchCachedStudentMovements(schoolId, date: date, gateId: gateId).map(
            (isarMovements) => isarMovements.map((m) => m.toEntity()).toList(),
          );
    }

    // Per-student history (e.g. parent portal) reads straight from remote -
    // the local cache is not keyed for efficient per-student lookups.
    return remoteDataSource.watchStudentMovements(schoolId, date: date, gateId: gateId, studentId: studentId);
  }

  @override
  Future<Either<Failure, void>> recordStaffMovement(StaffMovement movement) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarMovement = StaffMovementIsar.fromEntity(movement, isSynced: isConnected);
      await localDataSource.cacheStaffMovement(isarMovement);

      if (isConnected) {
        await remoteDataSource.recordStaffMovement(movement as StaffMovementModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<StaffMovement>> watchStaffMovements(String schoolId, {DateTime? date, String? gateId}) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchStaffMovements(schoolId, date: date, gateId: gateId).listen((movements) async {
          for (final movement in movements) {
            await localDataSource.cacheStaffMovement(StaffMovementIsar.fromEntity(movement));
          }
        });
      }
    });

    return localDataSource.watchCachedStaffMovements(schoolId, date: date, gateId: gateId).map(
          (isarMovements) => isarMovements.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, List<PickupAuthorization>>> getPickupAuthorizations(String studentId) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        final results = await remoteDataSource.getPickupAuthorizations(studentId);
        await localDataSource.cachePickupAuthorizations(
          studentId,
          results.map((r) => PickupAuthorizationIsar.fromEntity(r)).toList(),
        );
        return Right(results);
      }
      final cached = await localDataSource.getCachedPickupAuthorizations(studentId);
      return Right(cached.map((c) => c.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPickupAuthorization(PickupAuthorization authorization) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarAuth = PickupAuthorizationIsar.fromEntity(authorization, isSynced: isConnected);
      await localDataSource.cachePickupAuthorization(isarAuth);

      if (isConnected) {
        await remoteDataSource.addPickupAuthorization(authorization as PickupAuthorizationModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reportIncident(SecurityIncident incident) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarIncident = SecurityIncidentIsar.fromEntity(incident, isSynced: isConnected);
      await localDataSource.cacheIncident(isarIncident);

      if (isConnected) {
        await remoteDataSource.reportIncident(incident as SecurityIncidentModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<SecurityIncident>> watchIncidents(String schoolId) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchIncidents(schoolId).listen((incidents) async {
          for (final incident in incidents) {
            await localDataSource.cacheIncident(SecurityIncidentIsar.fromEntity(incident));
          }
        });
      }
    });

    return localDataSource.watchCachedIncidents(schoolId).map(
          (isarIncidents) => isarIncidents.map((i) => i.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> updateIncidentStatus(String schoolId, String incidentId, String status, String resolution) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.updateIncidentStatus(schoolId, incidentId, status, resolution);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> triggerEmergency(EmergencyEvent event) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarEvent = EmergencyEventIsar.fromEntity(event, isSynced: isConnected);
      await localDataSource.cacheEmergency(isarEvent);

      if (isConnected) {
        await remoteDataSource.triggerEmergency(event as EmergencyEventModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchActiveEmergencies(schoolId).listen((events) async {
          for (final event in events) {
            await localDataSource.cacheEmergency(EmergencyEventIsar.fromEntity(event));
          }
        });
      }
    });

    return localDataSource.watchActiveEmergencies(schoolId).map(
          (isarEvents) => isarEvents.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> resolveEmergency(String schoolId, String emergencyId, DateTime endTime, List<String> actions) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.resolveEmergency(schoolId, emergencyId, endTime, actions);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordPatrol(SecurityPatrol patrol) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarPatrol = SecurityPatrolIsar.fromEntity(patrol, isSynced: isConnected);
      await localDataSource.cachePatrol(isarPatrol);

      if (isConnected) {
        await remoteDataSource.recordPatrol(patrol as SecurityPatrolModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<SecurityPatrol>> watchPatrols(String schoolId) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchPatrols(schoolId).listen((patrols) async {
          for (final patrol in patrols) {
            await localDataSource.cachePatrol(SecurityPatrolIsar.fromEntity(patrol));
          }
        });
      }
    });

    return localDataSource.watchCachedPatrols(schoolId).map(
          (isarPatrols) => isarPatrols.map((p) => p.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> reportFoundItem(LostAndFoundItem item) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final isarItem = LostAndFoundItemIsar.fromEntity(item, isSynced: isConnected);
      await localDataSource.cacheLostAndFoundItem(isarItem);

      if (isConnected) {
        await remoteDataSource.reportFoundItem(item as LostAndFoundItemModel);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> claimItem(String schoolId, String itemId, Map<String, dynamic> claimDetails) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.claimItem(schoolId, itemId, claimDetails);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<LostAndFoundItem>> watchLostAndFound(String schoolId) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchLostAndFound(schoolId).listen((items) async {
          for (final item in items) {
            await localDataSource.cacheLostAndFoundItem(LostAndFoundItemIsar.fromEntity(item));
          }
        });
      }
    });

    return localDataSource.watchCachedLostAndFound(schoolId).map(
          (isarItems) => isarItems.map((i) => i.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSecurityDashboardStats(String schoolId) async {
    try {
      final stats = await remoteDataSource.getSecurityDashboardStats(schoolId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncSecurityData() async {
    try {
      if (!(await networkInfo.isConnected)) return const Left(NetworkFailure('No internet connection'));

      final unsyncedGates = await localDataSource.getUnsyncedGates();
      for (final gate in unsyncedGates) {
        final entity = gate.toEntity();
        final model = GateModel(
          id: entity.id,
          name: entity.name,
          type: entity.type,
          location: entity.location,
          assignedOfficerIds: entity.assignedOfficerIds,
          operatingHours: entity.operatingHours,
          allowedUserRoles: entity.allowedUserRoles,
          requiredVerificationMethods: entity.requiredVerificationMethods,
          schoolId: entity.schoolId,
          cameraId: entity.cameraId,
        );
        await remoteDataSource.updateGate(model);
      }
      await localDataSource.markGatesAsSynced(unsyncedGates.map((e) => e.gateId).toList());

      final unsyncedMovements = await localDataSource.getUnsyncedStudentMovements();
      for (final movement in unsyncedMovements) {
        await remoteDataSource.recordStudentMovement(StudentMovementModel(
          id: movement.movementId,
          studentId: movement.studentId,
          studentName: movement.studentName,
          className: movement.className,
          timestamp: movement.timestamp,
          gateId: movement.gateId,
          direction: movement.direction,
          movementType: movement.movementType,
          verificationMethod: movement.verificationMethod,
          officerId: movement.officerId,
          deviceId: movement.deviceId,
          schoolId: movement.schoolId,
        ));
      }
      await localDataSource.markStudentMovementsAsSynced(unsyncedMovements.map((e) => e.movementId).toList());

      final unsyncedStaffMovements = await localDataSource.getUnsyncedStaffMovements();
      for (final movement in unsyncedStaffMovements) {
        await remoteDataSource.recordStaffMovement(StaffMovementModel(
          id: movement.movementId,
          staffId: movement.staffId,
          staffName: movement.staffName,
          timestamp: movement.timestamp,
          gateId: movement.gateId,
          direction: movement.direction,
          verificationMethod: movement.verificationMethod,
          officerId: movement.officerId,
          schoolId: movement.schoolId,
        ));
      }
      await localDataSource.markStaffMovementsAsSynced(unsyncedStaffMovements.map((e) => e.movementId).toList());

      final unsyncedIncidents = await localDataSource.getUnsyncedIncidents();
      for (final incident in unsyncedIncidents) {
        await remoteDataSource.reportIncident(SecurityIncidentModel(
          id: incident.incidentId,
          type: incident.type,
          description: incident.description,
          timestamp: incident.timestamp,
          location: incident.location,
          involvedPersonIds: incident.involvedPersonIds,
          photoUrls: incident.photoUrls,
          reportedByOfficerId: incident.reportedByOfficerId,
          report: incident.report,
          status: incident.status,
          schoolId: incident.schoolId,
          cameraId: incident.cameraId,
        ));
      }
      await localDataSource.markIncidentsAsSynced(unsyncedIncidents.map((e) => e.incidentId).toList());

      final unsyncedEmergencies = await localDataSource.getUnsyncedEmergencies();
      for (final event in unsyncedEmergencies) {
        await remoteDataSource.triggerEmergency(EmergencyEventModel(
          id: event.eventId,
          type: event.type,
          startTime: event.startTime,
          endTime: event.endTime,
          description: event.description,
          responseActions: event.responseActions,
          involvedPersonIds: event.involvedPersonIds,
          status: event.status,
          schoolId: event.schoolId,
        ));
      }
      await localDataSource.markEmergenciesAsSynced(unsyncedEmergencies.map((e) => e.eventId).toList());

      final unsyncedPatrols = await localDataSource.getUnsyncedPatrols();
      for (final patrol in unsyncedPatrols) {
        await remoteDataSource.recordPatrol(SecurityPatrolModel(
          id: patrol.patrolId,
          officerId: patrol.officerId,
          location: patrol.location,
          timestamp: patrol.timestamp,
          observations: patrol.observations,
          photoUrls: patrol.photoUrls,
          issuesFound: patrol.issuesFound,
          schoolId: patrol.schoolId,
        ));
      }
      await localDataSource.markPatrolsAsSynced(unsyncedPatrols.map((e) => e.patrolId).toList());

      final unsyncedLostAndFound = await localDataSource.getUnsyncedLostAndFound();
      for (final item in unsyncedLostAndFound) {
        await remoteDataSource.reportFoundItem(LostAndFoundItemModel(
          id: item.itemId,
          description: item.description,
          locationFound: item.locationFound,
          dateFound: item.dateFound,
          photoUrl: item.photoUrl,
          foundByPersonId: item.foundByPersonId,
          isClaimed: item.isClaimed,
          claimDetails: item.toEntity().claimDetails,
          schoolId: item.schoolId,
        ));
      }
      await localDataSource.markLostAndFoundAsSynced(unsyncedLostAndFound.map((e) => e.itemId).toList());

      final unsyncedAuthorizations = await localDataSource.getUnsyncedPickupAuthorizations();
      for (final auth in unsyncedAuthorizations) {
        await remoteDataSource.addPickupAuthorization(PickupAuthorizationModel(
          id: auth.authorizationId,
          studentId: auth.studentId,
          parentId: auth.parentId,
          authorizedPersonName: auth.authorizedPersonName,
          phone: auth.phone,
          relationship: auth.relationship,
          photoUrl: auth.photoUrl,
          idDocumentUrl: auth.idDocumentUrl,
          expiryDate: auth.expiryDate,
          schoolId: auth.schoolId,
        ));
      }
      await localDataSource.markPickupAuthorizationsAsSynced(unsyncedAuthorizations.map((e) => e.authorizationId).toList());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
