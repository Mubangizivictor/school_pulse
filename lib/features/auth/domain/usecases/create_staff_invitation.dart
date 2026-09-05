import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

/// Issues (or resends) a verified, time-limited sign-in invitation for an
/// existing staff member via the `createStaffInvitation` Cloud Function.
class CreateStaffInvitation implements UseCase<void, String> {
  final AuthRepository repository;

  CreateStaffInvitation(this.repository);

  @override
  Future<Either<Failure, void>> call(String uid) {
    return repository.createStaffInvitation(uid);
  }
}

/// Cancels a pending staff sign-in invitation via `cancelStaffInvitation`.
class CancelStaffInvitation implements UseCase<void, String> {
  final AuthRepository repository;

  CancelStaffInvitation(this.repository);

  @override
  Future<Either<Failure, void>> call(String uid) {
    return repository.cancelStaffInvitation(uid);
  }
}
