import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/bursar_student_view.dart';
import '../repositories/finance_repository.dart';

class BursarStudentProjectionService {
  final PermissionEvaluator permissionEvaluator;
  final StudentRepository studentRepository;
  final FinanceRepository financeRepository;

  BursarStudentProjectionService({
    required this.permissionEvaluator,
    required this.studentRepository,
    required this.financeRepository,
  });

  Future<Either<Failure, BursarStudentView>> getStudentView({
    required String studentId,
    required String schoolId,
    required UserEntity operatorUser,
  }) async {
    final allowed = await _can(
      Permission.financeStudentBalanceRead,
      operatorUser,
    );
    if (!allowed) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to view student financial records.',
        ),
      );
    }

    final studentResult = await studentRepository.getStudentById(studentId);
    return studentResult.fold(Left.new, (student) async {
      final accountResult = await financeRepository.getStudentFinancialAccount(
        studentId,
        schoolId,
      );
      return accountResult.fold(
        Left.new,
        (account) => Right(
          BursarStudentView(
            studentId: student.id,
            name: student.name,
            classId: student.classId,
            totalBilled: account.totalBilled,
            totalPaid: account.totalPaid,
            balance: account.balance,
            isFullyPaid: account.isFullyPaid,
          ),
        ),
      );
    });
  }

  Future<bool> _can(String permissionId, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((_) => false, (allowed) => allowed);
  }
}
