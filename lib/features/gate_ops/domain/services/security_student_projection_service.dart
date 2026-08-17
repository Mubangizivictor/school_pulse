import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/security_student_view.dart';

/// The Security/Gatekeeper-facing projection - identity/photo/class only,
/// gated by `security.identity.verify`. Follows the same
/// permission-then-project shape as `NurseStudentProjectionService` /
/// `BursarStudentProjectionService`; deliberately has no dependency capable
/// of reading academic, financial, medical or discipline records, so there
/// is no field on `SecurityStudentView` those records could ever populate.
class SecurityStudentProjectionService {
  final PermissionEvaluator permissionEvaluator;
  final StudentRepository studentRepository;

  SecurityStudentProjectionService({
    required this.permissionEvaluator,
    required this.studentRepository,
  });

  Future<Either<Failure, SecurityStudentView>> getStudentView({
    required String studentId,
    required String schoolId,
    required UserEntity operatorUser,
  }) async {
    final allowed = await _can(
      Permission.securityIdentityVerify,
      operatorUser,
    );
    if (!allowed) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to verify student identity.',
        ),
      );
    }

    final studentResult = await studentRepository.getStudentById(studentId);
    return studentResult.fold(
      Left.new,
      (student) => Right(
        SecurityStudentView(
          studentId: student.id,
          name: student.name,
          photoUrl: student.photoUrl,
          classId: student.classId,
        ),
      ),
    );
  }

  Future<bool> _can(String permissionId, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((_) => false, (allowed) => allowed);
  }
}
