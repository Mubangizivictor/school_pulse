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
  const PermissionDeniedFailure([super.message = 'You do not have permission to perform this action']);
}
