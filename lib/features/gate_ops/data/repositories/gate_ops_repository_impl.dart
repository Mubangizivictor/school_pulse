import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/pickup_authorization.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/gate_ops_repository.dart';
import '../datasources/gate_ops_local_data_source.dart';
import '../datasources/gate_ops_remote_data_source.dart';
import '../models/gate_ops_isar_models.dart';
import '../sync/movement_sync_engine.dart';

/// Isar-first, best-effort-push repository per plan section 6: every write
/// lands in Isar immediately (the operation's success point - UI shows
/// "Saved" here regardless of network), then a push is attempted via
/// [MovementSyncEngine]; on success the Isar row flips to synced, on
/// failure it stays pending for the next sweep (`GateOpsBloc`'s
/// `Timer.periodic(30s)` or a reconnect/pull-to-refresh, wired in a later
/// commit).
class GateOpsRepositoryImpl implements GateOpsRepository {
  final GateOpsRemoteDataSource remoteDataSource;
  final GateOpsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final MovementSyncEngine syncEngine;

  GateOpsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.syncEngine,
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

    return localDataSource
        .watchCachedGates(schoolId)
        .map((isarGates) => isarGates.map((g) => g.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> recordMovementEvent(MovementEvent event) async {
    try {
      final isarEvent = MovementEventIsar.fromEntity(
        event.syncStatus == SyncStatus.pending ? event : _asPending(event),
      );
      await localDataSource.cacheMovementEvent(isarEvent);

      final pushed = await syncEngine.tryPush(
        'schools/${event.schoolId}/movement_events',
        event.id,
        _movementEventToMap(event),
      );
      if (pushed) {
        await localDataSource.markMovementEventSynced(event.id);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  MovementEvent _asPending(MovementEvent event) => MovementEvent(
    id: event.id,
    schoolId: event.schoolId,
    campusId: event.campusId,
    gateId: event.gateId,
    personType: event.personType,
    personId: event.personId,
    personName: event.personName,
    direction: event.direction,
    movementType: event.movementType,
    verificationMethod: event.verificationMethod,
    officerId: event.officerId,
    officerRole: event.officerRole,
    deviceId: event.deviceId,
    deviceName: event.deviceName,
    platform: event.platform,
    appVersion: event.appVersion,
    actionTimestamp: event.actionTimestamp,
    serverTimestamp: event.serverTimestamp,
    syncStatus: SyncStatus.pending,
    pickupParentCode: event.pickupParentCode,
    pickupParentName: event.pickupParentName,
    pickupPhoneNumber: event.pickupPhoneNumber,
  );

  Map<String, dynamic> _movementEventToMap(MovementEvent event) => {
    'schoolId': event.schoolId,
    'campusId': event.campusId,
    'gateId': event.gateId,
    'personType': event.personType.name,
    'personId': event.personId,
    'personName': event.personName,
    'direction': event.direction.name,
    'movementType': event.movementType,
    'verificationMethod': event.verificationMethod.id,
    'officerId': event.officerId,
    'officerRole': event.officerRole,
    'deviceId': event.deviceId,
    'deviceName': event.deviceName,
    'platform': event.platform,
    'appVersion': event.appVersion,
    'actionTimestamp': event.actionTimestamp,
    'pickupParentCode': event.pickupParentCode,
    'pickupParentName': event.pickupParentName,
    'pickupPhoneNumber': event.pickupPhoneNumber,
  };

  @override
  Stream<List<MovementEvent>> watchMovementEvents(
    String schoolId, {
    PersonType? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) {
    // Per-person history (e.g. parent portal) reads straight from remote -
    // the local cache is not keyed for efficient per-person lookups beyond
    // the gate-scoped "today's movements" query.
    if (personId != null) {
      return remoteDataSource.watchMovementEvents(
        schoolId,
        personType: personType,
        personId: personId,
        gateId: gateId,
        date: date,
      );
    }

    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource
            .watchMovementEvents(
              schoolId,
              personType: personType,
              gateId: gateId,
              date: date,
            )
            .listen((events) async {
              for (final event in events) {
                await localDataSource.cacheMovementEvent(
                  MovementEventIsar.fromEntity(event),
                );
              }
            });
      }
    });

    return localDataSource
        .watchCachedMovementEvents(
          schoolId,
          personType: personType?.name,
          gateId: gateId,
          date: date,
        )
        .map((isarEvents) => isarEvents.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> checkInVisitor(Visitor visitor) async {
    try {
      final pendingVisitor = Visitor(
        id: visitor.id,
        schoolId: visitor.schoolId,
        fullName: visitor.fullName,
        phone: visitor.phone,
        photoLocalPath: visitor.photoLocalPath,
        photoUrl: visitor.photoUrl,
        purpose: visitor.purpose,
        hostId: visitor.hostId,
        hostName: visitor.hostName,
        gateId: visitor.gateId,
        arrivalTime: visitor.arrivalTime,
        departureTime: visitor.departureTime,
        status: visitor.status,
        isQuickEntry: visitor.isQuickEntry,
        badgeNumber: visitor.badgeNumber,
        syncStatus: SyncStatus.pending,
      );
      await localDataSource.cacheVisitor(
        VisitorIsar.fromEntity(pendingVisitor),
      );

      final photoUrl = await syncEngine.uploadIfPresent(
        visitor.photoLocalPath,
        'visitors/${visitor.schoolId}/${visitor.id}/photo.jpg',
      );

      final pushed = await syncEngine
          .tryPush('schools/${visitor.schoolId}/visitors', visitor.id, {
            'schoolId': visitor.schoolId,
            'fullName': visitor.fullName,
            'phone': visitor.phone,
            'photoUrl': photoUrl ?? visitor.photoUrl,
            'purpose': visitor.purpose,
            'hostId': visitor.hostId,
            'hostName': visitor.hostName,
            'gateId': visitor.gateId,
            'arrivalTime': visitor.arrivalTime,
            'departureTime': visitor.departureTime,
            'status': visitor.status.name,
            'isQuickEntry': visitor.isQuickEntry,
            'badgeNumber': visitor.badgeNumber,
          });
      if (pushed) {
        await localDataSource.markVisitorSynced(visitor.id);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> checkOutVisitor(String visitorId) async {
    try {
      final cached = await localDataSource.getCachedVisitor(visitorId);
      if (cached == null) {
        return const Left(CacheFailure('Visitor not found locally'));
      }
      cached.status = VisitorStatus.checkedOut.name;
      cached.departureTime = DateTime.now();
      cached.syncStatus = SyncStatus.pending.name;
      await localDataSource.cacheVisitor(cached);

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.checkOutVisitor(cached.schoolId, visitorId);
        await localDataSource.markVisitorSynced(visitorId);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Visitor>> watchVisitors(String schoolId) {
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        remoteDataSource.watchVisitors(schoolId).listen((visitors) async {
          for (final visitor in visitors) {
            await localDataSource.cacheVisitor(VisitorIsar.fromEntity(visitor));
          }
        });
      }
    });

    return localDataSource
        .watchCachedVisitors(schoolId)
        .map((isarVisitors) => isarVisitors.map((v) => v.toEntity()).toList());
  }

  @override
  Future<List<Visitor>> getVisitorsOnce(String schoolId) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final visitors = await remoteDataSource.getVisitorsOnce(schoolId);
        for (final visitor in visitors) {
          await localDataSource.cacheVisitor(VisitorIsar.fromEntity(visitor));
        }
        return visitors;
      } catch (_) {
        // Fall through to cache on any remote failure.
      }
    }
    final cached = await localDataSource.getCachedVisitorsOnce(schoolId);
    return cached.map((v) => v.toEntity()).toList();
  }

  @override
  Future<Either<Failure, void>> reportIncident(
    SecurityIncident incident,
  ) async {
    try {
      await localDataSource.cacheIncident(
        SecurityIncidentIsar.fromEntity(incident),
      );

      final pushed = await syncEngine.tryPush(
        'schools/${incident.schoolId}/security_incidents',
        incident.id,
        {
          'schoolId': incident.schoolId,
          'gateId': incident.gateId,
          'type': incident.type,
          'description': incident.description,
          'timestamp': incident.timestamp,
          'photoUrls': incident.photoUrls,
          'reportedByOfficerId': incident.reportedByOfficerId,
          'status': incident.status,
        },
      );
      if (pushed) {
        await localDataSource.markIncidentSynced(incident.id);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> triggerEmergency(
    EmergencyEvent emergency,
  ) async {
    try {
      await localDataSource.cacheEmergency(
        EmergencyEventIsar.fromEntity(emergency),
      );

      final pushed = await syncEngine.tryPush(
        'schools/${emergency.schoolId}/emergency_events',
        emergency.id,
        {
          'schoolId': emergency.schoolId,
          'gateId': emergency.gateId,
          'type': emergency.type,
          'startTime': emergency.startTime,
          'endTime': emergency.endTime,
          'description': emergency.description,
          'officerId': emergency.officerId,
          'deviceId': emergency.deviceId,
          'status': emergency.status,
        },
      );
      if (pushed) {
        await localDataSource.markEmergencySynced(emergency.id);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resolveEmergency(String emergencyId) async {
    try {
      final cached = await localDataSource.getEmergency(emergencyId);
      if (cached == null) {
        return const Left(CacheFailure('Emergency not found locally'));
      }
      cached.status = 'Resolved';
      cached.endTime = DateTime.now();
      await localDataSource.cacheEmergency(cached);

      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.resolveEmergency(cached.schoolId, emergencyId);
        await localDataSource.markEmergencySynced(emergencyId);
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
        remoteDataSource.watchActiveEmergencies(schoolId).listen((
          emergencies,
        ) async {
          for (final emergency in emergencies) {
            await localDataSource.cacheEmergency(
              EmergencyEventIsar.fromEntity(emergency),
            );
          }
        });
      }
    });

    return localDataSource
        .watchActiveEmergencies(schoolId)
        .map((isarEvents) => isarEvents.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Either<Failure, GateOpsDashboardStats>> getGateOpsDashboardStats(
    String schoolId,
  ) async {
    try {
      final visitors = await getVisitorsOnce(schoolId);
      final visitorsInside = visitors
          .where((v) => v.status == VisitorStatus.checkedIn)
          .length;

      final today = DateTime.now();

      int studentsInside = 0;
      int staffInside = 0;
      try {
        final events = await remoteDataSource
            .watchMovementEvents(schoolId, date: today)
            .first
            .timeout(const Duration(seconds: 10));
        studentsInside = _countInside(
          events.where((e) => e.personType == PersonType.student).toList(),
        );
        staffInside = _countInside(
          events.where((e) => e.personType == PersonType.staff).toList(),
        );
      } catch (_) {
        // Offline / timed out - dashboard falls back to visitor-only counts.
      }

      return Right(
        GateOpsDashboardStats(
          peopleCurrentlyInside: visitorsInside + studentsInside + staffInside,
          visitorsInside: visitorsInside,
          studentsInside: studentsInside,
          staffInside: staffInside,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Counts distinct people whose latest movement today was "in".
  int _countInside(List<MovementEvent> events) {
    final latestByPerson = <String, MovementEvent>{};
    for (final event in events) {
      final existing = latestByPerson[event.personId];
      if (existing == null ||
          event.actionTimestamp.isAfter(existing.actionTimestamp)) {
        latestByPerson[event.personId] = event;
      }
    }
    return latestByPerson.values
        .where((e) => e.direction == MovementDirection.in_)
        .length;
  }

  @override
  Future<Either<Failure, List<PickupAuthorization>>> getPickupAuthorizations(
    String schoolId,
    String studentId,
  ) async {
    try {
      final results = await remoteDataSource.getPickupAuthorizations(
        schoolId,
        studentId,
      );
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPickupAuthorization(
    PickupAuthorization authorization,
  ) async {
    try {
      await remoteDataSource.addPickupAuthorization(authorization);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
