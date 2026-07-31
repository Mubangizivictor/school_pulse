import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/library_eligibility_view.dart';
import '../repositories/library_repository.dart';

/// Eligibility is derived here (overdueCount == 0), not read from an
/// existing typed use case - LibraryRepository only exposes an untyped
/// analytics map (totalBorrowed/currentlyBorrowed/overdueCount/history),
/// nothing computes eligible/not-eligible today.
class LibraryEligibilityService {
  final PermissionEvaluator permissionEvaluator;
  final StudentRepository studentRepository;
  final LibraryRepository libraryRepository;

  LibraryEligibilityService({
    required this.permissionEvaluator,
    required this.studentRepository,
    required this.libraryRepository,
  });

  Future<Either<Failure, LibraryEligibilityView>> getEligibility({
    required String studentId,
    required String schoolId,
    required UserEntity operatorUser,
  }) async {
    final allowed = await _can(Permission.libraryMemberVerify, operatorUser);
    if (!allowed) {
      return const Left(PermissionDeniedFailure('You do not have permission to check library eligibility.'));
    }

    final studentResult = await studentRepository.getStudentById(studentId);
    return studentResult.fold(
      Left.new,
      (student) async {
        try {
          final analytics = await libraryRepository.getBorrowerAnalytics(schoolId, studentId);
          final currentlyBorrowed = (analytics['currentlyBorrowed'] as int?) ?? 0;
          final overdueCount = (analytics['overdueCount'] as int?) ?? 0;
          final eligible = overdueCount == 0;

          return Right(LibraryEligibilityView(
            studentId: student.id,
            name: student.name,
            eligible: eligible,
            currentlyBorrowed: currentlyBorrowed,
            overdueCount: overdueCount,
            message: eligible ? 'Eligible to borrow' : 'Has $overdueCount overdue item(s) - return before borrowing',
          ));
        } catch (e) {
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  Future<bool> _can(String permissionId, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((_) => false, (allowed) => allowed);
  }
}
