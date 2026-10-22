import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/teacher/domain/entities/student_guardian_contact.dart';

/// Resolves a student's primary guardian contact from the same
/// registration-time link the parent portal itself uses:
/// [ParentStudentRelationship] -> its `parentCode` -> the access code's
/// name/phone.
///
/// This is a sibling of [StudentGuardianContactService]
/// (lib/features/teacher/domain/services/), not a replacement for it - that
/// service is deliberately gated on [Permission.classStudentProfileView] via
/// an [ActiveResponsibilityContext] (a teacher's roll-call/class assignment
/// concept). The Student ID Card preview is opened by any staff member
/// already authorized to manage that student's identity/credentials -
/// forcing a class-teacher-shaped context onto that flow would be an
/// awkward, semantically wrong fit. Callers here are responsible for their
/// own authorization (the ID card screen gates on the same staff check
/// used elsewhere, e.g. AdminStudentProfileScreen._canMutate) before calling
/// this - it performs no permission check of its own.
class PrimaryGuardianLookupService {
  final RelationshipRepository relationshipRepository;
  final StudentRepository studentRepository;

  PrimaryGuardianLookupService({
    required this.relationshipRepository,
    required this.studentRepository,
  });

  Future<Either<Failure, StudentGuardianContact?>> getPrimaryGuardian({
    required String schoolId,
    required String studentId,
  }) async {
    final relationshipsResult = await relationshipRepository
        .getRelationshipsForStudent(schoolId, studentId);

    return relationshipsResult.fold(Left.new, (relationships) async {
      final active = _choosePrimary(relationships);
      if (active == null) return const Right(null);

      final code = active.parentCode;
      if (code == null || code.isEmpty) return const Right(null);

      final accessCodeResult = await studentRepository.resolveAccessCode(code);
      return accessCodeResult.fold(
        (_) => const Right(null),
        (accessCode) => Right(
          StudentGuardianContact(
            name: accessCode.parentName ?? 'Parent/Guardian',
            phoneNumber: accessCode.phoneNumber ?? '',
            relationship: active.type.name,
            userId: active.userId,
          ),
        ),
      );
    });
  }

  ParentStudentRelationship? _choosePrimary(
    List<ParentStudentRelationship> relationships,
  ) {
    final active = relationships.where((r) => r.isActive).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) {
      if (a.isPrimaryGuardian == b.isPrimaryGuardian) return 0;
      return a.isPrimaryGuardian ? -1 : 1;
    });
    return active.first;
  }
}
