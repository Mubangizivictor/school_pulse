import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import '../repositories/student_identity_repository.dart';

/// Orchestrates a student's NFC card lifecycle across the two stores it
/// touches: the verification engine's local `CachedCredentialIsar` /
/// `RevokedCredentialIsar` tables (what `IdentityResolver` actually reads
/// at scan time) and `StudentIdentity.nfcStatus` (the informational status
/// shown on the student's own identity record). Each method here is not
/// atomic across the two - if the Firestore status update fails after the
/// card mapping already succeeded, the card is scan-usable but the
/// student's displayed nfcStatus lags until retried.
class NfcCredentialService {
  final NfcCredentialRepository nfcCredentialRepository;
  final StudentIdentityRepository studentIdentityRepository;

  NfcCredentialService({
    required this.nfcCredentialRepository,
    required this.studentIdentityRepository,
  });

  Future<Either<Failure, void>> assignToStudent({
    required String cardUid,
    required String studentId,
    required String uniqueSystemId,
    required String schoolId,
  }) async {
    final result = await nfcCredentialRepository.assign(
      credentialValue: cardUid,
      identityId: uniqueSystemId,
      identityType: 'student',
      schoolId: schoolId,
      studentId: studentId,
    );
    return _enrichDuplicateAndActivate(result, studentId);
  }

  Future<Either<Failure, void>> replaceForStudent({
    required String oldCardUid,
    required String newCardUid,
    required String studentId,
    required String uniqueSystemId,
    required String schoolId,
    required String reason,
  }) async {
    final result = await nfcCredentialRepository.replace(
      oldCredentialValue: oldCardUid,
      newCredentialValue: newCardUid,
      identityId: uniqueSystemId,
      identityType: 'student',
      schoolId: schoolId,
      reason: reason,
      studentId: studentId,
    );
    // replace() assigns the new card internally, so the same
    // already-registered-elsewhere conflict assignToStudent handles can
    // surface here too (revoke of the old card still succeeds either way).
    return _enrichDuplicateAndActivate(result, studentId);
  }

  /// Shared tail for assign/replace: on a card-already-registered
  /// conflict, resolves the other student's name so an authorised admin
  /// can act on it instead of getting a dead-end "already assigned"
  /// message; on success, flips this student's own nfcStatus to active.
  Future<Either<Failure, void>> _enrichDuplicateAndActivate(
    Either<Failure, void> result,
    String studentId,
  ) async {
    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => null)!;
      if (failure is! DuplicateCredentialFailure ||
          failure.conflictingIdentityType != 'student') {
        return Left(failure);
      }
      final conflictingStudent = await studentIdentityRepository
          .getStudentByUniqueId(failure.conflictingIdentityId);
      final name = conflictingStudent.fold(
        (_) => null,
        (student) => student?.name,
      );
      return Left(
        DuplicateCredentialFailure(
          conflictingIdentityId: failure.conflictingIdentityId,
          conflictingIdentityType: failure.conflictingIdentityType,
          message: name != null
              ? 'This card is already registered to $name.'
              : failure.message,
        ),
      );
    }

    return studentIdentityRepository.updateNfcStatus(studentId, 'active');
  }

  Future<Either<Failure, void>> revokeForStudent({
    required String cardUid,
    required String studentId,
    required String schoolId,
    required String reason,
  }) async {
    final result = await nfcCredentialRepository.revoke(
      credentialValue: cardUid,
      schoolId: schoolId,
      reason: reason,
    );
    return result.fold(
      Left.new,
      (_) => studentIdentityRepository.updateNfcStatus(studentId, 'revoked'),
    );
  }

  Future<Either<Failure, String?>> findAssignedCardForStudent({
    required String uniqueSystemId,
    required String schoolId,
  }) {
    return nfcCredentialRepository.findAssignedCredential(
      identityId: uniqueSystemId,
      schoolId: schoolId,
    );
  }

  Future<Either<Failure, void>> reactivateForStudent({
    required String cardUid,
    required String studentId,
    required String schoolId,
  }) async {
    final result = await nfcCredentialRepository.reactivate(
      credentialValue: cardUid,
      schoolId: schoolId,
    );
    return result.fold(
      Left.new,
      (_) => studentIdentityRepository.updateNfcStatus(studentId, 'active'),
    );
  }
}
