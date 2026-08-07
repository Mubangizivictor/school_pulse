import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  );

  /// Authenticates a parent using their special access code, phone number, and PIN.
  Future<Either<Failure, UserEntity>> loginParent({
    required String code,
    required String phoneNumber,
    required String pin,
  });

  /// Updates the parent's PIN and clears the mustChangePin flag. Requires
  /// the phone number on file so this can be verified server-side before
  /// the parent has a Firebase Auth session of their own.
  Future<Either<Failure, void>> completeParentPinSetup(
    String code,
    String phoneNumber,
    String newPin,
  );

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
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
  });
  Future<Either<Failure, void>> completePasswordReset(String newPassword);
  Future<Either<Failure, List<UserEntity>>> getStaffMembers(String schoolId);
  Future<Either<Failure, void>> toggleStaffActiveStatus(
    String userId,
    bool isActive, {
    String? reason,
  });
  Future<Either<Failure, void>> updateStaffMember(UserEntity user);
  Future<Either<Failure, void>> deleteStaffMember(String userId);

  /// Generates a new temporary password for a staff member via the
  /// `adminResetStaffPassword` Cloud Function, which verifies the caller is
  /// a school administrator for that staff member's school before using the
  /// Admin SDK to reset the Firebase Auth password. Sets `mustChangePassword`
  /// so the staff member is prompted to choose their own on next login.
  Future<Either<Failure, String>> adminResetStaffPassword(String userId);

  /// Reauthenticates the current user with [currentPassword] via
  /// Firebase Auth's email/password provider, then updates their password to
  /// [newPassword]. Used by the Security & Privacy > Change Password screen.
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// Updates the signed-in user's own profile fields (name/phone/photoUrl)
  /// from the Edit Profile screen.
  Future<Either<Failure, void>> updateProfile(UserEntity user);

  /// Flips the signed-in user's own `mfaEnabled` flag, used by the
  /// Two-Factor Auth screen toggle.
  Future<Either<Failure, void>> updateMfaEnabled(bool enabled);
}
