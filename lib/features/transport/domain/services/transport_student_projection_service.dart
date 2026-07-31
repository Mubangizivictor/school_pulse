import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/transport_student_view.dart';
import '../repositories/transport_repository.dart';

class TransportStudentProjectionService {
  final PermissionEvaluator permissionEvaluator;
  final StudentRepository studentRepository;
  final TransportRepository transportRepository;

  TransportStudentProjectionService({
    required this.permissionEvaluator,
    required this.studentRepository,
    required this.transportRepository,
  });

  Future<Either<Failure, TransportStudentView>> getStudentView({
    required String studentId,
    required UserEntity operatorUser,
  }) async {
    final allowed = await _can(Permission.transportBoardingVerify, operatorUser);
    if (!allowed) {
      return const Left(PermissionDeniedFailure('You do not have permission to view transport assignments.'));
    }

    final studentResult = await studentRepository.getStudentById(studentId);
    return studentResult.fold(
      Left.new,
      (student) async {
        final transportResult = await transportRepository.getTransportInfo(studentId);
        return transportResult.fold(
          Left.new,
          (info) => Right(TransportStudentView(
            studentId: student.id,
            name: student.name,
            routeName: info.routeName,
            stopName: info.stopName,
            status: info.status,
          )),
        );
      },
    );
  }

  Future<bool> _can(String permissionId, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((_) => false, (allowed) => allowed);
  }
}
