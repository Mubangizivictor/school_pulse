import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_event_recorder.dart';

/// The engine's own audit trail for a verification attempt. This is
/// deliberately separate from Security's `SecurityRepository.record*
/// Movement` calls, which remain the system of record for the movement
/// itself - `VerificationSessionBloc` calls both, not this instead of
/// that.
class VerificationEventRecorderImpl implements VerificationEventRecorder {
  final VerificationLocalDataSource localDataSource;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  VerificationEventRecorderImpl({
    required this.localDataSource,
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> record({
    required VerificationDecision decision,
    required VerificationContext context,
    required ScanCredential credential,
    required String direction,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final eventId = const Uuid().v4();
      final schoolId = context.gate.schoolId;

      final event = VerificationEventIsar()
        ..eventId = eventId
        ..schoolId = schoolId
        ..gateId = context.gate.id
        ..operatorId = context.operatorUser.id
        ..credentialKind = _kindOf(credential)
        ..identityId = _identityIdOf(decision.identity)
        ..identityType = _identityTypeOf(decision.identity)
        ..outcome = decision.outcome.name
        ..reasonCode = decision.reasonCode
        ..direction = direction
        ..timestamp = context.requestedAt
        ..deviceId = context.deviceId
        ..isSynced = false;

      await localDataSource.saveVerificationEvent(event);

      if (isConnected) {
        try {
          await _pushEvent(schoolId, event);
          event.isSynced = true;
          await localDataSource.saveVerificationEvent(event);
        } catch (_) {
          // The local record succeeded regardless - leave isSynced = false
          // so syncPendingEvents retries it later, rather than failing the
          // whole operation (and rather than marking it synced when it
          // never actually reached Firestore).
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingEvents() async {
    try {
      if (!(await networkInfo.isConnected)) return const Left(NetworkFailure('No internet connection'));

      final unsynced = await localDataSource.getUnsyncedEvents();
      for (final event in unsynced) {
        await _pushEvent(event.schoolId, event);
        await localDataSource.markEventSynced(event.eventId);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _pushEvent(String schoolId, VerificationEventIsar event) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('verification_events')
        .doc(event.eventId)
        .set({
      'eventId': event.eventId,
      'schoolId': event.schoolId,
      'gateId': event.gateId,
      'operatorId': event.operatorId,
      'credentialKind': event.credentialKind,
      'identityId': event.identityId,
      'identityType': event.identityType,
      'outcome': event.outcome,
      'reasonCode': event.reasonCode,
      'direction': event.direction,
      'timestamp': event.timestamp.toIso8601String(),
      'deviceId': event.deviceId,
    });
  }

  String _kindOf(ScanCredential credential) => switch (credential) {
        QrScanCredential() => 'qr',
        NfcScanCredential() => 'nfc',
        FingerprintScanCredential() => 'fingerprint',
        ManualCodeScanCredential() => 'manualCode',
        ParentCodeScanCredential() => 'parentCode',
        StaffLookupScanCredential() => 'staffLookup',
      };

  String _identityIdOf(ResolvedIdentity identity) => switch (identity) {
        StudentResolvedIdentity(:final id) => id,
        StaffResolvedIdentity(:final id) => id,
        ParentPickupResolvedIdentity(:final childId) => childId,
        UnresolvedResolvedIdentity() => 'unknown',
      };

  String _identityTypeOf(ResolvedIdentity identity) => switch (identity) {
        StudentResolvedIdentity() => 'student',
        StaffResolvedIdentity() => 'staff',
        ParentPickupResolvedIdentity() => 'student',
        UnresolvedResolvedIdentity() => 'unknown',
      };
}
