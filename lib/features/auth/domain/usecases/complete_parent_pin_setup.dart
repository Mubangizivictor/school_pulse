import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class CompleteParentPinSetup
    implements UseCase<void, CompleteParentPinSetupParams> {
  final AuthRepository repository;

  CompleteParentPinSetup(this.repository);

  @override
  Future<Either<Failure, void>> call(
    CompleteParentPinSetupParams params,
  ) async {
    return await repository.completeParentPinSetup(
      params.code,
      params.phoneNumber,
      params.newPin,
    );
  }
}

class CompleteParentPinSetupParams {
  final String code;
  final String phoneNumber;
  final String newPin;

  CompleteParentPinSetupParams({
    required this.code,
    required this.phoneNumber,
    required this.newPin,
  });
}
