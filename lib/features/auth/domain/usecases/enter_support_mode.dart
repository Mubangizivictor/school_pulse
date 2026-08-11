import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class EnterSupportMode
    implements UseCase<SupportModeSession, EnterSupportModeParams> {
  final AuthRepository repository;

  EnterSupportMode(this.repository);

  @override
  Future<Either<Failure, SupportModeSession>> call(
    EnterSupportModeParams params,
  ) {
    return repository.enterSupportMode(
      schoolId: params.schoolId,
      reason: params.reason,
    );
  }
}

class EnterSupportModeParams {
  final String schoolId;
  final String reason;

  EnterSupportModeParams({required this.schoolId, required this.reason});
}
