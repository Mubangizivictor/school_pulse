import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import '../repositories/student_identity_repository.dart';

/// Orchestrates a student's NFC card lifecycle across the verification
/// credential store and the student identity record.
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
    return _enrichDuplicate(result);
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
    return _enrichDuplicate(result);
  }

  /// The online assignment path already updates StudentIdentity.nfcStatus
  /// inside the secure assignNfcCredential Cloud Function transaction. The
  /// previous client-side update here was redundant and failed under
  /// Firestore rules, turning a successful card assignment into a visible
  /// permission-denied error. Keep duplicate enrichment only.
  Future<Either<Failure, void>> _enrichDuplicate(
    Either<Failure, void> result,
  ) async {
    if (result.isRight()) return const Right(null);

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
