import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/staff_identity.dart';
import '../../domain/repositories/staff_identity_repository.dart';
import '../models/staff_identity_model.dart';
import '../../../verification/data/datasources/verification_local_data_source.dart';
import '../../../verification/domain/entities/verification_cache_records.dart';
import '../../../verification/domain/services/qr_credential_codec.dart';

/// Admin-only, low-frequency lookups (opening a staff member's ID card
/// screen) - unlike StudentIdentityRepositoryImpl this skips the Isar
/// offline cache split and goes straight to Firestore/Cloud Functions.
class StaffIdentityRepositoryImpl implements StaffIdentityRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final VerificationLocalDataSource verificationLocalDataSource;
  final QrCredentialCodec qrCredentialCodec;

  StaffIdentityRepositoryImpl({
    required this.firestore,
    required this.functions,
    required this.verificationLocalDataSource,
    QrCredentialCodec? qrCredentialCodec,
  }) : qrCredentialCodec = qrCredentialCodec ?? const QrCredentialCodec();

  @override
  Future<Either<Failure, StaffIdentity>> getOrIssueStaffIdentity(
    String staffId,
  ) async {
    try {
      final callable = functions.httpsCallable('issueStaffIdentity');
      final result = await callable.call<Map<String, dynamic>>({
        'staffId': staffId,
      });
      final identityData = Map<String, dynamic>.from(
        result.data['identity'] as Map,
      );
      final identity = StaffIdentityModel.fromFirestore(identityData);
      await _cacheQrCredential(identity);
      return Right(identity);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Credentials resolve to the canonical staff uid (UserEntity.id) so
  /// IdentityResolver's staff lookup path needs no extra indirection.
  Future<void> _cacheQrCredential(StaffIdentity identity) async {
    final token = qrCredentialCodec.parse(identity.qrCodeData);
    if (token == null) return;
    await verificationLocalDataSource.cacheCredential(
      CachedCredential(
        credentialValue: token,
        credentialType: 'qr',
        identityId: identity.staffId,
        identityType: 'staff',
        schoolId: identity.schoolId,
        status: 'active',
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, StaffIdentity>> regenerateQrCredential(
    StaffIdentity identity,
  ) async {
    try {
      final callable = functions.httpsCallable('regenerateStaffQrCredential');
      final result = await callable.call<Map<String, dynamic>>({
        'staffId': identity.staffId,
      });
      final newQrCodeData = result.data['qrCodeData'] as String;

      final oldToken = qrCredentialCodec.parse(identity.qrCodeData);
      if (oldToken != null) {
        final old = await verificationLocalDataSource.findCredential(
          oldToken,
          identity.schoolId,
        );
        if (old != null) {
          old.status = 'replaced';
          old.updatedAt = DateTime.now();
          await verificationLocalDataSource.cacheCredential(old);
        }
      }

      final updated = StaffIdentityModel(
        staffId: identity.staffId,
        schoolId: identity.schoolId,
        uniqueSystemId: identity.uniqueSystemId,
        qrCodeData: newQrCodeData,
        nfcStatus: identity.nfcStatus,
      );
      await _cacheQrCredential(updated);
      return Right(updated);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
