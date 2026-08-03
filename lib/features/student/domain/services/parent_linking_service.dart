import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../relationships/domain/entities/relationship_enums.dart';
import '../../../relationships/domain/usecases/create_relationship.dart';
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
///
/// Also records a ParentStudentRelationship alongside the access code
/// (Phase 4) - the code stays the pre-activation artifact, the
/// relationship is the real, lockable, auditable link. userId is left
/// null here since the parent hasn't activated a portal account yet.
class ParentLinkingService {
  final StudentRepository repository;
  final CreateRelationship createRelationship;

  ParentLinkingService(this.repository, this.createRelationship);

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
  /// student was added to). [createdBy] is the staff member performing the
  /// link, recorded as the new relationship's creator.
  Future<Either<Failure, String>> linkStudentToParent({
    required String studentId,
    required String studentName,
    required String schoolId,
    required String phoneNumber,
    required String createdBy,
    String? parentName,
  }) async {
    final existingResult = await findExistingCodeForPhone(schoolId: schoolId, phoneNumber: phoneNumber);

    return existingResult.fold(
      (failure) async => Left(failure),
      (existing) async {
        if (existing == null) {
          final codeResult = await repository.createAccessCode(
            studentIds: [studentId],
            schoolId: schoolId,
            phoneNumber: phoneNumber,
            parentName: parentName,
          );
          return codeResult.fold(Left.new, (code) async {
            await _recordRelationship(
              schoolId: schoolId,
              studentId: studentId,
              parentCode: code,
              createdBy: createdBy,
            );
            return Right(code);
          });
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
        return updateResult.fold(Left.new, (_) async {
          await _recordRelationship(
            schoolId: schoolId,
            studentId: studentId,
            parentCode: existing.parentCode,
            createdBy: createdBy,
          );
          return Right(existing.parentCode);
        });
      },
    );
  }

  /// Best-effort: a relationship-write failure here must not undo the
  /// access code that was already created/updated above (the parent's
  /// login route is the load-bearing outcome; the relationship record is
  /// additive metadata on top of it).
  Future<void> _recordRelationship({
    required String schoolId,
    required String studentId,
    required String parentCode,
    required String createdBy,
  }) async {
    await createRelationship(CreateRelationshipParams(
      schoolId: schoolId,
      studentId: studentId,
      parentCode: parentCode,
      type: RelationshipType.parent,
      createdBy: createdBy,
    ));
  }
}
