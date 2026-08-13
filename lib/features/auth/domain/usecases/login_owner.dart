import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class LoginOwnerWithEmail implements UseCase<UserEntity, LoginOwnerParams> {
  final AuthRepository repository;

  LoginOwnerWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginOwnerParams params) async {
    return await repository.loginOwnerWithEmail(params.email, params.password);
  }
}

class LoginOwnerParams extends Equatable {
  final String email;
  final String password;

  const LoginOwnerParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginOwnerWithGoogle implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  LoginOwnerWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.loginOwnerWithGoogle();
  }
}

class LoginOwnerWithApple implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  LoginOwnerWithApple(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.loginOwnerWithApple();
  }
}

/// Re-asserts server-side platform-owner authorization for the current
/// Firebase session without re-authenticating - used whenever a superAdmin
/// profile reaches AuthAuthenticated through a path that skipped the
/// dedicated owner login (an MFA-resolved sign-in, or a restored session on
/// app restart), so the server-side check still gates every such session.
class VerifyOwnerSession implements UseCase<void, NoParams> {
  final AuthRepository repository;

  VerifyOwnerSession(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.verifyOwnerSession();
  }
}
