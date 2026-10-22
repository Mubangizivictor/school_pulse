import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import '../datasources/verification_local_data_source.dart';
import '../../domain/entities/verification_cache_records.dart';
import '../../domain/repositories/nfc_credential_repository.dart';

class NfcCredentialRepositoryImpl implements NfcCredentialRepository {
  final VerificationLocalDataSource localDataSource;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  final FirebaseFunctions? functions;

  NfcCredentialRepositoryImpl({
    required this.localDataSource,
    required this.firestore,
    required this.networkInfo,
    this.functions,
  });

  Future<Either<Failure, void>?> _assignServerSide({
    required String cardUid,
    required String? studentId,
    required String? staffId,
    required String schoolId,
  }) async {
    if (functions == null) return null;
    if (studentId == null && staffId == null) return null;
    if (!await networkInfo.isConnected) return null;

    try {
      final callableName = staffId != null
          ? 'assignStaffNfcCredential'
          : 'assignNfcCredential';
      final payload = staffId != null
          ? {'cardUid': cardUid, 'staffId': staffId}
          : {'cardUid': cardUid, 'studentId': studentId};
      await functions!
          .httpsCallable(callableName)
          .call<Map<String, dynamic>>(payload);
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        final details = e.details is Map ? e.details as Map : const {};
        return Left(
          DuplicateCredentialFailure(
            conflictingIdentityId:
                details['conflictingIdentityId'] as String? ?? '',
            conflictingIdentityType:
                details['conflictingIdentityType'] as String? ??
                (staffId != null ? 'staff' : 'student'),
          ),
        );
      }
      return Left(
        ServerFailure(
          e.message ?? 'NFC assignment failed on the server (${e.code}).',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('NFC assignment failed: $e'));
    }
  }

  Future<Either<Failure, void>?> _replaceServerSide({
    required String oldCardUid,
    required String newCardUid,
    required String? studentId,
    required String reason,
  }) async {
    if (functions == null || studentId == null) return null;
    if (!await networkInfo.isConnected) return null;
    try {
      await functions!
          .httpsCallable('replaceNfcCredential')
          .call<Map<String, dynamic>>({
            'cardUid': oldCardUid,
            'newCardUid': newCardUid,
            'studentId': studentId,
            'reason': reason,
          });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        final details = e.details is Map ? e.details as Map : const {};
        return Left(
          DuplicateCredentialFailure(
            conflictingIdentityId:
                details['conflictingIdentityId'] as String? ?? '',
            conflictingIdentityType:
                details['conflictingIdentityType'] as String? ?? 'student',
          ),
        );
      }
      return Left(
        ServerFailure(
          e.message ?? 'NFC card replacement failed on the server (${e.code}).',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('NFC card replacement failed: $e'));
    }
  }

