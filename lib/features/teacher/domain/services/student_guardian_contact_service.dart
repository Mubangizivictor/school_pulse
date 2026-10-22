import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/student_guardian_contact.dart';
import 'class_teacher_assignment_service.dart';

/// Resolves a student's primary guardian contact from the same
/// registration-time link the parent portal itself uses:
/// [ParentStudentRelationship] -> its `parentCode` -> the access code's
/// name/phone. Gated on [Permission.classStudentProfileView], the same
/// permission that already guards opening the student's profile at all -
/// contact details are part of that profile, not a wider grant.
class StudentGuardianContactService {
  final ClassTeacherAssignmentService assignmentService;
  final RelationshipRepository relationshipRepository;
  final StudentRepository studentRepository;

  StudentGuardianContactService({
    required this.assignmentService,
    required this.relationshipRepository,
    required this.studentRepository,
  });

  Future<Either<Failure, StudentGuardianContact?>> getPrimaryGuardian({
    required ActiveResponsibilityContext context,
    required String studentId,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classStudentProfileView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(
        Left.new,
        (_) => const Left(PermissionDeniedFailure()),
      );
    }

    final relationshipsResult = await relationshipRepository
        .getRelationshipsForStudent(context.schoolId, studentId);

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
