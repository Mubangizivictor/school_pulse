import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.loginWithEmail(email, password);
      return Right(userModel);
    } on FirebaseAuthMultiFactorException {
      rethrow;
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginParent({
    required String code,
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      final userModel = await remoteDataSource.loginParent(
        code: code,
        phoneNumber: phoneNumber,
        pin: pin,
      );
      return Right(userModel);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeParentPinSetup(
    String code,
    String phoneNumber,
    String newPin,
  ) async {
    try {
      await remoteDataSource.completeParentPinSetup(code, phoneNumber, newPin);
      return const Right(null);
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
    required String schoolId,
    required List<UserRole> roles,
    required String password,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
  }) async {
    try {
      final temporaryPassword = await remoteDataSource.createStaffAccount(
        name: name,
        email: email,
        schoolId: schoolId,
        roles: roles,
        password: password,
        assignedClass: assignedClass,
        subjects: subjects,
        academicYearId: academicYearId,
        departmentId: departmentId,
        designationId: designationId,
        campusId: campusId,
        employmentType: employmentType,
        dateJoined: dateJoined,
      );
      return Right(temporaryPassword);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completePasswordReset(
    String newPassword,
  ) async {
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
  Future<Either<Failure, List<UserEntity>>> getStaffMembers(
    String schoolId,
  ) async {
    try {
      final staff = await remoteDataSource.getStaffMembers(schoolId);
      return Right(staff);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleStaffActiveStatus(
    String userId,
    bool isActive, {
    String? reason,
  }) async {
    try {
      await remoteDataSource.toggleStaffActiveStatus(
        userId,
        isActive,
        reason: reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStaffMember(UserEntity user) async {
    try {
      await remoteDataSource.updateStaffMember(UserModel.fromEntity(user));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStaffMember(String userId) async {
    try {
      await remoteDataSource.deleteStaffMember(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> adminResetStaffPassword(String userId) async {
    try {
      final password = await remoteDataSource.adminResetStaffPassword(userId);
      return Right(password);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserEntity user) async {
    try {
      await remoteDataSource.updateProfile(UserModel.fromEntity(user));
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMfaEnabled(bool enabled) async {
    try {
      await remoteDataSource.updateMfaEnabled(enabled);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
