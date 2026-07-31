import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../datasources/verification_local_data_source.dart';
import '../models/verification_isar_models.dart';
import '../../domain/repositories/nfc_credential_repository.dart';

class NfcCredentialRepositoryImpl implements NfcCredentialRepository {
  final VerificationLocalDataSource localDataSource;

  NfcCredentialRepositoryImpl({required this.localDataSource});

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

      await localDataSource.cacheCredential(
        CachedCredentialIsar()
          ..credentialValue = credentialValue
          ..credentialType = 'nfc'
          ..identityId = identityId
          ..identityType = identityType
          ..schoolId = schoolId
          ..status = 'active'
          ..updatedAt = DateTime.now(),
      );
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
      }

      await localDataSource.saveRevocation(
        RevokedCredentialIsar()
          ..credentialValue = credentialValue
          ..schoolId = schoolId
          ..revokedAt = DateTime.now()
          ..reason = reason,
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
}
