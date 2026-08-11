import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class ExitSupportMode implements UseCase<void, ExitSupportModeParams> {
  final AuthRepository repository;

  ExitSupportMode(this.repository);

  @override
  Future<Either<Failure, void>> call(ExitSupportModeParams params) {
    return repository.exitSupportMode(
      ownerId: params.ownerId,
      schoolId: params.schoolId,
    );
  }
}

class ExitSupportModeParams {
  final String ownerId;
  final String? schoolId;

  ExitSupportModeParams({required this.ownerId, this.schoolId});
}
