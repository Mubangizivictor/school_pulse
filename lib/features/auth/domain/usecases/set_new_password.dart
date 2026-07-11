import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

/// Sets a new password for the signed-in user and clears mustChangePassword,
/// completing the first-login flow after an admin-issued temporary password.
class SetNewPassword implements UseCase<void, String> {
  final AuthRepository repository;

  SetNewPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(String newPassword) async {
    return await repository.completePasswordReset(newPassword);
  }
}
