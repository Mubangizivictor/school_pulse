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
    required String schoolId,
  }) async {
    if (functions == null || studentId == null) return null;
    if (!await networkInfo.isConnected) return null;

    try {
      await functions!.httpsCallable('assignNfcCredential').call<Map<String, dynamic>>({
        'cardUid': cardUid,
        'studentId': studentId,
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
          e.message ?? 'NFC assignment failed on the server (${e.code}).',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('NFC assignment failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> assign({
    required String credentialValue,
    required String identityId,
    required String identityType,
    required String schoolId,
    String? studentId,
  }) async {
    try {
      var serverConfirmed = false;
      if (identityType == 'student') {
        final serverResult = await _assignServerSide(
          cardUid: credentialValue,
          studentId: studentId,
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
      await _pushCredential(credential);
      await _pushRevocationDeleted(schoolId, credentialValue);
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
  }) async {
    final revokeResult = await revoke(
      credentialValue: oldCredentialValue,
      schoolId: schoolId,
      reason: reason,
    );
    return revokeResult.fold(
      Left.new,
      (_) => assign(
        credentialValue: newCredentialValue,
        identityId: identityId,
        identityType: identityType,
        schoolId: schoolId,
        studentId: studentId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> revoke({
    required String credentialValue,
    required String schoolId,
    required String reason,
  }) async {
    try {
      final existing = await localDataSource.findCredential(
        credentialValue,
        schoolId,
      );
      if (existing != null) {
        existing.status = 'revoked';
        existing.updatedAt = DateTime.now();
        await localDataSource.cacheCredential(existing);
        await _pushCredential(existing);
      }

      final revocation = RevokedCredential(
        credentialValue: credentialValue,
        schoolId: schoolId,
        revokedAt: DateTime.now(),
        reason: reason,
      );
      await localDataSource.saveRevocation(revocation);
      await _pushRevocation(revocation);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reactivate({
    required String credentialValue,
    required String schoolId,
  }) async {
    try {
      final existing = await localDataSource.findCredential(
        credentialValue,
        schoolId,
      );
      if (existing == null) {
        return Left(
          ServerFailure(
            'No prior mapping found for this card - assign it instead.',
          ),
        );
      }

      await localDataSource.deleteRevocation(credentialValue, schoolId);
      existing.status = 'active';
      existing.updatedAt = DateTime.now();
      await localDataSource.cacheCredential(existing);
      await _pushCredential(existing);
      await _pushRevocationDeleted(schoolId, credentialValue);
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

  Future<void> _pushCredential(CachedCredential credential) async {
    if (!await networkInfo.isConnected) return;
    try {
      await firestore
          .collection('schools')
          .doc(credential.schoolId)
          .collection('credentials')
          .doc(credential.credentialValue)
          .set({
            'credentialValue': credential.credentialValue,
            'credentialType': credential.credentialType,
            'identityId': credential.identityId,
            'identityType': credential.identityType,
            'schoolId': credential.schoolId,
            'status': credential.status,
            'updatedAt': credential.updatedAt.toIso8601String(),
            'credentialVersion': credential.credentialVersion,
          }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _pushRevocation(RevokedCredential revocation) async {
    if (!await networkInfo.isConnected) return;
    try {
      await firestore
          .collection('schools')
          .doc(revocation.schoolId)
          .collection('revoked_credentials')
          .doc(revocation.credentialValue)
          .set({
            'credentialValue': revocation.credentialValue,
            'schoolId': revocation.schoolId,
            'revokedAt': revocation.revokedAt.toIso8601String(),
            'reason': revocation.reason,
          });
    } catch (_) {}
  }

  Future<void> _pushRevocationDeleted(
    String schoolId,
    String credentialValue,
  ) async {
    if (!await networkInfo.isConnected) return;
    try {
      await firestore
          .collection('schools')
          .doc(schoolId)
          .collection('revoked_credentials')
          .doc(credentialValue)
          .delete();
    } catch (_) {}
  }
}
