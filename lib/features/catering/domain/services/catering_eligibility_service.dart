import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/catering_eligibility_view.dart';
import '../repositories/catering_repository.dart';

/// verifyStudentMealEligibility's underlying map includes a
/// finance-derived percentagePaid figure - this service deliberately
/// never reads that key into CateringEligibilityView, per the spec's
/// "never reveal balances" requirement for this role.
class CateringEligibilityService {
  final PermissionEvaluator permissionEvaluator;
  final StudentRepository studentRepository;
  final CateringRepository cateringRepository;

  CateringEligibilityService({
    required this.permissionEvaluator,
    required this.studentRepository,
    required this.cateringRepository,
  });

  Future<Either<Failure, CateringEligibilityView>> getEligibility({
    required String studentId,
    required UserEntity operatorUser,
  }) async {
    final allowed = await _can(Permission.mealsVerify, operatorUser);
    if (!allowed) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to verify meal eligibility.',
        ),
      );
    }

    final studentResult = await studentRepository.getStudentById(studentId);
    return studentResult.fold(Left.new, (student) async {
      final eligibilityResult = await cateringRepository
          .verifyStudentMealEligibility(studentId);
      return eligibilityResult.fold(Left.new, (data) {
        final status = data['eligibilityStatus'] as String? ?? 'Not Cleared';
        final eligible = status == 'Cleared';
        return Right(
          CateringEligibilityView(
            studentId: student.id,
            name: student.name,
            classId: student.classId,
            photoUrl: student.photoUrl,
            eligible: eligible,
            message: eligible
                ? 'Meal authorized'
                : 'Meal not authorized. Please contact the bursar.',
            dietaryRestrictions: student.medicalInfo?.allergies ?? const [],
          ),
        );
      });
    });
  }

  Future<bool> _can(String permissionId, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((_) => false, (allowed) => allowed);
  }
}
