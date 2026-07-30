import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../datasources/visitor_local_data_source.dart';
import '../datasources/visitor_remote_data_source.dart';
import '../../domain/entities/visitor.dart';
import '../models/visitor_isar.dart';

class VisitorSyncWorker {
  final VisitorLocalDataSource localDataSource;
  final VisitorRemoteDataSource remoteDataSource;
  final FirebaseStorage storage;

  VisitorSyncWorker({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.storage,
  });

  Future<void> syncPendingRecords() async {
    final pending = await localDataSource.getPendingSyncVisitors();
    
    for (var visitorIsar in pending) {
      try {
        Visitor visitor = visitorIsar.toEntity();
        
        // 1. Upload photo if exists and not yet uploaded (remote path would be needed in entity if we tracked it)
        // For simplicity, we'll check if photoLocalPath exists and try to upload it if we don't have a remote URL
        // In a real app, you'd probably have a 'photoUrl' field in Visitor entity.
        
        String? remotePhotoUrl;
        if (visitor.photoLocalPath != null) {
          final file = File(visitor.photoLocalPath!);
          if (await file.exists()) {
            final fileName = p.basename(visitor.photoLocalPath!);
            final ref = storage.ref().child('visitors/${visitor.schoolId}/${visitor.id}/$fileName');
            await ref.putFile(file);
            remotePhotoUrl = await ref.getDownloadURL();
          }
        }

        String? remoteIdImageUrl;
        if (visitor.idImageLocalPath != null) {
          final file = File(visitor.idImageLocalPath!);
          if (await file.exists()) {
            final fileName = p.basename(visitor.idImageLocalPath!);
            final ref = storage.ref().child('visitors/${visitor.schoolId}/${visitor.id}/$fileName');
            await ref.putFile(file);
            remoteIdImageUrl = await ref.getDownloadURL();
          }
        }

        String? remoteSignatureUrl;
        if (visitor.signatureLocalPath != null) {
          final file = File(visitor.signatureLocalPath!);
          if (await file.exists()) {
            final fileName = p.basename(visitor.signatureLocalPath!);
            final ref = storage.ref().child('visitors/${visitor.schoolId}/${visitor.id}/$fileName');
            await ref.putFile(file);
            remoteSignatureUrl = await ref.getDownloadURL();
          }
        }

        // 2. Sync record to Firestore
        final visitorMap = _visitorToMap(visitor);
        if (remotePhotoUrl != null) {
          visitorMap['photoUrl'] = remotePhotoUrl;
        }
        if (remoteIdImageUrl != null) {
          visitorMap['idImageUrl'] = remoteIdImageUrl;
        }
        if (remoteSignatureUrl != null) {
          visitorMap['signatureUrl'] = remoteSignatureUrl;
        }

        await remoteDataSource.syncVisitor(visitorMap);

        // 3. Mark as synced locally
        final synced = visitor.copyWith(
          isSynced: true,
          photoUrl: remotePhotoUrl ?? visitor.photoUrl,
          idImageUrl: remoteIdImageUrl ?? visitor.idImageUrl,
          signatureUrl: remoteSignatureUrl ?? visitor.signatureUrl,
        );
        await localDataSource.saveVisitor(VisitorIsar.fromEntity(synced));

        // 4. Local storage cleanup policy:
        if (remotePhotoUrl != null && visitor.photoLocalPath != null) {
          final file = File(visitor.photoLocalPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        if (remoteIdImageUrl != null && visitor.idImageLocalPath != null) {
          final file = File(visitor.idImageLocalPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        if (remoteSignatureUrl != null && visitor.signatureLocalPath != null) {
          final file = File(visitor.signatureLocalPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Update record to reflect local files are gone
        final cleaned = synced.copyWith(
          photoLocalPath: remotePhotoUrl != null ? null : synced.photoLocalPath,
          idImageLocalPath: remoteIdImageUrl != null ? null : synced.idImageLocalPath,
          signatureLocalPath: remoteSignatureUrl != null ? null : synced.signatureLocalPath,
        );
        await localDataSource.saveVisitor(VisitorIsar.fromEntity(cleaned));
        
      } catch (e) {
        // Log error and continue with next record
        // ignore: avoid_print
        debugPrint('Error syncing visitor ${visitorIsar.visitorId}: $e');
      }
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
