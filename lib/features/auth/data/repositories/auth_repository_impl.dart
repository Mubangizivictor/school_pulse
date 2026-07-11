import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password) async {
    try {
      final userModel = await remoteDataSource.loginWithEmail(email, password);
      return Right(userModel);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber) async {
    try {
      final verificationId = await remoteDataSource.loginWithPhone(phoneNumber);
      return Right(verificationId);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String verificationId, String smsCode, {List<String>? linkedStudentIds}) async {
    try {
      final userModel = await remoteDataSource.verifyOtp(verificationId, smsCode, linkedStudentIds: linkedStudentIds);
      return Right(userModel);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createStaffAccount({
    required String name,
    required String email,
    required UserRole role,
    required String password,
  }) async {
    try {
      final temporaryPassword = await remoteDataSource.createStaffAccount(
        name: name,
        email: email,
        role: role,
        password: password,
      );
      return Right(temporaryPassword);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completePasswordReset(String newPassword) async {
    try {
      await remoteDataSource.completePasswordReset(newPassword);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getStaffMembers() async {
    try {
      final staff = await remoteDataSource.getStaffMembers();
      return Right(staff);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleStaffActiveStatus(String userId, bool isActive) async {
    try {
      await remoteDataSource.toggleStaffActiveStatus(userId, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
