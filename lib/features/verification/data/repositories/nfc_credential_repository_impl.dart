import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import '../datasources/verification_local_data_source.dart';
import '../models/verification_isar_models.dart';
import '../../domain/repositories/nfc_credential_repository.dart';

/// Local Isar writes are always the source of truth for "did this
/// operation succeed" - the Firestore push below is best-effort, mirroring
/// VerificationEventRecorderImpl: if the device is offline (or the push
/// otherwise fails), the local mapping still takes effect immediately and
/// resolves correctly on *this* device, it just won't be visible to other
/// devices until they resolve a scan miss against Firestore (see
/// IdentityResolverImpl._resolveNfc's cache-miss fallback) or this device
/// is next online for another assign/revoke/reactivate call.
class NfcCredentialRepositoryImpl implements NfcCredentialRepository {
  final VerificationLocalDataSource localDataSource;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  NfcCredentialRepositoryImpl({
    required this.localDataSource,
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> assign({
    required String credentialValue,
    required String identityId,
    required String identityType,
    required String schoolId,
  }) async {
    try {
      final existing = await localDataSource.findCredential(credentialValue, schoolId);
      if (existing != null && existing.status == 'active' && existing.identityId != identityId) {
        return Left(ServerFailure(
          'This card is already assigned to another identity. Revoke or replace it first.',
        ));
      }

      // Reassigning a previously-revoked card ("reuse after secure
      // deactivation") must clear the denylist entry too, or the resolver
      // would keep rejecting it - findRevocation is checked before
      // findCredential at scan time.
      await localDataSource.deleteRevocation(credentialValue, schoolId);

      final credential = CachedCredentialIsar()
        ..credentialValue = credentialValue
        ..credentialType = 'nfc'
        ..identityId = identityId
        ..identityType = identityType
        ..schoolId = schoolId
        ..status = 'active'
        ..updatedAt = DateTime.now();
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
  }) async {
    final revokeResult = await revoke(credentialValue: oldCredentialValue, schoolId: schoolId, reason: reason);
    return revokeResult.fold(
      Left.new,
      (_) => assign(
        credentialValue: newCredentialValue,
        identityId: identityId,
        identityType: identityType,
        schoolId: schoolId,
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
      final existing = await localDataSource.findCredential(credentialValue, schoolId);
      if (existing != null) {
        existing.status = 'revoked';
        existing.updatedAt = DateTime.now();
        await localDataSource.cacheCredential(existing);
        await _pushCredential(existing);
      }

      final revocation = RevokedCredentialIsar()
        ..credentialValue = credentialValue
        ..schoolId = schoolId
        ..revokedAt = DateTime.now()
        ..reason = reason;
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
      final existing = await localDataSource.findCredential(credentialValue, schoolId);
      if (existing == null) {
        return Left(ServerFailure('No prior mapping found for this card - assign it instead.'));
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
      final existing = await localDataSource.findCredentialByIdentity(identityId, schoolId);
      return Right(existing?.credentialValue);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _pushCredential(CachedCredentialIsar credential) async {
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
      });
    } catch (_) {
      // Local write already succeeded - a later assign/revoke/reactivate
      // on this device, or another device's scan-time fallback read,
      // will pick this mapping up eventually.
    }
  }

  Future<void> _pushRevocation(RevokedCredentialIsar revocation) async {
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
    } catch (_) {
      // Same as _pushCredential - local denylist already applies on this
      // device regardless.
    }
  }

  Future<void> _pushRevocationDeleted(String schoolId, String credentialValue) async {
    if (!await networkInfo.isConnected) return;
    try {
      await firestore.collection('schools').doc(schoolId).collection('revoked_credentials').doc(credentialValue).delete();
    } catch (_) {}
  }
}
