import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtp implements UseCase<UserEntity, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.verificationId, params.smsCode, linkedStudentIds: params.linkedStudentIds);
  }
}

class VerifyOtpParams extends Equatable {
  final String verificationId;
  final String smsCode;
  final List<String>? linkedStudentIds;

  const VerifyOtpParams({required this.verificationId, required this.smsCode, this.linkedStudentIds});

  @override
  List<Object?> get props => [verificationId, smsCode, linkedStudentIds];
}
