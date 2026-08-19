import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_identity.dart';

abstract class StaffIdentityRepository {
  /// Issues a new identity or returns the existing one for this staff
  /// member - safe to call every time the ID card screen opens.
  Future<Either<Failure, StaffIdentity>> getOrIssueStaffIdentity(
    String staffId,
  );

  /// Issues a new opaque printable QR credential and retires the previous
  /// one without deleting its audit history.
  Future<Either<Failure, StaffIdentity>> regenerateQrCredential(
    StaffIdentity identity,
  );
}
