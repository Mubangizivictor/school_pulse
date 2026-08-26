import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import '../repositories/student_identity_repository.dart';

/// Canonical NFC lifecycle for students.
///
/// The physical card is bound directly to Student.id. StudentIdentity's
/// uniqueSystemId remains printable/auditable metadata but Attendance no
/// longer needs a second student_identities lookup to discover who was
/// scanned.
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
      identityId: studentId,
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
      identityId: studentId,
      identityType: 'student',
      schoolId: schoolId,
      reason: reason,
      studentId: studentId,
    );
    return _enrichDuplicate(result);
  }

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
  }) {
    return nfcCredentialRepository.revoke(
      credentialValue: cardUid,
      schoolId: schoolId,
      reason: reason,
      studentId: studentId,
    );
  }

  Future<Either<Failure, String?>> findAssignedCardForStudent({
    required String uniqueSystemId,
    required String schoolId,
  }) {
    // Parameter name retained for API compatibility; callers now pass the
    // canonical Student.id rather than StudentIdentity.uniqueSystemId.
    return nfcCredentialRepository.findAssignedCredential(
      identityId: uniqueSystemId,
      schoolId: schoolId,
    );
  }

  Future<Either<Failure, void>> reactivateForStudent({
    required String cardUid,
    required String studentId,
    required String schoolId,
  }) {
    return nfcCredentialRepository.reactivate(
      credentialValue: cardUid,
      schoolId: schoolId,
      studentId: studentId,
    );
  }
}
