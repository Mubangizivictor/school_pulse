import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password);
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyOtp(String verificationId, String smsCode, {List<String>? linkedStudentIds});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, String>> createStaffAccount({
    required String name,
    required String email,
    required UserRole role,
    required String password,
  });
  Future<Either<Failure, void>> completePasswordReset(String newPassword);
  Future<Either<Failure, List<UserEntity>>> getStaffMembers();
  Future<Either<Failure, void>> toggleStaffActiveStatus(String userId, bool isActive);
}
