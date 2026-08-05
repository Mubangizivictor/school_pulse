import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication Error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network Error']);
}

/// The operator doesn't hold the permission required for the action -
/// distinct from ServerFailure so a UI can show a specific "not
/// authorized" state instead of a generic error.
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([
    super.message = 'You do not have permission to perform this action',
  ]);
}

/// The staff assignment the action was attempted under is no longer valid -
/// suspended, removed, or past its end date. Separate from
/// PermissionDeniedFailure because the fix is different: the teacher needs to
/// switch responsibility, not request a permission.
class AssignmentInvalidFailure extends Failure {
  const AssignmentInvalidFailure([
    super.message =
        'This assignment is no longer active. Switch to another responsibility.',
  ]);
}

/// Input failed a domain rule - a mark above the maximum, a missing reason on
/// an edit, a student who isn't enrolled. Carries the offending field so a
/// form can highlight it.
class ValidationFailure extends Failure {
  final String? field;
  const ValidationFailure(super.message, {this.field});

  @override
  List<Object> get props => [message, field ?? ''];
}

/// The action needs connectivity and cannot be queued - final approvals,
/// permission changes, anything the server has to decide.
class OfflineNotAllowedFailure extends Failure {
  const OfflineNotAllowedFailure([
    super.message = 'This action needs an internet connection.',
  ]);
}

/// A queued write collided with a newer server version that must not be
/// silently overwritten (approved marks, submitted attendance).
class SyncConflictFailure extends Failure {
  const SyncConflictFailure([
    super.message = 'This record changed on the server while you were offline.',
  ]);
}
