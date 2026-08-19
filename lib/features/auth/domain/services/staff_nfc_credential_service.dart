import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';

/// Staff equivalent of NfcCredentialService. Kept as a separate file rather
/// than adding staff methods to the student service - same generic
/// NfcCredentialRepository underneath, but this way a staff-specific change
/// can never regress the already-shipped student NFC flow.
class StaffNfcCredentialService {
  final NfcCredentialRepository nfcCredentialRepository;

  StaffNfcCredentialService({required this.nfcCredentialRepository});

  Future<Either<Failure, void>> assignToStaff({
    required String cardUid,
    required String staffId,
    required String schoolId,
  }) {
    return nfcCredentialRepository.assign(
      credentialValue: cardUid,
      identityId: staffId,
      identityType: 'staff',
      schoolId: schoolId,
      staffId: staffId,
    );
  }

  Future<Either<Failure, void>> replaceForStaff({
    required String oldCardUid,
    required String newCardUid,
    required String staffId,
    required String schoolId,
    required String reason,
  }) {
    return nfcCredentialRepository.replace(
      oldCredentialValue: oldCardUid,
      newCredentialValue: newCardUid,
      identityId: staffId,
      identityType: 'staff',
      schoolId: schoolId,
      reason: reason,
      staffId: staffId,
    );
  }

  Future<Either<Failure, void>> revokeForStaff({
    required String cardUid,
    required String staffId,
    required String schoolId,
    required String reason,
  }) {
    return nfcCredentialRepository.revoke(
      credentialValue: cardUid,
      schoolId: schoolId,
      reason: reason,
    );
  }

  Future<Either<Failure, void>> reactivateForStaff({
    required String cardUid,
    required String staffId,
    required String schoolId,
  }) {
    return nfcCredentialRepository.reactivate(
      credentialValue: cardUid,
      schoolId: schoolId,
    );
  }

  Future<Either<Failure, String?>> findAssignedCardForStaff({
    required String staffId,
    required String schoolId,
  }) {
    return nfcCredentialRepository.findAssignedCredential(
      identityId: staffId,
      schoolId: schoolId,
    );
  }
}
