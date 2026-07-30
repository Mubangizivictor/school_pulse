import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../datasources/visitor_sync_worker.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_blacklist.dart';
import '../../domain/entities/pre_approved_visitor.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../../domain/entities/package_delivery.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_local_data_source.dart';
import '../datasources/visitor_remote_data_source.dart';
import 'package:school_pulse/features/attendance_qr_integration/domain/services/google_sheets_service.dart';
import '../models/visitor_isar.dart';
import '../models/visitor_blacklist_isar.dart';
import '../models/pre_approved_visitor_isar.dart';
import '../models/scheduled_visit_isar.dart';
import '../models/package_delivery_isar.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorLocalDataSource localDataSource;
  final VisitorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final FirebaseStorage storage;
  final GoogleSheetsService googleSheetsService;

  VisitorRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.storage,
    required this.googleSheetsService,
  });

  @override
  Future<Either<Failure, Visitor>> checkInVisitor(Visitor visitor) async {
    try {
      final visitorIsar = VisitorIsar.fromEntity(visitor);
      await localDataSource.saveVisitor(visitorIsar);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.syncVisitor(_visitorToMap(visitor));
          final updatedVisitor = visitor.copyWith(isSynced: true);
          await localDataSource.saveVisitor(VisitorIsar.fromEntity(updatedVisitor));
          return Right(updatedVisitor);
        } catch (e) {
          // If remote sync fails, we still return Right because it's saved locally
          return Right(visitor);
        }
      }
      return Right(visitor);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Visitor>> checkOutVisitor(
      String visitorId, DateTime departureTime, String duration) async {
    try {
      final visitorIsar = await localDataSource.getVisitorById(visitorId);
      if (visitorIsar == null) return Left(CacheFailure());

      final updatedEntity = visitorIsar.toEntity().copyWith(
            departureTime: departureTime,
            expectedDuration: duration,
            status: VisitorStatus.checkedOut,
            isSynced: false,
          );

      await localDataSource.saveVisitor(VisitorIsar.fromEntity(updatedEntity));

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.syncVisitor(_visitorToMap(updatedEntity));
          final syncedEntity = updatedEntity.copyWith(isSynced: true);
          await localDataSource.saveVisitor(VisitorIsar.fromEntity(syncedEntity));
          return Right(syncedEntity);
        } catch (e) {
          return Right(updatedEntity);
        }
      }
      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Visitor>>> getVisitors(String schoolId) async {
    try {
      final localVisitors = await localDataSource.getVisitors(schoolId);
      return Right(localVisitors.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Visitor>>> searchVisitors(String schoolId, String query) async {
    try {
      final visitors = await localDataSource.getVisitors(schoolId);
      final filtered = visitors
          .where((v) =>
              v.fullName.toLowerCase().contains(query.toLowerCase()) ||
              v.phone.contains(query) ||
              (v.company?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .map((e) => e.toEntity())
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<VisitorBlacklist>>> getBlacklist() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteData = await remoteDataSource.getBlacklist();
        final blacklistIsar = remoteData.map((data) {
          final b = VisitorBlacklistIsar()
            ..blacklistId = data['id']
            ..visitorId = data['visitorId']
            ..fullName = data['fullName'] ?? ''
            ..phone = data['phone']
            ..reason = data['reason']
            ..dateAdded = (data['dateAdded'] as dynamic).toDate()
            ..addedBy = data['addedBy'];
          return b;
        }).toList();
        await localDataSource.saveBlacklist(blacklistIsar);
      }
      final localData = await localDataSource.getBlacklist();
      return Right(localData.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addToBlacklist(VisitorBlacklist blacklist) async {
    try {
      final blacklistIsar = VisitorBlacklistIsar()
        ..blacklistId = blacklist.id
        ..visitorId = blacklist.visitorId
        ..fullName = blacklist.fullName
        ..phone = blacklist.phone
        ..reason = blacklist.reason
        ..dateAdded = blacklist.dateAdded
        ..addedBy = blacklist.addedBy;

      await localDataSource.saveBlacklist([blacklistIsar]);

      if (await networkInfo.isConnected) {
        await remoteDataSource.addToBlacklist({
          'id': blacklist.id,
          'visitorId': blacklist.visitorId,
          'fullName': blacklist.fullName,
          'phone': blacklist.phone,
          'reason': blacklist.reason,
          'dateAdded': blacklist.dateAdded,
          'addedBy': blacklist.addedBy,
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<PreApprovedVisitor>>> getPreApprovedVisitors(String schoolId) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteData = await remoteDataSource.getPreApprovedVisitors(schoolId);
        final preApprovedIsar = remoteData.map((data) {
          final p = PreApprovedVisitorIsar()
            ..preApprovedId = data['id']
            ..schoolId = data['schoolId']
            ..fullName = data['fullName']
            ..phone = data['phone']
            ..purpose = data['purpose']
            ..expectedDate = (data['expectedDate'] as dynamic).toDate()
            ..host = data['host']
            ..isUsed = data['isUsed'];
          return p;
        }).toList();
        await localDataSource.savePreApprovedVisitors(preApprovedIsar);
      }
      final localData = await localDataSource.getPreApprovedVisitors(schoolId);
      return Right(localData.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markPreApprovedAsUsed(String preApprovedId) async {
    try {
      await localDataSource.markPreApprovedAsUsed(preApprovedId);
      if (await networkInfo.isConnected) {
        await remoteDataSource.markPreApprovedAsUsed(preApprovedId);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingRecords() async {
    try {
      if (!(await networkInfo.isConnected)) return Left(NetworkFailure());

      final worker = VisitorSyncWorker(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        storage: storage,
      );
      
      await worker.syncPendingRecords();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<List<Visitor>> watchVisitors(String schoolId) {
    return localDataSource.watchVisitors(schoolId).map(
      (list) => list.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, List<Visitor>>> getActiveVisitors(String schoolId) async {
    try {
      final visitors = await localDataSource.getActiveVisitors(schoolId);
      return Right(visitors.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Visitor>>> getOverstayedVisitors(String schoolId) async {
    try {
      final visitors = await localDataSource.getOverstayedVisitors(schoolId);
      return Right(visitors.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<ScheduledVisit>>> getScheduledVisits(String schoolId) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteData = await remoteDataSource.getScheduledVisits(schoolId);
        final isarVisits = remoteData.map((data) {
          return ScheduledVisitIsar()
            ..scheduledVisitId = data['id']
            ..schoolId = data['schoolId']
            ..fullName = data['fullName']
            ..phone = data['phone']
            ..host = data['host']
            ..hostId = data['hostId']
            ..purpose = data['purpose']
            ..scheduledTime = (data['scheduledTime'] as dynamic).toDate()
            ..isApproved = data['isApproved']
            ..isRejected = data['isRejected'] ?? false
            ..isCheckedIn = data['isCheckedIn'];
        }).toList();
        await localDataSource.saveScheduledVisits(isarVisits);
      }
      final localData = await localDataSource.getScheduledVisits(schoolId);
      return Right(localData.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> approveScheduledVisit(String visitId) async {
    try {
      await localDataSource.markScheduledVisitApproved(visitId);
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateScheduledVisit(visitId, {'isApproved': true});
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rejectScheduledVisit(String visitId) async {
    try {
      await localDataSource.markScheduledVisitRejected(visitId);
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateScheduledVisit(visitId, {'isRejected': true});
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> checkInScheduledVisit(String visitId) async {
    try {
      await localDataSource.markScheduledVisitCheckedIn(visitId);
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateScheduledVisit(visitId, {'isCheckedIn': true});
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logPackageDelivery(PackageDelivery delivery) async {
    try {
      final isar = PackageDeliveryIsar.fromEntity(delivery);
      await localDataSource.savePackageDelivery(isar);
      if (await networkInfo.isConnected) {
        await remoteDataSource.syncPackageDelivery({
          'id': delivery.id,
          'schoolId': delivery.schoolId,
          'recipientName': delivery.recipientName,
          'recipientId': delivery.recipientId,
          'courierName': delivery.courierName,
          'courierPhone': delivery.courierPhone,
          'trackingNumber': delivery.trackingNumber,
          'arrivalTime': delivery.arrivalTime,
          'isCollected': delivery.isCollected,
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<PackageDelivery>>> getPackageDeliveries(String schoolId) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteData = await remoteDataSource.getPackageDeliveries(schoolId);
        for (var data in remoteData) {
          final isar = PackageDeliveryIsar()
            ..packageId = data['id']
            ..schoolId = data['schoolId']
            ..recipientName = data['recipientName']
            ..recipientId = data['recipientId']
            ..courierName = data['courierName']
            ..courierPhone = data['courierPhone']
            ..trackingNumber = data['trackingNumber']
            ..arrivalTime = (data['arrivalTime'] as dynamic).toDate()
            ..collectedTime = data['collectedTime'] != null ? (data['collectedTime'] as dynamic).toDate() : null
            ..collectedBy = data['collectedBy']
            ..isCollected = data['isCollected'];
          await localDataSource.savePackageDelivery(isar);
        }
      }
      final localData = await localDataSource.getPackageDeliveries(schoolId);
      return Right(localData.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markPackageAsCollected(String packageId, String collectedBy) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.syncPackageDelivery({
          'id': packageId,
          'isCollected': true,
          'collectedBy': collectedBy,
          'collectedTime': DateTime.now(),
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Visitor>> reissueBadge(String visitorId) async {
    try {
      final visitorIsar = await localDataSource.getVisitorById(visitorId);
      if (visitorIsar == null) return Left(CacheFailure());

      final newBadgeNumber = 'BDG-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final updated = visitorIsar.toEntity().copyWith(
            badgeNumber: newBadgeNumber,
            badgeReplacementCount: visitorIsar.toEntity().badgeReplacementCount + 1,
            isSynced: false,
          );

      await localDataSource.saveVisitor(VisitorIsar.fromEntity(updated));

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.syncVisitor(_visitorToMap(updated));
          final synced = updated.copyWith(isSynced: true);
          await localDataSource.saveVisitor(VisitorIsar.fromEntity(synced));
          return Right(synced);
        } catch (e) {
          return Right(updated);
        }
      }
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> exportToSheets(String schoolId, String schoolName) async {
    try {
      final visitorsResult = await getVisitors(schoolId);
      return visitorsResult.fold(
        (failure) => Left(failure),
        (visitors) async {
          return await googleSheetsService.exportVisitors(
            schoolId: schoolId,
            schoolName: schoolName,
            visitors: visitors,
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Map<String, dynamic> _visitorToMap(Visitor v) {
    return {
      'id': v.id,
      'schoolId': v.schoolId,
      'fullName': v.fullName,
      'phone': v.phone,
      'nationalId': v.nationalId,
      'gender': v.gender,
      'vehicleNumber': v.vehicleNumber,
      'parkingSlot': v.parkingSlot,
      'company': v.company,
      'host': v.host,
      'hostId': v.hostId,
      'department': v.department,
      'purpose': v.purpose,
      'category': v.category.name,
      'expectedDuration': v.expectedDuration,
      'expectedDepartureTime': v.expectedDepartureTime,
      'itemsCarried': v.itemsCarried,
      'notes': v.notes,
      'arrivalTime': v.arrivalTime,
      'departureTime': v.departureTime,
      'status': v.status.name,
      'approvalStatus': v.approvalStatus.name,
      'deviceId': v.deviceId,
      'gateId': v.gateId,
      'photoUrl': v.photoUrl,
      'idImageUrl': v.idImageUrl,
      'signatureUrl': v.signatureUrl,
      'studentId': v.studentId,
      'scheduledVisitId': v.scheduledVisitId,
      'isBlacklisted': v.isBlacklisted,
      'badgeNumber': v.badgeNumber,
      'badgeReplacementCount': v.badgeReplacementCount,
      'agreementAccepted': v.agreementAccepted,
    };
  }
}
