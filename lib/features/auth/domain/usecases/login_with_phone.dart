import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class LoginWithPhone implements UseCase<String, String> {
  final AuthRepository repository;

  LoginWithPhone(this.repository);

  @override
  Future<Either<Failure, String>> call(String phoneNumber) async {
    return await repository.loginWithPhone(phoneNumber);
  }
}
