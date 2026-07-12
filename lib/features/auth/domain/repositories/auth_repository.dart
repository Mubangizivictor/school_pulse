import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password);
  
  /// Authenticates a parent using their special access code, phone number, and PIN.
  Future<Either<Failure, UserEntity>> loginParent({
    required String code,
    required String phoneNumber,
    required String pin,
  });

  /// Updates the parent's PIN and clears the mustChangePin flag.
  Future<Either<Failure, void>> completeParentPinSetup(String code, String newPin);

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, String>> createStaffAccount({
    required String name,
    required String email,
    required UserRole role,
    required String password,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
  });
  Future<Either<Failure, void>> completePasswordReset(String newPassword);
  Future<Either<Failure, List<UserEntity>>> getStaffMembers();
  Future<Either<Failure, void>> toggleStaffActiveStatus(String userId, bool isActive);
  Future<Either<Failure, void>> updateStaffMember(UserEntity user);
  Future<Either<Failure, void>> deleteStaffMember(String userId);
}
