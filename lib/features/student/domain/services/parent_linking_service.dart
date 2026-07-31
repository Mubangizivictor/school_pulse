import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parent_access_code.dart';
import '../repositories/student_repository.dart';

/// Closes the gap between "student enrolled" and "parent can sign in":
/// admitStudent() never touched ParentAccessCode, so a newly enrolled
/// student had no route to a parent login unless an admin separately
/// remembered to create one from User Management. Reuses the sibling
/// concept already built into ParentAccessCode (one code, many
/// studentIds) - if the parent's phone number already has a code (an
/// existing sibling), the new student is added to it rather than a
/// second, disconnected code being created for the same family.
class ParentLinkingService {
  final StudentRepository repository;

  ParentLinkingService(this.repository);

  Future<Either<Failure, ParentAccessCode?>> findExistingCodeForPhone({
    required String schoolId,
    required String phoneNumber,
  }) async {
    final result = await repository.getAllAccessCodes(schoolId: schoolId);
    return result.fold(
      Left.new,
      (codes) {
        final normalized = phoneNumber.trim();
        final matches = codes.where((c) => c.phoneNumber?.trim() == normalized);
        return Right(matches.isEmpty ? null : matches.first);
      },
    );
  }

  /// Returns the parent access code (new or the existing sibling code the
  /// student was added to).
  Future<Either<Failure, String>> linkStudentToParent({
    required String studentId,
    required String studentName,
    required String schoolId,
    required String phoneNumber,
    String? parentName,
  }) async {
    final existingResult = await findExistingCodeForPhone(schoolId: schoolId, phoneNumber: phoneNumber);

    return existingResult.fold(
      (failure) async => Left(failure),
      (existing) async {
        if (existing == null) {
          return repository.createAccessCode(
            studentIds: [studentId],
            schoolId: schoolId,
            phoneNumber: phoneNumber,
            parentName: parentName,
          );
        }

        if (existing.studentIds.contains(studentId)) {
          return Right(existing.parentCode);
        }

        final updated = ParentAccessCode(
          id: existing.id,
          parentCode: existing.parentCode,
          schoolId: existing.schoolId,
          studentIds: [...existing.studentIds, studentId],
          studentNames: [...existing.studentNames, studentName],
          parentName: existing.parentName ?? parentName,
          phoneNumber: existing.phoneNumber,
          pin: existing.pin,
          mustChangePin: existing.mustChangePin,
          isActive: existing.isActive,
          deactivationReason: existing.deactivationReason,
        );
        final updateResult = await repository.updateAccessCode(updated);
        return updateResult.fold(Left.new, (_) => Right(existing.parentCode));
      },
    );
  }
}
