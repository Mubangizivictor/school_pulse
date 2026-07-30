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
  Stream<List<Gate>> watchGates() {
    // Attempt to sync from remote if online
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchGates('default_school_id').listen((gates) async {
          final isarGates = gates.map((g) => GateIsar.fromEntity(g)).toList();
          await localDataSource.cacheGates(isarGates);
        });
      }
    });

    return localDataSource.watchCachedGates().map(
      (isarGates) => isarGates.map((g) => g.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, void>> createGate(Gate gate) async {
    try {
      await remoteDataSource.createGate(gate as GateModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGate(Gate gate) async {
    try {
      await remoteDataSource.updateGate(gate as GateModel);
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
  Stream<List<StudentMovement>> watchStudentMovements({DateTime? date, String? gateId}) {
    // For simplicity, we watch local movements.
    // In a full implementation, we'd merge or use the remote stream when online.
    return localDataSource.watchCachedStudentMovements().map(
      (isarMovements) => isarMovements.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, void>> recordStaffMovement(StaffMovement movement) async {
    try {
      await remoteDataSource.recordStaffMovement(movement as StaffMovementModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<StaffMovement>> watchStaffMovements({DateTime? date, String? gateId}) {
    return remoteDataSource.watchStaffMovements('default_school_id', date: date, gateId: gateId);
  }

  @override
  Future<Either<Failure, List<PickupAuthorization>>> getPickupAuthorizations(String studentId) async {
    try {
      final results = await remoteDataSource.getPickupAuthorizations(studentId);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPickupAuthorization(PickupAuthorization authorization) async {
    try {
      await remoteDataSource.addPickupAuthorization(authorization as PickupAuthorizationModel);
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
  Stream<List<SecurityIncident>> watchIncidents() {
    return localDataSource.watchCachedIncidents().map(
      (isarIncidents) => isarIncidents.map((i) => i.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, void>> updateIncidentStatus(String incidentId, String status, String resolution) async {
    try {
      await remoteDataSource.updateIncidentStatus(incidentId, status, resolution);
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
  Stream<List<EmergencyEvent>> watchActiveEmergencies() {
    return localDataSource.watchActiveEmergencies().map(
      (isarEvents) => isarEvents.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, void>> resolveEmergency(String emergencyId, DateTime endTime, List<String> actions) async {
    try {
      await remoteDataSource.resolveEmergency(emergencyId, endTime, actions);
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
  Stream<List<SecurityPatrol>> watchPatrols() {
    return remoteDataSource.watchPatrols('default_school_id');
  }

  @override
  Future<Either<Failure, void>> reportFoundItem(LostAndFoundItem item) async {
    try {
      await remoteDataSource.reportFoundItem(item as LostAndFoundItemModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> claimItem(String itemId, Map<String, dynamic> claimDetails) async {
    try {
      await remoteDataSource.claimItem(itemId, claimDetails);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<LostAndFoundItem>> watchLostAndFound() {
    return remoteDataSource.watchLostAndFound('default_school_id');
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSecurityDashboardStats() async {
    try {
      final stats = await remoteDataSource.getSecurityDashboardStats('default_school_id');
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncSecurityData() async {
    try {
      if (!(await networkInfo.isConnected)) return const Left(NetworkFailure('No internet connection'));

      // Sync Student Movements
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

      // Sync Incidents
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
         ));
      }
      await localDataSource.markIncidentsAsSynced(unsyncedIncidents.map((e) => e.incidentId).toList());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