  Future<Either<Failure, void>?> _revokeServerSide({
    required String cardUid,
    required String? studentId,
    required String reason,
  }) async {
    if (functions == null || studentId == null) return null;
    if (!await networkInfo.isConnected) return null;
    try {
      await functions!
          .httpsCallable('revokeNfcCredential')
          .call<Map<String, dynamic>>({
            'cardUid': cardUid,
            'studentId': studentId,
            'reason': reason,
          });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(
        ServerFailure(
          e.message ?? 'NFC card revocation failed on the server (${e.code}).',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('NFC card revocation failed: $e'));
    }
  }

  Future<Either<Failure, void>?> _reactivateServerSide({
    required String cardUid,
    required String? studentId,
  }) async {
    if (functions == null || studentId == null) return null;
    if (!await networkInfo.isConnected) return null;
    try {
      await functions!
          .httpsCallable('reactivateNfcCredential')
          .call<Map<String, dynamic>>({
            'cardUid': cardUid,
            'studentId': studentId,
          });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(
        ServerFailure(
          e.message ??
              'NFC card reactivation failed on the server (${e.code}).',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('NFC card reactivation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> assign({
    required String credentialValue,
    required String identityId,
    required String identityType,
    required String schoolId,
    String? studentId,
    String? staffId,
  }) async {
    try {
      var serverConfirmed = false;
      if (identityType == 'student' || identityType == 'staff') {
        final serverResult = await _assignServerSide(
          cardUid: credentialValue,
          studentId: studentId,
          staffId: staffId,
          schoolId: schoolId,
        );
        if (serverResult != null) {
          if (serverResult.isLeft()) return serverResult;
          serverConfirmed = true;
        }
      }

      final existing = await localDataSource.findCredential(
        credentialValue,
        schoolId,
      );
      if (!serverConfirmed &&
          existing != null &&
          existing.status == 'active' &&
          existing.identityId != identityId) {
        return Left(
          DuplicateCredentialFailure(
            conflictingIdentityId: existing.identityId,
            conflictingIdentityType: existing.identityType,
          ),
        );
      }

      // A server-confirmed assignment is authoritative. This intentionally
      // overwrites old local entries that used StudentIdentity.uniqueSystemId
      // so existing test cards migrate cleanly to canonical Student.id.
      // Firestore rules deny direct client writes to credentials/
      // revoked_credentials (every mutation now goes through a Cloud
      // Function), so only the local Isar cache is updated here - it is a
      // read-side mirror for offline scan resolution, not a write path.
      await localDataSource.deleteRevocation(credentialValue, schoolId);
      final credential = CachedCredential(
        credentialValue: credentialValue,
        credentialType: 'nfc',
        identityId: identityId,
        identityType: identityType,
        schoolId: schoolId,
        status: 'active',
        updatedAt: DateTime.now(),
      );
      await localDataSource.cacheCredential(credential);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> replace({
    required String oldCredentialValue,
    required String newCredentialValue,
    required String identityId,
    required String identityType,
    required String schoolId,
    required String reason,
    String? studentId,
    String? staffId,
  }) async {
    try {
      if (identityType == 'student' && studentId != null) {
        final serverResult = await _replaceServerSide(
          oldCardUid: oldCredentialValue,
          newCardUid: newCredentialValue,
          studentId: studentId,
          reason: reason,
        );
        if (serverResult != null) {
          if (serverResult.isLeft()) return serverResult;
          await localDataSource.deleteRevocation(oldCredentialValue, schoolId);
          await localDataSource.cacheCredential(
            CachedCredential(
              credentialValue: newCredentialValue,
              credentialType: 'nfc',
              identityId: identityId,
              identityType: identityType,
              schoolId: schoolId,
              status: 'active',
              updatedAt: DateTime.now(),
            ),
          );
          return const Right(null);
        }
      }

      // Offline or non-student identity: fall back to the local
      // revoke-then-assign orchestration so the device's own gate keeps
      // working without connectivity.
      final revokeResult = await revoke(
        credentialValue: oldCredentialValue,
        schoolId: schoolId,
        reason: reason,
      );
      return await revokeResult.fold(
        Left.new,
        (_) => assign(
          credentialValue: newCredentialValue,
          identityId: identityId,
          identityType: identityType,
          schoolId: schoolId,
          studentId: studentId,
          staffId: staffId,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revoke({
    required String credentialValue,
    required String schoolId,
    required String reason,
    String? studentId,
  }) async {
    try {
      if (studentId != null) {
        final serverResult = await _revokeServerSide(
          cardUid: credentialValue,
          studentId: studentId,
          reason: reason,
        );
        if (serverResult != null && serverResult.isLeft()) {
          return serverResult;
        }
      }

      final existing = await localDataSource.findCredential(
        credentialValue,
        schoolId,
      );
      if (existing != null) {
        existing.status = 'revoked';
        existing.updatedAt = DateTime.now();
        await localDataSource.cacheCredential(existing);
      }

      await localDataSource.saveRevocation(
        RevokedCredential(
          credentialValue: credentialValue,
          schoolId: schoolId,
          revokedAt: DateTime.now(),
          reason: reason,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reactivate({
    required String credentialValue,
    required String schoolId,
    String? studentId,
  }) async {
    try {
      if (studentId != null) {
        final serverResult = await _reactivateServerSide(
          cardUid: credentialValue,
          studentId: studentId,
        );
        if (serverResult != null && serverResult.isLeft()) {
          return serverResult;
        }
      }

      final existing = await localDataSource.findCredential(
        credentialValue,
        schoolId,
      );
      if (existing == null && studentId == null) {
        return Left(
          ServerFailure(
            'No prior mapping found for this card - assign it instead.',
          ),
        );
      }

      await localDataSource.deleteRevocation(credentialValue, schoolId);
      if (existing != null) {
        existing.status = 'active';
        existing.updatedAt = DateTime.now();
        await localDataSource.cacheCredential(existing);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> findAssignedCredential({
    required String identityId,
    required String schoolId,
  }) async {
    try {
      final existing = await localDataSource.findCredentialByIdentity(
        identityId,
        schoolId,
      );
      return Right(existing?.credentialValue);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
