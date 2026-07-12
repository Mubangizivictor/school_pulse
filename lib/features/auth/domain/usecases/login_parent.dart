import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class LoginParent implements UseCase<UserEntity, LoginParentParams> {
  final AuthRepository repository;

  LoginParent(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParentParams params) async {
    return await repository.loginParent(
      code: params.code,
      phoneNumber: params.phoneNumber,
      pin: params.pin,
    );
  }
}

class LoginParentParams {
  final String code;
  final String phoneNumber;
  final String pin;

  LoginParentParams({
    required this.code,
    required this.phoneNumber,
    required this.pin,
  });
}
